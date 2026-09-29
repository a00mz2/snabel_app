// ignore_for_file: depend_on_referenced_packages, avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/class/client_capabilities.dart';
import 'package:customer/core/functions/checkInternetConnection.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter/foundation.dart';
import 'package:customer/core/services/support_chat_service.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

/// نتيجة محاولة تجديد التوكن.
///
/// الفصل بين [authRejected] و[transient] هو ما يمنع تسجيل الخروج العرضي:
/// الأول وحده يعني أن الخادم رفض توكن التحديث نهائياً.
enum RefreshOutcome {
  /// توكن جديد محفوظ — أعد الطلب
  success,

  /// 401/403 من مسار التجديد، أو لا توكن محفوظ ⇒ الجلسة انتهت فعلاً
  authRejected,

  /// شبكة، مهلة، 5xx، جسم مشوّه ⇒ أبقِ الجلسة وأعد المحاولة لاحقاً
  transient,
}

class Crud {
  Future<RefreshOutcome>? _refreshInFlight;

  /// يمنع تكرار مسح الجلسة و [Get.offAllNamed] عند فشل التحديث لعدة طلبات 401 في نفس الوقت.
  bool _logoutNavigationDone = false;

  /// استدعاؤها بعد تسجيل دخول ناجح ليعمل الحارس من جديد في الجلسة التالية.
  void resetLogoutNavigationGuard() {
    _logoutNavigationDone = false;
  }

  Map<String, String> _buildHeaders({bool isPublicRoutes = false}) {
    final token = myServices.sharedPreferences.getString('Token');
    final headers = {
      'Content-Type': 'application/json',
      ...clientCapabilityHeaders,
    };

    // لا نرسل Authorization إلا عند وجود توكن فعلي وليس مساراً عاماً
    if (!isPublicRoutes && token != null && token.isNotEmpty) {
      headers['Authorization'] = "Bearer $token";
    }

    return headers;
  }

  bool _isAccountStateError(int statusCode, Map<String, dynamic> decoded) {
    if (statusCode == 402) return true; // الحساب غير موافق عليه
    if (statusCode != 403) return false;

    final message = (decoded["message"] ?? "").toString().toLowerCase();
    final error = (decoded["error"] ?? "").toString().toLowerCase();
    final merged = "$message $error";

    const accountKeywords = [
      "معطل",
      "غير مفعل",
      "لم تتم الموافقة",
      "لم يتم الموافقة",
      "بانتظار",
      "inactive",
      "disabled",
      "not approved",
      "unapproved",
      "pending",
    ];

    final hasKeyword = accountKeywords.any((k) => merged.contains(k));
    final hasStatusFlag =
        decoded["isActive"] == false ||
        decoded["isApproved"] == false ||
        decoded["accountStatus"] == "inactive" ||
        decoded["accountStatus"] == "pending" ||
        decoded["accountStatus"] == "pending_approval";

    return hasKeyword || hasStatusFlag;
  }

  void _endSession({
    required String reason,
    int? statusCode,
    String? url,
    Map<String, dynamic>? responseBody,
  }) {
    if (_logoutNavigationDone) {
      print("🚪 [SESSION_LOGOUT] skipped duplicate (already ended)");
      return;
    }
    _logoutNavigationDone = true;

    print("🚪 [SESSION_LOGOUT] reason=$reason");
    if (statusCode != null) print("🚪 [SESSION_LOGOUT] statusCode=$statusCode");
    if (url != null) print("🚪 [SESSION_LOGOUT] url=$url");
    if (responseBody != null) {
      print("🚪 [SESSION_LOGOUT] responseBody=$responseBody");
    }

    // قبل مسح التوكن: وإلا حاولت الخدمة تجديد توكن محذوف
    if (Get.isRegistered<SupportChatService>()) {
      Get.find<SupportChatService>().stop();
    }

    myServices.sharedPreferences.remove("id");
    myServices.sharedPreferences.remove("USERNAME");
    myServices.sharedPreferences.remove("PASSWORD");
    myServices.sharedPreferences.remove("Token");
    myServices.sharedPreferences.remove("refreshToken");
    myServices.sharedPreferences.setString("router", "/");
    AppSnackBar.error("انتهت صلاحية الجلسة أو التوكن غير صالح");
    Get.offAllNamed("/");
  }

  /// تجديد مُوحَّد بطلب واحد مهما تزامنت النداءات.
  ///
  /// ⚠️ **عام عمداً**: خدمة الدردشة كانت تستدعي [refreshToken] مباشرةً خارج هذا القفل،
  /// فيلتقي تجديدان يحملان توكن التحديث نفسه عند العودة من الخلفية بعد ١٥ دقيقة،
  /// ويخسر أحدهما السباق. كل من يحتاج توكناً طازجاً يمرّ من هنا.
  Future<RefreshOutcome> refreshWithLock() async {
    final inFlight = _refreshInFlight;
    if (inFlight != null) {
      print("🔁 [REFRESH_TOKEN] waiting for in-flight refresh...");
      return inFlight;
    }

    print("🔁 [REFRESH_TOKEN] starting refresh request...");
    final future = _performRefresh();
    _refreshInFlight = future;
    try {
      final result = await future;
      print("🔁 [REFRESH_TOKEN] completed result=$result");
      return result;
    } finally {
      _refreshInFlight = null;
    }
  }

  Future<Either<StatusRequest, Map>> postData(
    String linkurl,
    Map<String, dynamic> data, {
    bool isRetry = false,
    isPublicRoutes = false,
  }) async {
    if (await checkInternetConnection()) {
      try {
        final headers = _buildHeaders(isPublicRoutes: isPublicRoutes);

        var request = http.Request('POST', Uri.parse(linkurl));
        request.body = json.encode(data);
        request.headers.addAll(headers);

        http.StreamedResponse streamedResponse = await request.send();

        String responseBody = await streamedResponse.stream.bytesToString();
        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(responseBody);
        } catch (_) {
          decoded = {"raw": responseBody};
        }

        if (_isAccountStateError(streamedResponse.statusCode, decoded)) {
          print(
            "ℹ️ [SESSION_KEEP] account status response (${streamedResponse.statusCode}) on POST $linkurl",
          );
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.failure,
            "statusCode": streamedResponse.statusCode,
          });
        }

        if (streamedResponse.statusCode == 401 &&
            !isRetry &&
            !isPublicRoutes) {
          final outcome = await refreshWithLock();
          if (outcome == RefreshOutcome.success) {
            return await postData(linkurl, data, isRetry: true);
          }
          // رفض نهائي من الخادم وحده يُنهي الجلسة. الفشل العابر (شبكة، مهلة،
          // 5xx، إعادة تشغيل الخادم) يُبقيها ويترك الطلب يفشل كردٍّ عادي —
          // إنهاؤها هنا كان يطرد المستخدم لانقطاع لحظي بعد ١٥ دقيقة خمول.
          if (outcome == RefreshOutcome.authRejected) {
            _endSession(
              reason: "refresh_failed_after_401_post",
              statusCode: streamedResponse.statusCode,
              url: linkurl,
              responseBody: decoded,
            );
          }
          return Right({...decoded, "statusRequest": StatusRequest.failure});
        }

        if (streamedResponse.statusCode == 200 ||
            streamedResponse.statusCode == 201) {
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.success,
            "statusCode": streamedResponse.statusCode,
          });
        } else if (streamedResponse.statusCode == 400) {
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.failure,
            "statusCode": streamedResponse.statusCode,
          });
        } else {
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.serverFailure,
            "statusCode": streamedResponse.statusCode,
          });
        }
      } catch (e) {
        return const Left(StatusRequest.failure);
      }
    } else {
      return const Left(StatusRequest.offlineFailure);
    }
  }

  Future<Either<StatusRequest, Map>> getData(
    String linkurl, {
    bool isRetry = false,
    isPublicRoutes = false,
  }) async {
    if (await checkInternetConnection()) {
      try {
        final headers = _buildHeaders(isPublicRoutes: isPublicRoutes);

        var request = http.Request('GET', Uri.parse(linkurl));
        request.headers.addAll(headers);

        http.StreamedResponse streamedResponse = await request.send();

        String responseBody = await streamedResponse.stream.bytesToString();
        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(responseBody);
        } catch (_) {
          decoded = {"raw": responseBody};
        }

        if (_isAccountStateError(streamedResponse.statusCode, decoded)) {
          print(
            "ℹ️ [SESSION_KEEP] account status response (${streamedResponse.statusCode}) on GET $linkurl",
          );
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.failure,
            "statusCode": streamedResponse.statusCode,
          });
        }

        if (streamedResponse.statusCode == 401 &&
            !isRetry &&
            !isPublicRoutes) {
          final outcome = await refreshWithLock();
          if (outcome == RefreshOutcome.success) {
            return await getData(linkurl, isRetry: true);
          }
          // رفض نهائي من الخادم وحده يُنهي الجلسة. الفشل العابر (شبكة، مهلة،
          // 5xx، إعادة تشغيل الخادم) يُبقيها ويترك الطلب يفشل كردٍّ عادي —
          // إنهاؤها هنا كان يطرد المستخدم لانقطاع لحظي بعد ١٥ دقيقة خمول.
          if (outcome == RefreshOutcome.authRejected) {
            _endSession(
              reason: "refresh_failed_after_401_get",
              statusCode: streamedResponse.statusCode,
              url: linkurl,
              responseBody: decoded,
            );
          }
          return Right({...decoded, "statusRequest": StatusRequest.failure});
        }

        if (streamedResponse.statusCode == 200 ||
            streamedResponse.statusCode == 201) {
          return Right(decoded);
        } else if (streamedResponse.statusCode == 400) {
          return Right({...decoded, "statusRequest": StatusRequest.failure});
        } else {
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.serverFailure,
            "statusCode": streamedResponse.statusCode,
          });
        }
      } catch (e) {
        return const Left(StatusRequest.failure);
      }
    } else {
      return const Left(StatusRequest.offlineFailure);
    }
  }

  //داله ارسال الملفات
  Future<Either<StatusRequest, Map>> postDataWithFile(
    String linkUrl,
    Map<String, String> fields,
    List fileBytes,
    String fileFieldName, {
    bool isRetry = false,
    bool isPublicRoutes = false,
  }) async {
    if (!await checkInternetConnection()) {
      return const Left(StatusRequest.offlineFailure);
    }
    try {
      final token = myServices.sharedPreferences.getString('Token');
      final headers = <String, String>{...clientCapabilityHeaders};
      if (!isPublicRoutes && token != null && token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      }

      var request = http.MultipartRequest('POST', Uri.parse(linkUrl));

      request.fields.addAll(fields);

      // ⚠️ `is` لا `runtimeType ==`: `Uint8List` صنف مجرّد لا يوجد كائن نوعه الفعلي هو هو.
      // الأصناف الحقيقية `_Uint8List` و`_Uint8ArrayView` (VM) و`NativeUint8List` (الويب)،
      // ولا تتجاوز `runtimeType`. فالمقارنة بالتساوي كانت false دائماً على كل المنصّات
      // وتُسقط الملف بصمت فيصل الخادمَ طلبٌ بلا أي جزء ملف.
      for (var element in fileBytes) {
        if (element is Uint8List) {
          request.files.add(
            http.MultipartFile.fromBytes(
              fileFieldName,
              element,
              filename: "uploaded_image.png",
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }
      }
      request.headers.addAll(headers);

      http.StreamedResponse streamedResponse = await request.send();

      String responseBody = await streamedResponse.stream.bytesToString();
      Map<String, dynamic> decoded;
      try {
        decoded = jsonDecode(responseBody);
      } catch (_) {
        decoded = {"raw": responseBody};
      }
      print(streamedResponse.statusCode);

      if (_isAccountStateError(streamedResponse.statusCode, decoded)) {
        return Right({
          ...decoded,
          "statusRequest": StatusRequest.failure,
          "statusCode": streamedResponse.statusCode,
        });
      }

      if (streamedResponse.statusCode == 401 &&
          !isRetry &&
          !isPublicRoutes) {
        final outcome = await refreshWithLock();
        if (outcome == RefreshOutcome.success) {
          return await postDataWithFile(
            linkUrl,
            fields,
            fileBytes,
            fileFieldName,
            isRetry: true,
          );
        }
        // رفض نهائي من الخادم وحده يُنهي الجلسة. الفشل العابر (شبكة، مهلة،
        // 5xx، إعادة تشغيل الخادم) يُبقيها ويترك الطلب يفشل كردٍّ عادي —
        // إنهاؤها هنا كان يطرد المستخدم لانقطاع لحظي بعد ١٥ دقيقة خمول.
        if (outcome == RefreshOutcome.authRejected) {
          _endSession(
            reason: "refresh_failed_after_401_file_post",
            statusCode: streamedResponse.statusCode,
            url: linkUrl,
            responseBody: decoded,
          );
        }
        return Right({...decoded, "statusRequest": StatusRequest.failure});
      }

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        return Right(decoded);
      } else if (streamedResponse.statusCode == 400) {
        return Right({...decoded, "statusRequest": StatusRequest.failure});
      } else {
        return Right({
          ...decoded,
          "statusRequest": StatusRequest.serverFailure,
          "statusCode": streamedResponse.statusCode,
        });
      }
    } catch (e) {
      return const Left(StatusRequest.failure);
    }
  }

  // دالة ارسال مجموعة صور
  Future<Either<StatusRequest, Map>> postDataWithFiles(
    String linkUrl,
    Map<String, dynamic> fields,
    Map<String, Uint8List> files, {
    bool isRetry = false,
    bool isPublicRoutes = false,
  }) async {
    if (await checkInternetConnection()) {
      try {
        final token = myServices.sharedPreferences.getString('Token');
        final headers = <String, String>{...clientCapabilityHeaders};
        if (!isPublicRoutes && token != null && token.isNotEmpty) {
          headers['Authorization'] = "Bearer $token";
        }

        var request = http.MultipartRequest('POST', Uri.parse(linkUrl));

        // إضافة الحقول النصية
        fields.forEach((key, value) {
          if (value == null) return;
          request.fields[key] = value is String ? value : jsonEncode(value);
        });

        // إضافة الملفات
        for (var entry in files.entries) {
          request.files.add(
            http.MultipartFile.fromBytes(
              entry.key,
              entry.value,
              filename:
                  "${entry.key}_${DateTime.now().millisecondsSinceEpoch}.jpg",
              contentType: MediaType('image', 'jpeg'),
            ),
          );
        }

        request.headers.addAll(headers);

        http.StreamedResponse streamedResponse = await request.send();
        String responseBody = await streamedResponse.stream.bytesToString();

        Map<String, dynamic> decoded;
        try {
          decoded = jsonDecode(responseBody);
        } catch (_) {
          decoded = {"raw": responseBody};
        }

        if (_isAccountStateError(streamedResponse.statusCode, decoded)) {
          print(
            "ℹ️ [SESSION_KEEP] account status response (${streamedResponse.statusCode}) on MULTIPART POST $linkUrl",
          );
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.failure,
            "statusCode": streamedResponse.statusCode,
          });
        }

        // 🧩 التعامل مع انتهاء صلاحية التوكن (401)
        if (streamedResponse.statusCode == 401 &&
            !isRetry &&
            !isPublicRoutes) {
          final outcome = await refreshWithLock();
          if (outcome == RefreshOutcome.success) {
            // إعادة الطلب بعد تحديث التوكن
            return await postDataWithFiles(
              linkUrl,
              fields,
              files,
              isRetry: true,
            );
          }
          // رفض نهائي من الخادم وحده يُنهي الجلسة. الفشل العابر (شبكة، مهلة،
          // 5xx، إعادة تشغيل الخادم) يُبقيها ويترك الطلب يفشل كردٍّ عادي —
          // إنهاؤها هنا كان يطرد المستخدم لانقطاع لحظي بعد ١٥ دقيقة خمول.
          if (outcome == RefreshOutcome.authRejected) {
            _endSession(
              reason: "refresh_failed_after_401_multipart_post",
              statusCode: streamedResponse.statusCode,
              url: linkUrl,
              responseBody: decoded,
            );
          }
          return Right({...decoded, "statusRequest": StatusRequest.failure});
        }

        // 🟢 الحالات العادية
        if (streamedResponse.statusCode == 200 ||
            streamedResponse.statusCode == 201) {
          return Right(decoded);
        } else if (streamedResponse.statusCode == 400) {
          return Right({...decoded, "statusRequest": StatusRequest.failure});
        } else {
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.serverFailure,
            "statusCode": streamedResponse.statusCode,
          });
        }
      } catch (e) {
        return const Left(StatusRequest.failure);
      }
    } else {
      return const Left(StatusRequest.offlineFailure);
    }
  }

  /// ⚠️ مُبقاة للتوافق مع المستدعين القدامى — تمرّ عبر القفل الآن لا حوله.
  Future<bool> refreshToken() async =>
      (await refreshWithLock()) == RefreshOutcome.success;

  /// ينفّذ طلب التجديد ويُصنّف نتيجته.
  ///
  /// التصنيف هو بيت القصيد: الإصدار السابق كان يُعيد `false` لكل شيء — مهلة، انقطاع
  /// شبكة، 500، جسم غير JSON — والمستدعي يفسّر `false` كرفض مصادقة فيُنهي الجلسة.
  /// أي انقطاع لحظي يصادف انتهاء توكن الوصول كان يُخرج المستخدم.
  Future<RefreshOutcome> _performRefresh() async {
    final currentRefreshToken = myServices.sharedPreferences.getString(
      'refreshToken',
    );
    if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
      print("❌ [REFRESH_TOKEN] missing refreshToken in local storage");
      return RefreshOutcome.authRejected; // لا توكن أصلاً ⇒ لا جلسة
    }

    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(Applink.CustomersRefreshToken),
            headers: {
              "Content-Type": "application/json",
              ...clientCapabilityHeaders,
            },
            body: json.encode({"refreshToken": currentRefreshToken}),
          )
          // بدون مهلة يبقى كل طلب 401 معلّقاً خلف القفل حتى يستسلم النظام
          .timeout(const Duration(seconds: 20));
    } catch (e) {
      print("❌ [REFRESH_TOKEN] transient exception=$e");
      return RefreshOutcome.transient;
    }

    // 401/403 وحدهما نهائيان: الخادم يقول إن توكن التحديث ملغى أو فاسد
    if (response.statusCode == 401 || response.statusCode == 403) {
      print("❌ [REFRESH_TOKEN] rejected status=${response.statusCode}");
      return RefreshOutcome.authRejected;
    }
    if (response.statusCode != 200) {
      print("⚠️ [REFRESH_TOKEN] transient status=${response.statusCode}");
      return RefreshOutcome.transient;
    }

    try {
      final decodedRaw = jsonDecode(response.body);
      if (decodedRaw is! Map) return RefreshOutcome.transient;
      final decoded = Map<String, dynamic>.from(decodedRaw);
      final newToken = decoded["accessToken"];
      final newRefreshToken = decoded["refreshToken"];
      if (newToken is! String || newToken.isEmpty) {
        return RefreshOutcome.transient;
      }
      await myServices.sharedPreferences.setString("Token", newToken);
      if (newRefreshToken is String && newRefreshToken.isNotEmpty) {
        await myServices.sharedPreferences.setString(
          "refreshToken",
          newRefreshToken,
        );
      }
      print("✅ [REFRESH_TOKEN] success and tokens updated");
      return RefreshOutcome.success;
    } catch (e) {
      // جسم مشوّه ليس دليلاً على إلغاء التوكن
      print("⚠️ [REFRESH_TOKEN] malformed body=$e");
      return RefreshOutcome.transient;
    }
  }

}

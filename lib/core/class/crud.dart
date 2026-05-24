// ignore_for_file: depend_on_referenced_packages, avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/checkInternetConnection.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:dartz/dartz.dart';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Crud {
  Future<bool>? _refreshInFlight;

  /// يمنع تكرار مسح الجلسة و [Get.offAllNamed] عند فشل التحديث لعدة طلبات 401 في نفس الوقت.
  bool _logoutNavigationDone = false;

  /// استدعاؤها بعد تسجيل دخول ناجح ليعمل الحارس من جديد في الجلسة التالية.
  void resetLogoutNavigationGuard() {
    _logoutNavigationDone = false;
  }

  Map<String, String> _buildHeaders({bool isPublicRoutes = false}) {
    final token = myServices.sharedPreferences.getString('Token');
    final headers = {'Content-Type': 'application/json'};

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

    myServices.sharedPreferences.remove("id");
    myServices.sharedPreferences.remove("USERNAME");
    myServices.sharedPreferences.remove("PASSWORD");
    myServices.sharedPreferences.remove("Token");
    myServices.sharedPreferences.remove("refreshToken");
    myServices.sharedPreferences.setString("router", "/");
    AppSnackBar.error("انتهت صلاحية الجلسة أو التوكن غير صالح");
    Get.offAllNamed("/");
  }

  Future<bool> _refreshTokenWithLock() async {
    if (_refreshInFlight != null) {
      print("🔁 [REFRESH_TOKEN] waiting for in-flight refresh...");
      return _refreshInFlight!;
    }

    print("🔁 [REFRESH_TOKEN] starting refresh request...");
    _refreshInFlight = refreshToken();
    try {
      final result = await _refreshInFlight!;
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
          if (await _refreshTokenWithLock()) {
            return await postData(linkurl, data, isRetry: true);
          } else {
            _endSession(
              reason: "refresh_failed_after_401_post",
              statusCode: streamedResponse.statusCode,
              url: linkurl,
              responseBody: decoded,
            );
            return Right({...decoded, "statusRequest": StatusRequest.failure});
          }
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
          if (await _refreshTokenWithLock()) {
            return await getData(linkurl, isRetry: true);
          } else {
            _endSession(
              reason: "refresh_failed_after_401_get",
              statusCode: streamedResponse.statusCode,
              url: linkurl,
              responseBody: decoded,
            );
            return Right({...decoded, "statusRequest": StatusRequest.failure});
          }
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
      final headers = <String, String>{};
      if (!isPublicRoutes && token != null && token.isNotEmpty) {
        headers['Authorization'] = "Bearer $token";
      }

      var request = http.MultipartRequest('POST', Uri.parse(linkUrl));

      request.fields.addAll(fields);

      for (var element in fileBytes) {
        if (element.runtimeType == Uint8List) {
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
        if (await _refreshTokenWithLock()) {
          return await postDataWithFile(
            linkUrl,
            fields,
            fileBytes,
            fileFieldName,
            isRetry: true,
          );
        } else {
          _endSession(
            reason: "refresh_failed_after_401_file_post",
            statusCode: streamedResponse.statusCode,
            url: linkUrl,
            responseBody: decoded,
          );
          return Right({...decoded, "statusRequest": StatusRequest.failure});
        }
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
        final headers = <String, String>{};
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
          if (await _refreshTokenWithLock()) {
            // إعادة الطلب بعد تحديث التوكن
            return await postDataWithFiles(
              linkUrl,
              fields,
              files,
              isRetry: true,
            );
          } else {
            _endSession(
              reason: "refresh_failed_after_401_multipart_post",
              statusCode: streamedResponse.statusCode,
              url: linkUrl,
              responseBody: decoded,
            );
            return Right({...decoded, "statusRequest": StatusRequest.failure});
          }
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

  Future<bool> refreshToken() async {
    try {
      final currentRefreshToken = myServices.sharedPreferences.getString(
        'refreshToken',
      );
      if (currentRefreshToken == null || currentRefreshToken.isEmpty) {
        print("❌ [REFRESH_TOKEN] missing refreshToken in local storage");
        return false;
      }

      var response = await http.post(
        Uri.parse(Applink.CustomersRefreshToken),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"refreshToken": currentRefreshToken}),
      );

      if (response.statusCode == 200) {
        final decodedRaw = jsonDecode(response.body);
        if (decodedRaw is! Map) {
          print("❌ [REFRESH_TOKEN] body is not a JSON object");
          return false;
        }
        final decoded = Map<String, dynamic>.from(decodedRaw);
        final newToken = decoded["accessToken"];
        final newRefreshToken = decoded["refreshToken"];
        if (newToken is! String ||
            newRefreshToken is! String ||
            newToken.isEmpty ||
            newRefreshToken.isEmpty) {
          print("❌ [REFRESH_TOKEN] missing accessToken or refreshToken");
          return false;
        }

        await myServices.sharedPreferences.setString("Token", newToken);
        await myServices.sharedPreferences.setString(
          "refreshToken",
          newRefreshToken,
        );
        print("✅ [REFRESH_TOKEN] success and tokens updated");
        return true;
      } else {
        print(
          "❌ [REFRESH_TOKEN] failed status=${response.statusCode} body=${response.body}",
        );
        return false;
      }
    } catch (e) {
      print("❌ [REFRESH_TOKEN] exception=$e");
      return false;
    }
  }
}

// ignore_for_file: depend_on_referenced_packages, avoid_print, deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:customer/core/services/support_chat_service.dart';
import 'package:customer/core/class/client_capabilities.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/linkApi.dart';
import 'package:customer/driver/core/functions/checkInternetConnection.dart';
import 'package:customer/driver/core/services/services.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

class DriverCrud {
  final _baseHeaders = {
    'Content-Type': 'application/json',
    ...clientCapabilityHeaders,
  };

  Future<Either<StatusRequest, Map>> request({
    required String method,
    required String url,
    dynamic data, // ✅ بدل Map
    Map<String, Uint8List>? files,
    bool isPublic = false,
    bool isRetry = false,
    String methodMultipart = "POST",
  }) async {
    if (!await checkInternetConnection()) {
      return const Left(StatusRequest.offlineFailure);
    }

    try {
      final token = myServices.sharedPreferences.getString('Token');

      final headers = {
        ..._baseHeaders,
        if (!isPublic && token != null) 'Authorization': 'Bearer $token',
      };

      http.StreamedResponse response;

      // 🔍 اختيار نوع الطلب
      if (method.toUpperCase() == 'MULTIPART') {
        response = await _sendMultipart(
          url,
          headers,
          data ?? {},
          files ?? {},
          methodMultipart,
        );
      } else {
        response = await _sendStandard(url, headers, data, method);
      }

      // 📦 قراءة الرد
      String body = await response.stream.bytesToString();
      Map<String, dynamic> decoded;

      try {
        decoded = jsonDecode(body);
      } catch (_) {
        decoded = {"raw": body};
      }

      if ((response.statusCode == 401 || response.statusCode == 403) &&
          !isRetry &&
          !isPublic) {
        final result = await _refreshTokenWithLock();
        if (result == _RefreshResult.success) {
          return await request(
            method: method,
            url: url,
            data: data,
            files: files,
            isRetry: true,
            isPublic: isPublic,
            methodMultipart: methodMultipart,
          );
        } else if (result == _RefreshResult.authRejected) {
          // رفض نهائي (refresh token ملغى/منتهٍ) → إنهاء الجلسة فعلاً.
          _endSession();
          return Right({...decoded, "statusRequest": StatusRequest.failure});
        } else {
          // فشل عابر (شبكة/مهلة/خطأ خادم 5xx) → لا نُسجّل خروجاً ونُبقي الجلسة.
          return Right({
            ...decoded,
            "statusRequest": StatusRequest.failure,
            "transient": true,
          });
        }
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return Right({
          ...decoded,
          "statusRequest": StatusRequest.success,
          "statusCode": response.statusCode,
        });
      }

      return Right({
        ...decoded,
        "statusRequest": StatusRequest.failure,
        "statusCode": response.statusCode,
      });
    } catch (e) {
      if (kDebugMode) print("❌ CRUD Error: $e");
      return const Left(StatusRequest.failure);
    }
  }

  Future<http.StreamedResponse> _sendStandard(
    String url,
    Map<String, String> headers,
    dynamic data, // ✅
    String method,
  ) async {
    var request = http.Request(method.toUpperCase(), Uri.parse(url));

    if (data != null) {
      request.body = jsonEncode(data);
    }

    request.headers.addAll(headers);
    return await request.send().timeout(const Duration(seconds: 30));
  }

  Future<http.StreamedResponse> _sendMultipart(
    String url,
    Map<String, String> headers,
    Map<String, dynamic> fields,
    Map<String, Uint8List> files,
    String methodMultipart,
  ) async {
    var request = http.MultipartRequest(methodMultipart, Uri.parse(url));

    // الحقول
    fields.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    // الملفات (قد تكون فارغة)
    for (var entry in files.entries) {
      final compressed = await _compressImage(entry.value);
      request.files.add(
        http.MultipartFile.fromBytes(
          entry.key,
          compressed,
          filename: "${entry.key}_${DateTime.now().millisecondsSinceEpoch}.jpg",
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    }

    // لا تمرّر Content-Type: application/json — MultipartRequest يضبط boundary تلقائياً
    final headersSafe = Map<String, String>.from(headers)
      ..removeWhere((k, _) => k.toLowerCase() == 'content-type');
    request.headers.addAll(headersSafe);
    return await request.send().timeout(const Duration(seconds: 60));
  }

  Future<Uint8List> _compressImage(Uint8List data) async {
    try {
      final decoded = img.decodeImage(data);
      if (decoded == null) return data;
      return Uint8List.fromList(img.encodeJpg(decoded, quality: 85));
    } catch (_) {
      return data;
    }
  }

  /// قفل تجديد مشترك: عند وصول عدّة طلبات لـ 401 في آنٍ واحد (شائع عند فتح
  /// الشاشة الرئيسية) نُجري تجديداً واحداً فقط ويشترك الجميع بنتيجته. بدون هذا،
  /// كل طلب يُجدّد بالتوكن القديم، وبما أن الخادم يُدوّر التوكن (يحذف القديم)،
  /// تفشل التجديدات المتزامنة الأخرى → تسجيل خروج خاطئ.
  static Future<_RefreshResult>? _refreshInFlight;

  Future<_RefreshResult> _refreshTokenWithLock() {
    final existing = _refreshInFlight;
    if (existing != null) return existing;
    final future = _refreshToken().whenComplete(() {
      _refreshInFlight = null;
    });
    _refreshInFlight = future;
    return future;
  }

  /// يُميّز بين رفض المصادقة النهائي (توكن ملغى/منتهٍ → خروج) والفشل العابر
  /// (شبكة/مهلة/خطأ خادم → نُبقي الجلسة).
  Future<_RefreshResult> _refreshToken() async {
    final refreshToken = myServices.sharedPreferences.getString("refreshToken");
    if (refreshToken == null || refreshToken.isEmpty) {
      return _RefreshResult.authRejected;
    }
    try {
      final res = await http
          .post(
            Uri.parse(DriverApplink.driverRefreshToken),
            headers: {
              "Content-Type": "application/json",
              ...clientCapabilityHeaders,
            },
            body: jsonEncode({"refreshToken": refreshToken}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final decoded = jsonDecode(res.body) as Map<String, dynamic>;
        final access = decoded["accessToken"];
        if (access is! String || access.isEmpty) {
          return _RefreshResult.authRejected;
        }
        await myServices.sharedPreferences.setString("Token", access);

        final nextRefresh = decoded["refreshToken"];
        if (nextRefresh is String && nextRefresh.isNotEmpty) {
          await myServices.sharedPreferences.setString(
            "refreshToken",
            nextRefresh,
          );
        }
        return _RefreshResult.success;
      }

      // رفض نهائي: التوكن ملغى/منتهٍ/غير صالح.
      if (res.statusCode == 401 || res.statusCode == 403) {
        return _RefreshResult.authRejected;
      }
      // 5xx أو غيره → عابر (لا نُنهي الجلسة).
      return _RefreshResult.transient;
    } on TimeoutException {
      return _RefreshResult.transient;
    } catch (_) {
      // خطأ شبكة/تحليل → عابر.
      return _RefreshResult.transient;
    }
  }

  /// تجديد توكن السائق عند الطلب، بنفس القفل المشترك أعلاه فلا يتسابق تجديدان.
  ///
  /// موجودة من أجل سوكِت «تواصل مع الدعم»: فهو يحتاج توكناً طازجاً عند كل مصافحة
  /// وإعادة اتصال، ولا يمرّ بـ`request()` فلا يبلغ مسار 401 الذي يُجدّد تلقائياً.
  /// بدونها كان سيستدعي تجديد **الزبون** فيُخرج السائق من جلسته.
  Future<bool> ensureFreshToken() async {
    final result = await _refreshTokenWithLock();
    return result == _RefreshResult.success;
  }

  /// حارس تسجيل خروج مفرد — يمنع تكرار clear()/offAllNamed عند تزامن عدّة طلبات.
  static bool _sessionEnded = false;

  /// يُستدعى بعد نجاح الدخول لإعادة تفعيل الحارس لجلسة جديدة.
  static void resetSessionGuard() => _sessionEnded = false;

  void _endSession() {
    if (_sessionEnded) return;
    _sessionEnded = true;
    // قبل مسح التفضيلات: وإلا بقيت خدمة الدردشة تُصافح بتوكن فارغ كل ١٥ ثانية
    // وتحمل هوية السائق السابق إلى جلسة الجهاز التالية
    if (Get.isRegistered<SupportChatService>()) {
      Get.find<SupportChatService>().stop();
    }
    myServices.sharedPreferences.clear();
    myServices.sharedPreferences.setString("router", "/");
    Get.offAllNamed("/");
  }
}

/// نتيجة محاولة تجديد التوكن.
enum _RefreshResult { success, authRejected, transient }

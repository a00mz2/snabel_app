// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:customer/linkApi.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/view/screen/ForceUpdateScreen.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _checkVersionAndNavigate();
  }

  Future<void> _checkVersionAndNavigate() async {
    // ─── انتظر ثانية واحدة لعرض شاشة البداية ────────────────────────────
    await Future.delayed(const Duration(seconds: 1));

    // ─── اقرأ رقم الإصدار الحالي من pubspec.yaml عبر package_info_plus ──
    String appVersion = '0.0.0';
    try {
      final info = await PackageInfo.fromPlatform();
      appVersion = info.version; // مثل "1.0.1"
      print("📦 [VERSION_CHECK] appVersion=$appVersion");
    } catch (e) {
      print("⚠️ [VERSION_CHECK] failed to read package info: $e");
    }

    // ─── فحص الإصدار مع الباك اند ─────────────────────────────────────
    try {
      final url = Applink.getAppConfig(appVersion: appVersion);
      print("🌐 [VERSION_CHECK] url=$url");

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final versionStatus = data['versionStatus'] as String? ?? 'ok';
        final latestVersion = data['latestVersion'] as String? ?? '';
        final updateUrl = data['updateUrl'] as String? ?? '';

        print(
          "🔖 [VERSION_CHECK] status=$versionStatus latest=$latestVersion",
        );

        if (versionStatus == 'blocked') {
          // ─── الإصدار محجوب — عرض شاشة التحديث الإجبارية ────────────
          Get.offAllNamed(
            ForceUpdateScreen.routeName,
            arguments: {
              'latestVersion': latestVersion,
              'updateUrl': updateUrl,
            },
          );
          return;
        }
      } else {
        print(
          "⚠️ [VERSION_CHECK] server returned ${response.statusCode} — proceeding normally",
        );
      }
    } catch (e) {
      // في حال فشل الطلب (لا إنترنت، timeout...) نتابع بشكل طبيعي
      print("⚠️ [VERSION_CHECK] request failed: $e — proceeding normally");
    }

    // ─── التوجيه الطبيعي ─────────────────────────────────────────────
    final targetRoute = myServices.sharedPreferences.getString('router');
    final hasToken =
        (myServices.sharedPreferences.getString('Token') ?? "").isNotEmpty;
    final hasRefresh =
        (myServices.sharedPreferences.getString('refreshToken') ?? "")
            .isNotEmpty;

    print(
      "🚦 [SPLASH_ROUTE] router=$targetRoute hasToken=$hasToken hasRefresh=$hasRefresh",
    );

    Get.offAllNamed(
      targetRoute == null || targetRoute.isEmpty ? "/" : targetRoute,
    );
  }

  @override
  void onClose() {
    super.onClose();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );
  }
}

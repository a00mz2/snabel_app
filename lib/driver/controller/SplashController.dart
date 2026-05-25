// ignore_for_file: file_names

import 'package:customer/driver/core/services/services.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class DriverSplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      Get.offAllNamed(_resolveNextRoute());
    });
  }

  /// يمنع مسار النص `"null"` ويفضّل الجلسة عند وجود توكن صالح.
  String _resolveNextRoute() {
    final prefs = myServices.sharedPreferences;
    final token = prefs.getString('Token');
    final router = prefs.getString('router');

    const loginRoute = '/';

    if (token == null || token.isEmpty) {
      return loginRoute;
    }

    if (router != null &&
        router.isNotEmpty &&
        router != 'null' &&
        router.startsWith('/')) {
      return router;
    }

    return '/driver/MainScreen';
  }
}

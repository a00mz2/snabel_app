import 'package:customer/core/services/services.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 1), () {
      final targetRoute = myServices.sharedPreferences.getString('router');
      final hasToken =
          (myServices.sharedPreferences.getString('Token') ?? "").isNotEmpty;
      final hasRefresh =
          (myServices.sharedPreferences.getString('refreshToken') ?? "")
              .isNotEmpty;

      print(
        "🚦 [SPLASH_ROUTE] router=$targetRoute hasToken=$hasToken hasRefresh=$hasRefresh",
      );

      Get.offAllNamed(targetRoute == null || targetRoute.isEmpty ? "/" : targetRoute);
    });
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

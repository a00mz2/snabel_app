// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:customer/driver/controller/SplashController.dart';
import 'package:customer/driver/core/constant/assets/images.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final DriverSplashController controller = Get.put(DriverSplashController());

  @override
  Widget build(BuildContext context) {
    // 1. تفعيل وضع Fullscreen حقيقي
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    ); // إزالة كل overlays (StatusBar + NavigationBar)

    // 2. جعل شريط الحالة شفاف (للأمان)
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xffF39316),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [Image.asset(AppImage.LeftSplash, width: 130)],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [Image.asset(AppImage.RightSplash, width: 130)],
                ),
              ],
            ),
            Center(child: Image.asset(AppImage.logoSplash, width: 250)),
          ],
        ),
      ),
    );
  }
}

import 'package:customer/controller/SplashController.dart';
import 'package:customer/core/constant/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashController controller = Get.put(SplashController());

  @override
  Widget build(BuildContext context) {
    // تفعيل وضع ملء الشاشة الفعلي (يمتد خلف النظام)
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // جعل الشريطين شفافين تمامًا
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
    );

    return Scaffold(
      extendBodyBehindAppBar: true, // ✅ لتغطية المساحة خلف الشريط العلوي
      backgroundColor: const Color(0xffF39316),
      body: SizedBox.expand(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Image.asset(AppImage.RightSplash, width: 130),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Image.asset(AppImage.LeftSplash, width: 130),
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

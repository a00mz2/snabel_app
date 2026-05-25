// ignore_for_file: file_names

import 'package:customer/driver/controller/LoginController.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/constant/assets/icons.dart';
import 'package:customer/driver/core/constant/assets/images.dart';
import 'package:customer/driver/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/textBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final DriverLoginController controller = Get.put(DriverLoginController());
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent, // اللون شفاف
        statusBarIconBrightness: Brightness.light, // أيقونات فاتحة
      ),
    );
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImage.Union,
              alignment: Alignment.topRight, // تبقى في أقصى اليمين بالأعلى
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: controller.formstate.value,
              child: ListView(
                children: [
                  SizedBox(height: 16),
                  // ⬅ سهم الرجوع لصفحة اختيار الدور
                  Align(
                    alignment: Alignment.centerRight,
                    child: _BackToRoleSelect(),
                  ),
                  SizedBox(height: 8),
                  Image.asset(AppImage.logoSplash, width: 150, height: 150),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "مرحبًا بك مرة أخرى 👋",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: MyFontWeight.semiBold,
                          color: Color(0xff231F1E),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "سجّل دخولك إلى حسابك وابدأ بطلب منتجاتنا .",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: MyFontWeight.regular,
                          color: Color(0xffA19491),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextBoxs(
                    controller: controller.phoneController,
                    typeVal: "phone",
                    maxLength: 11,
                    maxLines: 11,
                    type: TextInputType.number,
                    suffixIcon: Text("+964"),
                    prefixIcon: Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(AppIcons.phone),
                    ),
                    hintText: "رقم التليفون",
                  ),
                  SizedBox(height: 10),
                  Obx(
                    () => TextBoxs(
                      prefixIcon: Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(AppIcons.pass),
                      ),
                      hintText: "كلمة مرور",
                      controller: controller.passwordController,
                      obscureText: controller.obscureText.value,
                      showPassword: () => controller.showPassword(),
                    ),
                  ),
                  SizedBox(height: 24),
                  Obx(
                    () => ButtonAppWidget(
                      statusRequest: controller.statusRequest.value,
                      lable: "تسجيل الدخول",
                      onPressed: () => controller.login(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// زر رجوع صغير في أعلى شاشة دخول السائق — يعيد المستخدم لصفحة اختيار الدور `/`.
class _BackToRoleSelect extends StatelessWidget {
  const _BackToRoleSelect();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.offAllNamed('/'),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffF3F2F1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Color(0xff231F1E),
          size: 16,
        ),
      ),
    );
  }
}

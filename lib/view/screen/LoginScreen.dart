// ignore_for_file: file_names

import 'package:customer/controller/LoginController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/constant/assets/images.dart';
import 'package:customer/core/functions/SetServer.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/textBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  final LoginController controller = Get.put(LoginController());
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
                  SizedBox(height: 40),
                  InkWell(
                    onLongPress: () => setServer(context),
                    child: Image.asset(
                      AppImage.logoSplash,
                      width: 150,
                      height: 150,
                    ),
                  ),
                  SizedBox(height: 40),
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
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Get.toNamed('/ForgotPassword'),
                        child: Text(
                          "هل نسيت كلمة السر؟",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: Color(0xff231F1E),
                                fontSize: 12,
                                fontWeight: MyFontWeight.regular,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Obx(
                    () => ButtonAppWidget(
                      statusRequest: controller.statusRequest.value,
                      lable: "تسجيل الدخول",
                      onPressed: () => controller.login(context),
                    ),
                  ),
                  SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "ليس لديكِ حساب؟ ",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Color(0xffA19491),
                          fontSize: 14,
                          fontWeight: MyFontWeight.light,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.toNamed("/SignUp"),
                        child: Text(
                          "إنشاء حساب",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: Color(0xff231F1E),
                                fontSize: 14,
                                fontWeight: MyFontWeight.regular,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

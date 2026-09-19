// ignore_for_file: file_names, avoid_print, deprecated_member_use, use_build_context_synchronously

import 'package:customer/core/services/support_chat_service.dart';
import 'package:customer/driver/core/class/crud.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/core/services/services.dart';
import 'package:customer/driver/model/LoginModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverLoginController extends GetxController {
  LoginModel model = LoginModel(Get.find());
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  var statusRequest = StatusRequest.none.obs;
  var obscureText = true.obs;
  var formstate = GlobalKey<FormState>().obs;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
  }

  showPassword() {
    obscureText.value = !obscureText.value;
  }

  void login(BuildContext context) async {
    if (formstate.value.currentState!.validate()) {
      statusRequest.value = StatusRequest.loading;
      var response = await model.login(
        phoneController.text,
        passwordController.text,
      );

      if (handlingData(response) == StatusRequest.success &&
          response is Map) {
        final body = Map<String, dynamic>.from(response);
        AppSnackBar.success(apiMessageFromMap(body, 'تم تسجيل الدخول'));
        await saveDataLogin(body);
        Get.offAndToNamed("/driver/MainScreen");
      } else {
        AppSnackBar.error(apiErrorMessage(response, 'فشل تسجيل الدخول'));
      }

      statusRequest.value = handlingData(response);
    }
  }

  saveDataLogin(Map<String, dynamic> response) async {
    phoneController.text = "";
    passwordController.text = "";

    // إعادة تفعيل حارس الجلسة لجلسة جديدة (بعد أي خروج سابق).
    DriverCrud.resetSessionGuard();

    final access = response['accessToken'];
    final refresh = response['refreshToken'];
    if (access is String && access.isNotEmpty) {
      await myServices.sharedPreferences.setString("Token", access);
    }
    if (refresh is String && refresh.isNotEmpty) {
      await myServices.sharedPreferences.setString("refreshToken", refresh);
    }
    await myServices.sharedPreferences.setString("router", "/driver/MainScreen");
    await myServices.sharedPreferences.setString("userRole", "driver");

    // بعد كتابة الدور والتوكن لا قبلهما: الخدمة تقرأهما من التفضيلات عند الاتصال
    if (Get.isRegistered<SupportChatService>()) {
      Get.find<SupportChatService>().start();
    }

    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null && token.isNotEmpty) {
      final tokenRes = await model.addDriverToken(token);
      if (handlingData(tokenRes) == StatusRequest.success) {
        AppSnackBar.success(
          apiMessageFromMap(tokenRes, 'تم تسجيل الجهاز للإشعارات'),
        );
      } else {
        AppSnackBar.error(
          apiErrorMessage(tokenRes, 'تعذر تسجيل الجهاز للإشعارات'),
        );
      }
    }
  }
}

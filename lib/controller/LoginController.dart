// ignore_for_file: file_names, avoid_print, deprecated_member_use, use_build_context_synchronously

import 'package:customer/core/class/crud.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/model/LoginModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  LoginModel model = LoginModel(Get.find());
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  var statusRequest = StatusRequest.none.obs;
  var obscureText = true.obs;
  var formstate = GlobalKey<FormState>().obs;

  RxString role = "customer".obs;

  @override
  void onInit() {
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    phoneController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    phoneController.text = "";
    passwordController.text = "";
    super.onClose();
  }

  choosingRole(String value) {
    role.value = value;
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

      if (handlingData(response) == StatusRequest.success) {
        AppSnackBar.success(tryResponseMessage(response) ?? '');
        await saveDataLogin(response);
        Get.offAllNamed("/MainScreen");
      } else {
        AppSnackBar.error(tryResponseMessage(response) ?? "");
      }

      statusRequest.value = handlingData(response);
    } else {}
  }

  saveDataLogin(response) async {
    Get.find<Crud>().resetLogoutNavigationGuard();
    phoneController.clear();
    passwordController.clear();
    await myServices.sharedPreferences.setString(
      "Token",
      response['accessToken'],
    );
    myServices.sharedPreferences.setString(
      "refreshToken",
      response['refreshToken'],
    );
    myServices.sharedPreferences.setString(
      "name",
      response["customer"]["customerName"],
    );
    myServices.sharedPreferences.setString(
      "phone",
      response["customer"]["phone"],
    );
    myServices.sharedPreferences.setString("router", "/MainScreen");
    myServices.sharedPreferences.setString("userRole", "customer");

    final FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null && token != "") {
      var responseTokin = await model.addToken(token);
      if (handlingData(responseTokin) == StatusRequest.success) {
        myServices.sharedPreferences.setString("tokinFCM", token);
      }
    }
  }
}

// ignore_for_file: avoid_print

import 'dart:async';
import 'package:customer/core/class/crud.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/model/LoginModel.dart';
import 'package:customer/model/SignUpModel.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:latlong2/latlong.dart';
import 'package:otp_text_field/otp_field.dart';

class SignUpControler extends GetxController {
  SignUpModel model = SignUpModel(Get.find());
  LoginModel loginModel = LoginModel(Get.find());

  @override
  void onInit() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.onInit();
    phoneController = TextEditingController();
    passwordController = TextEditingController();
    rEpasswordController = TextEditingController();
    customerNameController = TextEditingController();
    storeNameController = TextEditingController();
    addressController = TextEditingController();
    locationController = TextEditingController();
  }

  Rx<StatusRequest> buttonStatusRequest = StatusRequest.success.obs;
  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  var obscureText = true.obs;
  var rEobscureText = true.obs;

  late TextEditingController customerNameController;
  late TextEditingController storeNameController;
  late TextEditingController phoneController;
  late TextEditingController passwordController;
  late TextEditingController rEpasswordController;
  late TextEditingController addressController;
  late TextEditingController locationController;
  var formstate = GlobalKey<FormState>().obs;

  Rxn<Uint8List> imageElmint = Rxn<Uint8List>();

  RxString fileName = ''.obs;

  var selectedLocation = Rx<LatLng?>(null);
  var tempLocation = Rx<LatLng?>(null);

  var listCustomerType = [
    {"name": "مطعم", "value": "مطعم"},
    {"name": "متجر", "value": "متجر"},
    {"name": "كافيه", "value": "كافيه"},
    {"name": "مجهز", "value": "مجهز"},
    {"name": "أخرى", "value": "أخرى"},
  ];
  var customerType = {}.obs;

  var listprovince = [
    {"name": "بغداد", "value": "بغداد"},
    {"name": "البصرة", "value": "البصرة"},
    {"name": "الموصل", "value": "الموصل"},
    {"name": "أربيل", "value": "أربيل"},
    {"name": "النجف", "value": "النجف"},
    {"name": "كربلاء", "value": "كربلاء"},
    {"name": "ديالى", "value": "ديالى"},
    {"name": "صلاح الدين", "value": "صلاح الدين"},
    {"name": "ذي قار", "value": "ذي قار"},
    {"name": "واسط", "value": "واسط"},
    {"name": "ميسان", "value": "ميسان"},
    {"name": "القادسية", "value": "القادسية"},
    {"name": "الأنبار", "value": "الأنبار"},
    {"name": "كركوك", "value": "كركوك"},
    {"name": "السليمانية", "value": "السليمانية"},
    {"name": "حلبجة", "value": "حلبجة"},
    {"name": "دهوك", "value": "دهوك"},
    {"name": "بابل", "value": "بابل"},
  ];
  var province = {}.obs;

  var isLoading = false.obs;

  //Function

  selectedcustomerType(Map<dynamic, dynamic> item) {
    customerType.value = item;
  }

  selectedProvince(Map<dynamic, dynamic> item) {
    province.value = item;
  }

  showPassword({bool isRePassword = false}) {
    if (isRePassword) {
      rEobscureText.value = !rEobscureText.value;
    } else {
      obscureText.value = !obscureText.value;
    }
  }

  void setLocation(LatLng location) {
    selectedLocation.value = location;
  }

  void setTempLocation(LatLng loc) {
    tempLocation.value = loc;
  }

  void confirmLocation() {
    if (tempLocation.value != null) {
      selectedLocation.value = tempLocation.value;
      locationController.text =
          "https://www.google.com/maps/dir/?api=1&destination=${tempLocation.value!.latitude},${tempLocation.value!.longitude}";
    }
  }

  verification() async {
    if (formstate.value.currentState!.validate()) {
      if (customerType.isEmpty) {
        Get.snackbar("خطأ", "يرجى اختيار نوع المتجر");
      } else if (locationController.text.toString().isEmpty) {
        Get.snackbar("خطأ", "يرجى اختيار الموقع");
      } else if (imageElmint.value == null) {
        Get.snackbar("خطأ", "يرجى إرفاق صورة الهوية");
      } else if (province.isEmpty) {
        Get.snackbar("خطأ", "يرجى اختيار المحافظة");
      } else if (passwordController.text != rEpasswordController.text) {
        Get.snackbar("خطأ", "كلمة المرور غير متطابقة");
      } else {
        buttonStatusRequest.value = StatusRequest.loading;
        var response = await model.createOtp(phoneController.text);

        if (handlingData(response) == StatusRequest.success) {
          AppSnackBar.success(response['message'] ?? "");
          Get.toNamed("/Otp");
          startTimer();
        } else {
          try {
            AppSnackBar.error(response['message'] ?? "هناك خطأ ما");
          } catch (e) {
            AppSnackBar.error("هناك خطأ ما");
          }
        }

        buttonStatusRequest.value = StatusRequest.success;
      }
    }
  }

  //=========================otp=========================
  var secondsRemaining = 30.obs;
  var enableResend = false.obs;
  Timer? timer;
  var otpCode = ''.obs;
  final OtpFieldController otpFieldController = OtpFieldController();
  void startTimer() {
    secondsRemaining.value = 30;
    enableResend.value = false;
    timer?.cancel();

    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        enableResend.value = true;
        t.cancel();
      }
    });
  }

  void resendCode() async {
    if (enableResend.value) {
      model.createOtp(phoneController.text);
      startTimer();
      clearOtpField();
      Get.snackbar("إعادة الإرسال", "تم إرسال الكود مجددًا ✅");
    }
  }

  //تفريغ حقول  otp
  void clearOtpField() {
    try {
      otpFieldController.clear();
    } catch (_) {}
    otpCode.value = '';
  }

  void verifyCode() async {
    if (rEpasswordController.text != passwordController.text) {
      AppSnackBar.error("كلمة المرور غير متطابقة");
      return;
    }
    statusRequest.value = StatusRequest.loading;

    var response = await model.createCustomer(
      customerName: customerNameController.text,
      storeName: storeNameController.text,
      province: province['value'],
      phone: phoneController.text,
      address: addressController.text,
      storeLocation: locationController.text,
      type: customerType['value'],
      password: passwordController.text,
      otp: otpCode.value,
      document: imageElmint.value,
    );

    if (handlingData(response) == StatusRequest.success) {
      AppSnackBar.success(response['message']);
      await login();
    } else {
      statusRequest.value = StatusRequest.success;
      AppSnackBar.error(tryResponseMessage(response) ?? '');
      clearOtpField();
    }
  }

  login() async {
    statusRequest.value = StatusRequest.loading;
    var response = await loginModel.login(
      phoneController.text,
      passwordController.text,
    );

    if (handlingData(response) == StatusRequest.success) {
      AppSnackBar.success(response['message'] ?? '');
      await saveDataLogin(response);
      Get.offAllNamed("/MainScreen");
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? "");
    }
  }

  saveDataLogin(response) async {
    Get.find<Crud>().resetLogoutNavigationGuard();
    phoneController.clear();
    passwordController.clear();

    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(
        response['refreshToken'],
      );
      myServices.sharedPreferences.setString("id", decodedToken['Id']);
      myServices.sharedPreferences.setString("Token", response['accessToken']);
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
      final FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();

      if (token != null && token != "") {
        var responseTokin = await loginModel.addToken(token);
        if (handlingData(responseTokin) == StatusRequest.success) {
          myServices.sharedPreferences.setString("tokinFCM", token);
        }
      }
    } catch (e) {
      print("خطأ في حفظ حالة تسجيل الدخول: $e");
    }
  }
}

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

  // ─── التحقق من صحة البيانات قبل إرسال OTP ───────────────────────────────
  verification() async {
    // تفعيل التحقق البصري (تلوين الحقول الفارغة بالأحمر)
    formstate.value.currentState?.validate();

    // 1. أسماء الحقول النصية مع رسائلها الواضحة
    final textFields = [
      {
        "controller": customerNameController,
        "msg": "يرجى إدخال اسم صاحب المتجر",
      },
      {"controller": storeNameController, "msg": "يرجى إدخال اسم المتجر"},
      {"controller": phoneController, "msg": "يرجى إدخال رقم الهاتف"},
      {"controller": addressController, "msg": "يرجى إدخال عنوان المتجر"},
      {"controller": passwordController, "msg": "يرجى إدخال كلمة المرور"},
      {
        "controller": rEpasswordController,
        "msg": "يرجى تأكيد كلمة المرور",
      },
    ];

    // 2. التحقق من كل حقل نصي بالاسم
    for (final field in textFields) {
      final ctrl = field["controller"] as TextEditingController;
      if (ctrl.text.trim().isEmpty) {
        AppSnackBar.error(field["msg"] as String);
        return;
      }
    }

    // 3. التحقق من صحة رقم الهاتف (صيغة عراقية)
    final phone = phoneController.text.trim();
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final validPhone =
        RegExp(r'^9647\d{9}$').hasMatch(digits) ||
        RegExp(r'^07\d{9}$').hasMatch(digits);
    if (!validPhone) {
      AppSnackBar.error("رقم الهاتف غير صالح — أدخل: 07xxxxxxxxx");
      return;
    }

    // 4. التحقق من المحافظة
    if (province.isEmpty) {
      AppSnackBar.error("يرجى اختيار المحافظة");
      return;
    }

    // 5. التحقق من الموقع الجغرافي
    if (locationController.text.trim().isEmpty) {
      AppSnackBar.error("يرجى تحديد موقع المتجر على الخريطة");
      return;
    }

    // 6. التحقق من نوع المتجر
    if (customerType.isEmpty) {
      AppSnackBar.error("يرجى اختيار نوع المتجر");
      return;
    }

    // 7. التحقق من صورة / وثيقة الاعتماد
    if (imageElmint.value == null) {
      AppSnackBar.error("يرجى إرفاق وثيقة الاعتماد (صورة الهوية)");
      return;
    }

    // 8. التحقق من تطابق كلمتَي المرور
    if (passwordController.text != rEpasswordController.text) {
      AppSnackBar.error("كلمة المرور وتأكيدها غير متطابقتين");
      return;
    }

    // 9. كل التحقق نجح — إرسال OTP
    buttonStatusRequest.value = StatusRequest.loading;
    var response = await model.createOtp(phoneController.text);

    if (handlingData(response) == StatusRequest.success) {
      AppSnackBar.success(response['message'] ?? "تم إرسال رمز التحقق");
      Get.toNamed("/Otp");
      startTimer();
    } else {
      try {
        AppSnackBar.error(response['message'] ?? "هناك خطأ ما");
      } catch (_) {
        AppSnackBar.error("هناك خطأ ما، يرجى المحاولة مجدداً");
      }
    }

    buttonStatusRequest.value = StatusRequest.success;
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
      // إعادة الحالة لـ success حتى لا تبقى شاشة OTP مجمّدة
      statusRequest.value = StatusRequest.success;
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

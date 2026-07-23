// ignore_for_file: avoid_print

import 'dart:async';

import 'package:customer/core/class/otp_opt_in.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/ForgotPasswordModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController() : _model = ForgotPasswordModel(Get.find());

  final ForgotPasswordModel _model;

  final formPhoneKey = GlobalKey<FormState>();
  final formResetKey = GlobalKey<FormState>();

  late final TextEditingController phoneController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  final OtpFieldController otpFieldController = OtpFieldController();

  final Rx<StatusRequest> statusRequest = StatusRequest.none.obs;
  final RxInt step = 0.obs;

  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  final RxString otpCode = ''.obs;

  /// بيانات الاشتراك بخدمة واتساب (opt-in) — من استجابة طلب الرمز.
  final Rx<OtpOptInInfo> otpOptIn = Rx<OtpOptInInfo>(const OtpOptInInfo());

  var secondsRemaining = 60.obs;
  var enableResend = false.obs;
  Timer? timer;

  /// يفتح واتساب على رقم الخدمة مع كلمة الاشتراك معبأة — لاستلام الرمز.
  Future<void> openWhatsAppForCode() async {
    final ok = await otpOptIn.value.openWhatsApp();
    if (!ok) {
      AppSnackBar.error('تعذر فتح واتساب، تأكد من تثبيته على جهازك');
    }
  }

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    timer?.cancel();
    phoneController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void toggleObscure({required bool confirm}) {
    if (confirm) {
      obscureConfirm.value = !obscureConfirm.value;
    } else {
      obscureNew.value = !obscureNew.value;
    }
  }

  void startTimer() {
    secondsRemaining.value = 60;
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

  void clearOtpField() {
    try {
      otpFieldController.clear();
    } catch (_) {}
    otpCode.value = '';
  }

  Future<void> requestOtp() async {
    if (formPhoneKey.currentState != null &&
        !formPhoneKey.currentState!.validate()) {
      return;
    }
    final phone = phoneController.text.trim();

    statusRequest.value = StatusRequest.loading;
    dynamic response = await _model.requestForgotPasswordOtp(phone);

    if (handlingData(response) != StatusRequest.success) {
      response = await _model.requestForgotPasswordOtpViaCreateOtp(phone);
    }

    if (handlingData(response) == StatusRequest.success) {
      // التقاط بيانات الاشتراك — إن كان الرقم غير مشترك يظهر زر واتساب.
      otpOptIn.value = OtpOptInInfo.fromResponse(response);
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم إرسال الرمز إلى واتساب',
      );
      step.value = 1;
      startTimer();
      clearOtpField();
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر إرسال الرمز');
    }

    statusRequest.value = handlingData(response);
  }

  Future<void> resendOtp() async {
    if (!enableResend.value) return;
    statusRequest.value = StatusRequest.loading;
    final phone = phoneController.text.trim();
    dynamic response = await _model.requestForgotPasswordOtp(phone);
    if (handlingData(response) != StatusRequest.success) {
      response = await _model.requestForgotPasswordOtpViaCreateOtp(phone);
    }
    if (handlingData(response) == StatusRequest.success) {
      otpOptIn.value = OtpOptInInfo.fromResponse(response);
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم إعادة إرسال الرمز',
      );
      startTimer();
      clearOtpField();
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر إعادة الإرسال');
    }
    statusRequest.value = handlingData(response);
  }

  Future<void> submitNewPassword() async {
    final otp = otpCode.value.trim();
    if (otp.length < 6) {
      AppSnackBar.warning('أدخل رمز التحقق المكوّن من 6 أرقام');
      return;
    }

    if (newPasswordController.text.length < 6) {
      AppSnackBar.warning('كلمة المرور يجب ألا تقل عن 6 أحرف');
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      AppSnackBar.warning('كلمة المرور وتأكيدها غير متطابقتين');
      return;
    }

    if (formResetKey.currentState != null &&
        !formResetKey.currentState!.validate()) {
      return;
    }

    statusRequest.value = StatusRequest.loading;
    final response = await _model.resetPasswordWithOtp(
      phone: phoneController.text.trim(),
      otp: otp,
      newPassword: newPasswordController.text,
    );

    if (handlingData(response) == StatusRequest.success) {
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم تغيير كلمة المرور بنجاح',
      );
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.offAllNamed('/');
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر إكمال العملية');
      clearOtpField();
    }

    statusRequest.value = handlingData(response);
  }

  void goBackStep() {
    if (step.value == 1) {
      step.value = 0;
      timer?.cancel();
      clearOtpField();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } else {
      Get.back();
    }
  }
}

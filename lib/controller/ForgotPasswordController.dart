import 'package:customer/core/class/otp_verify_mixin.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/ForgotPasswordModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController with OtpVerifyMixin {
  ForgotPasswordController() : _model = ForgotPasswordModel(Get.find());

  final ForgotPasswordModel _model;

  final formPhoneKey = GlobalKey<FormState>();
  final formResetKey = GlobalKey<FormState>();

  late final TextEditingController phoneController;
  late final TextEditingController newPasswordController;
  late final TextEditingController confirmPasswordController;

  final Rx<StatusRequest> statusRequest = StatusRequest.none.obs;
  final RxInt step = 0.obs;

  final obscureNew = true.obs;
  final obscureConfirm = true.obs;

  @override
  void onInit() {
    super.onInit();
    phoneController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void onClose() {
    disposeOtp();
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

  /// الخطوة 1: التحقق من الرقم وإرسال رمز التحقق إلى واتساب.
  Future<void> requestOtp() async {
    if (formPhoneKey.currentState != null &&
        !formPhoneKey.currentState!.validate()) {
      return;
    }
    final phone = phoneController.text.trim();

    statusRequest.value = StatusRequest.loading;
    final result = await sendOtp(phone, 'resetPassword');
    statusRequest.value = StatusRequest.none;

    switch (result) {
      case OtpSendResult.sent:
        step.value = 1;
        break;
      case OtpSendResult.cooldown:
        // مهلة من الخادم — رمز سابق قد يكون صالحاً، ننتقل مع عرض العدّاد
        AppSnackBar.warning(otpError.value);
        step.value = 1;
        break;
      case OtpSendResult.failed:
        AppSnackBar.error(
          otpError.value.isEmpty ? 'تعذّر إرسال رمز التحقق' : otpError.value,
        );
        break;
    }
  }

  /// الخطوة 2: تعيين كلمة المرور بالرمز المدخل (يُتحقَّق ويُستهلك في الخادم).
  Future<void> submitNewPassword() async {
    if (!otpIsComplete) {
      AppSnackBar.warning('أدخل رمز التحقق المكوّن من $kOtpLength أرقام أولاً');
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
      otp: otpCode.value,
      newPassword: newPasswordController.text,
    );

    if (handlingData(response) == StatusRequest.success) {
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم تغيير كلمة المرور بنجاح',
      );
      disposeOtp();
      newPasswordController.clear();
      confirmPasswordController.clear();
      Get.offAllNamed('/');
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر إكمال العملية');
      statusRequest.value = StatusRequest.none;
      clearOtpField();
    }
  }

  void goBackStep() {
    if (step.value == 1) {
      disposeOtp();
      clearOtpField();
      otpError.value = '';
      step.value = 0;
      newPasswordController.clear();
      confirmPasswordController.clear();
    } else {
      Get.back();
    }
  }
}

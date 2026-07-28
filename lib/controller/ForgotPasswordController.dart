import 'package:customer/core/class/reverse_verify_mixin.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/ForgotPasswordModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgotPasswordController extends GetxController with ReverseVerifyMixin {
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
    disposeReverse();
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

  /// الخطوة 1: التحقق من الرقم وبدء التحقق العكسي.
  Future<void> requestOtp() async {
    if (formPhoneKey.currentState != null &&
        !formPhoneKey.currentState!.validate()) {
      return;
    }
    final phone = phoneController.text.trim();

    statusRequest.value = StatusRequest.loading;
    final started = await startReverse(phone, 'resetPassword');
    statusRequest.value = StatusRequest.none;

    if (started) {
      step.value = 1;
    } else {
      AppSnackBar.error(
        reverseError.value.isEmpty ? 'تعذّر بدء التحقق' : reverseError.value,
      );
    }
  }

  /// إعادة بدء جلسة تحقّق جديدة.
  Future<void> restartReverse() => requestOtp();

  /// الخطوة 2: تعيين كلمة المرور بعد اكتمال التحقق العكسي.
  Future<void> submitNewPassword() async {
    if (!reverseVerified.value) {
      AppSnackBar.warning('أكمل التحقق أولاً: أرسل الرمز على واتساب');
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
      reverseRef: reverseRef,
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
      statusRequest.value = StatusRequest.none;
    }
  }

  void goBackStep() {
    if (step.value == 1) {
      step.value = 0;
      disposeReverse();
      newPasswordController.clear();
      confirmPasswordController.clear();
    } else {
      Get.back();
    }
  }
}

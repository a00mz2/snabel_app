import 'package:customer/core/class/crud.dart';
import 'package:customer/linkApi.dart';

class ForgotPasswordModel {
  ForgotPasswordModel(this.crud);

  final Crud crud;

  /// الخطوة 1 — طلب OTP على واتساب (عام، بدون Authorization)
  Future<dynamic> requestForgotPasswordOtp(String phone) async {
    final response = await crud.postData(
      Applink.requestForgotPasswordOtp,
      <String, dynamic>{'phone': phone.trim()},
      isPublicRoutes: true,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// بديل: createOtp مع action (إن طابق الخادم)
  Future<dynamic> requestForgotPasswordOtpViaCreateOtp(String phone) async {
    final response = await crud.postData(
      Applink.createOtp,
      <String, dynamic>{
        'phone': phone.trim(),
        'action': 'resetPassword',
      },
      isPublicRoutes: true,
    );
    return response.fold((l) => l, (r) => r);
  }

  /// الخطوة 2 — تعيين كلمة المرور الجديدة.
  /// يقبل التحقق العكسي (reverseRef) أو الـ OTP التقليدي (otp).
  Future<dynamic> resetPasswordWithOtp({
    required String phone,
    String? otp,
    String? reverseRef,
    required String newPassword,
  }) async {
    final body = <String, dynamic>{
      'phone': phone.trim(),
      'newPassword': newPassword,
      if (otp != null && otp.trim().isNotEmpty) 'otp': otp.trim(),
      if (reverseRef != null && reverseRef.isNotEmpty) 'reverseRef': reverseRef,
    };
    var response = await crud.postData(
      Applink.resetPasswordWithOtp,
      body,
      isPublicRoutes: true,
    );
    return response.fold((l) => l, (r) => r);
  }
}

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

  /// الخطوة 2 — تعيين كلمة المرور الجديدة
  Future<dynamic> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    final body = <String, dynamic>{
      'phone': phone.trim(),
      'otp': otp.trim(),
      'newPassword': newPassword,
    };
    var response = await crud.postData(
      Applink.resetPasswordWithOtp,
      body,
      isPublicRoutes: true,
    );
    return response.fold((l) => l, (r) => r);
  }
}

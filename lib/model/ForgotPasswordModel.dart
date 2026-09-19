import 'package:customer/core/class/crud.dart';
import 'package:customer/linkApi.dart';

class ForgotPasswordModel {
  ForgotPasswordModel(this.crud);

  final Crud crud;

  /// الخطوة 2 — تعيين كلمة المرور الجديدة بالرمز المرسل إلى واتساب.
  /// (الخطوة 1 — طلب الرمز — عبر OtpModel.requestOtp بغرض "resetPassword".)
  Future<dynamic> resetPasswordWithOtp({
    required String phone,
    required String otp,
    required String newPassword,
  }) async {
    final response = await crud.postData(
      Applink.resetPasswordWithOtp,
      <String, dynamic>{
        'phone': phone.trim(),
        'otp': otp.trim(),
        'newPassword': newPassword,
      },
      isPublicRoutes: true,
    );
    return response.fold((l) => l, (r) => r);
  }
}

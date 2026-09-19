import 'package:customer/core/class/crud.dart';
import 'package:customer/linkApi.dart';

/// طبقة API لرمز التحقق (OTP) — الخادم يُولّد الرمز ويرسله عبر واتساب (Meta Cloud API).
///  requestOtp → 200: { success, message, phone, expiresInSec, resendAfterSec }
///               429: { message, retryAfterSec }  (مهلة إعادة الإرسال / حصة الساعة)
class OtpModel {
  OtpModel(this.crud);
  final Crud crud;

  /// [purpose]: "register" أو "resetPassword" (كلاهما بلا توكن).
  Future<dynamic> requestOtp(String phone, String purpose) async {
    final response = await crud.postData(
      Applink.createOtp,
      {"phone": phone.trim(), "action": purpose},
      isRetry: false,
      isPublicRoutes: true,
    );
    return response.fold((failure) => failure, (data) => data);
  }
}

import 'dart:async';

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/OtpModel.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';

/// طول رمز التحقق (يطابق الخادم).
const int kOtpLength = 6;

/// نتيجة طلب إرسال رمز.
enum OtpSendResult {
  /// أُرسل رمز جديد.
  sent,

  /// الخادم رفض لوجود مهلة (429 مع retryAfterSec) — قد يكون رمز سابق ما زال صالحاً.
  cooldown,

  /// فشل الإرسال — الرسالة في [OtpVerifyMixin.otpError].
  failed,
}

/// منطق رمز التحقق القابل لإعادة الاستخدام (التسجيل + نسيت كلمة المرور).
///
/// التدفّق:
///  1. [sendOtp] → الخادم يُولّد الرمز ويرسله إلى واتساب الرقم عبر Meta.
///  2. المستخدم يضغط «نسخ الرمز» في رسالة واتساب ثم [pasteFromClipboard]، أو يكتبه.
///  3. الكنترولر يقرأ [otpCode] ويرسله مع الطلب النهائي (createCustomer / resetPasswordWithOtp).
///  4. العدّاد [secondsRemaining] يبدأ من قيمة الخادم (resendAfterSec)، ثم يُتاح [resendOtp].
mixin OtpVerifyMixin on GetxController {
  late final OtpModel _otpApi = OtpModel(Get.find());

  /// يربط حقل المربعات الستّة — يحمل مرجعاً لحالة الحقل، لذا كل استدعاء له داخل try/catch.
  final OtpFieldController otpFieldController = OtpFieldController();
  final RxString otpCode = ''.obs;
  final RxBool otpSending = false.obs;
  final RxInt secondsRemaining = 0.obs;
  final RxBool enableResend = false.obs;
  final RxString otpError = ''.obs;

  /// آخر رقم/غرض أُرسل لهما رمز — لإعادة الإرسال.
  final RxString otpPhone = ''.obs;
  final RxString otpPurpose = ''.obs;
  DateTime? otpExpiresAt;

  Timer? _resendTimer;

  static const int _defaultResendAfterSec = 60;
  static const int _defaultExpiresInSec = 300;

  bool get otpIsComplete => otpCode.value.length == kOtpLength;
  bool get otpExpired =>
      otpExpiresAt != null && DateTime.now().isAfter(otpExpiresAt!);

  /// يطلب رمزاً جديداً. [purpose]: "register" أو "resetPassword".
  Future<OtpSendResult> sendOtp(String phone, String purpose) async {
    if (otpSending.value) return OtpSendResult.failed;
    otpSending.value = true;
    otpError.value = '';
    otpPhone.value = phone.trim();
    otpPurpose.value = purpose;
    try {
      final resp = await _otpApi.requestOtp(phone, purpose);
      final map = tryResponseMap(resp);

      if (handlingData(resp) == StatusRequest.success) {
        final resendAfter =
            _readInt(map?['resendAfterSec'], _defaultResendAfterSec);
        final expiresIn = _readInt(map?['expiresInSec'], _defaultExpiresInSec);
        otpExpiresAt = DateTime.now().add(Duration(seconds: expiresIn));
        clearOtpField();
        startResendTimer(resendAfter);
        return OtpSendResult.sent;
      }

      otpError.value =
          tryResponseMessage(resp) ?? 'تعذّر إرسال رمز التحقق، حاول مجدداً';
      final retryAfter = _readInt(map?['retryAfterSec'], 0);
      if (retryAfter > 0) {
        // مهلة من الخادم: نعرض عدّاده ونسمح بالمتابعة (رمز سابق قد يكون صالحاً).
        startResendTimer(retryAfter);
        return OtpSendResult.cooldown;
      }
      return OtpSendResult.failed;
    } finally {
      otpSending.value = false;
    }
  }

  /// إعادة الإرسال لنفس الرقم والغرض بعد انتهاء العدّاد.
  Future<void> resendOtp() async {
    if (!enableResend.value || otpSending.value) return;
    if (otpPhone.value.isEmpty || otpPurpose.value.isEmpty) return;

    final result = await sendOtp(otpPhone.value, otpPurpose.value);
    if (result == OtpSendResult.sent) {
      AppSnackBar.success('تم إرسال رمز جديد إلى واتساب');
    } else if (result == OtpSendResult.failed) {
      AppSnackBar.error(
        otpError.value.isEmpty ? 'تعذّر إعادة الإرسال' : otpError.value,
      );
    }
  }

  /// يبدأ عدّاد إعادة الإرسال من [seconds] (قيمة الخادم، لا قيمة ثابتة).
  void startResendTimer(int seconds) {
    _resendTimer?.cancel();
    secondsRemaining.value = seconds < 0 ? 0 : seconds;
    enableResend.value = secondsRemaining.value == 0;
    if (enableResend.value) return;

    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (secondsRemaining.value > 1) {
        secondsRemaining.value--;
      } else {
        secondsRemaining.value = 0;
        enableResend.value = true;
        t.cancel();
      }
    });
  }

  /// يقرأ الحافظة (زر «نسخ الرمز» في رسالة واتساب) ويعبّئ المربعات.
  /// تعبئة الحقل تُطلق onCompleted تلقائياً.
  Future<bool> pasteFromClipboard() async {
    String? text;
    try {
      text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    } catch (_) {
      text = null;
    }

    final match = RegExp('\\d{$kOtpLength}').firstMatch(text ?? '');
    if (match == null) {
      AppSnackBar.warning('لم يُعثر على رمز مكوّن من $kOtpLength أرقام في الحافظة');
      return false;
    }

    final code = match.group(0)!;
    otpCode.value = code;
    try {
      otpFieldController.set(code.split(''));
    } catch (_) {
      // الحقل غير مركّب حالياً — القيمة محفوظة في otpCode على أي حال.
    }
    return true;
  }

  void clearOtpField() {
    try {
      otpFieldController.clear();
    } catch (_) {}
    otpCode.value = '';
  }

  void disposeOtp() {
    _resendTimer?.cancel();
    _resendTimer = null;
  }

  static int _readInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse('${v ?? ''}') ?? fallback;
  }
}

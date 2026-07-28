import 'dart:async';

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/model/ReverseVerifyModel.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// منطق التحقق العكسي القابل لإعادة الاستخدام (التسجيل + نسيت كلمة المرور).
///
/// التدفّق:
///  1. [startReverse] → يبدأ جلسة، يعرض [reverseCode] و [reverseWaLink].
///  2. المستخدم يضغط زر واتساب ([openReverseWhatsApp]) ويرسل الرمز.
///  3. التحقق يصل بطريقتين:
///     - لحظي: استقصاء تلقائي كل 3 ثوانٍ (الـ webhook يجعل الخادم يعرف فوراً).
///     - بزر: [checkReverseStatus] عند ضغط المستخدم «تحقّقت».
///  4. عند التحقق → [reverseVerified]=true ويُستدعى [onReverseVerified].
mixin ReverseVerifyMixin on GetxController {
  late final ReverseVerifyModel _reverseApi = ReverseVerifyModel(Get.find());

  final RxString reverseCode = ''.obs;
  final RxString reverseWaLink = ''.obs;
  final RxString reverseServiceNumber = ''.obs;
  final RxString _reverseRef = ''.obs;
  final RxBool reverseVerified = false.obs;
  final RxBool reverseStarting = false.obs;
  final RxBool reverseChecking = false.obs;
  final RxString reverseError = ''.obs;

  Timer? _pollTimer;

  String get reverseRef => _reverseRef.value;
  bool get hasReverseSession => _reverseRef.value.isNotEmpty;

  /// الرسالة الكاملة التي يجب أن يُرسلها المستخدم (مثل: "verify ABC23456").
  /// تُستخرج من نص رابط واتساب لضمان مطابقتها لما يتوقّعه المزوّد.
  String get reverseMessage {
    final link = reverseWaLink.value;
    if (link.isNotEmpty) {
      final uri = Uri.tryParse(link);
      final text = uri?.queryParameters['text'];
      if (text != null && text.trim().isNotEmpty) return text;
    }
    final c = reverseCode.value.trim();
    return c.isEmpty ? '' : 'verify $c';
  }

  /// يبدأ جلسة تحقّق عكسي. purpose: "register" أو "resetPassword".
  Future<bool> startReverse(String phone, String purpose) async {
    reverseStarting.value = true;
    reverseError.value = '';
    reverseVerified.value = false;
    _reverseRef.value = '';
    reverseCode.value = '';
    reverseWaLink.value = '';
    reverseServiceNumber.value = '';
    _pollTimer?.cancel();
    try {
      final resp = await _reverseApi.start(phone, purpose);
      final ok = handlingData(resp) == StatusRequest.success &&
          resp is Map &&
          resp['ref'] != null;
      if (ok) {
        _reverseRef.value = resp['ref'].toString();
        reverseCode.value = (resp['code'] ?? '').toString();
        reverseWaLink.value = (resp['waLink'] ?? '').toString();
        reverseServiceNumber.value = (resp['serviceNumber'] ?? '').toString();
        _startPolling();
        return true;
      }
      reverseError.value =
          tryResponseMessage(resp) ?? 'تعذّر بدء التحقق، حاول مجدداً';
      return false;
    } finally {
      reverseStarting.value = false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => checkReverseStatus(silent: true),
    );
  }

  /// يستعلم عن حالة التحقق. [silent] للاستقصاء التلقائي (بلا رسائل خطأ).
  Future<bool> checkReverseStatus({bool silent = false}) async {
    if (_reverseRef.value.isEmpty || reverseVerified.value) {
      return reverseVerified.value;
    }
    if (!silent) reverseChecking.value = true;
    try {
      final resp = await _reverseApi.status(_reverseRef.value);
      if (resp is Map && resp['verified'] == true) {
        reverseVerified.value = true;
        _pollTimer?.cancel();
        onReverseVerified();
        return true;
      }
      if (resp is Map && resp['status'] == 'expired') {
        _pollTimer?.cancel();
        reverseError.value = 'انتهت صلاحية التحقق، ابدأ من جديد';
      } else if (!silent) {
        reverseError.value =
            'لم يصل تأكيد الإرسال بعد — تأكد من إرسال الرمز على واتساب';
      }
      return false;
    } finally {
      if (!silent) reverseChecking.value = false;
    }
  }

  /// يفتح واتساب على رقم الخدمة والرمز معبّأ مسبقاً (verify CODE).
  Future<bool> openReverseWhatsApp() async {
    final link = reverseWaLink.value;
    if (link.trim().isEmpty) return false;
    try {
      return await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }

  /// تُستدعى تلقائياً فور نجاح التحقق — تُعاد تعريفها في كل كنترولر للمتابعة.
  void onReverseVerified() {}

  void disposeReverse() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }
}

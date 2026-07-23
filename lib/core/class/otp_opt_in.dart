import 'package:url_launcher/url_launcher.dart';

/// بيانات الاشتراك (opt-in) القادمة من الخادم عند طلب رمز تحقق لرقم غير مشترك
/// في خدمة الواتساب.
///
/// عندما يكون `pending == true` فالرمز مخزَّن عند مزوّد الخدمة ولن يصل إلا بعد
/// أن يرسل المستخدم كلمة الاشتراك (`optInWord`) إلى رقم الخدمة (`serviceNumber`).
/// حقل `waLink` رابط جاهز يفتح واتساب على رقم الخدمة والكلمة معبأة مسبقاً.
class OtpOptInInfo {
  final bool pending;
  final String? waLink;
  final String? optInWord;
  final String? serviceNumber;
  final String? instruction;

  const OtpOptInInfo({
    this.pending = false,
    this.waLink,
    this.optInWord,
    this.serviceNumber,
    this.instruction,
  });

  factory OtpOptInInfo.fromResponse(dynamic response) {
    if (response is Map) {
      return OtpOptInInfo(
        pending: response['pending'] == true,
        waLink: response['waLink']?.toString(),
        optInWord: response['optInWord']?.toString(),
        serviceNumber: response['serviceNumber']?.toString(),
        instruction: response['instruction']?.toString(),
      );
    }
    return const OtpOptInInfo();
  }

  /// هل يمكن عرض زر «اضغط للحصول على الكود»؟
  bool get showOptInButton =>
      pending && waLink != null && waLink!.trim().isNotEmpty;

  /// نص الإرشاد المعروض فوق الزر — نص موجَّه للمستخدم النهائي،
  /// وليس نص المزوّد الخام (المصاغ لمن يستدعي الـ API).
  ///
  /// التنبيه في السطر الثاني مهم: الزر يفتح واتساب على هذا الجهاز، فإن كان
  /// الحساب المفتوح لرقم مختلف عن الرقم المُدخل، يُسجَّل الاشتراك للرقم الخطأ
  /// ولن يصل الرمز.
  String get displayInstruction =>
      'إذا لم يصلك رمز التحقق اضغط هنا\n'
      '(يجب أن يكون حساب الواتساب للرقم الذي أدخلته مفتوحاً على هذا الجهاز)';

  /// يفتح واتساب على رقم الخدمة مع كلمة الاشتراك معبأة مسبقاً.
  Future<bool> openWhatsApp() async {
    final link = waLink;
    if (link == null || link.trim().isEmpty) return false;
    try {
      return await launchUrl(
        Uri.parse(link),
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {
      return false;
    }
  }
}

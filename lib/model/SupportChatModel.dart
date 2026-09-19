import 'dart:typed_data';

import 'package:customer/core/services/support_http.dart';
import 'package:customer/linkApi.dart';

/// طبقة REST لـ«تواصل مع الدعم» — بديل السوكِت عند انقطاعه، ومصدر السجل والترقيم دائماً.
///
/// تخدم **الزبون والسائق** معاً: [SupportHttp] يختار طبقة النقل وتجديد التوكن حسب دور
/// الجلسة، و[Applink] يختار قاعدة المسار (`/customer/support/*` أو `/driver/support/*`).
/// الطرف لا يمرّر معرّف المحادثة في أي نداء: الخادم يشتقّه من التوكن.
class SupportChatModel {
  SupportChatModel([SupportHttp? http]) : http = http ?? SupportHttp.forCurrentRole();

  final SupportHttp http;

  /// جلب أو إنشاء محادثتي مع أحدث صفحة رسائل في نداء واحد.
  Future<dynamic> getConversation({int limit = 30}) {
    return http.postJson(Applink.supportConversation, {'limit': limit});
  }

  /// [before] للتصفح إلى الأقدم، [after] للّحاق بعد انقطاع. النتيجة تصاعدية دائماً.
  Future<dynamic> getMessages({String? before, String? after, int limit = 30}) {
    final query = <String, String>{
      'limit': '$limit',
      if (before != null && before.isNotEmpty) 'before': before,
      if (after != null && after.isNotEmpty) 'after': after,
    };
    final url = Uri.parse(
      Applink.supportMessages,
    ).replace(queryParameters: query).toString();
    return http.getJson(url);
  }

  /// [clientId] يجب أن يبقى ثابتاً في كل إعادة محاولة — الخادم يمنع التكرار به.
  Future<dynamic> sendMessage({
    required String clientId,
    String? text,
    Map<String, dynamic>? attachment,
  }) {
    return http.postJson(Applink.supportSendMessage, {
      'clientId': clientId,
      if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
      'attachment': ?attachment,
    });
  }

  Future<dynamic> markRead({String? upToMessageId}) {
    return http.postJson(Applink.supportMarkRead, {
      if (upToMessageId != null && upToMessageId.isNotEmpty)
        'upToMessageId': upToMessageId,
    });
  }

  Future<dynamic> unreadCount() => http.getJson(Applink.supportUnreadCount);

  /// رفع الصورة أولاً ثم إرسال رابطها في الرسالة — لا بيانات ثنائية عبر السوكِت.
  /// اسم الملف على الخادم مُولَّد (UUID)، فلا يُمرَّر اسم من العميل.
  ///
  /// ⚠️ لا تستعمل `Crud.postDataWithFile` (المفرد) هنا: كان يفلتر البايتات بـ
  /// `runtimeType == Uint8List` وهي مقارنة لا تتحقّق أبداً (`Uint8List` صنف مجرّد،
  /// والنوع الفعلي `_Uint8List`/`_Uint8ArrayView`/`NativeUint8List`)، فكان الملف يُحذف
  /// بصمت ويردّ الخادم «لم يتم إرسال أي صورة».
  Future<dynamic> uploadAttachment({required Uint8List bytes}) {
    return http.postImage(Applink.supportAttachments, bytes);
  }
}

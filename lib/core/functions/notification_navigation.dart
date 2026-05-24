import 'package:customer/view/screen/orderDetailSecrren.dart';
import 'package:flutter/foundation.dart';

/// يفتح [orderDetailSecrren] عندما تحتوي بيانات الإشعار (FCM أو قائمة الإشعارات) على طلب.
/// يدعم `orderNumber` / `order_number` و `orderId` / `order_id` كما تصل من FCM.
///
/// إن وُجد [notificationDocumentId] (مثل `_id` من سجل الإشعار في القائمة) وكان مساوياً
/// لقيمة `orderId` في الحمولة، يُزال `orderId` لأنه غالباً خطأ (تم تخزين معرف الإشعار بدل الطلب).
/// يعيد `true` إذا تم التوجيه إلى تفاصيل الطلب.
bool navigateToOrderFromNotificationData(
  Map<String, dynamic>? data, {
  String? notificationDocumentId,
}) {
  if (data == null || data.isEmpty) return false;

  final map = Map<String, dynamic>.from(data);
  final nid = notificationDocumentId?.trim();
  if (nid != null && nid.isNotEmpty) {
    final oid = map['orderId'] ?? map['order_id'];
    final os = oid?.toString().trim();
    if (os != null && os.isNotEmpty && os == nid) {
      map.remove('orderId');
      map.remove('order_id');
      if (kDebugMode) {
        debugPrint(
          '[OrderDetailDiag] orderId matched notification _id — removed; '
          'use orderNumber if present',
        );
      }
    }
  }

  final num = map['orderNumber'] ?? map['order_number'];
  final oid = map['orderId'] ?? map['order_id'];
  final hasNum = num != null && num.toString().trim().isNotEmpty;
  final hasOid = oid != null && oid.toString().trim().isNotEmpty;
  if (!hasNum && !hasOid) return false;

  if (kDebugMode) {
    debugPrint(
      '[OrderDetailDiag] notification payload keys=${map.keys.toList()} '
      'orderNumber=${hasNum ? num : "-"} orderId=${hasOid ? oid : "-"}',
    );
  }

  orderDetailSecrren.navigateWithOrderPayload(map);
  return true;
}

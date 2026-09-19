import 'package:customer/core/constant/assets/icons.dart';
import 'package:flutter/material.dart';

String _statusKey(status) => status?.toString().trim() ?? '';

/// حالات التسليم الفعلي — «واصل جزئي» تسليم حقيقي بمحتوى معدَّل.
/// مصدر الحقيقة الوحيد: يستخدمه تبويب «مكتمل» وبوابة التقييم معاً فلا يتفرّق التعريفان.
const Set<String> kDeliveredOrderStatuses = <String>{'تم التسليم', 'واصل جزئي'};

bool isDeliveredStatus(dynamic status) =>
    kDeliveredOrderStatuses.contains(_statusKey(status));

Color statusOrderColors(status) {
  switch (_statusKey(status)) {
    case "جديد":
      return Color(0xffE1B400);
    case "قيد التجهيز":
      return Color(0xff1634F3);
    case "تم التجهيز":
      return Color(0xff1634F3);
    case "قيد التوصيل":
      return Color(0xffF39316);
    case "مع السائق":
      return Color(0xffF39316);
    case "تم التسليم":
      return Color(0xff12B76A);
    case "واصل جزئي":
      return Color(0xff0E9F6E);
    case "مرفوض":
      return Color(0xffF31616);
    default:
      return Colors.black;
  }
}

/// حجم موحّد لشارة الحالة فوق أيقونة الطلب (قائمة الطلبات).
const double _kOrderStatusBadgeSize = 20;

Widget statusOrderIcon(status) {
  final s = _statusKey(status);
  switch (s) {
    case "جديد":
      return _badgeImage(AppIcons.newOrderStatus);
    case "قيد التجهيز":
      return _badgeImage(AppIcons.PreparationOrderStatus);

    case "تم التجهيز":
      return _badgeImage(AppIcons.PreparationOrderStatus);
    case "قيد التوصيل":
      return _badgeImage(AppIcons.DeliveryOrderStatus);

    case "مع السائق":
      return _badgeImage(AppIcons.DeliveryOrderStatus);

    case "تم التسليم":
      return _badgeImage(AppIcons.SuccessOrderStatus);

    case "واصل جزئي":
      return _badgeImage(AppIcons.SuccessOrderStatus);

    case "مرفوض":
      // دائرة بلون الحالة + أيقونة بيضاء بنفس قطر باقي الشارات
      return SizedBox(
        width: _kOrderStatusBadgeSize,
        height: _kOrderStatusBadgeSize,
        child: CircleAvatar(
          radius: _kOrderStatusBadgeSize / 2,
          backgroundColor: statusOrderColors("مرفوض"),
          child: const Icon(
            Icons.close_rounded,
            color: Colors.white,
            size: 12,
          ),
        ),
      );
    default:
      return SizedBox(width: _kOrderStatusBadgeSize, height: _kOrderStatusBadgeSize);
  }
}

Widget _badgeImage(String asset) {
  return SizedBox(
    width: _kOrderStatusBadgeSize,
    height: _kOrderStatusBadgeSize,
    child: Image.asset(asset, width: _kOrderStatusBadgeSize, height: _kOrderStatusBadgeSize, fit: BoxFit.contain),
  );
}

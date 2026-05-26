import 'package:flutter/material.dart';

Color statusOrderColors(status) {
  switch (status) {
    case "جديد":
      return Color(0xff25273B);
    case "قيد التجهيز":
      return Color(0xffA8A8A8);
    case "تم التجهيز":
      return Color(0xff25273B);
    case "قيد التوصيل":
      return Colors.blue;
    case "مع السائق":
      return Color(0xffE9B824);
    case "تم التسليم":
      return Color(0xff008000);
    case "مرفوض":
      return Colors.red;
    default:
      return Colors.black;
  }
}

/// تسمية عربية موحّدة لعرض حالة الطلب (واجهة السائق).
String statusName(dynamic status) {
  final s = status?.toString().trim() ?? '';
  switch (s) {
    case 'جديد':
      return 'جديد';
    case 'قيد التجهيز':
      return 'قيد التجهيز';
    case 'تم التجهيز':
      return 'جاهز للاستلام';
    case 'قيد التوصيل':
      return 'قيد الاستلام';
    case 'مع السائق':
      return 'قيد التوصيل';
    case 'تم التسليم':
      return 'واصل';
    case 'مرفوض':
      return 'مرفوض';
    default:
      if (s.isEmpty) return 'غير محدد';
      return s;
  }
}

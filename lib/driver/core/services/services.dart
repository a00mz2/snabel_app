// ignore_for_file: avoid_print

// بعد دمج تطبيق السائق داخل تطبيق الزبون نستخدم نسخة واحدة من Myservices
// و myServices — تُعرَّف في package:customer/core/services/services.dart.
// كل الـimports القديمة من package:customer/driver/core/services/services.dart
// تستمر بالعمل عبر إعادة التصدير هذه.
export 'package:customer/core/services/services.dart';

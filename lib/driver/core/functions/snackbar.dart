// بعد دمج تطبيق السائق داخل تطبيق الزبون، نستخدم نسخة AppSnackBar الواحدة
// المعرّفة في package:customer/core/functions/snackbar.dart.
// النسخة الموحَّدة قوية ضدّ حالات Overlay غير الجاهز، وتلجأ تلقائياً
// إلى ScaffoldMessenger كبديل (هذا يحلّ مشكلة "لا تظهر رسالة خطأ" في شاشة دخول السائق).
//
// كل الـimports القديمة من package:customer/driver/core/functions/snackbar.dart
// تستمر بالعمل عبر إعادة التصدير هذه — لا حاجة لتعديل أيّ كود سائق آخر.
export 'package:customer/core/functions/snackbar.dart';

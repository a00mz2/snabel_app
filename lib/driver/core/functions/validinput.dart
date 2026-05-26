String? validInput(
  String val,
  int min,
  int max,
  String type, {
  bool isrequired = true,
}) {
  // تحقق من الحقل الفارغ أولاً
  if (val.isEmpty) {
    if (!isrequired) {
      return null; // الحقل اختياري فارغ => لا يوجد خطأ
    } else if (type != "percentage") {
      return "لا يمكن ترك الحقل فارغ"; // إلزامي فارغ => خطأ
    }
  }

  // تحقق اسم المستخدم
  if (type == "username") {
    if (val.isEmpty && isrequired) {
      return "يرجى ادخال اسم المستخدم";
    }
  }

  // تحقق الرقم
  if (type == "phone" && val.isNotEmpty) {
    if (val.length < min) {
      return "لا يمكن ان يكون حقل الرقم اقل من $min رقم";
    }
    if (!val.startsWith("07")) {
      return "رقم الهاتف غير صالح يجب ان يبد ب 07 ";
    }
  }

  // تحقق النسبة المئوية
  if (type == "percentage" && val.isNotEmpty) {
    final parsed = int.tryParse(val);
    if (parsed == null || parsed > 99) {
      return "لا يمكن أن تكون اكبر من 99 ";
    }
  }

  // تحقق الروابط
  if (type == "url" && val.isNotEmpty) {
    final Uri? uri = Uri.tryParse(val);
    if (uri == null || !uri.hasScheme || !uri.hasAuthority) {
      return "الرابط غير صالح";
    }
  }

  // تحقق البريد الالكتروني
  if (type == "email" && val.isNotEmpty) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(val)) {
      return "البريد الالكتروني غير صالح";
    }
  }

  return null; // لا يوجد خطأ
}

import 'package:customer/driver/linkApi.dart';

/// يبني رابطاً صالحاً لصورة مخزّنة على الخادم (مسار نسبي أو رابط كامل).
String resolveServerImageUrl(dynamic raw) {
  if (raw == null) return '';
  final s = raw.toString().trim();
  if (s.isEmpty || s == 'null') return '';
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  var path = s;
  if (path.startsWith('/')) path = path.substring(1);
  // يطابق الباك اند: التخزين `customers/...` والعرض الثابت تحت `/customersImages/`
  const customersPrefix = 'customers/';
  if (path.startsWith(customersPrefix)) {
    path = 'customersImages/${path.substring(customersPrefix.length)}';
  }
  return '${DriverApplink.serverImage}$path';
}

/// صور إثبات التسليم تُخزَّن `orders/<file>` وتُعرض تحت `/public/uploads/` (نفس لوحة الإدارة).
String resolveOrderProofUrl(dynamic raw) {
  if (raw == null) return '';
  final s = raw.toString().trim();
  if (s.isEmpty || s == 'null') return '';
  if (s.startsWith('http://') || s.startsWith('https://')) return s;
  final path = s.startsWith('/') ? s.substring(1) : s;
  return '${DriverApplink.serverImage}public/uploads/$path';
}

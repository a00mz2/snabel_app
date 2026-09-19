/// أسباب رفض الطلب — مطابقة لخريطة الخادم `compat/constants/orderRejectionReasons.cjs`.
/// النسخة نفسها في اللوحة: `snabel_admin/lib/core/constant/order_rejection_reasons.dart`
/// — حدّث الملفات الثلاثة معاً. يستعملها تطبيق الزبون (عرض) وتطبيق السائق (اختيار + عرض).
class RejectionReason {
  const RejectionReason(this.code, this.label);

  final String code;
  final String label;
}

/// أسباب السائق (تظهر في ورقة الرفض بتطبيق السائق).
const List<RejectionReason> kDriverRejectionReasons = <RejectionReason>[
  RejectionReason('store_closed', 'المحل مغلق'),
  RejectionReason('customer_refused', 'الزبون رفض الاستلام'),
  RejectionReason('no_cash', 'لا يوجد مبلغ للتسديد'),
  RejectionReason('wrong_address', 'عنوان خاطئ / تعذر الوصول'),
  RejectionReason('customer_unreachable', 'تعذر التواصل مع الزبون'),
  RejectionReason('other', 'أخرى'),
];

/// أسباب موظف اللوحة (للعرض فقط في التطبيقات).
const List<RejectionReason> kStaffRejectionReasons = <RejectionReason>[
  RejectionReason('out_of_stock', 'نفاد المنتج'),
  RejectionReason('customer_request', 'بطلب من الزبون'),
  RejectionReason('duplicate_or_suspicious', 'طلب مكرر / مشبوه'),
  RejectionReason('credit_limit', 'تجاوز الحد المالي'),
  RejectionReason('other', 'أخرى'),
];

const String kRejectionOtherCode = 'other';
const int kRejectionDetailsMaxLength = 300;

/// التسمية العربية لأي كود؛ يعيد الكود نفسه إن كان مجهولاً.
String rejectionReasonLabelAr(String? code) {
  final c = (code ?? '').trim();
  if (c.isEmpty) return '—';
  if (c == 'customer_cancelled') return 'إلغاء من الزبون';
  for (final r in kDriverRejectionReasons) {
    if (r.code == c) return r.label;
  }
  for (final r in kStaffRejectionReasons) {
    if (r.code == c) return r.label;
  }
  return c;
}

/// نص العرض من كائن `rejection` القادم من الخادم (يفضّل `label` ثم الخريطة المحلية).
String rejectionDisplayLabel(dynamic rejection) {
  if (rejection is! Map) return '—';
  final label = rejection['label']?.toString().trim() ?? '';
  if (label.isNotEmpty) return label;
  return rejectionReasonLabelAr(rejection['code']?.toString());
}

/// «بواسطة: الاسم (الدور)» من `rejection.by`.
String rejectionByLabelAr(dynamic rejection) {
  if (rejection is! Map) return '';
  final by = rejection['by'];
  if (by is! Map) return '';
  final name = by['name']?.toString().trim() ?? '';
  final role = by['role']?.toString().trim() ?? '';
  final roleAr = switch (role) {
    'driver' => 'السائق',
    'admin' => 'الإدارة',
    'customer' => 'الزبون',
    _ => '',
  };
  if (name.isEmpty && roleAr.isEmpty) return '';
  if (name.isEmpty) return roleAr;
  if (roleAr.isEmpty) return name;
  return '$name ($roleAr)';
}

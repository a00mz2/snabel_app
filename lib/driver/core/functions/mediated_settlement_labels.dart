// يطابق `SETTLEMENT_STATUS_LABELS_AR` في `driverSettlementStatuses.cjs` (مشروع Tahouna).

/// تسمية عربية لحالة طلب التحصيل/التسديد من رمز الحالة.
String mediatedSettlementStatusLabelAr(String? statusCode) {
  final s = statusCode?.trim() ?? '';
  switch (s) {
    case 'pending_driver_approval':
      return 'بانتظار موافقة السائق';
    case 'pending_receipt':
      return 'بانتظار الاستلام';
    case 'awaiting_admin_settlement':
      return 'في ذمة السائق';
    case 'settled_to_admin':
      return 'تم التسديد للإدارة';
    case 'rejected':
      return 'مرفوض';
    case 'cancelled':
      return 'ملغي';
    // ترحيل حالات قديمة (LEGACY_STATUS_MAP)
    case 'pending':
      return 'بانتظار موافقة السائق';
    case 'approved':
      return 'بانتظار الاستلام';
    case 'completed':
      return 'في ذمة السائق';
    default:
      if (s.isEmpty) return '—';
      return s;
  }
}

/// يفضّل `statusLabelAr` من الـ API إن وُجد، وإلا يترجم `status`.
String mediatedSettlementDisplayLabelAr(Map<String, dynamic> data) {
  final ar = data['statusLabelAr']?.toString().trim();
  if (ar != null && ar.isNotEmpty) return ar;
  final code = data['status']?.toString();
  return mediatedSettlementStatusLabelAr(code);
}

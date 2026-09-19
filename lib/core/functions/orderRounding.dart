/// [round-250] قاعدة تقريب إجمالي الطلب — نسخة العميل من
/// `api/src/compat/services/orderTotals.cjs` (مصدر الحقيقة هو الخادم؛ هذه للمعاينة فقط).
///
/// الإجمالي الذي يدفعه الزبون = (مجموع الأصناف + رسوم التوصيل) مقرَّباً **للأعلى**
/// إلى أقرب مضاعف للخطوة (250 د.ع افتراضياً؛ الخادم يعيد `roundingStep` في
/// معاينات السلة والنماذج ليُفضَّل على الثابت). الفرق محفوظ في `roundingAdjustment`.
library;

/// الخطوة الافتراضية إن لم يرسل الخادم غيرها.
const int kOrderRoundingStep = 250;

int _toInt(num? v) {
  if (v == null) return 0;
  if (v is double && !v.isFinite) return 0;
  return v.round();
}

/// الخطوة من رد الخادم إن كانت صالحة وإلا الافتراضي.
int roundingStepOrDefault(dynamic raw) {
  final n = raw is num ? raw : num.tryParse('${raw ?? ''}');
  if (n == null || !n.isFinite || n <= 0) return kOrderRoundingStep;
  return n.round();
}

/// تقريب للأعلى إلى مضاعف الخطوة؛ الصفر والسالب يعودان كما هما.
int roundUpToStep(num? amount, {int step = kOrderRoundingStep}) {
  final n = _toInt(amount);
  if (n <= 0) return n;
  final s = step > 0 ? step : kOrderRoundingStep;
  return ((n + s - 1) ~/ s) * s;
}

/// نتيجة معاينة إعادة الحساب بعد تعديل (تطابق `recomputeAfterDelta` في الخادم).
class OrderTotalPreview {
  const OrderTotalPreview({
    required this.previousTotal,
    required this.base,
    required this.roundingAdjustment,
    required this.totalPrice,
    required this.delta,
  });

  final int previousTotal;

  /// الإجمالي بلا تقريب بعد التعديل (قد يكون سالباً — الخادم يرفضه).
  final int base;
  final int roundingAdjustment;
  final int totalPrice;

  /// ما يتحرّك فعلاً في المحفظة أو مبلغ التحصيل (الإجمالي الجديد − السابق).
  final int delta;
}

/// إعادة حساب الإجمالي بعد تغيير بقيمة [lineDelta] على الأصناف:
/// يُطرح التقريب السابق أولاً ثم يُقرَّب من جديد، والتخفيض لا يرفع الإجمالي أبداً.
OrderTotalPreview previewAfterDelta({
  required num? currentTotal,
  num? currentRounding,
  required num? lineDelta,
  int step = kOrderRoundingStep,
}) {
  final prev = _toInt(currentTotal);
  final prevRounding = _toInt(currentRounding);
  final ld = _toInt(lineDelta);
  final base = prev - prevRounding + ld;

  int total;
  if (ld == 0) {
    total = prev;
  } else {
    total = roundUpToStep(base, step: step);
    if (ld < 0 && total > prev) total = prev;
  }
  final pad = total - base;
  return OrderTotalPreview(
    previousTotal: prev,
    base: base,
    roundingAdjustment: pad > 0 ? pad : 0,
    totalPrice: total,
    delta: total - prev,
  );
}

/// فرق المحفظة المتوقع لتعديل واحد. إن غاب إجمالي الطلب تعود قيمة البند الخام.
double walletDeltaPreview({
  required num? orderTotal,
  num? orderRounding,
  required num lineDelta,
  int step = kOrderRoundingStep,
}) {
  if (orderTotal == null) return lineDelta.toDouble();
  return previewAfterDelta(
    currentTotal: orderTotal,
    currentRounding: orderRounding,
    lineDelta: lineDelta,
    step: step,
  ).delta.toDouble();
}

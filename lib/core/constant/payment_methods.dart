// طريقة دفع الطلب — مرآة `paymentMethod` في `OrderModel.js` على الخادم.
// مشترك بين تطبيق الزبون وتطبيق السائق (نفس الحزمة).

/// آجل: يُخصم من محفظة المتجر عند الإنشاء ويُعاد عند الرفض أو الحذف.
const String kPaymentWallet = 'wallet';

/// نقد عند الاستلام: لا يمسّ المحفظة إطلاقاً — لا دين ولا إرجاع.
const String kPaymentCash = 'cash';

bool isCashPaymentMethod(String? method) => method == kPaymentCash;

/// الطلبات المنشأة قبل إضافة الحقل تُقرأ «آجل» وهو سلوكها الفعلي.
String paymentMethodLabelAr(String? method) =>
    isCashPaymentMethod(method) ? 'دفع عند الاستلام' : 'آجل (من المحفظة)';

String paymentMethodShortLabelAr(String? method) =>
    isCashPaymentMethod(method) ? 'نقدي' : 'آجل';

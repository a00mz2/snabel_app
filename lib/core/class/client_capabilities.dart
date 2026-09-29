/// [price-decimal] ما يعلنه هذا التطبيق للخادم عن قدراته.
///
/// الخادم يرسل الأسعار **بكسورها** فقط لعميل يعلن `price-decimals`، ويقرّبها
/// لغيره — لأن النسخ المنشورة قبل 1.0.7 كانت تحلّل السعر `int` وتنهار على
/// `double`. هذه النسخة تحتمل الكسور في كل شاشاتها (`formatNumber(num?)`،
/// `totalItemPrice` بنوع `num`، …) فتعلن ذلك في كل طلب.
///
/// الاسم والقيمة يطابقان `CLIENT_CAPABILITIES_HEADER` و
/// `PRICE_DECIMALS_CAPABILITY` في `api/src/compat/services/moneyPolicy.cjs`.
library;

const String kClientCapabilitiesHeader = 'X-Client-Capabilities';
const String kPriceDecimalsCapability = 'price-decimals';

/// يُدمج في ترويسات كل طلب (جهتا الزبون والسائق، ومسارات الرفع والتجديد).
const Map<String, String> clientCapabilityHeaders = {
  kClientCapabilitiesHeader: kPriceDecimalsCapability,
};

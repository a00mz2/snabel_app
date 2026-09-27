import 'package:intl/intl.dart';

/// [price-decimal] يقبل `num` لا `int`.
///
/// كان توقيعه `int`، وكل مستدعٍ يمرّر قيمة `dynamic` من JSON، فسعر عشري كان
/// يرمي `double is not a subtype of int` ويترك مستطيلاً رمادياً مكان العنصر.
/// يعرض الكسر بخانتين إن وُجد، وبلا كسور إن كان الرقم صحيحاً.
String formatNumber(num? originalNumber) => formatNumberNum(originalNumber ?? 0);

String formatNumberNum(num number, {int? decimalDigits}) {
  final digits = decimalDigits ?? ((number % 1 == 0) ? 0 : 2);

  final formatted = NumberFormat.simpleCurrency(
    name: "",
    decimalDigits: digits,
  ).format(number);

  return formatted;
}

num reverseSignNumberNum(num value) {
  return -value;
}

import 'package:intl/intl.dart';

/// [price-decimal] يقبل `num` لا `int` — انظر نسخة الزبون.
///
/// جهة السائق لم تكن تملك صيغة متسامحة إطلاقاً، فكانت عاجزة عن عرض أي كسر.
String formatNumber(num? originalNumber) => formatNumberNum(originalNumber ?? 0);

/// خانتان عند الكسر، وبلا كسور عند الرقم الصحيح.
String formatNumberNum(num number, {int? decimalDigits}) {
  final digits = decimalDigits ?? ((number % 1 == 0) ? 0 : 2);
  return NumberFormat.simpleCurrency(name: "", decimalDigits: digits)
      .format(number);
}

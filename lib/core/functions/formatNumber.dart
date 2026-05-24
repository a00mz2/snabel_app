import 'package:intl/intl.dart';

String formatNumber(int originalNumber) {
  String formattedNumber = NumberFormat.simpleCurrency(
    name: "",
    decimalDigits: 0,
  ).format(originalNumber);

  return formattedNumber.toString();
}

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

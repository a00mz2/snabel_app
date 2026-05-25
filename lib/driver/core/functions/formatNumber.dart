import 'package:intl/intl.dart';

String formatNumber(int originalNumber) {
  String formattedNumber =
      NumberFormat.simpleCurrency(name: "", decimalDigits: 0)
          .format(originalNumber);

  return formattedNumber.toString();
}

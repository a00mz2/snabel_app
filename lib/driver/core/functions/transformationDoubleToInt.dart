// ignore_for_file: file_names

import 'package:customer/driver/core/constant/size.dart';

int doubleToInt(number) {
  if (number > 0) {
    double result = number / limit;
    if (result % 1 == 0) {
      return result.toInt();
    } else {
      return (result + 1).toInt();
    }
  } else {
    return 1;
  }
}

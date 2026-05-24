// ignore_for_file: camel_case_types, file_names

import 'package:get/get.dart';
import '../core/class/crud.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(Crud());
  }
}

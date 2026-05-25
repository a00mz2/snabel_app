// ignore_for_file: camel_case_types, file_names

import 'package:get/get.dart';
import '../core/class/crud.dart';
import 'package:customer/driver/core/class/crud.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    // Crud الخاص بالزبون
    Get.put(Crud());
    // DriverCrud الخاص بالسائق — اسم مختلف ليتجنّب تصادم GetX (الذي يبني المفتاح من اسم الـclass).
    // نسجّله مبكراً حتى تجده موديلات السائق عبر Get.find().
    Get.put(DriverCrud());
  }
}

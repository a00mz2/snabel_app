// ignore_for_file: prefer_typing_uninitialized_variables

import 'package:customer/driver/controller/HomeController.dart';
import 'package:customer/driver/controller/driver_settlement_detail_controller.dart';
import 'package:customer/driver/controller/driver_cod_collections_controller.dart';
import 'package:customer/driver/controller/driver_wallet_controller.dart';
import 'package:customer/driver/controller/LoginController.dart';
import 'package:customer/driver/controller/MainController.dart';
import 'package:customer/driver/controller/NotificationsController.dart';
import 'package:customer/driver/controller/OrderDetelsController.dart';
import 'package:customer/driver/controller/ProfileController.dart';
import 'package:customer/driver/controller/SplashController.dart';
import 'package:customer/driver/controller/orders_controller.dart';
import 'package:get/get.dart';

class DriverLoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DriverLoginController());
  }
}

class DriverSplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(DriverSplashController());
  }
}

class DriverMainBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MainControlIer());
    Get.put(DriverHomeController());
    Get.put(DriverOrdersController());
    Get.put(DriverWalletController());
    Get.put(DriverProfileController());
  }
}

class DriverSettlementDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DriverSettlementDetailController());
  }
}

// [cod-collect] مبالغ الدفع عند الاستلام (شاشة مستقلة)
class DriverCodCollectionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DriverCodCollectionsController());
  }
}

class OrderDetelsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OrderDetelsController());
  }
}

class DriverNotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DriverNotificationsController(), fenix: true);
  }
}

// ignore_for_file: prefer_typing_uninitialized_variables, empty_catches

import 'package:customer/controller/CartController.dart';
import 'package:customer/controller/HomeController.dart';
import 'package:customer/controller/LoginController.dart';
import 'package:customer/controller/MainController.dart';
import 'package:customer/controller/NotificationsController.dart';
import 'package:customer/controller/OrdersController.dart';
import 'package:customer/controller/ProductsDetailController.dart';
import 'package:customer/controller/ProfileController.dart';
import 'package:customer/controller/SearchController.dart';
import 'package:customer/controller/SectionProductsController.dart';
import 'package:customer/controller/SectionsController.dart';
import 'package:customer/controller/SignUpControler.dart';
import 'package:customer/controller/SplashController.dart';
import 'package:customer/controller/WalletController.dart';
import 'package:customer/controller/orderDetailController.dart';
import 'package:customer/controller/PinnedOrderDetailController.dart';
import 'package:customer/controller/PinnedOrderEditController.dart';
import 'package:customer/controller/PinnedOrdersListController.dart';
import 'package:customer/controller/ContactUsController.dart';
import 'package:customer/controller/ForgotPasswordController.dart';
import 'package:get/get.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(LoginController());
  }
}

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ForgotPasswordController(), fenix: true);
  }
}

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SplashController());
  }
}

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SignUpControler(), fenix: true);
  }
}

class SearchingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SearchingController(), fenix: true);
  }
}

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationsController(), fenix: true);
  }
}

class SectionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SectionsController(), fenix: true);
  }
}

class SectionProductsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SectionProductsController());
  }
}

class ProductsDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final productId = args['productId'];
    Get.put(ProductsDetailController(productId));
  }
}

class SendOrderBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CartController(), fenix: true);
  }
}

class OrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final orderNumber = OrderDetailPendingRouteArgs.take() ??
        resolveOrderIdentifierFromArguments(args) ??
        '';
    // إزالة المتحكم السابق حتى لا تبقى بيانات طلب سابق عند فتح طلب آخر
    if (Get.isRegistered<OrderDetailController>()) {
      Get.delete<OrderDetailController>(force: true);
    }
    Get.put(OrderDetailController(orderNumber));
  }
}

class UpdateDataProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}

class PinnedOrdersBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => PinnedOrdersListController(), fenix: true);
  }
}

class PinnedOrderDetailBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final id = args is Map ? args['pinnedOrderId']?.toString() ?? '' : '';
    Get.lazyPut(() => PinnedOrderDetailController(id), fenix: true);
  }
}

class PinnedOrderEditBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;
    final id = args is Map ? args['pinnedOrderId']?.toString() ?? '' : '';
    Get.lazyPut(() => PinnedOrderEditController(id), fenix: true);
  }
}

class ContactUsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ContactUsController(), fenix: true);
  }
}

class MainBinding extends Bindings {
  @override
  void dependencies() {
    final args = Get.arguments;

    var current = 0;

    try {
      current = args['current'];
    } catch (e) {}

    Get.put(MainController(current: current));
    Get.lazyPut(() => HomeController(), fenix: true);
    Get.create(() => CartController());
    Get.lazyPut(() => OrdersController(), fenix: true);
    Get.lazyPut(() => WalletController(), fenix: true);
    Get.lazyPut(() => ProfileController(), fenix: true);
  }
}

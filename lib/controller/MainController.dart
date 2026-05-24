// ignore_for_file: file_names, avoid_print
import 'package:customer/controller/CartController.dart';
import 'package:customer/controller/OrdersController.dart';
import 'package:customer/controller/WalletController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/model/MainModel.dart';
import 'package:customer/model/NotificationsModel.dart';
import 'package:get/get.dart';

class MainController extends GetxController {
  NotificationsModel notificationsModel = NotificationsModel(Get.find());

  final CartController cartController = Get.put(CartController());
  final OrdersController ordersController = Get.put(OrdersController());
  final WalletController walletController = Get.put(WalletController());

  RxInt countNotifications = 0.obs;

  final int current;
  MainController({this.current = 0});

  MainModel model = MainModel(Get.find());
  var currentIndex = 0.obs;

  void changePage(int index) {
    currentIndex.value = index;
    if (index == 1) {
      cartController.getCart();
    } else if (index == 2) {
      walletController.getTransactions();
    } else if (index == 3) {
      ordersController.getOrders();
    }
  }

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = current;
    print("✅ staerted MainController");
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 STOP MainController");
  }

  getUnreadCount() async {
    print("===================");
    var response = await notificationsModel.getUnreadCount();
    if (handlingData(response) == StatusRequest.success) {
      final m = tryResponseMap(response);
      final c = m?['unreadCount'];
      if (c is int) {
        countNotifications.value = c;
      } else if (c is num) {
        countNotifications.value = c.toInt();
      }
    }
  }
}

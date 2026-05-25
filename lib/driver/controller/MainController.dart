import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/model/NotificationsModel.dart';
import 'package:get/get.dart';

class MainControlIer extends GetxController {
  NotificationsModel notificationsModel = NotificationsModel(Get.find());

  RxInt countNotifications = 0.obs;

  final currentIndex = 0.obs;
  void changeTab(int index) {
    currentIndex.value = index;
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      final c = args['current'];
      if (c is int && c >= 0 && c <= 3) {
        currentIndex.value = c;
      }
    }
  }

  getUnreadCount() async {
    var response = await notificationsModel.getUnreadCount();
    if (handlingData(response) == StatusRequest.success && response is Map) {
      final n = response['unreadCount'];
      if (n is int) {
        countNotifications.value = n;
      } else if (n is num) {
        countNotifications.value = n.toInt();
      } else {
        countNotifications.value = int.tryParse(n?.toString() ?? '') ?? 0;
      }
    }
  }
}

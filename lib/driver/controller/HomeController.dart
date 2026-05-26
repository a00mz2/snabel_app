// ignore_for_file: file_names, avoid_print

import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/core/services/services.dart';
import 'package:customer/driver/model/OrderModel.dart';
import 'package:get/get.dart';

class DriverHomeController extends GetxController {
  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  OrderModel orderModel = OrderModel(Get.find());

  @override
  void onInit() {
    super.onInit();
    print("start Home");

    getOrders();
  }

  @override
  void onClose() {
    super.onClose();
    print("stop Home");
  }

  //===================data=========================
  RxInt totalOrders = 0.obs;
  RxInt nweOrders = 0.obs;

  RxMap statsOrder = {}.obs;

  var listOrder = [].obs;
  //===================Function=========================
  int _intFrom(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return 0;
  }

  getOrders() async {
    statusRequest.value = StatusRequest.loading;
    var response = await orderModel.getOrders();

    if (handlingData(response) == StatusRequest.success && response is Map) {
      final map = response;
      listOrder.value = map['orders'] ?? [];
      totalOrders.value = _intFrom(map['totalOrders']);

      final stats = map['stats'];
      Map<String, dynamic> byStatus = {};
      if (stats is Map && stats['byStatus'] is Map) {
        byStatus = Map<String, dynamic>.from(
          (stats['byStatus'] as Map).map(
            (k, v) => MapEntry(k.toString(), v),
          ),
        );
      }
      statsOrder.value = byStatus;

      nweOrders.value =
          _intFrom(byStatus['قيد التجهيز']) + _intFrom(byStatus['تم التجهيز']);
    } else {
      AppSnackBar.error(
        apiErrorMessage(response, 'خطأ أثناء جلب البيانات'),
      );
    }

    statusRequest.value = handlingData(response);
    statusCode.value = handlingStatusCode(response);
  }

  logOut() async {
    await myServices.sharedPreferences.clear();
    await myServices.sharedPreferences.setString('router', '/');
    Get.offAllNamed("/");
  }
}

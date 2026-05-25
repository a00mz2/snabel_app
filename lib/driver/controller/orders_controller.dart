import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/model/OrderModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverOrdersController extends GetxController {
  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;
  Rx<StatusRequest> statusRequestPagination = StatusRequest.success.obs;

  OrderModel data = OrderModel(Get.find());

  //================pagnation============
  int page = 1;
  late ScrollController scrollController;
  RxBool isLoadingMore = false.obs;
  RxBool hasMore = true.obs;
  //=====================================

  var listOrder = [].obs;

  RxInt statusTabBar = 0.obs;
  var status = ["all"];

  @override
  void onInit() {
    super.onInit();
    scrollController = ScrollController();
    scrollController.addListener(_onScroll);
    getOrders();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (isLoadingMore.value || !hasMore.value) return;
    final position = scrollController.position;
    if (position.atEdge && position.pixels == position.maxScrollExtent) {
      loadMore();
    }
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value) return;
    if (!hasMore.value) return;

    isLoadingMore.value = true;
    try {
      page += 1;
      statusRequestPagination.value = StatusRequest.loading;
      await getOrders(append: true);
    } finally {
      isLoadingMore.value = false;
    }
  }

  selcteingStatusTabBar(int index) {
    statusTabBar.value = index;
    switch (index) {
      case 0:
        status = ["all"];
        break;
      case 1:
        status = ['قيد التجهيز'];
        break;
      case 2:
        status = ["تم التجهيز"];
        break;
      case 3:
        status = ["قيد التوصيل"];
        break;
      case 4:
        status = ["مع السائق"];
        break;
      case 5:
        status = ["تم التسليم"];
        break;
      case 6:
        status = ["مرفوض"];
        break;
      default:
        status = ["all"];
        break;
    }

    page = 1;
    hasMore.value = true;
    getOrders();
  }

  getOrders({bool append = false}) async {
    if (append) {
      statusRequestPagination.value = StatusRequest.loading;
    } else {
      page = 1;
      hasMore.value = true;
      statusRequest.value = StatusRequest.loading;
    }

    var response = await data.getOrders(status: status, page: page);

    if (handlingData(response) == StatusRequest.success && response is Map) {
      List<dynamic> items = [];
      final raw = response['orders'];
      if (raw is List) {
        items = List<dynamic>.from(raw);
      }

      if (append) {
        listOrder.addAll(items);
        if (items.isEmpty) {
          hasMore.value = false;
        }
      } else {
        listOrder.value = items;
      }
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'خطأ أثناء جلب الطلبات'));
    }

    statusRequest.value = handlingData(response);
    statusRequestPagination.value = handlingData(response);
    statusCode.value = handlingStatusCode(response);
  }
}

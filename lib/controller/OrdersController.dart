// ignore_for_file: avoid_print

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/model/OrderModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersController extends GetxController {
  OrderModel model = OrderModel(Get.find());

  @override
  void onInit() {
    super.onInit();
    print("✅ staerted OrdersController");

    getOrders();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        pagination();
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 STOP OrdersController");
  }

  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;
  Rx<StatusRequest> statusRequestPagination = StatusRequest.success.obs;

  //=================ControllerS=====================
  final ScrollController scrollController = ScrollController();

  // =================var====================
  RxInt statusTabBar = 0.obs;
  int page = 2;
  var status = ["all"];

  //========Data==============================
  var listOrders = [].obs;
  //=================== Function==============
  selcteingStatusTabBar(int index) {
    statusTabBar.value = index;
    switch (index) {
      case 0:
        status = ["all"];
      case 1:
        status = ['جديد'];
      case 2:
        status = ['قيد التجهيز', "تم التجهيز"];
      case 3:
        status = ['قيد التوصيل', 'مع السائق'];
      case 4:
        status = ['تم التسليم'];
      case 5:
        status = ['مرفوض'];
      default:
        status = ["all"];
    }
    getOrders();
  }

  //===============Api========================
  getOrders() async {
    page = 2;
    statusRequest.value = StatusRequest.loading;
    var response = await model.getOrders(status: status);
    if (handlingData(response) == StatusRequest.success) {
      listOrders.value = response['orders'];
    }

    statusCode.value = handlingStatusCode(response);
    statusRequest.value = handlingData(response);
  }

  pagination() async {
    statusRequestPagination.value = StatusRequest.loading;
    var response = await model.getOrders(status: status, page: page);
    if (handlingData(response) == StatusRequest.success) {
      listOrders.value += response['orders'];

      if (response['orders'].length == 0) {
        return statusRequestPagination.value = handlingData(response);
      }
      page++;
    }
    statusRequestPagination.value = handlingData(response);
  }
}

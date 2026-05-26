// ignore_for_file: avoid_print

import 'package:customer/driver/controller/MainController.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/model/NotificationsModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverNotificationsController extends GetxController {
  NotificationsModel model = NotificationsModel(Get.find());
  MainControlIer mainController = Get.find<MainControlIer>();

  @override
  void onInit() {
    super.onInit();
    getNotifications();
    scrollController.addListener(() {
      if (!scrollController.hasClients) return;
      final position = scrollController.position;
      if (position.pixels >= position.maxScrollExtent - 1) {
        pagination();
      }
    });
    print("✅ staerted DriverNotificationsController");
  }

  @override
  void onClose() {
    super.onClose();
    mainController.getUnreadCount();
    print("🧹 STOP DriverNotificationsController");
  }

  //=================var=====================

  Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  Rx<StatusRequest> statusRequestPagination = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  /// الصفحة التالية لطلب [pagination] (بعد تحميل الصفحة 1 في [getNotifications]).
  int _nextPage = 2;

  bool _paginationBusy = false;

  //=================ControllerS=====================
  final ScrollController scrollController = ScrollController();

  //=============data========================
  var listNotifications = [].obs;

  // =======================Function=================

  //=============api=========================
  getNotifications() async {
    _nextPage = 2;
    statusRequest.value = StatusRequest.loading;
    var response = await model.getNotifications(page: 1);
    if (handlingData(response) == StatusRequest.success && response is Map) {
      final raw = response['notifications'];
      if (raw is List) {
        listNotifications.value = List<dynamic>.from(raw);
      } else {
        listNotifications.clear();
      }
    }
    statusCode.value = handlingStatusCode(response);
    statusRequest.value = handlingData(response);
  }

  pagination() async {
    if (_paginationBusy) return;
    _paginationBusy = true;
    try {
      statusRequestPagination.value = StatusRequest.loading;
      var response = await model.getNotifications(page: _nextPage);
      if (handlingData(response) == StatusRequest.success && response is Map) {
        final raw = response['notifications'];
        if (raw is List) {
          final chunk = List<dynamic>.from(raw);
          if (chunk.isEmpty) {
            statusRequestPagination.value = StatusRequest.success;
            return;
          }
          listNotifications.addAll(chunk);
          _nextPage++;
        }
      }
      statusRequestPagination.value = handlingData(response);
    } finally {
      _paginationBusy = false;
    }
  }
}

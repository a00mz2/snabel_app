// ignore_for_file: avoid_print

import 'dart:convert';

import 'package:customer/controller/MainController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/notification_navigation.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/NotificationsModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  NotificationsModel model = NotificationsModel(Get.find());
  MainController mainController = Get.find<MainController>();

  @override
  void onInit() {
    super.onInit();
    getNotifications();
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        pagination();
      }
    });
    print("✅ staerted NotificationsController");
  }

  @override
  void onClose() {
    super.onClose();
    mainController.getUnreadCount();
    print("🧹 STOP NotificationsController");
  }

  //=================var=====================

  Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  Rx<StatusRequest> statusRequestPagination = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  int page = 2;

  //=================ControllerS=====================
  final ScrollController scrollController = ScrollController();

  //=============data========================
  var listNotifications = [].obs;

  // =======================Function=================

  //=============api=========================
  getNotifications() async {
    page = 2;
    statusRequest.value = StatusRequest.loading;
    var response = await model.getNotifications();
    if (handlingData(response) == StatusRequest.success) {
      listNotifications.value = response['notifications'];
    }
    statusCode.value = handlingStatusCode(response);
    statusRequest.value = handlingData(response);
  }

  pagination() async {
    statusRequestPagination.value = StatusRequest.loading;
    var response = await model.getNotifications(page: page);
    if (handlingData(response) == StatusRequest.success) {
      listNotifications.value += response['notifications'];
      if (response['notifications'].length == 0) {
        AppSnackBar.info("تم جلب جميع البيانات");
      }
      page++;
    }
    statusRequestPagination.value = handlingData(response);
  }

  /// عند الضغط على بطاقة إشعار: التوجيه لطلب إن وُجدت بيانات طلب في [data].
  void onNotificationTap(int index) {
    if (index < 0 || index >= listNotifications.length) return;
    final raw = listNotifications[index];
    if (raw is! Map) return;
    final item = Map<String, dynamic>.from(raw);
    final data = item['data'];
    Map<String, dynamic>? dataMap;
    if (data is Map) {
      dataMap = Map<String, dynamic>.from(data);
    } else if (data is String && data.isNotEmpty) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          dataMap = Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    final notificationDocId = item['_id']?.toString();
    navigateToOrderFromNotificationData(
      dataMap,
      notificationDocumentId: notificationDocId,
    );
  }
}

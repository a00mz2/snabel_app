// ignore_for_file: avoid_print

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/showConfirmationDialog.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/PinnedOrdersModel.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinnedOrderDetailController extends GetxController {
  PinnedOrderDetailController(this.pinnedOrderId);

  final String pinnedOrderId;
  final PinnedOrdersModel model = PinnedOrdersModel(Get.find());

  Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  RxInt statusCode = 200.obs;
  Rx<StatusRequest> statusButton = StatusRequest.success.obs;

  final Rxn<Map<String, dynamic>> order = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    statusRequest.value = StatusRequest.loading;
    final response = await model.getMyPinnedOrder(pinnedOrderId);
    if (handlingData(response) == StatusRequest.success) {
      final m = tryResponseMap(response);
      final po = m?['pinnedOrder'];
      if (po is Map) {
        order.value = Map<String, dynamic>.from(po);
      }
    }
    statusCode.value = handlingStatusCode(response);
    statusRequest.value = handlingData(response);
  }

  Future<void> toggleActive(bool value) async {
    statusButton.value = StatusRequest.loading;
    final response = await model.updateMyPinnedOrder({
      'pinnedOrderId': pinnedOrderId,
      'isActive': value,
    });
    if (handlingData(response) == StatusRequest.success) {
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم التحديث بنجاح',
      );
      final m = tryResponseMap(response);
      final po = m?['pinnedOrder'];
      if (po is Map) {
        order.value = Map<String, dynamic>.from(po);
      } else {
        await load();
      }
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر التحديث');
    }
    statusButton.value = handlingData(response);
  }

  Future<void> confirmDelete(BuildContext context) async {
    final ok = await showConfirmationDialog(
      context,
      title: 'حذف الطلب المثبت؟',
      subtitle: 'لن يمكن التراجع عن هذا الإجراء.',
      textActivButton: 'حذف',
      icon: Image.asset(AppIcons.tabler_pin, width: 48, height: 48),
    );
    if (ok != true) return;

    statusButton.value = StatusRequest.loading;
    final response = await model.deleteMyPinnedOrder(pinnedOrderId);
    if (handlingData(response) == StatusRequest.success) {
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم الحذف بنجاح',
      );
      Get.back(result: true);
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر الحذف');
    }
    statusButton.value = handlingData(response);
  }

  Future<void> openEdit() async {
    await Get.toNamed(
      '/PinnedOrderEdit',
      arguments: {'pinnedOrderId': pinnedOrderId},
    );
    await load();
  }
}

// ignore_for_file: avoid_print

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/pinned_order_utils.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/model/PinnedOrdersModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinnedOrdersListController extends GetxController {
  final PinnedOrdersModel model = PinnedOrdersModel(Get.find());

  final ScrollController scrollController = ScrollController();

  Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  RxInt statusCode = 200.obs;
  Rx<StatusRequest> statusRequestPagination = StatusRequest.success.obs;

  var listPinned = <Map<String, dynamic>>[].obs;

  int page = 1;
  int limit = 10;
  int totalPages = 1;
  int total = 0;

  /// null = الكل، true = نشط، false = متوقف
  Rxn<bool> filterActive = Rxn<bool>();

  @override
  void onInit() {
    super.onInit();
    fetchList(reset: true);
    scrollController.addListener(_onScroll);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 120) {
      loadMore();
    }
  }

  void setFilter(bool? active) {
    filterActive.value = active;
    fetchList(reset: true);
  }

  Future<void> fetchList({bool reset = false}) async {
    if (reset) {
      page = 1;
      totalPages = 1;
      statusRequest.value = StatusRequest.loading;
    }
    final response = await model.listMyPinnedOrders(
      page: page,
      limit: limit,
      isActive: filterActive.value,
    );

    if (handlingData(response) == StatusRequest.success) {
      final m = tryResponseMap(response);
      final raw = m?['pinnedOrders'];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) {
            list.add(Map<String, dynamic>.from(e));
          }
        }
      }
      if (m != null) {
        total = (m['total'] is num) ? (m['total'] as num).toInt() : list.length;
        totalPages = (m['totalPages'] is num)
            ? (m['totalPages'] as num).toInt().clamp(1, 999999)
            : 1;
      }
      if (reset) {
        listPinned.assignAll(list);
      } else {
        listPinned.addAll(list);
      }
    }

    statusCode.value = handlingStatusCode(response);
    statusRequest.value = handlingData(response);
    statusRequestPagination.value = handlingData(response);
  }

  Future<void> loadMore() async {
    if (statusRequestPagination.value == StatusRequest.loading) return;
    if (totalPages > 0 && page >= totalPages) return;
    if (statusRequest.value != StatusRequest.success) return;

    page++;
    statusRequestPagination.value = StatusRequest.loading;
    final response = await model.listMyPinnedOrders(
      page: page,
      limit: limit,
      isActive: filterActive.value,
    );

    if (handlingData(response) == StatusRequest.success) {
      final m = tryResponseMap(response);
      final raw = m?['pinnedOrders'];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) {
            listPinned.add(Map<String, dynamic>.from(e));
          }
        }
      }
    }
    statusRequestPagination.value = handlingData(response);
  }

  Future<void> refreshList() => fetchList(reset: true);

  String? idAt(int index) {
    if (index < 0 || index >= listPinned.length) return null;
    return pinnedOrderIdFromMap(listPinned[index]);
  }
}

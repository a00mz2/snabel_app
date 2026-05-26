import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/model/driver_settlement_model.dart';
import 'package:customer/driver/model/ProfileModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverWalletController extends GetxController {
  final DriverSettlementModel model = DriverSettlementModel(Get.find());
  final ProfileModel _profileModel = ProfileModel(Get.find());

  /// رصيد التحصيل النقدي لدى السائق (`collectionBalance` من الملف الشخصي).
  final collectionBalance = 0.obs;
  final balanceLoading = false.obs;

  /// بعد أول جلب ناجح لا نُخفِ المبلغ أثناء التحديث؛ نعرض مؤشراً صغيراً بجانبه فقط.
  bool _balanceFetchedOnce = false;

  final statusRequest = StatusRequest.none.obs;
  final statusRequestPagination = StatusRequest.success.obs;

  final settlements = <dynamic>[].obs;
  final statusMeta = <Map<String, dynamic>>[].obs;
  final flowHintAr = Rxn<String>();

  final scrollController = ScrollController();

  int page = 1;
  final limit = 20;
  final selectedStatus = 'all'.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    scrollController.addListener(_onScroll);
    load(reset: true, silent: false);
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (isLoadingMore.value || !hasMore.value) return;
    final p = scrollController.position;
    if (p.atEdge && p.pixels == p.maxScrollExtent) {
      loadMore();
    }
  }

  bool get balanceHasBeenLoaded => _balanceFetchedOnce;

  Future<void> fetchCollectionBalance() async {
    balanceLoading.value = true;
    try {
      final response = await _profileModel.getDriverProfile();
      if (handlingData(response) == StatusRequest.success && response is Map) {
        final d = response['driver'];
        if (d is Map) {
          final v = d['collectionBalance'];
          final n = v is num
              ? v.toDouble()
              : double.tryParse(v?.toString() ?? '') ?? 0;
          collectionBalance.value = n.round();
          _balanceFetchedOnce = true;
        }
      }
    } finally {
      balanceLoading.value = false;
    }
  }

  /// [silent]: عند true لا نضع أبداً `statusRequest.loading` في البداية (تحديث من تفاصيل التحصيل/خلفية
  /// دون شاشة تحميل برتقالية بملء القائمة — حتى لو كانت القائمة فارغة).
  Future<void> load({bool reset = false, bool silent = false}) async {
    if (reset) {
      page = 1;
      hasMore.value = true;
      if (!silent) {
        statusRequest.value = StatusRequest.loading;
      }
    }

    await fetchCollectionBalance();

    final response = await model.mySettlements(
      page: page,
      limit: limit,
      status: selectedStatus.value,
    );

    if (handlingData(response) == StatusRequest.success && response is Map) {
      final list = response['settlements'];
      final meta = response['statusMeta'];
      if (meta is Map) {
        final st = meta['statuses'];
        if (st is List) {
          statusMeta.assignAll(
            st.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
          );
        }
        flowHintAr.value = meta['flowHintAr'] as String?;
      } else {
        flowHintAr.value = null;
      }
      if (list is List) {
        settlements.assignAll(list);
        final totalPages = response['totalPages'];
        final tp = totalPages is num ? totalPages.toInt() : 1;
        hasMore.value = page < tp;
      }
    }

    statusRequest.value = handlingData(response);
    statusRequestPagination.value = StatusRequest.success;
  }

  Future<void> loadMore() async {
    if (isLoadingMore.value || !hasMore.value) return;
    isLoadingMore.value = true;
    statusRequestPagination.value = StatusRequest.loading;
    page += 1;
    final response = await model.mySettlements(
      page: page,
      limit: limit,
      status: selectedStatus.value,
    );

    if (handlingData(response) == StatusRequest.success && response is Map) {
      final list = response['settlements'];
      if (list is List && list.isNotEmpty) {
        settlements.addAll(list);
      } else {
        hasMore.value = false;
        page -= 1;
      }
      final totalPages = response['totalPages'];
      final tp = totalPages is num ? totalPages.toInt() : 1;
      hasMore.value = page < tp;
    } else {
      page -= 1;
    }

    statusRequestPagination.value = handlingData(response);
    isLoadingMore.value = false;
  }

  Future<void> refreshList() => load(reset: true, silent: true);

  void setStatusFilter(String status) {
    if (selectedStatus.value == status) return;
    selectedStatus.value = status;
    load(reset: true, silent: false);
  }

  /// جلب عنصر للتفاصيل عند فتح الإشعار بـ [settlementId] فقط.
  Future<Map<String, dynamic>?> fetchOneById(String id) async {
    final response = await model.mySettlements(
      page: 1,
      limit: 100,
      status: 'all',
    );
    if (handlingData(response) != StatusRequest.success || response is! Map) {
      return null;
    }
    final list = response['settlements'];
    if (list is! List) return null;
    for (final item in list) {
      if (item is! Map) continue;
      final sid = item['_id']?.toString();
      if (sid == id) return Map<String, dynamic>.from(item);
    }
    return null;
  }
}

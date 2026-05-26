import 'package:customer/driver/controller/driver_wallet_controller.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/model/driver_settlement_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

class DriverSettlementDetailController extends GetxController {
  final DriverSettlementModel model = DriverSettlementModel(Get.find());

  final settlement = Rxn<Map<String, dynamic>>();
  final loading = true.obs;
  final approving = false.obs;
  final confirming = false.obs;

  @override
  void onInit() {
    super.onInit();
    _resolveArgs();
  }

  void _resolveArgs() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      if (args['settlement'] is Map) {
        settlement.value = Map<String, dynamic>.from(args['settlement'] as Map);
        loading.value = false;
        return;
      }
      final sid = args['settlementId']?.toString();
      if (sid != null && sid.isNotEmpty) {
        _loadById(sid);
        return;
      }
    }
    loading.value = false;
  }

  Future<void> _loadById(String id) async {
    loading.value = true;
    if (Get.isRegistered<DriverWalletController>()) {
      final found = await Get.find<DriverWalletController>().fetchOneById(id);
      if (found != null) {
        settlement.value = found;
        loading.value = false;
        return;
      }
    }
    final response = await model.mySettlements(page: 1, limit: 100, status: 'all');
    if (handlingData(response) == StatusRequest.success && response is Map) {
      final list = response['settlements'];
      if (list is List) {
        for (final item in list) {
          if (item is Map && item['_id']?.toString() == id) {
            settlement.value = Map<String, dynamic>.from(item);
            break;
          }
        }
      }
    }
    loading.value = false;
  }

  String get requestId => settlement.value?['_id']?.toString() ?? '';

  Future<void> approve() async {
    final id = requestId;
    if (id.isEmpty || approving.value) return;
    approving.value = true;
    final response = await model.approve(id);
    approving.value = false;
    if (handlingData(response) == StatusRequest.success && response is Map) {
      final s = response['settlement'];
      if (s is Map) {
        settlement.value = Map<String, dynamic>.from(s);
      }
      AppSnackBar.success(apiMessageFromMap(response, 'تمت الموافقة'));
      _notifyWalletRefresh();
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'تعذر تنفيذ الموافقة'));
    }
  }

  Future<void> confirm() async {
    final id = requestId;
    if (id.isEmpty || confirming.value) return;
    confirming.value = true;
    if (kDebugMode) {
      debugPrint('[DriverSettlement] confirm requestId=$id');
    }
    final response = await model.confirm(id);
    confirming.value = false;
    if (kDebugMode) {
      debugPrint('[DriverSettlement] confirm response: $response');
    }
    if (handlingData(response) == StatusRequest.success && response is Map) {
      final s = response['settlement'];
      if (s is Map) {
        settlement.value = Map<String, dynamic>.from(s);
      }
      AppSnackBar.success(apiMessageFromMap(response, 'تم تأكيد الاستلام'));
      _notifyWalletRefresh();
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'تعذر التأكيد'));
    }
  }

  void _notifyWalletRefresh() {
    if (!Get.isRegistered<DriverWalletController>()) return;
    // بعد إطار الرسم حتى لا يتداخل تحديث قائمة المحفظة مع تخطيط زر التحميل في الأسفل
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (Get.isRegistered<DriverWalletController>()) {
        Get.find<DriverWalletController>().refreshList();
      }
    });
  }
}

import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/model/driver_cod_collection_model.dart';
import 'package:get/get.dart';

/// مبالغ «الدفع عند الاستلام»: ما في ذمة السائق وما استلمته الإدارة منه.
///
/// للعرض فقط — عملية الاستلام تُسجَّل من لوحة الإدارة، ويصل السائق إشعار
/// (`DRIVER_COD_SETTLED`) عند تسجيلها.
class DriverCodCollectionsController extends GetxController {
  final DriverCodCollectionModel model = DriverCodCollectionModel(Get.find());

  final statusRequest = StatusRequest.none.obs;

  final outstandingRows = <Map<String, dynamic>>[].obs;
  final settledRows = <Map<String, dynamic>>[].obs;

  final outstandingCount = 0.obs;
  final outstandingAmount = 0.obs;
  final settledCount = 0.obs;
  final settledAmount = 0.obs;

  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  int _asInt(dynamic v) {
    if (v is num) return v.round();
    return (double.tryParse(v?.toString() ?? '') ?? 0).round();
  }

  List<Map<String, dynamic>> _rowsOf(dynamic response) {
    if (response is! Map) return <Map<String, dynamic>>[];
    final raw = response['rows'];
    if (raw is! List) return <Map<String, dynamic>>[];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  void _applyTotals(dynamic response) {
    if (response is! Map) return;
    final t = response['totals'];
    if (t is! Map) return;
    outstandingCount.value = _asInt(t['outstandingCount']);
    outstandingAmount.value = _asInt(t['outstandingAmount']);
    settledCount.value = _asInt(t['settledCount']);
    settledAmount.value = _asInt(t['settledAmount']);
  }

  Future<void> load({bool silent = false}) async {
    if (!silent) statusRequest.value = StatusRequest.loading;
    errorMessage.value = null;
    try {
      final results = await Future.wait<dynamic>(<Future<dynamic>>[
        model.myCodCollections(status: 'outstanding'),
        model.myCodCollections(status: 'settled'),
      ]);

      final outstanding = results[0];
      final settled = results[1];

      final s1 = handlingData(outstanding);
      if (s1 != StatusRequest.success) {
        statusRequest.value = s1;
        errorMessage.value = outstanding is Map
            ? outstanding['message']?.toString()
            : null;
        return;
      }

      outstandingRows.assignAll(_rowsOf(outstanding));
      _applyTotals(outstanding);

      if (handlingData(settled) == StatusRequest.success) {
        settledRows.assignAll(_rowsOf(settled));
        _applyTotals(settled);
      }

      statusRequest.value = StatusRequest.success;
    } catch (e) {
      statusRequest.value = StatusRequest.serverFailure;
      errorMessage.value = 'تعذر الاتصال بالخادم';
    }
  }

  Future<void> refreshData() => load(silent: true);
}

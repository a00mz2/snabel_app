// ignore_for_file: file_names

import 'dart:typed_data';

import 'package:customer/driver/controller/orders_controller.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/model/OrderModel.dart';
import 'package:get/get.dart';
import 'package:customer/core/constant/payment_methods.dart';

import 'package:customer/core/functions/orderRounding.dart';
int _toInt(dynamic v, [int fallback = 0]) {
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}') ?? fallback;
}

class OrderDetelsController extends GetxController {
  final RxMap<String, dynamic> dataOrder = <String, dynamic>{}.obs;

  OrderModel data = OrderModel(Get.find());

  /// حالة أزرار تحديث الطلب فقط — لا تُمرَّر إلى [ScaffoldWidget] حتى لا يُستبدل محتوى الصفحة بشاشة تحميل.
  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  Rx<StatusRequest> statusRequestButtonreject = StatusRequest.success.obs;

  /// تبقى [success] دائماً لجسم الصفحة؛ التحميل يظهر داخل الأزرار فقط.
  final Rx<StatusRequest> scaffoldBodyStatus = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  // ───────── تعديل المحتوى قبل التسليم (تقليل كميات / حذف أصناف) ─────────

  /// الحالات التي يُسمح فيها للسائق بتعديل محتوى الطلب (نفس قيود الخادم).
  static const List<String> editableStatuses = ['قيد التوصيل', 'مع السائق'];

  final RxBool editMode = false.obs;

  /// نسخة قابلة للتعديل من بنود الطلب أثناء وضع التعديل.
  final RxList<Map<String, dynamic>> editedItems = <Map<String, dynamic>>[].obs;
  final Rx<StatusRequest> statusSaveContent = StatusRequest.success.obs;

  String get _status => dataOrder['status']?.toString().trim() ?? '';

  bool get canEditContent => editableStatuses.contains(_status);

  /// السائق عدّل المحتوى سابقاً → «تم التسليم» ستُسجَّل «واصل جزئي» من الخادم.
  bool get partialDelivery => dataOrder['partialDelivery'] == true;

  // ───────── ملاحظة الزبون / سبب الرفض / صورة التسليم / الدفع عند الاستلام ─────────

  /// ملاحظة الزبون على الطلب (اختيارية).
  String? get customerNote {
    final s = dataOrder['note']?.toString().trim() ?? '';
    return s.isEmpty ? null : s;
  }

  /// سبب الرفض المسجَّل على الطلب.
  Map? get rejection {
    final v = dataOrder['rejection'];
    return v is Map ? v : null;
  }

  /// المسار النسبي لصورة تأكيد التسليم (`orders/<file>`).
  String? get deliveryProofImage {
    final v = dataOrder['deliveryProof'];
    if (v is! Map) return null;
    final s = v['image']?.toString().trim() ?? '';
    return s.isEmpty ? null : s;
  }

  Map? get cashOnDelivery {
    final v = dataOrder['cashOnDelivery'];
    return v is Map ? v : null;
  }

  /// تحصيل نقدي مطلوب ولم يُؤكَّد بعد → «تم التسليم» مقفل.
  bool get codPending {
    final st = cashOnDelivery?['status']?.toString();
    return st != null && st.isNotEmpty && st != 'collected';
  }

  bool get codCollected => cashOnDelivery?['status'] == 'collected';

  int get codAmount => _toInt(cashOnDelivery?['amount']);

  /// «تسديد الفرق» أو «الدفع الكامل».
  String get codModeLabel =>
      cashOnDelivery?['mode'] == 'full' ? 'الدفع الكامل' : 'تسديد الفرق';

  /// [pay-method] طريقة دفع الطلب؛ القديمة بلا الحقل تُقرأ «آجل».
  String get paymentMethod =>
      dataOrder['paymentMethod']?.toString() ?? kPaymentWallet;

  bool get isCashOrder => isCashPaymentMethod(paymentMethod);

  /// وصف ما يجب قبضه: الطلب النقدي كامل القيمة، وغيره فائض عن الحد.
  String get codPurposeLabel =>
      isCashOrder ? 'طلب نقدي — كامل قيمة الطلب' : codModeLabel;

  /// حالة زر تأكيد التحصيل النقدي.
  final Rx<StatusRequest> statusRequestCash = StatusRequest.success.obs;

  List<Map<String, dynamic>> _itemsSnapshot() {
    final raw = dataOrder['items'];
    if (raw is! List) return <Map<String, dynamic>>[];
    return <Map<String, dynamic>>[
      for (final e in raw)
        if (e is Map) Map<String, dynamic>.from(e),
    ];
  }

  int _qty(Map item) => _toInt(item['quantity']);

  int _lineTotal(Map item) {
    final price = item['price'];
    if (price is! num) return 0;
    final packing = item['packing'];
    var packQty = 1;
    if (packing is Map && packing['quantity'] is num) {
      packQty = (packing['quantity'] as num).toInt();
      if (packQty < 1) packQty = 1;
    }
    return (price * packQty * _qty(item)).toInt();
  }

  int get totalPrice => _toInt(dataOrder['totalPrice']);
  int get deliveryFee => _toInt(dataOrder['deliveryFee']);

  /// [round-250] تقريب الإجمالي كما خزّنه الخادم (0 للطلبات القديمة).
  int get roundingAdjustment => _toInt(dataOrder['roundingAdjustment']);

  /// المجموع (بدون التوصيل): في وضع التعديل يُحسب من البنود المعدّلة.
  int get previewSubtotal {
    if (editMode.value) {
      var s = 0;
      for (final it in editedItems) {
        s += _lineTotal(it);
      }
      return s;
    }
    return totalPrice - deliveryFee;
  }

  /// المجموع الكلي (شامل التوصيل) — `totalPrice` يتضمن رسوم التوصيل أصلاً.
  /// [round-250] في وضع التعديل يُعاد تقريبه للأعلى كما سيفعل الخادم
  /// (والتخفيض لا يرفعه أبداً)، فيرى السائق الرقم الذي سيُحصَّل بالضبط.
  int get previewTotal {
    if (!editMode.value) return totalPrice;
    final originalSubtotal = totalPrice - deliveryFee - roundingAdjustment;
    return previewAfterDelta(
      currentTotal: totalPrice,
      currentRounding: roundingAdjustment,
      lineDelta: previewSubtotal - originalSubtotal,
    ).totalPrice;
  }

  /// البنود المعروضة في القائمة (المعدّلة أثناء التعديل وإلا الأصلية).
  List<Map<String, dynamic>> get visibleItems =>
      editMode.value ? editedItems.toList() : _itemsSnapshot();

  void startEdit() {
    if (!canEditContent) return;
    editedItems.assignAll(_itemsSnapshot());
    editMode.value = true;
  }

  void cancelEdit() {
    editMode.value = false;
    editedItems.clear();
  }

  int _originalQtyOf(Map item) {
    final id = item['_id']?.toString();
    for (final o in _itemsSnapshot()) {
      if (o['_id']?.toString() == id) return _qty(o);
    }
    return _qty(item);
  }

  /// هل يمكن إعادة زيادة الكمية (حتى الكمية الأصلية فقط — السائق لا يزيد).
  bool canIncrement(int index) {
    if (index < 0 || index >= editedItems.length) return false;
    final it = editedItems[index];
    return _qty(it) < _originalQtyOf(it);
  }

  void incrementItem(int index) {
    if (!canIncrement(index)) return;
    final it = editedItems[index];
    editedItems[index] = {...it, 'quantity': _qty(it) + 1};
  }

  /// التقليل حتى الصفر = حذف البند.
  void decrementItem(int index) {
    if (index < 0 || index >= editedItems.length) return;
    final it = editedItems[index];
    final q = _qty(it);
    if (q <= 1) {
      removeItem(index);
      return;
    }
    editedItems[index] = {...it, 'quantity': q - 1};
  }

  void removeItem(int index) {
    if (index < 0 || index >= editedItems.length) return;
    if (editedItems.length <= 1) {
      AppSnackBar.error('لا يمكن حذف كل الأصناف — ارفض الطلب بدلاً من ذلك');
      return;
    }
    editedItems.removeAt(index);
  }

  /// التغييرات بصيغة الخادم: [{itemId, quantity}] أو [{itemId, remove: true}].
  List<Map<String, dynamic>> _buildChanges() {
    final original = _itemsSnapshot();
    final byId = <String, Map<String, dynamic>>{
      for (final e in editedItems)
        if (e['_id'] != null) e['_id'].toString(): e,
    };
    final out = <Map<String, dynamic>>[];
    for (final o in original) {
      final id = o['_id']?.toString();
      if (id == null || id.isEmpty) continue;
      final e = byId[id];
      if (e == null) {
        out.add({'itemId': id, 'remove': true});
      } else if (_qty(e) != _qty(o)) {
        out.add({'itemId': id, 'quantity': _qty(e)});
      }
    }
    return out;
  }

  bool get hasContentChanges => _buildChanges().isNotEmpty;

  /// دمج حقول الطلب المتغيّرة فقط (نُبقي customers/deliveryPeriod كما وصلت مع الصورة).
  void _mergeOrder(dynamic fresh) {
    if (fresh is! Map) return;
    const keys = [
      'items',
      'totalPrice',
      'totalProducts',
      'deliveryFee',
      'roundingAdjustment', // [round-250]
      'partialDelivery',
      'partialDeliveryAt',
      'originalTotalPrice',
      'originalTotalProducts',
      'contentEdits',
      'updatedAt',
      'status',
      'statusHistory',
      'note',
      'rejection',
      'deliveryProof',
      'cashOnDelivery',
    'paymentMethod', // [pay-method]
    ];
    final patch = <String, dynamic>{};
    for (final k in keys) {
      if (fresh.containsKey(k)) patch[k] = fresh[k];
    }
    dataOrder.addAll(patch);
  }

  void _refreshOrdersList() {
    if (Get.isRegistered<DriverOrdersController>()) {
      Get.find<DriverOrdersController>().getOrders();
    }
  }

  Future<void> saveContentEdit() async {
    final changes = _buildChanges();
    if (changes.isEmpty) {
      AppSnackBar.info('لا توجد تغييرات لحفظها');
      return;
    }
    statusSaveContent.value = StatusRequest.loading;
    final response = await data.updateOrderContent(
      orderId: dataOrder['_id'].toString(),
      expectedUpdatedAt: dataOrder['updatedAt']?.toString(),
      items: changes,
    );
    final outcome = handlingData(response);

    if (outcome == StatusRequest.success && response is Map) {
      _mergeOrder(response['order']);
      editMode.value = false;
      editedItems.clear();
      AppSnackBar.success(apiMessageFromMap(response, 'تم تعديل محتوى الطلب'));
      _refreshOrdersList();
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'فشل تعديل محتوى الطلب'));
      // تعارض إصدار (409): أعد تحميل الطلب حتى تُبنى التعديلات على أحدث نسخة
      if (handlingStatusCode(response) == 409) {
        await refreshOrder();
        cancelEdit();
      }
    }
    statusSaveContent.value = outcome;
    statusCode.value = handlingStatusCode(response);
  }

  /// إعادة جلب الطلب الحالي من الخادم (بحث برقم الطلب) ودمج حقوله.
  Future<void> refreshOrder() async {
    final number = dataOrder['orderNumber']?.toString() ?? '';
    if (number.isEmpty) return;
    final response = await data.getOrders(search: number);
    if (handlingData(response) != StatusRequest.success || response is! Map) {
      return;
    }
    final orders = response['orders'];
    if (orders is! List) return;
    final myId = dataOrder['_id']?.toString();
    for (final o in orders) {
      if (o is Map && o['_id']?.toString() == myId) {
        _mergeOrder(o);
        break;
      }
    }
  }

  /// [rejection]: `{code, details?}` من ورقة أسباب الرفض — إلزامي عند «مرفوض».
  updateStatusOrder(
    orderid,
    staus, {
    bool isReject = false,
    Map<String, dynamic>? rejection,
  }) async {
    if (isReject) {
      statusRequestButtonreject.value = StatusRequest.loading;
    } else {
      statusRequest.value = StatusRequest.loading;
    }
    var response = await data.updateStatusOrder(
      orderId: orderid,
      status: staus,
      rejection: rejection,
    );
    final outcome = handlingData(response);

    if (outcome == StatusRequest.success && response is Map) {
      // الخادم قد يحوّل «تم التسليم» إلى «واصل جزئي» بعد تعديل المحتوى
      final ns = response['newStatus'];
      if (ns != null) {
        dataOrder['status'] = ns;
      }
      _mergeOrder(response['order']);
      AppSnackBar.success(apiMessageFromMap(response, 'تم التحديث'));
      _refreshOrdersList();
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'فشل تحديث الطلب'));
    }

    if (isReject) {
      statusRequestButtonreject.value = outcome;
    } else {
      statusRequest.value = outcome;
    }
    statusCode.value = handlingStatusCode(response);
  }

  /// تسليم الطلب بصورة تأكيد (الكاميرا فقط من الشاشة).
  Future<void> deliverOrder(String orderId, Uint8List proof) async {
    if (codPending) {
      AppSnackBar.info('يجب تأكيد استلام المبلغ النقدي قبل التسليم');
      return;
    }
    statusRequest.value = StatusRequest.loading;
    final response = await data.deliverOrder(orderId: orderId, proof: proof);
    final outcome = handlingData(response);

    if (outcome == StatusRequest.success && response is Map) {
      final ns = response['newStatus'];
      if (ns != null) dataOrder['status'] = ns;
      _mergeOrder(response['order']);
      AppSnackBar.success(apiMessageFromMap(response, 'تم تأكيد التسليم'));
      _refreshOrdersList();
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'فشل تأكيد التسليم'));
    }
    // نُعيد الزر إلى وضعه ليتمكن السائق من إعادة المحاولة
    statusRequest.value = StatusRequest.success;
    statusCode.value = handlingStatusCode(response);
  }

  /// تأكيد استلام المبلغ النقدي من الزبون (يفتح إمكانية التسليم).
  Future<void> confirmCashCollection(String orderId) async {
    statusRequestCash.value = StatusRequest.loading;
    final response = await data.confirmCashCollection(orderId: orderId);
    final outcome = handlingData(response);

    if (outcome == StatusRequest.success && response is Map) {
      _mergeOrder(response['order']);
      AppSnackBar.success(
        apiMessageFromMap(response, 'تم تسجيل استلام المبلغ'),
      );
      _refreshOrdersList();
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'فشل تأكيد استلام المبلغ'));
    }
    statusRequestCash.value = StatusRequest.success;
    statusCode.value = handlingStatusCode(response);
  }

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      dataOrder.assignAll(args);
    } else if (args is Map) {
      dataOrder.assignAll(Map<String, dynamic>.from(args));
    }
    super.onInit();
  }
}

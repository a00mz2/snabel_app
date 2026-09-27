// ignore_for_file: avoid_print

import 'package:customer/controller/OrdersController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/pinned_order_utils.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/OrderModel.dart';
import 'package:customer/model/ProductsModel.dart';
import 'package:get/get.dart';

import 'package:customer/core/functions/orderRounding.dart';
double _toDouble(dynamic v, [double fallback = 0]) {
  if (v is num) return v.toDouble();
  return double.tryParse('${v ?? ''}') ?? fallback;
}

int _toInt(dynamic v, [int fallback = 0]) {
  if (v is num) return v.toInt();
  return int.tryParse('${v ?? ''}') ?? fallback;
}

/// سطر في محرر محتوى الطلب: بند موجود (له [itemId]) أو إضافة جديدة ([isNew]).
class OrderLineEdit {
  OrderLineEdit({
    this.itemId,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.originalQuantity,
    required this.price,
    this.imageFileName,
    this.packingRaw,
    this.availablePackings = const [],
    this.isNew = false,
  });

  final String? itemId;
  final String? productId;
  final String name;
  int quantity;
  final int originalQuantity;

  /// سعر الوحدة (للمعاينة فقط — الخادم يسعّر الإضافات بنفسه).
  final double price;
  String? imageFileName;
  Map<String, dynamic>? packingRaw;
  List<Map<String, dynamic>> availablePackings;
  final bool isNew;

  int get packQty {
    final q = packingRaw?['quantity'];
    final n = q is num ? q.toInt() : int.tryParse('${q ?? ''}') ?? 1;
    return n > 0 ? n : 1;
  }

  String get packingLabel => packingRaw?['label']?.toString() ?? '';

  double get lineTotal => price * packQty * quantity;

  double get originalLineTotal => price * packQty * originalQuantity;

  bool get isChanged => isNew || quantity != originalQuantity;
}

/// تعديل محتوى طلب قائم وهو «جديد» (قيد المراجعة): كميات / حذف / إضافة.
/// الفرق يُسوّى على المحفظة من الخادم (POST customer/updateOrderContent).
class OrderEditController extends GetxController {
  OrderEditController(this.order);

  static const int maxQty = 9999;

  /// خريطة الطلب كما وصلت من `getOrders` (تُمرَّر عبر Get.arguments['order']).
  final Map<String, dynamic> order;

  final OrderModel _orders = OrderModel(Get.find());
  final ProductsModel _products = ProductsModel(Get.find());

  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  final Rx<StatusRequest> statusSave = StatusRequest.success.obs;
  final RxInt statusCode = 200.obs;

  final RxList<OrderLineEdit> lines = <OrderLineEdit>[].obs;

  /// بنود موجودة حُذفت في المحرر (يمكن التراجع قبل الحفظ).
  final RxList<OrderLineEdit> removed = <OrderLineEdit>[].obs;
  final RxList<Map<String, dynamic>> productCatalog =
      <Map<String, dynamic>>[].obs;

  String get orderId => (order['_id'] ?? order['id'] ?? '').toString();
  String get orderNumber => (order['orderNumber'] ?? '').toString();

  String? get expectedUpdatedAt {
    final v = order['updatedAt']?.toString();
    return (v == null || v.isEmpty) ? null : v;
  }

  double get deliveryFee => _toDouble(order['deliveryFee']);
  double get originalTotal => _toDouble(order['totalPrice']);

  /// [round-250] تقريب الإجمالي الحالي كما خزّنه الخادم (0 للطلبات القديمة).
  double get currentRounding => _toDouble(order['roundingAdjustment']);

  /// مجموع فروق الأسطر الخام (قبل إعادة التقريب).
  double get lineDelta {
    double d = 0;
    for (final l in lines) {
      d += l.isNew ? l.lineTotal : (l.lineTotal - l.originalLineTotal);
    }
    for (final r in removed) {
      d -= r.originalLineTotal;
    }
    return d;
  }

  /// [round-250] معاينة الإجمالي بعد إعادة التقريب للأقرب — نفس قاعدة الخادم.
  OrderTotalPreview get _preview => previewAfterDelta(
        currentTotal: originalTotal,
        currentRounding: currentRounding,
        lineDelta: lineDelta,
        step: roundingStepOrDefault(order['roundingStep']),
      );

  /// فرق الإجمالي المتوقع (سالب = يُرجع إلى المحفظة، موجب = يُخصم).
  double get delta => _preview.delta.toDouble();

  double get newTotal => _preview.totalPrice.toDouble();

  bool get hasChanges => removed.isNotEmpty || lines.any((l) => l.isChanged);

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    statusRequest.value = StatusRequest.loading;
    _applyOrderItems();

    final catalogRes = await _products.getProducts(page: 1);
    if (handlingData(catalogRes) == StatusRequest.success) {
      final m = tryResponseMap(catalogRes);
      final raw = m?['products'];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) list.add(Map<String, dynamic>.from(e));
        }
      }
      productCatalog.assignAll(list);
    }

    statusCode.value = 200;
    statusRequest.value = StatusRequest.success;
  }

  void _applyOrderItems() {
    lines.clear();
    removed.clear();
    final items = order['items'];
    if (items is! List) return;
    for (final raw in items) {
      if (raw is! Map) continue;
      final item = Map<String, dynamic>.from(raw);
      final p = item['product'];
      String? productId;
      var name = (item['name'] ?? '').toString();
      if (p is Map) {
        productId = '${p['_id'] ?? p['id'] ?? ''}';
        if (name.isEmpty) name = (p['name'] ?? '').toString();
      } else if (p != null) {
        productId = p.toString();
      }
      if (productId != null && productId.isEmpty) productId = null;

      Map<String, dynamic>? packing;
      if (item['packing'] is Map) {
        packing = Map<String, dynamic>.from(item['packing'] as Map);
      }
      final qty = _toInt(item['quantity'], 1);
      lines.add(
        OrderLineEdit(
          itemId: item['_id']?.toString(),
          productId: productId,
          name: name.isEmpty ? 'منتج' : name,
          quantity: qty < 1 ? 1 : qty,
          originalQuantity: qty < 1 ? 1 : qty,
          price: _toDouble(item['price']),
          imageFileName: item['image']?.toString(),
          packingRaw: packing,
        ),
      );
    }
  }

  void bumpQty(int index, int delta) {
    if (index < 0 || index >= lines.length) return;
    final l = lines[index];
    final n = l.quantity + delta;
    if (n >= 1 && n <= maxQty) l.quantity = n;
    lines.refresh();
  }

  void removeLine(int index) {
    if (index < 0 || index >= lines.length) return;
    final l = lines.removeAt(index);
    if (!l.isNew) removed.add(l);
  }

  void restoreRemoved(int index) {
    if (index < 0 || index >= removed.length) return;
    final l = removed.removeAt(index);
    lines.add(l);
  }

  /// اختيار التعبئة لبند جديد فقط (تعبئة البند الموجود ثابتة).
  void selectPackingLine(int index, Map<String, dynamic> p) {
    if (index < 0 || index >= lines.length) return;
    if (!lines[index].isNew) return;
    final id = p['_id']?.toString() ?? p['id']?.toString();
    final label = p['label']?.toString() ?? '';
    final q = p['quantity'];
    lines[index].packingRaw = <String, dynamic>{
      'label': label,
      'quantity': q is num ? q : int.tryParse('$q') ?? 1,
      if (id != null && id.isNotEmpty) '_id': id,
    };
    lines.refresh();
  }

  void addProductFromCatalog(Map<String, dynamic> prod) {
    final id = '${prod['_id'] ?? prod['id'] ?? ''}';
    if (id.isEmpty) return;
    final name = (prod['name'] ?? '').toString();
    final price = _toDouble(prod['price']);
    final img = productMainImageFileName(prod) ?? prod['mainImage']?.toString();
    final packs = prod['packings'];
    final packList = <Map<String, dynamic>>[];
    Map<String, dynamic>? firstPack;
    if (packs is List && packs.isNotEmpty) {
      for (final e in packs) {
        if (e is Map) packList.add(Map<String, dynamic>.from(e));
      }
      if (packList.isNotEmpty) {
        final f = packList.first;
        final pid = f['_id']?.toString() ?? f['id']?.toString();
        firstPack = <String, dynamic>{
          'label': f['label']?.toString() ?? '',
          'quantity': f['quantity'] is num
              ? f['quantity']
              : int.tryParse('${f['quantity']}') ?? 1,
          if (pid != null && pid.isNotEmpty) '_id': pid,
        };
      }
    }
    lines.add(
      OrderLineEdit(
        productId: id,
        name: name.isEmpty ? 'منتج' : name,
        quantity: 1,
        originalQuantity: 0,
        price: price,
        imageFileName: img,
        packingRaw: firstPack,
        availablePackings: packList,
        isNew: true,
      ),
    );
  }

  Future<void> save() async {
    if (lines.isEmpty) {
      AppSnackBar.error('لا يمكن حذف كل الأصناف — يمكنك إلغاء الطلب بدلاً من ذلك');
      return;
    }
    if (!hasChanges) {
      AppSnackBar.info('لا توجد تغييرات لحفظها');
      return;
    }

    final items = <Map<String, dynamic>>[];
    for (final l in lines) {
      if (l.isNew || l.itemId == null) continue;
      if (l.quantity != l.originalQuantity) {
        items.add({'itemId': l.itemId, 'quantity': l.quantity});
      }
    }
    for (final r in removed) {
      if (r.itemId == null) continue;
      items.add({'itemId': r.itemId, 'remove': true});
    }

    final additions = <Map<String, dynamic>>[];
    for (final l in lines) {
      if (!l.isNew) continue;
      final pid = l.productId;
      if (pid == null || pid.isEmpty) continue;
      final pk = l.packingRaw;
      additions.add({
        'product': pid,
        'quantity': l.quantity,
        if (pk != null && pk.isNotEmpty)
          'packing': {'label': pk['label'], 'quantity': pk['quantity']},
      });
    }

    statusSave.value = StatusRequest.loading;
    final response = await _orders.updateOrderContent({
      'orderId': orderId,
      if (expectedUpdatedAt != null) 'expectedUpdatedAt': expectedUpdatedAt,
      'changes': {'items': items, 'additions': additions},
    });

    if (handlingData(response) == StatusRequest.success) {
      statusSave.value = StatusRequest.success;
      AppSnackBar.success(tryResponseMessage(response) ?? 'تم تعديل الطلب');
      if (Get.isRegistered<OrdersController>()) {
        Get.find<OrdersController>().getOrders();
      }
      Get.back(result: true);
      return;
    }
    AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر حفظ التعديلات');
    statusSave.value = handlingData(response);
  }
}

// ignore_for_file: non_constant_identifier_names

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/core/functions/statusColors.dart';
import 'package:customer/model/OrderModel.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

void _orderDetailDiag(String message) {
  if (kDebugMode) {
    debugPrint('[OrderDetailDiag] $message');
  }
}

const _orderIdKeys = ['orderNumber', 'order_number', 'orderId', 'order_id'];

/// من [Get.arguments] أو بيانات FCM (يدعم camelCase وsnake_case ومجموعة `data` المتداخلة).
String? resolveOrderIdentifierFromArguments(Object? args, [int depth = 0]) {
  if (depth > 4 || args is! Map) return null;
  final m = Map<String, dynamic>.from(args);
  for (final k in _orderIdKeys) {
    final v = m[k];
    if (v != null) {
      final s = v.toString().trim();
      if (s.isNotEmpty) return s;
    }
  }
  final nested = m['data'];
  if (nested is Map) {
    return resolveOrderIdentifierFromArguments(nested, depth + 1);
  }
  return null;
}

/// يحفظ معرّف الطلب قبل [Get.toNamed] لأن [Get.arguments] قد لا يُحدَّث في لحظة تشغيل
/// [OrderDetailBinding] (يُحدَّث لاحقاً في [NavigatorObserver.didPush]).
class OrderDetailPendingRouteArgs {
  OrderDetailPendingRouteArgs._();
  static String? _id;

  static void stash(String orderIdentifier) {
    final s = orderIdentifier.trim();
    _id = s.isEmpty ? null : s;
  }

  static String? take() {
    final v = _id;
    _id = null;
    return v;
  }
}

/// ترتيب البحث: [orderNumber] أولاً ثم [orderId] (ObjectId) — لا تُخلط القيم تحت مفتاح واحد.
List<String> orderSearchCandidatesFromRouteArgs(
  Object? args,
  String constructorOrderId,
) {
  final out = <String>[];
  if (args is Map) {
    final m = Map<String, dynamic>.from(args);
    final num = m['orderNumber'] ?? m['order_number'];
    final oid = m['orderId'] ?? m['order_id'];
    final ns = num?.toString().trim();
    final os = oid?.toString().trim();
    if (ns != null && ns.isNotEmpty) out.add(ns);
    if (os != null && os.isNotEmpty && !out.contains(os)) out.add(os);
  }
  if (out.isEmpty && constructorOrderId.isNotEmpty) {
    out.add(constructorOrderId);
  }
  return out;
}

class OrderDetailController extends GetxController {
  OrderModel model = OrderModel(Get.find());

  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  @override
  void onInit() {
    super.onInit();
    final candidates = orderSearchCandidatesFromRouteArgs(
      Get.arguments,
      orderId,
    );
    if (candidates.isNotEmpty) {
      orderId = candidates.first;
    }
    _orderDetailDiag(
      'onInit orderId="$orderId" Get.arguments=${Get.arguments}',
    );
    getOrder();
  }

  @override
  void onReady() {
    super.onReady();
    final resolved = resolveOrderIdentifierFromArguments(Get.arguments);
    if (resolved != null && resolved.isNotEmpty && resolved != orderId) {
      _orderDetailDiag(
        'onReady corrected orderId from "$orderId" to "$resolved"',
      );
      orderId = resolved;
      getOrder();
    }
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 STOP OrderDetailController");
  }

  //===========variables===========

  /// رقم الطلب أو المعرف للبحث في الـ API (يُحدَّث من [Get.arguments] في [onInit] إن لزم).
  String orderId = '';
  OrderDetailController([String? id]) {
    orderId = (id ?? '').trim();
  }
  //==========data==========

  var dataOrder = {}.obs;

  //==========functions==========

  String packageName(int index) {
    try {
      return dataOrder['items'][index]['packing']['label'];
    } catch (e) {
      return "";
    }
  }

  /// [price-decimal] `num` لا `int` — السعر قد يكون كسراً.
  ///
  /// كان `try/catch` لا ينقذ: كتلة `catch` تكرّر الضرب نفسه فترمي مرة أخرى.
  num totalItemPrice(int index) {
    final item = dataOrder['items'][index];
    final price = _asNum(item['price']);
    final qty = _asNum(item['quantity'] ?? 1);
    final packing = item['packing'];
    final packQty = packing is Map ? _asNum(packing['quantity'] ?? 1) : 1;
    return price * (packQty == 0 ? 1 : packQty) * qty;
  }

  static num _asNum(dynamic v) =>
      v is num ? v : (num.tryParse('${v ?? ''}') ?? 0);

  //==========التقييم==========

  /// حالة الإرسال لكل سطر — تمنع الضغط المزدوج وتعرض مؤشراً في مكانه.
  final RxnInt submittingItemIndex = RxnInt();
  final RxBool isSubmittingDriverRating = false.obs;

  /// مسوّدات التعليق — تبقى بعد فشل الإرسال فلا يُعيد التاجر الكتابة.
  final Map<String, String> _commentDrafts = <String, String>{};

  bool get isDelivered => isDeliveredStatus(dataOrder['status']);

  List get _items {
    final raw = dataOrder['items'];
    return raw is List ? raw : const [];
  }

  /// معرّف المنتج من البند — قد يصل ككائن مُعبّأ أو معرّف خام أو غائباً.
  String productIdOfItem(int index) {
    try {
      final p = _items[index]['product'];
      if (p is Map) return '${p['_id'] ?? p['id'] ?? ''}';
      return p == null ? '' : p.toString();
    } catch (_) {
      return '';
    }
  }

  String nameOfItem(int index) {
    try {
      return _items[index]['name']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  String imageOfItem(int index) {
    try {
      return _items[index]['image']?.toString() ?? '';
    } catch (_) {
      return '';
    }
  }

  Map<String, dynamic>? myRatingOfItem(int index) {
    try {
      final r = _items[index]['myRating'];
      return r is Map ? Map<String, dynamic>.from(r) : null;
    } catch (_) {
      return null;
    }
  }

  int myStarsOfItem(int index) {
    final r = myRatingOfItem(index);
    final s = r?['stars'];
    return s is num ? s.toInt() : int.tryParse('${s ?? ''}') ?? 0;
  }

  /// السطر الثاني فصاعداً لنفس المنتج (تعبئتان مختلفتان): تقييم واحد لكل منتج،
  /// فيُعطَّل زره ويُعرض تقييم توأمه.
  bool isDuplicateProductLine(int index) {
    final id = productIdOfItem(index);
    if (id.isEmpty) return false;
    for (var i = 0; i < index; i++) {
      if (productIdOfItem(i) == id) return true;
    }
    return false;
  }

  /// عدد المنتجات المختلفة التي لم تُقيَّم بعد.
  int get pendingRatingsCount {
    final seen = <String>{};
    var n = 0;
    for (var i = 0; i < _items.length; i++) {
      final id = productIdOfItem(i);
      if (id.isEmpty || seen.contains(id)) continue;
      seen.add(id);
      if (myStarsOfItem(i) == 0) n++;
    }
    return n;
  }

  int? get firstUnratedItemIndex {
    for (var i = 0; i < _items.length; i++) {
      if (productIdOfItem(i).isEmpty) continue;
      if (isDuplicateProductLine(i)) continue;
      if (myStarsOfItem(i) == 0) return i;
    }
    return null;
  }

  Map<String, dynamic>? get orderDriver {
    final d = dataOrder['driver'];
    return d is Map ? Map<String, dynamic>.from(d) : null;
  }

  Map<String, dynamic>? get myDriverRating {
    final r = dataOrder['driverRating'];
    return r is Map ? Map<String, dynamic>.from(r) : null;
  }

  int get myDriverStars {
    final s = myDriverRating?['stars'];
    return s is num ? s.toInt() : int.tryParse('${s ?? ''}') ?? 0;
  }

  String draftFor(String key) => _commentDrafts[key] ?? '';

  String get _orderObjectId =>
      (dataOrder['_id'] ?? dataOrder['id'] ?? '').toString();

  /// إرسال تقييم منتج مع كتابة تفاؤلية.
  Future<bool> submitProductRating({
    required int index,
    required int stars,
    required String comment,
  }) async {
    if (submittingItemIndex.value != null) return false;
    final orderId = _orderObjectId;
    final productId = productIdOfItem(index);
    if (orderId.isEmpty || productId.isEmpty) return false;

    _commentDrafts[productId] = comment;
    submittingItemIndex.value = index;
    try {
      final response = await model.rateProduct(
        orderId: orderId,
        productId: productId,
        stars: stars,
        comment: comment,
      );
      if (handlingData(response) != StatusRequest.success) {
        AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر حفظ التقييم');
        return false;
      }

      _commentDrafts.remove(productId);
      // التقييم يخص المنتج لا السطر ⇒ يُطبَّق على كل سطر يحمل نفس المنتج
      _writeMyRating(productId: productId, stars: stars, comment: comment);
      AppSnackBar.success(tryResponseMessage(response) ?? 'تم حفظ التقييم');
      return true;
    } finally {
      submittingItemIndex.value = null;
    }
  }

  Future<bool> submitDriverRating({
    required int stars,
    required String comment,
  }) async {
    if (isSubmittingDriverRating.value) return false;
    final orderId = _orderObjectId;
    if (orderId.isEmpty) return false;

    _commentDrafts['__driver__'] = comment;
    isSubmittingDriverRating.value = true;
    try {
      final response = await model.rateDriver(
        orderId: orderId,
        stars: stars,
        comment: comment,
      );
      if (handlingData(response) != StatusRequest.success) {
        AppSnackBar.error(
          tryResponseMessage(response) ?? 'تعذر حفظ تقييم السائق',
        );
        return false;
      }

      _commentDrafts.remove('__driver__');
      dataOrder['driverRating'] = <String, dynamic>{
        'stars': stars,
        'comment': comment,
        'ratedAt': DateTime.now().toIso8601String(),
      };
      dataOrder.refresh();
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم حفظ تقييم السائق',
      );
      return true;
    } finally {
      isSubmittingDriverRating.value = false;
    }
  }

  /// ⚠️ RxMap لا يراقب التعديل المتداخل: `items[i]['x'] = y` لا يُطلق أي إشعار.
  /// لذا نعيد إسناد المفتاح العلوي بقائمة جديدة ثم refresh().
  void _writeMyRating({
    required String productId,
    required int stars,
    required String comment,
  }) {
    final raw = dataOrder['items'];
    if (raw is! List) return;
    final items = List<dynamic>.from(raw);
    final payload = <String, dynamic>{
      'stars': stars,
      'comment': comment,
      'ratedAt': DateTime.now().toIso8601String(),
    };
    for (var i = 0; i < items.length; i++) {
      final it = items[i];
      if (it is! Map) continue;
      final p = it['product'];
      final id = p is Map ? '${p['_id'] ?? p['id'] ?? ''}' : '${p ?? ''}';
      if (id != productId) continue;
      items[i] = <String, dynamic>{...Map<String, dynamic>.from(it), 'myRating': payload};
    }
    dataOrder['items'] = items;
    dataOrder.refresh();
  }

  //===========api===========

  /// [silent] يمنع وميض الشاشة وفقدان موضع التمرير عند إعادة الجلب بعد إجراء.
  getOrder({bool silent = false}) async {
    if (!silent) {
      statusRequest.value = StatusRequest.loading;
      dataOrder.value = <String, dynamic>{};
    }

    final candidates = orderSearchCandidatesFromRouteArgs(
      Get.arguments,
      orderId,
    );
    if (candidates.isEmpty) {
      _orderDetailDiag(
        'getOrder: no search candidates — check payload / binding',
      );
      // لا معرّف للبحث → نفس حالة «الطلب غير موجود» (لا خطأ خادم)
      statusRequest.value = StatusRequest.empty;
      statusCode.value = 404;
      return;
    }

    dynamic response;
    for (var i = 0; i < candidates.length; i++) {
      final s = candidates[i];
      orderId = s;
      _orderDetailDiag(
        'getOrder: try ${i + 1}/${candidates.length} search="$s"',
      );
      response = await model.getOrders(search: s);
      final handled = handlingData(response);
      if (handled != StatusRequest.success) {
        statusCode.value = handlingStatusCode(response);
        statusRequest.value = handled;
        _orderDetailDiag('getOrder: failed on search="$s"');
        return;
      }
      final m = tryResponseMap(response);
      final orders = m?['orders'];
      if (orders is List && orders.isNotEmpty) {
        final first = orders[0];
        if (first is Map) {
          dataOrder.value = Map<String, dynamic>.from(first);
        }
        try {
          _orderDetailDiag(
            'getOrder: OK search="$s" items=${(dataOrder['items'] as List?)?.length ?? 0}',
          );
        } catch (_) {}
        break;
      }
      if (i == candidates.length - 1) {
        dataOrder.value = <String, dynamic>{};
        final total = m?['totalOrders'];
        _orderDetailDiag(
          'getOrder: all searches empty — totalOrders=$total lastSearch="$s"',
        );
        // الخادم يعيد 200 بقائمة فارغة عندما لا يوجد الطلب (حُذف من الإدارة أو
        // الرقم غير صحيح) — لا نعتبره نجاحاً فتُعرض صفحة صفرية بلا رسالة.
        statusRequest.value = StatusRequest.empty;
        statusCode.value = 404;
        return;
      }
    }

    if (response != null) {
      statusCode.value = handlingStatusCode(response);
      statusRequest.value = handlingData(response);
    }
    _orderDetailDiag(
      'getOrder: final statusRequest=${statusRequest.value} statusCode=${statusCode.value}',
    );
  }
}

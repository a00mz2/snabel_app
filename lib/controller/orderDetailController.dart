// ignore_for_file: non_constant_identifier_names

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/model/OrderModel.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

void _orderDetailDiag(String message) {
  if (kDebugMode) {
    debugPrint('[OrderDetailDiag] $message');
  }
}

const _orderIdKeys = [
  'orderNumber',
  'order_number',
  'orderId',
  'order_id',
];

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
    final candidates =
        orderSearchCandidatesFromRouteArgs(Get.arguments, orderId);
    if (candidates.isNotEmpty) {
      orderId = candidates.first;
    }
    _orderDetailDiag('onInit orderId="$orderId" Get.arguments=${Get.arguments}');
    getOrder();
  }

  @override
  void onReady() {
    super.onReady();
    final resolved = resolveOrderIdentifierFromArguments(Get.arguments);
    if (resolved != null &&
        resolved.isNotEmpty &&
        resolved != orderId) {
      _orderDetailDiag('onReady corrected orderId from "$orderId" to "$resolved"');
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

  int totalItemPrice(int index) {
    try {
      return (dataOrder['items'][index]['price'] *
          (dataOrder['items'][index]['packing']['quantity'] *
              dataOrder['items'][index]['quantity']));
    } catch (e) {
      return (dataOrder['items'][index]['price'] *
          dataOrder['items'][index]['quantity']);
    }
  }

  //===========api===========

  getOrder() async {
    statusRequest.value = StatusRequest.loading;
    dataOrder.value = <String, dynamic>{};

    final candidates =
        orderSearchCandidatesFromRouteArgs(Get.arguments, orderId);
    if (candidates.isEmpty) {
      _orderDetailDiag(
        'getOrder: no search candidates — check payload / binding',
      );
      statusRequest.value = StatusRequest.failure;
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

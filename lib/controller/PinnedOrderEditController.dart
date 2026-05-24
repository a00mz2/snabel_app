// ignore_for_file: avoid_print

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/pinned_order_utils.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/CartModel.dart';
import 'package:customer/model/PinnedOrdersModel.dart';
import 'package:customer/model/ProductsModel.dart';
import 'package:get/get.dart';

class PinnedLineEdit {
  PinnedLineEdit({
    required this.productId,
    required this.name,
    required this.quantity,
    this.price,
    this.imageFileName,
    this.packingRaw,
    this.availablePackings = const [],
  });

  String? productId;
  String name;
  int quantity;
  double? price;
  String? imageFileName;
  Map<String, dynamic>? packingRaw;
  List<Map<String, dynamic>> availablePackings;

  Map<String, dynamic> toItemPayload() {
    final pid = productId;
    if (pid == null || pid.isEmpty) {
      throw StateError('product id');
    }
    return <String, dynamic>{
      'product': pid,
      'quantity': quantity,
      if (packingRaw != null && packingRaw!.isNotEmpty) 'packing': packingRaw,
    };
  }
}

class PinnedOrderEditController extends GetxController {
  PinnedOrderEditController(this.pinnedOrderId);

  final String pinnedOrderId;
  final PinnedOrdersModel _pinnedApi = PinnedOrdersModel(Get.find());
  final ProductsModel _products = ProductsModel(Get.find());
  final CartModel _cart = CartModel(Get.find());

  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  final Rx<StatusRequest> statusSave = StatusRequest.success.obs;
  final RxInt statusCode = 200.obs;

  final RxList<Map<String, dynamic>> deliveryPeriods =
      <Map<String, dynamic>>[].obs;
  final RxList<PinnedLineEdit> lines = <PinnedLineEdit>[].obs;
  final RxList<Map<String, dynamic>> productCatalog =
      <Map<String, dynamic>>[].obs;

  final RxString repeatType = 'daily'.obs;
  final RxList<int> customDays = <int>[].obs;
  final RxnString selectedPeriodId = RxnString();

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  String _todayDateParam() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day).toIso8601String().split('T').first;
  }

  Future<void> _load() async {
    statusRequest.value = StatusRequest.loading;

    final dateStr = _todayDateParam();
    final periodsRes = await _cart.getDeliveryPeriods(dateStr);
    final detailRes = await _pinnedApi.getMyPinnedOrder(pinnedOrderId);
    final catalogRes = await _products.getProducts(page: 1);

    if (handlingData(periodsRes) == StatusRequest.success) {
      final m = tryResponseMap(periodsRes);
      final raw = m?['periods'];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) list.add(Map<String, dynamic>.from(e));
        }
      }
      deliveryPeriods.assignAll(list);
    }

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

    if (handlingData(detailRes) == StatusRequest.success) {
      final m = tryResponseMap(detailRes);
      final po = m?['pinnedOrder'];
      if (po is Map) {
        _applyPinnedMap(Map<String, dynamic>.from(po));
      }
    } else {
      AppSnackBar.error(tryResponseMessage(detailRes) ?? 'تعذر تحميل الطلب');
    }

    await _enrichPackings();

    statusCode.value = handlingStatusCode(detailRes);
    statusRequest.value = handlingData(detailRes);
  }

  void _applyPinnedMap(Map<String, dynamic> po) {
    final repeat = po['repeat'];
    if (repeat is Map) {
      final t = repeat['type']?.toString();
      repeatType.value = (t == 'custom' || t == 'daily') ? t! : 'daily';
      customDays.clear();
      final raw = repeat['daysOfWeek'];
      if (raw is List) {
        for (final e in raw) {
          final n = int.tryParse('$e');
          if (n != null && n >= 0 && n <= 6) customDays.add(n);
        }
      }
      customDays.sort();
    } else {
      repeatType.value = 'daily';
    }

    var pid = po['deliveryPeriodId']?.toString();
    if (pid != null && pid.isEmpty) pid = null;
    final embedded = po['deliveryPeriod'];
    if (pid == null && embedded is Map) {
      pid = '${embedded['_id'] ?? embedded['id'] ?? ''}';
      if (pid.isEmpty) pid = null;
    }
    if (pid != null &&
        !deliveryPeriods.any((p) => '${p['_id'] ?? p['id']}' == pid) &&
        embedded is Map) {
      deliveryPeriods.add(Map<String, dynamic>.from(embedded));
    }
    selectedPeriodId.value = pid;

    lines.clear();
    final items = po['items'];
    if (items is List) {
      for (final raw in items) {
        if (raw is! Map) continue;
        final item = Map<String, dynamic>.from(raw);
        final p = item['product'];
        String? productId;
        String name = '';
        double? price;
        String? img;
        if (p is Map) {
          final pm = Map<String, dynamic>.from(p);
          productId = '${p['_id'] ?? p['id'] ?? ''}';
          if (productId.isEmpty) productId = null;
          name = (p['name'] ?? '').toString();
          price = (p['price'] is num)
              ? (p['price'] as num).toDouble()
              : double.tryParse('${p['price']}');
          img = productMainImageFileName(pm) ?? p['mainImage']?.toString();
        } else if (p != null) {
          productId = p.toString();
        }
        Map<String, dynamic>? packing;
        if (item['packing'] is Map) {
          packing = Map<String, dynamic>.from(item['packing'] as Map);
        }
        final q = item['quantity'];
        final qty = q is num ? q.toInt() : int.tryParse('$q') ?? 1;
        lines.add(
          PinnedLineEdit(
            productId: productId,
            name: name.isEmpty ? 'منتج' : name,
            quantity: qty,
            price: price,
            imageFileName: img,
            packingRaw: packing,
          ),
        );
      }
    }
  }

  Future<void> _enrichPackings() async {
    for (var i = 0; i < lines.length; i++) {
      final id = lines[i].productId;
      if (id == null || id.isEmpty) {
        _ensureServerPackingOnly(lines[i]);
        continue;
      }
      final res = await _products.getProducts(id: id);
      if (handlingData(res) != StatusRequest.success) {
        _ensureServerPackingOnly(lines[i]);
        continue;
      }
      final m = tryResponseMap(res);
      Map<String, dynamic>? prod;
      final rawProducts = m?['products'];
      if (rawProducts is List && rawProducts.isNotEmpty) {
        final first = rawProducts.first;
        if (first is Map) prod = Map<String, dynamic>.from(first);
      }
      if (prod == null) {
        final single = m?['product'];
        if (single is Map) prod = Map<String, dynamic>.from(single);
      }
      final packs = prod!['packings'];
      final list = <Map<String, dynamic>>[];
      if (packs is List) {
        for (final e in packs) {
          if (e is Map) list.add(Map<String, dynamic>.from(e));
        }
      }

      final rawPacking = lines[i].packingRaw;
      Map<String, dynamic>? merged = rawPacking;

      if (rawPacking != null && rawPacking.isNotEmpty) {
        Map<String, dynamic>? match;
        for (final p in list) {
          if (packingMapsLooselyMatch(p, rawPacking)) {
            match = p;
            break;
          }
        }
        if (match != null) {
          final mid = match['_id']?.toString() ?? match['id']?.toString();
          merged = <String, dynamic>{
            ...match,
            'label': match['label'] ?? rawPacking['label'],
            'quantity': match['quantity'] ?? rawPacking['quantity'],
            if (mid != null && mid.isNotEmpty) '_id': mid,
          };
        } else {
          list.insert(0, Map<String, dynamic>.from(rawPacking));
          merged = Map<String, dynamic>.from(rawPacking);
        }
      }

      lines[i].availablePackings = list;
      lines[i].packingRaw = merged;

      final imgName = productMainImageFileName(prod);
      if (imgName != null && imgName.isNotEmpty) {
        lines[i].imageFileName = imgName;
      }
    }
    lines.refresh();
  }

  void _ensureServerPackingOnly(PinnedLineEdit line) {
    final r = line.packingRaw;
    if (r == null || r.isEmpty) return;
    if (line.availablePackings.isEmpty) {
      line.availablePackings = [Map<String, dynamic>.from(r)];
    }
  }

  void setRepeatType(String t) {
    repeatType.value = t;
    if (t == 'daily') {
      customDays.clear();
    }
  }

  void toggleDay(int d) {
    if (customDays.contains(d)) {
      customDays.remove(d);
    } else {
      customDays.add(d);
    }
    customDays.sort();
    customDays.refresh();
  }

  void setPeriod(String? id) {
    selectedPeriodId.value = id;
  }

  void bumpQty(int index, int delta) {
    final l = lines[index];
    final n = l.quantity + delta;
    if (n >= 1) l.quantity = n;
    lines.refresh();
  }

  void removeLine(int index) {
    lines.removeAt(index);
  }

  void setPacking(int index, Map<String, dynamic>? pack) {
    lines[index].packingRaw = pack;
    lines.refresh();
  }

  void selectPackingLine(int index, Map<String, dynamic> p) {
    final id = p['_id']?.toString() ?? p['id']?.toString();
    final label = p['label']?.toString() ?? '';
    final q = p['quantity'];
    setPacking(index, <String, dynamic>{
      'label': label,
      'quantity': q is num ? q : int.tryParse('$q') ?? 1,
      if (id != null && id.isNotEmpty) '_id': id,
    });
  }

  void addProductFromCatalog(Map<String, dynamic> prod) {
    final id = '${prod['_id'] ?? prod['id'] ?? ''}';
    if (id.isEmpty) return;
    final name = (prod['name'] ?? '').toString();
    final price = (prod['price'] is num)
        ? (prod['price'] as num).toDouble()
        : double.tryParse('${prod['price']}');
    final img = prod['mainImage']?.toString();
    final packs = prod['packings'];
    List<Map<String, dynamic>> packList = [];
    Map<String, dynamic>? firstPack;
    if (packs is List && packs.isNotEmpty && packs.first is Map) {
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
      PinnedLineEdit(
        productId: id,
        name: name,
        quantity: 1,
        price: price,
        imageFileName: img,
        packingRaw: firstPack,
        availablePackings: packList,
      ),
    );
  }

  Map<String, dynamic> _repeatBody() {
    if (repeatType.value == 'daily') {
      return {'type': 'daily'};
    }
    final sorted = List<int>.from(customDays)..sort();
    return {'type': 'custom', 'daysOfWeek': sorted};
  }

  Future<void> save() async {
    final periodId = selectedPeriodId.value;
    if (periodId == null || periodId.isEmpty) {
      AppSnackBar.error('اختر فترة التوصيل');
      return;
    }
    if (repeatType.value == 'custom' && customDays.isEmpty) {
      AppSnackBar.error('اختر يوماً واحداً على الأقل للتكرار المخصص');
      return;
    }
    if (lines.isEmpty) {
      AppSnackBar.error('أضف صنفاً واحداً على الأقل');
      return;
    }

    final items = <Map<String, dynamic>>[];
    try {
      for (final l in lines) {
        items.add(l.toItemPayload());
      }
    } catch (_) {
      AppSnackBar.error('بيانات الأصناف غير كاملة');
      return;
    }

    statusSave.value = StatusRequest.loading;
    final response = await _pinnedApi.updateMyPinnedOrder({
      'pinnedOrderId': pinnedOrderId,
      'repeat': _repeatBody(),
      'deliveryPeriodId': periodId,
      'items': items,
    });

    if (handlingData(response) == StatusRequest.success) {
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم حفظ التعديلات بنجاح',
      );
      Get.back(result: true);
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر الحفظ');
    }
    statusSave.value = handlingData(response);
  }

  static String arWeekday(int i) {
    const names = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];
    if (i < 0 || i >= names.length) return '$i';
    return names[i];
  }
}

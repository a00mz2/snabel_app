import 'package:customer/core/functions/formatDate.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/linkApi.dart';

/// مُعرّف الطلب المثبت من مستند الـ API.
String? pinnedOrderIdFromMap(Map<String, dynamic>? m) {
  if (m == null) return null;
  final v = m['_id'] ?? m['id'];
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

String productLineName(Map<String, dynamic> item) {
  final p = item['product'];
  if (p is Map) {
    return (p['name'] ?? '').toString();
  }
  return (item['name'] ?? '').toString();
}

/// اسم ملف الصورة الرئيسية من كائن منتج (السيرفر يستخدم `images[].name` وليس `mainImage`).
String? productMainImageFileName(Map<String, dynamic> p) {
  final direct = p['mainImage'] ?? p['image'];
  if (direct != null && '$direct'.trim().isNotEmpty) {
    return direct.toString().trim();
  }
  final images = p['images'];
  if (images is! List || images.isEmpty) return null;
  for (final e in images) {
    if (e is Map && e['isMain'] == true) {
      final n = e['name'];
      if (n != null && '$n'.trim().isNotEmpty) return n.toString().trim();
    }
  }
  final first = images.first;
  if (first is Map && first['name'] != null) {
    return first['name'].toString().trim();
  }
  final idx = p['mainImageIndex'];
  if (idx is num && images.isNotEmpty) {
    final i = idx.toInt().clamp(0, images.length - 1);
    final el = images[i];
    if (el is Map && el['name'] != null) {
      return el['name'].toString().trim();
    }
  }
  return null;
}

String? productLineImageUrl(Map<String, dynamic> item) {
  final top = item['image'];
  if (top != null && '$top'.trim().isNotEmpty) {
    return Applink.productImage(top.toString().trim());
  }
  final p = item['product'];
  if (p is Map) {
    final fn = productMainImageFileName(Map<String, dynamic>.from(p));
    if (fn != null && fn.isNotEmpty) {
      return Applink.productImage(fn);
    }
  }
  return null;
}

String formatPinnedDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return '—';
  final d = DateTime.tryParse(raw);
  if (d == null) return raw;
  return formatDate(d);
}

String formatMoney(num? v) {
  if (v == null) return '—';
  return '${formatNumberNum(v)} د.ع';
}

/// تسمية التكرار من الحقول المعرّبة في الـ API أو من النوع.
String repeatSummary(Map<String, dynamic>? repeat) {
  if (repeat == null) return '—';
  final ar = repeat['typeLabelAr']?.toString().trim();
  if (ar != null && ar.isNotEmpty) return ar;
  final t = repeat['type']?.toString();
  if (t == 'daily') return 'يومي';
  if (t == 'custom') {
    final days = repeat['daysLabelsAr'];
    if (days is List && days.isNotEmpty) {
      final parts = <String>[];
      for (final e in days) {
        if (e is Map && e['labelAr'] != null) {
          parts.add('${e['labelAr']}');
        }
      }
      if (parts.isNotEmpty) return parts.join('، ');
    }
    return 'أيام محددة';
  }
  return t ?? '—';
}

String orderNumberLabel(Map<String, dynamic> data) {
  final o = data['order'];
  if (o is Map) {
    final n = o['orderNumber'];
    if (n != null && '$n'.isNotEmpty) return 'طلب رقم $n';
  }
  final n = data['orderNumber'];
  if (n != null && '$n'.isNotEmpty) return 'طلب رقم $n';
  return 'طلب مثبت';
}

// --- تغليف الطلب المثبت (مطابقة السيرفر مع كتالوج المنتج) ---

num packingQty(dynamic q) {
  if (q == null) return 0;
  if (q is num) return q;
  return num.tryParse(q.toString()) ?? 0;
}

/// سطر عرض التغليف في تفاصيل الطلب (مثلاً: كرتون ×6).
String productPackingDisplayLine(Map<String, dynamic> item) {
  final pk = item['packing'];
  if (pk is! Map) return '';
  final m = Map<String, dynamic>.from(pk);
  final label = m['label']?.toString().trim() ?? '';
  if (label.isEmpty) return '';
  final q = packingQty(m['quantity']);
  return '$label ×$q';
}

/// مفتاح مستقر لعنصر تغليف داخل القائمة المنسدلة.
String packingKey(Map<String, dynamic> p) {
  final id = p['_id']?.toString() ?? p['id']?.toString() ?? '';
  if (id.isNotEmpty) return id;
  final l = p['label']?.toString() ?? '';
  return '${l}_${packingQty(p['quantity'])}';
}

bool packingMapsLooselyMatch(Map<String, dynamic> a, Map<String, dynamic> b) {
  final idA = a['_id']?.toString() ?? a['id']?.toString() ?? '';
  final idB = b['_id']?.toString() ?? b['id']?.toString() ?? '';
  if (idA.isNotEmpty && idB.isNotEmpty && idA == idB) return true;
  final la = a['label']?.toString() ?? '';
  final lb = b['label']?.toString() ?? '';
  if (la.isEmpty && lb.isEmpty) return false;
  return la == lb && packingQty(a['quantity']) == packingQty(b['quantity']);
}

/// قيمة [Dropdown] تطابق تغليف السيرفر (غالباً بدون `_id`) مع أصناف المنتج.
String? resolvePackingDropdownValue({
  required List<Map<String, dynamic>> available,
  required Map<String, dynamic>? raw,
}) {
  if (available.isEmpty) return null;
  if (raw == null || raw.isEmpty) {
    return packingKey(available.first);
  }
  final rid = raw['_id']?.toString() ?? raw['id']?.toString() ?? '';
  if (rid.isNotEmpty) {
    for (final p in available) {
      final pid = p['_id']?.toString() ?? p['id']?.toString() ?? '';
      if (pid.isNotEmpty && pid == rid) {
        return packingKey(p);
      }
    }
  }
  for (final p in available) {
    if (packingMapsLooselyMatch(p, raw)) {
      return packingKey(p);
    }
  }
  return packingKey(available.first);
}

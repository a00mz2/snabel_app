import 'dart:typed_data';

import 'package:customer/core/class/crud.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/driver/core/class/crud.dart' as driver_crud;
import 'package:customer/driver/core/class/statusRequest.dart' as driver_status;
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

/// طبقة النقل لـ«تواصل مع الدعم»، مجرّدة عن دور الجلسة.
///
/// ⚠️ سبب وجودها: التطبيق ملف تنفيذي واحد لدورين، ولكل دور طبقة HTTP مختلفة كلياً.
/// [Crud] (الزبون) و[driver_crud.DriverCrud] (السائق) لا يتشاركان لا الواجهة ولا
/// **نقطة تجديد التوكن**: الزبون يجدّد عبر `CustomersRefreshToken` والسائق عبر
/// `DriverRefreshToken`، ولكلٍّ حارس جلسة مستقل. استعمال طبقة الزبون في جلسة سائق يعني
/// أن أول انتهاء توكن يضرب نقطة تجديد الزبون فيفشل ويُخرج السائق من التطبيق.
///
/// الدردشة نفسها (النموذج والكنترولر والشاشة) لا تعرف شيئاً عن هذا — تتعامل مع هذه
/// الواجهة وحدها، فلا توجد نسخة سائق من شاشة الدردشة.
///
/// كل دالة تُعيد النتيجة **مطويّة** (`dynamic`): إمّا `Map` أو `StatusRequest` الخاص
/// بالزبون. السبب في [_DriverSupportHttp._toCustomerWorld].
abstract class SupportHttp {
  Future<dynamic> postJson(String url, Map<String, dynamic> body);

  Future<dynamic> getJson(String url);

  /// رفع صورة واحدة تحت اسم الحقل `image` — يطابق `upload.single("image")` في الخادم.
  Future<dynamic> postImage(String url, Uint8List bytes);

  /// توكن طازج قبل مصافحة السوكِت. `true` إن نجح التجديد.
  Future<bool> refreshToken();

  /// يختار التنفيذ المناسب لدور الجلسة الحالية.
  factory SupportHttp.forCurrentRole() {
    return Applink.sessionRole == 'driver'
        ? _DriverSupportHttp()
        : _CustomerSupportHttp();
  }
}

class _CustomerSupportHttp implements SupportHttp {
  final Crud _crud = Get.find<Crud>();

  @override
  Future<dynamic> postJson(String url, Map<String, dynamic> body) async {
    final response = await _crud.postData(url, body);
    return response.fold((l) => l, (r) => r);
  }

  @override
  Future<dynamic> getJson(String url) async {
    final response = await _crud.getData(url);
    return response.fold((l) => l, (r) => r);
  }

  @override
  Future<dynamic> postImage(String url, Uint8List bytes) async {
    final response = await _crud.postDataWithFiles(
      url,
      <String, dynamic>{},
      <String, Uint8List>{'image': bytes},
    );
    return response.fold((l) => l, (r) => r);
  }

  @override
  Future<bool> refreshToken() => _crud.refreshToken();
}

class _DriverSupportHttp implements SupportHttp {
  final driver_crud.DriverCrud _crud = driver_crud.DriverCrud();

  /// ⚠️ في المشروع **نوعا `StatusRequest`**: واحد للزبون وآخر للسائق، بأعضاء متطابقة
  /// لكنهما نوعان مختلفان. و`DriverCrud` يضع نسخته داخل مفتاح `statusRequest` في الخريطة
  /// المُعادة. لو وصلت تلك الخريطة إلى `handlingData` الخاص بالزبون لانهار عند
  /// `data["statusRequest"] as StatusRequest` بخطأ نوع وقت التشغيل.
  /// لذا نترجم هنا عند الحدود بالاسم — الحدّ الوحيد الذي يلتقي فيه العالمان.
  static StatusRequest _translate(driver_status.StatusRequest s) {
    return StatusRequest.values.firstWhere(
      (c) => c.name == s.name,
      orElse: () => StatusRequest.failure,
    );
  }

  static dynamic _toCustomerWorld(dynamic folded) {
    if (folded is driver_status.StatusRequest) return _translate(folded);
    if (folded is Map) {
      final raw = folded['statusRequest'];
      if (raw is driver_status.StatusRequest) {
        return <dynamic, dynamic>{...folded, 'statusRequest': _translate(raw)};
      }
    }
    return folded;
  }

  Future<dynamic> _run(Future<dynamic> Function() call) async {
    final response = await call();
    final folded = response.fold((l) => l, (r) => r);
    return _toCustomerWorld(folded);
  }

  @override
  Future<dynamic> postJson(String url, Map<String, dynamic> body) =>
      _run(() => _crud.request(method: 'POST', url: url, data: body));

  @override
  Future<dynamic> getJson(String url) =>
      _run(() => _crud.request(method: 'GET', url: url));

  /// `DriverCrud` يضغط الصورة ويعيد ترميزها JPEG قبل الرفع — مطابق للقائمة البيضاء في الخادم.
  @override
  Future<dynamic> postImage(String url, Uint8List bytes) => _run(
    () => _crud.request(
      method: 'MULTIPART',
      url: url,
      files: <String, Uint8List>{'image': bytes},
    ),
  );

  @override
  Future<bool> refreshToken() => _crud.ensureFreshToken();
}

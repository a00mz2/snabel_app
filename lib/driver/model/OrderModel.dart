import 'dart:typed_data';

import 'package:customer/driver/core/class/crud.dart';
import 'package:customer/driver/core/constant/size.dart';
import 'package:customer/driver/core/services/services.dart';
import 'package:customer/driver/linkApi.dart';
import 'package:get/get.dart';

class OrderModel {
  Myservices myservices = Get.find();
  DriverCrud crud;

  OrderModel(this.crud);

  getOrders({status = const ["all"], page = 1, search = ""}) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.getOrders,
      data: {"page": page, "limit": limit, "status": status, "search": search},
    );
    return response.fold((failure) => failure, (data) => data);
  }

  /// تعديل محتوى الطلب قبل التسليم — POST driver/updateOrderContent.
  /// [items]: [{itemId, quantity}] أو [{itemId, remove: true}].
  updateOrderContent({
    required String orderId,
    String? expectedUpdatedAt,
    required List<Map<String, dynamic>> items,
  }) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.updateOrderContent,
      data: {
        "orderId": orderId,
        if (expectedUpdatedAt != null && expectedUpdatedAt.isNotEmpty)
          "expectedUpdatedAt": expectedUpdatedAt,
        "changes": {"items": items},
      },
    );
    return response.fold((failure) => failure, (data) => data);
  }

  /// [rejection]: `{code, details?}` — إلزامي عند «مرفوض» (الخادم يرفض بدونه بـ 400).
  updateStatusOrder({status, orderId, Map<String, dynamic>? rejection}) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.updateStatusOrder,
      data: {
        "orderId": orderId,
        "newStatus": status,
        if (rejection != null) "rejection": rejection,
      },
    );
    return response.fold((failure) => failure, (data) => data);
  }

  /// «تم التسليم» يمرّ حصراً من هنا مع صورة تأكيد (الخادم يرفض updateStatusOrder للسائق).
  Future<dynamic> deliverOrder({
    required String orderId,
    required Uint8List proof,
  }) async {
    var response = await crud.request(
      method: "MULTIPART",
      url: DriverApplink.deliverOrder,
      data: {"orderId": orderId},
      files: {"proof": proof},
      methodMultipart: "POST",
    );
    return response.fold((failure) => failure, (data) => data);
  }

  /// تأكيد استلام المبلغ النقدي من الزبون (قبل التسليم).
  Future<dynamic> confirmCashCollection({required String orderId}) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.confirmOrderCashCollection,
      data: {"orderId": orderId},
    );
    return response.fold((failure) => failure, (data) => data);
  }
}

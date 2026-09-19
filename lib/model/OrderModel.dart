import 'package:customer/core/class/crud.dart';
import 'package:customer/core/constant/size.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class OrderModel {
  Myservices myservices = Get.find();
  Crud crud;

  OrderModel(this.crud);

  Future<dynamic> getOrders({status, page, search}) async {
    var response = await crud.postData(Applink.getOrders, {
      "page": page ?? 1,
      "limit": limit,
      "status": status ?? "all",
      "search": search ?? "",
    });
    return response.fold((failure) => failure, (data) => data);
  }

  /// تقييم منتج داخل طلب مُسلَّم (إرسال أو تعديل — الخادم يميّز بنفسه).
  Future<dynamic> rateProduct({
    required String orderId,
    required String productId,
    required int stars,
    String comment = '',
  }) async {
    var response = await crud.postData(Applink.rateOrderProduct, {
      'orderId': orderId,
      'productId': productId,
      'stars': stars,
      if (comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
    return response.fold((failure) => failure, (data) => data);
  }

  /// تقييم سائق الطلب بعد التسليم.
  Future<dynamic> rateDriver({
    required String orderId,
    required int stars,
    String comment = '',
  }) async {
    var response = await crud.postData(Applink.rateOrderDriver, {
      'orderId': orderId,
      'stars': stars,
      if (comment.trim().isNotEmpty) 'comment': comment.trim(),
    });
    return response.fold((failure) => failure, (data) => data);
  }

  /// تعديل محتوى الطلب وهو «جديد» — POST customer/updateOrderContent.
  /// body: { orderId, expectedUpdatedAt?, changes: { items: [...], additions: [...] } }
  Future<dynamic> updateOrderContent(Map<String, dynamic> body) async {
    var response = await crud.postData(Applink.updateOrderContent, body);
    return response.fold((failure) => failure, (data) => data);
  }
}

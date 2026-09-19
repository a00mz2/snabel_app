import 'package:customer/core/class/crud.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class CartModel {
  Myservices myservices = Get.find();
  Crud crud;

  CartModel(this.crud);

  Future<dynamic> addToCart(
    String productId,
    int quantity, {
    String? packingId,
  }) async {
    var response = await crud.postData(Applink.addToCart, {
      "productId": productId,
      "packingId": packingId ?? "",
      "quantity": quantity,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> updateCartQuantity(String productCartId, int quantity) async {
    var response = await crud.postData(Applink.updateCartQuantity, {
      "productCartId": productCartId,
      "quantity": quantity,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> removeFromCart(String productCartId) async {
    var response = await crud.postData(Applink.removeFromCart, {
      "productCartId": productCartId,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> getCart() async {
    var response = await crud.postData(Applink.getCart, {});
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> getDeliveryPeriods(deliveryDate) async {
    var response = await crud.postData(Applink.getDeliveryPeriods, {
      'deliveryDate': deliveryDate,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  /// [note]: ملاحظة الزبون على الطلب (اختيارية، ≤ 500 حرف).
  /// [codMode]: `excess` أو `full` — يُرسل فقط بعد أن يختار الزبون الدفع نقداً
  /// عند تجاوز الحد الائتماني (الخادم يعيد 400 `CREDIT_LIMIT_EXCEEDED` بدونه).
  Future<dynamic> createOrderFromCart(
    deliveryPeriodId,
    deliveryDate, {
    String? note,
    String? codMode,
    String? paymentMethod,
  }) async {
    var response = await crud.postData(Applink.createOrderFromCart, {
      'deliveryPeriodId': deliveryPeriodId,
      'deliveryDate': deliveryDate,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      if (codMode != null) 'codMode': codMode,
      // [pay-method] cash = لا يُخصم من المحفظة ولا يخضع للحد المالي
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        'paymentMethod': paymentMethod,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> createPinnedOrder(
    deliveryPeriodId,
    daysOfWeek, {
    String? paymentMethod,
  }) async {
    var response = await crud.postData(Applink.createPinnedOrder, {
      "deliveryPeriodId": deliveryPeriodId,
      "repeat": {"type": "custom", "daysOfWeek": daysOfWeek},
      // [pay-method] طريقة ثابتة لكل طلب يولّده هذا القالب يومياً
      if (paymentMethod != null && paymentMethod.isNotEmpty)
        "paymentMethod": paymentMethod,
    });
    return response.fold((failure) => failure, (data) => data);
  }
}

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

  Future<dynamic> createOrderFromCart(deliveryPeriodId, deliveryDate) async {
    var response = await crud.postData(Applink.createOrderFromCart, {
      'deliveryPeriodId': deliveryPeriodId,
      'deliveryDate': deliveryDate,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> createPinnedOrder(deliveryPeriodId, daysOfWeek) async {
    var response = await crud.postData(Applink.createPinnedOrder, {
      "deliveryPeriodId": deliveryPeriodId,
      "repeat": {"type": "custom", "daysOfWeek": daysOfWeek},
    });
    return response.fold((failure) => failure, (data) => data);
  }
}

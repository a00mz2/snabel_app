import 'package:customer/core/class/crud.dart';
import 'package:customer/linkApi.dart';

class PinnedOrdersModel {
  final Crud crud;

  PinnedOrdersModel(this.crud);

  Future<dynamic> listMyPinnedOrders({
    int page = 1,
    int limit = 10,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{
      'page': page,
      'limit': limit,
    };
    if (isActive != null) body['isActive'] = isActive;
    final response = await crud.postData(Applink.listMyPinnedOrders, body);
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> getMyPinnedOrder(String pinnedOrderId) async {
    final response = await crud.postData(Applink.getMyPinnedOrder, {
      'pinnedOrderId': pinnedOrderId,
    });
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> updateMyPinnedOrder(Map<String, dynamic> body) async {
    final response = await crud.postData(Applink.updateMyPinnedOrder, body);
    return response.fold((l) => l, (r) => r);
  }

  Future<dynamic> deleteMyPinnedOrder(String pinnedOrderId) async {
    final response = await crud.postData(Applink.deleteMyPinnedOrder, {
      'pinnedOrderId': pinnedOrderId,
    });
    return response.fold((l) => l, (r) => r);
  }
}

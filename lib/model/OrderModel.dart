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
}

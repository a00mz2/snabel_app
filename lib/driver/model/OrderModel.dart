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

  updateStatusOrder({status, orderId}) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.updateStatusOrder,
      data: {"orderId": orderId, "newStatus": status},
    );
    return response.fold((failure) => failure, (data) => data);
  }
}

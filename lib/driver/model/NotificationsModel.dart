import 'package:customer/driver/core/class/crud.dart';
import 'package:customer/driver/core/constant/size.dart';
import 'package:customer/driver/core/services/services.dart';
import 'package:customer/driver/linkApi.dart';
import 'package:get/get.dart';

class NotificationsModel {
  Myservices myservices = Get.find();
  DriverCrud crud;

  NotificationsModel(this.crud);

  Future<dynamic> getNotifications({int? page}) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.getNotifications,
      data: {"page": page ?? 1, "limit": limit},
    );
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> getUnreadCount({int? page}) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.getUnreadCount,

      data: {},
    );
    return response.fold((failure) => failure, (data) => data);
  }
}

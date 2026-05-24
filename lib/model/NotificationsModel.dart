import 'package:customer/core/class/crud.dart';
import 'package:customer/core/constant/size.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class NotificationsModel {
  Myservices myservices = Get.find();
  Crud crud;

  NotificationsModel(this.crud);

  Future<dynamic> getNotifications({int? page}) async {
    var response = await crud.postData(Applink.getNotifications, {
      "page": page ?? 1,
      "limit": limit,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> getUnreadCount({int? page}) async {
    var response = await crud.postData(Applink.getUnreadCount, {});
    return response.fold((failure) => failure, (data) => data);
  }
}

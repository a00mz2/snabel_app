import 'package:customer/driver/core/class/crud.dart';
import 'package:customer/driver/core/services/services.dart';
import 'package:customer/driver/linkApi.dart';
import 'package:get/get.dart';

class LoginModel {
  Myservices myservices = Get.find();
  DriverCrud crud;

  LoginModel(this.crud);

  Future<dynamic> login(String userName, String password) async {
    var response = await crud.request(
      method: "POST",
      isPublic: true,
      url: DriverApplink.login,
      data: {"phone": userName, "password": password},
    );

    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> addDriverToken(deviceToken) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.addDriverToken,
      data: {"deviceToken": deviceToken},
    );
    return response.fold((failure) => failure, (data) => data);
  }

  /// حذف توكن FCM للجهاز الحالي عند تسجيل الخروج.
  Future<dynamic> removeDriverToken(String deviceToken) async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.removeDriverToken,
      data: {"deviceToken": deviceToken},
    );
    return response.fold((failure) => failure, (data) => data);
  }
}

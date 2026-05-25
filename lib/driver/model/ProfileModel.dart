import 'package:customer/driver/core/class/crud.dart';
import 'package:customer/driver/core/services/services.dart';
import 'package:customer/driver/linkApi.dart';
import 'package:get/get.dart';

class ProfileModel {
  Myservices myservices = Get.find();
  DriverCrud crud;

  ProfileModel(this.crud);

  Future<dynamic> getDriverProfile() async {
    var response = await crud.request(
      method: "POST",
      url: DriverApplink.getDriverProfile,
      data: {},
    );

    return response.fold((failure) => failure, (data) => data);
  }
}

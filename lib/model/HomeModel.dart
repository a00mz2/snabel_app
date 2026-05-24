import 'package:customer/core/class/crud.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class HomeModel {
  Myservices myservices = Get.find();
  Crud crud;

  HomeModel(this.crud);

  Future<dynamic> getDataHome() async {
    var response = await crud.postData(Applink.GetDataHome, {});
    return response.fold((failure) => failure, (data) => data);
  }
}

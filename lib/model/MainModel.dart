import 'package:customer/core/class/crud.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class MainModel {
  Myservices myservices = Get.find();
  Crud crud;

  MainModel(this.crud);

  Future<dynamic> getDataCustomer() async {
    var response = await crud.postData(Applink.getDataCustomer, {});
    print(response);
    return response.fold((failure) => failure, (data) => data);
  }
}

import 'package:customer/core/class/crud.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class LoginModel {
  Myservices myservices = Get.find();
  Crud crud;

  LoginModel(this.crud);

  Future<dynamic> login(String userName, String password) async {
    var response = await crud.postData(Applink.login, isRetry: true, {
      "phone": userName,
      "password": password,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> addToken(String tokin) async {
    var response = await crud.postData(Applink.addToken, isRetry: true, {
      "token": tokin,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> removeToken(String tokin) async {
    var response = await crud.postData(Applink.removeToken, isRetry: true, {
      "token": tokin,
    });
    return response.fold((failure) => failure, (data) => data);
  }
}

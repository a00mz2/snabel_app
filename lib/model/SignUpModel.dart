import 'dart:typed_data';
import 'package:customer/core/class/crud.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class SignUpModel {
  Myservices myservices = Get.find();
  Crud crud;

  SignUpModel(this.crud);

  Future<dynamic> createOtp(String phone) async {
    var response = await crud.postData(Applink.createOtp, isRetry: true, {
      "phone": phone,
      "action": "register",
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> createCustomer({
    String? customerName,
    String? storeName,
    String? province, //المحافظة
    String? phone,
    String? password,
    String? otp,
    String? address,
    String? storeLocation,
    String? type,
    String? secondaryPhone,
    Uint8List? document,
  }) async {
    print("=======================");
    print(type);
    print("=======================");
    var response = await crud.postDataWithFiles(
      Applink.createCustomer,
      isRetry: true,
      {
        "customerName": customerName,
        "StoreName": storeName,
        "province": province,
        "phone": phone,
        "password": password,
        "otp": otp,
        "address": address,
        "storeLocation": storeLocation,
        "Type": type,
        "secondaryPhone": secondaryPhone,
      },
      {"document": ?document},
    );
    return response.fold((failure) => failure, (data) => data);
  }
}

import 'package:customer/core/class/crud.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class ProfileModel {
  Myservices myservices = Get.find();
  Crud crud;

  ProfileModel(this.crud);

  Future<dynamic> getDataCustomer() async {
    var response = await crud.postData(Applink.getDataCustomer, {});
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> softDeleteMyAccount() async {
    var response = await crud.postData(Applink.softDeleteMyAccount, {});
    return response.fold((failure) => failure, (data) => data);
  }

  updateCustomer(
    String name,
    String secondaryPhone, {
    Uint8List? imageElmint,
  }) async {
    // ⚠️ بلا isRetry: تمريرها على النداء **الأول** يُقنع طبقة HTTP أن هذه إعادة محاولة
    // بعد تجديد، فلا تُجدِّد التوكن عند 401 ويموت الحفظ بعد ١٥ دقيقة خمول.
    var response = await crud.postDataWithFiles(
      Applink.updateCustomer,
      {
        "customerName": name,
        "secondaryPhone": secondaryPhone,
      },
      imageElmint == null ? {} : {"storeImage": imageElmint},
    );
    return response.fold((failure) => failure, (data) => data);
  }
}

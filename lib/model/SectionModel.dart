import 'package:customer/core/class/crud.dart';
import 'package:customer/core/constant/size.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class SectionModel {
  Myservices myservices = Get.find();
  Crud crud;

  SectionModel(this.crud);

  Future<dynamic> getSection({int? page}) async {
    var response = await crud.postData(Applink.getCategories, {
      "page": page ?? 1,
      "limit": limit + 1,
      "isActive": true,
    });
    return response.fold((failure) => failure, (data) => data);
  }
}

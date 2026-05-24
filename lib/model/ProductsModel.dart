import 'package:customer/core/class/crud.dart';
import 'package:customer/core/constant/size.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class ProductsModel {
  Myservices myservices = Get.find();
  Crud crud;

  ProductsModel(this.crud);

  Future<dynamic> getProducts({
    String? search,
    category,
    int? page,
    bool? isMostRequested,
    String? id,
    bool? favoritesOnly,
  }) async {
    var response = await crud.postData(Applink.getProducts, {
      "page": page ?? 1,
      "limit": limit,
      "category": category ?? "",
      "isActive": "true",
      "isMostRequested": isMostRequested,
      "search": search ?? "",
      "id": id ?? "",
      "favoritesOnly": favoritesOnly ?? false,
    });

    return response.fold((failure) => failure, (data) => data);
  }
}

import 'package:customer/core/class/crud.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class FavoriteModel {
  Myservices myservices = Get.find();
  Crud crud;

  FavoriteModel(this.crud);

  Future<dynamic> toggleFavorite(String productId, bool toggle) async {
    var response = await crud.postData(Applink.toggleFavorite, {
      "productId": productId,
      "toggle": toggle,
    });
    return response.fold((failure) => failure, (data) => data);
  }

  Future<dynamic> getFavorites(String productId, bool toggle) async {
    var response = await crud.postData(Applink.getFavorites, {});
    return response.fold((failure) => failure, (data) => data);
  }
}

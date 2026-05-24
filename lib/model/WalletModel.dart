import 'package:customer/core/class/crud.dart';
import 'package:customer/core/constant/size.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class WalletModel {
  Myservices myservices = Get.find();
  Crud crud;

  WalletModel(this.crud);

  Future<dynamic> getTransactions({String? specificDate, int? page}) async {
    print('page=========');
    print(page);
    var response = await crud.postData(Applink.getTransactions, {
      "page": page ?? 1,
      "limit": limit,
      "specificDate": specificDate ?? "",
    });
    return response.fold((failure) => failure, (data) => data);
  }
}

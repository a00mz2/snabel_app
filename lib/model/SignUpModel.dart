import 'dart:typed_data';
import 'package:customer/core/class/crud.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:get/get.dart';

class SignUpModel {
  Myservices myservices = Get.find();
  Crud crud;

  SignUpModel(this.crud);

  /// إنشاء الحساب — [otp] الرمز المرسل إلى واتساب (يُتحقَّق ويُستهلك في الخادم).
  /// طلب الرمز نفسه عبر OtpModel.requestOtp.
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
    // مسار عام — لا يتطلب توكن، ولا داعي للـ retry بعد 401
    var response = await crud.postDataWithFiles(
      Applink.createCustomer,
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
      isRetry: false,
      isPublicRoutes: true,
    );
    return response.fold((failure) => failure, (data) => data);
  }
}

import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/model/ProfileModel.dart';
import 'package:get/get.dart';

class DriverProfileController extends GetxController {
  ProfileModel data = ProfileModel(Get.find());
  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  var dataAcoont = {}.obs;

  @override
  void onInit() {
    super.onInit();
    getDriverProfile();
  }

  getDriverProfile() async {
    statusRequest.value = StatusRequest.loading;
    var response = await data.getDriverProfile();
    if (handlingData(response) == StatusRequest.success && response is Map) {
      dataAcoont.value = response['driver'];
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'خطأ غير متوقع'));
    }
    statusRequest.value = handlingData(response);
    statusCode.value = handlingStatusCode(response);
  }
}

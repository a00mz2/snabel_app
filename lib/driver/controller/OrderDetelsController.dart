// ignore_for_file: file_names

import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/functions/handlingData.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/model/OrderModel.dart';
import 'package:get/get.dart';

class OrderDetelsController extends GetxController {
  final RxMap<String, dynamic> dataOrder = <String, dynamic>{}.obs;

  OrderModel data = OrderModel(Get.find());

  /// حالة أزرار تحديث الطلب فقط — لا تُمرَّر إلى [ScaffoldWidget] حتى لا يُستبدل محتوى الصفحة بشاشة تحميل.
  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  Rx<StatusRequest> statusRequestButtonreject = StatusRequest.success.obs;

  /// تبقى [success] دائماً لجسم الصفحة؛ التحميل يظهر داخل الأزرار فقط.
  final Rx<StatusRequest> scaffoldBodyStatus = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  updateStatusOrder(orderid, staus, {bool isReject = false}) async {
    if (isReject) {
      statusRequestButtonreject.value = StatusRequest.loading;
    } else {
      statusRequest.value = StatusRequest.loading;
    }
    var response = await data.updateStatusOrder(
      orderId: orderid,
      status: staus,
    );
    final outcome = handlingData(response);

    if (outcome == StatusRequest.success && response is Map) {
      final ns = response['newStatus'];
      if (ns != null) {
        dataOrder['status'] = ns;
      }
      AppSnackBar.success(apiMessageFromMap(response, 'تم التحديث'));
    } else {
      AppSnackBar.error(apiErrorMessage(response, 'فشل تحديث الطلب'));
    }

    if (isReject) {
      statusRequestButtonreject.value = outcome;
    } else {
      statusRequest.value = outcome;
    }
    statusCode.value = handlingStatusCode(response);
  }

  @override
  void onInit() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      dataOrder.assignAll(args);
    }
    super.onInit();
  }
}

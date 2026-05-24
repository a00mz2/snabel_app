import 'package:customer/model/CartModel.dart';
import 'package:get/get.dart';

class SendOrderController extends GetxController {
  CartModel model = CartModel(Get.find());
  @override
  void onInit() async {
    super.onInit();
    print("✅ staerted CartController");
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 STOP CartController");
  }
}

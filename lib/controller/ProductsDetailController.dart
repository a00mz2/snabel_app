// ignore_for_file: avoid_print, unused_local_variable

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/CartModel.dart';
import 'package:customer/model/ProductsModel.dart';
import 'package:get/get.dart';

class ProductsDetailController extends GetxController {
  /// ===================== Models =====================
  final ProductsModel model = ProductsModel(Get.find());
  final CartModel cartModel = CartModel(Get.find());

  /// ===================== Constructor =====================
  late final String productId;
  ProductsDetailController([String? id]) {
    productId = id ?? '';
  }

  /// ===================== Reactive Variables =====================
  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  final RxInt statusCode = 200.obs;
  final RxInt selectedImageIndex = 0.obs;
  final RxInt selectedPackingIndex = 0.obs;
  final RxInt count = 1.obs;
  final RxBool isExpanded = false.obs;
  final RxBool isInCart = false.obs;

  /// ===================== Data =====================
  final dataProduct = {}.obs;
  final images = [].obs;
  final packings = [].obs;

  /// ===================== Lifecycle =====================
  @override
  void onInit() {
    super.onInit();
    print("🟢 ProductDetailsController initialized for product: $productId");
    getProduct();
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 ProductDetailsController closed");
  }

  /// ===================== Utility Functions =====================

  /// فحص هل المنتج في السلة
  bool isInCartFun() {
    try {
      if (packings.isEmpty) {
        return (dataProduct['isInCart'] ?? false) as bool;
      } else {
        final currentPack = packings[selectedPackingIndex.value];
        return (currentPack['isInCart'] ?? false) as bool;
      }
    } catch (e) {
      print('⚠️ Error checking cart state: $e');
      return false;
    }
  }

  /// تحديد كمية المنتج بناءً على حالة السلة
  void handlingCount() {
    try {
      if (isInCartFun()) {
        if (packings.isEmpty) {
          count.value = (dataProduct['cartQuantity'] ?? 1) as int;
        } else {
          count.value =
              (packings[selectedPackingIndex.value]['cartQuantity'] ?? 1)
                  as int;
        }
      } else {
        count.value = 1;
      }
    } catch (e) {
      print('⚠️ Error in handlingCount: $e');
      count.value = 1;
    }
  }

  /// زيادة أو تقليل الكمية
  Future<void> cartEdt(bool add) async {
    if (add) {
      count.value++;
    } else if (count.value > 1) {
      count.value--;
    }

    // تحديث الكمية في السلة فقط إذا كان المنتج مضافًا
    if (!isInCartFun()) return;

    try {
      final String? cartItemId = packings.isEmpty
          ? dataProduct['cartItemId']
          : packings[selectedPackingIndex.value]['cartItemId'];

      if (cartItemId == null) {
        print("⚠️ cartItemId is null — cannot update cart quantity");
        return;
      }

      final response = await cartModel.updateCartQuantity(
        cartItemId,
        count.value,
      );
      final status = handlingData(response);

      if (status != StatusRequest.success) {
        AppSnackBar.error(
          tryResponseMessage(response) ?? "فشل تحديث الكمية",
        );
      }
    } catch (e) {
      print("❌ Error updating cart quantity: $e");
    }
  }

  /// إضافة المنتج إلى السلة
  Future<void> addToCart() async {
    try {
      if (packings.isEmpty) {
        dataProduct['isInCart'] = true;
        dataProduct['cartQuantity'] = count.value;
        isInCart.value = true;

        final response = await cartModel.addToCart(
          dataProduct['_id'],
          count.value,
        );

        if (handlingData(response) != StatusRequest.success) {
          isInCart.value = false;
          AppSnackBar.error(
            tryResponseMessage(response) ?? "فشل إضافة المنتج إلى السلة",
          );
        }
      } else {
        packings[selectedPackingIndex.value]['isInCart'] = true;
        packings[selectedPackingIndex.value]['cartQuantity'] = count.value;
        dataProduct['quantity'] = count.value;
        isInCart.value = true;

        final response = await cartModel.addToCart(
          dataProduct['_id'],
          count.value,
          packingId: packings[selectedPackingIndex.value]['_id'],
        );

        if (handlingData(response) != StatusRequest.success) {
          isInCart.value = false;
          AppSnackBar.error(
            tryResponseMessage(response) ?? "فشل إضافة المنتج إلى السلة",
          );
        }
      }
    } catch (e) {
      print("❌ Error adding to cart: $e");
      isInCart.value = false;
      AppSnackBar.error("حدث خطأ أثناء إضافة المنتج إلى السلة");
    }
  }

  /// توسيع / إخفاء الوصف
  void toggle() => isExpanded.value = !isExpanded.value;

  /// تغيير الصورة
  void onImageChanged(int index) {
    if (index >= 0 && index < images.length) {
      selectedImageIndex.value = index;
    }
  }

  /// عند تغيير التغليف (البكج)
  void onPackingChanged(int index) {
    if (index < 0 || index >= packings.length) return;
    selectedPackingIndex.value = index;

    final pack = packings[index];
    if (pack['imageIndex'] < images.length) {
      selectedImageIndex.value = (pack['imageIndex'] ?? 0);
    } else {
      selectedImageIndex.value = 0;
    }

    print('======================');
    print(selectedImageIndex.value);
    print('======================');

    isInCart.value = isInCartFun();
    handlingCount();
  }

  /// ===================== API =====================
  Future<void> getProduct() async {
    statusRequest.value = StatusRequest.loading;

    try {
      final response = await model.getProducts(id: productId);
      final status = handlingData(response);

      if (status == StatusRequest.success) {
        final product = tryResponseMap(response)?['product'] ?? {};
        dataProduct.value = product;
        images.value = product['images'] ?? [];
        packings.value = product['packings'] ?? [];

        selectedImageIndex.value = product['mainImageIndex'] ?? 0;
        isInCart.value = packings.isNotEmpty
            ? (packings[selectedPackingIndex.value]['isInCart'] ?? false)
            : (product['isInCart'] ?? false);

        handlingCount();
      }

      statusCode.value = handlingStatusCode(response);
      statusRequest.value = status;
    } catch (e) {
      print("❌ Error loading product: $e");
      statusRequest.value = StatusRequest.serverFailure;
      AppSnackBar.error("حدث خطأ أثناء تحميل بيانات المنتج");
    }
  }
}

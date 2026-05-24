import 'dart:async';
import 'package:customer/controller/HomeController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/model/ProductsModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SectionProductsController extends GetxController {
  final ProductsModel model = ProductsModel(Get.find());
  final HomeController homeController = Get.find<HomeController>();

  // متغيرات تفاعلية (Reactive) لتحديث الواجهة فوراً
  RxString categoryId = "".obs;
  RxString categoryName = "".obs;
  RxString categoryImage = "".obs;
  RxInt indexCategory = 0.obs;

  RxInt page = 1.obs;
  var listProducts = [].obs;

  /// عند true تُجلب منتجات المفضلة فقط (من وسائط التنقل).
  bool favoritesOnly = false;

  Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  Rx<StatusRequest> statusRequestPagination = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  late TextEditingController textSearchController;
  final ScrollController scrollController = ScrollController();
  Timer? debounce;

  @override
  void onInit() {
    super.onInit();
    textSearchController = TextEditingController();

    // استلام البيانات الأولية من Arguments
    final args = Get.arguments ?? {};
    categoryId.value = args['categoryId'] ?? "";
    categoryName.value = args['name'] ?? "";
    categoryImage.value = args['image'] ?? "";
    favoritesOnly = args['favoritesOnly'] == true;

    // تحديد التبويب المختار حالياً
    indexCategory.value = homeController.listCategories.indexWhere(
      (element) => element['_id'] == categoryId.value,
    );

    getProducts();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        pagination();
      }
    });
  }

  // تم تعديل المعامل ليكون int عادي لحل مشكلة النوع
  getProducts({String? thisCategoryId, int? newIndex}) async {
    page.value = 1;
    statusRequest.value = StatusRequest.loading;

    // إذا تم الضغط على تبويب جديد، نحدث البيانات
    if (newIndex != null) {
      indexCategory.value = newIndex;
      var selected = homeController.listCategories[newIndex];
      categoryId.value = selected['_id'];
      categoryName.value = selected['name'];
      categoryImage.value = selected['image']?.toString() ?? "";
    }

    var response = await model.getProducts(
      category: categoryId.value,
      search: textSearchController.text,
      favoritesOnly: favoritesOnly,
    );

    if (handlingData(response) == StatusRequest.success) {
      listProducts.value = response['products'];
    } else {
      listProducts.clear();
    }
    statusCode.value = handlingStatusCode(response);
    statusRequest.value = handlingData(response);
  }

  onSearchChanged() {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () => getProducts());
  }

  pagination() async {
    if (statusRequestPagination.value == StatusRequest.loading) return;
    statusRequestPagination.value = StatusRequest.loading;
    var response = await model.getProducts(
      page: page.value + 1,
      category: categoryId.value,
      search: textSearchController.text,
      favoritesOnly: favoritesOnly,
    );
    if (handlingData(response) == StatusRequest.success) {
      listProducts.addAll(response['products']);
      page.value++;
    }
    statusRequestPagination.value = StatusRequest.success;
  }

  @override
  void onClose() {
    textSearchController.dispose();
    scrollController.dispose();
    debounce?.cancel();
    super.onClose();
  }
}

// ignore_for_file: avoid_print

import 'dart:async';

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/model/ProductsModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchingController extends GetxController {
  ProductsModel model = ProductsModel(Get.find());

  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  final FocusNode focusNode = FocusNode();
  late TextEditingController textSearchController;

  @override
  void onInit() {
    super.onInit();
    print("✅ staerted SearchingController");
    textSearchController = TextEditingController();
    Future.delayed(const Duration(milliseconds: 300), () {
      FocusScope.of(Get.context!).requestFocus(focusNode);
    });
  }

  @override
  void onClose() {
    super.onClose();
    focusNode.dispose();
    textSearchController.dispose();
    super.onClose();
    print("🧹 STOP SearchingController");
  }

  //=======================data===================

  var listProducts = [].obs;

  Timer? debounce;
  onSearchChanged() {
    if (debounce?.isActive ?? false) debounce!.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      getProducts();
    });
  }

  getProducts() async {
    statusRequest.value = StatusRequest.loading;
    print(textSearchController.text.toString().isEmpty);
    if (textSearchController.text.toString().isEmpty) {
      listProducts.value = [];
      statusRequest.value = StatusRequest.success;
      statusCode.value = 200;
      print(11111111111);
    } else {
      var response = await model.getProducts(
        search: textSearchController.text.toString(),
      );
      print(response);
      if (handlingData(response) == StatusRequest.success) {
        listProducts.value = response['products'];
      }
      statusRequest.value = handlingData(response);
      statusCode.value = handlingStatusCode(response);
    }
  }
}

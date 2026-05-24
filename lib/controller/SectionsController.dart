// ignore_for_file: avoid_print

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/model/SectionModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SectionsController extends GetxController {
  SectionModel model = SectionModel(Get.find());

  @override
  void onInit() {
    super.onInit();
    print("✅ staerted SectionsController");
    getSection();

    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        pagination();
      }
    });
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 STOP SectionsController");
  }

  //=================ControllerS=====================
  final ScrollController scrollController = ScrollController();

  //=============var================
  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  Rx<StatusRequest> statusRequestPagination = StatusRequest.success.obs;

  RxInt statusCode = 200.obs;
  int page = 2;

  //=============data================

  var listSection = [].obs;
  //=============api================

  getSection() async {
    page = 2;
    statusRequest.value = StatusRequest.loading;
    var response = await model.getSection(page: 1);
    if (handlingData(response) == StatusRequest.success) {
      listSection.value = response['categories'];
    }
    print(listSection);
    statusCode.value = handlingStatusCode(response);
    statusRequest.value = handlingData(response);
  }

  pagination() async {
    print("object");
    statusRequestPagination.value = StatusRequest.loading;
    var response = await model.getSection(page: page);
    if (handlingData(response) == StatusRequest.success) {
      listSection.value += response['categories'] ?? [];
      page++;
    }
    statusRequestPagination.value = handlingData(response);
  }
}

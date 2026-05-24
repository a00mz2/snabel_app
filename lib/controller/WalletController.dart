import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/model/WalletModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletController extends GetxController {
  WalletModel model = WalletModel(Get.find());

  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  Rx<StatusRequest> statusRequestPagination = StatusRequest.success.obs;

  Rx<StatusRequest> statusRequestList = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  Rxn<DateTime> selectedDate = Rxn<DateTime>();
  var startOfWeek = DateTime.now()
      .subtract(Duration(days: DateTime.now().weekday - 1))
      .obs;

  @override
  void onInit() {
    super.onInit();
    print("✅ WalletController Started");
    getTransactions();
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
    print("🧹 WalletController Closed");
  }

  //=================ControllerS=====================
  final ScrollController scrollController = ScrollController();

  //=======================var=====================
  /// 🔹 اسم الشهر الحالي بالعربية
  String get monthName =>
      DateFormat('MMMM yyyy', 'ar').format(startOfWeek.value);

  int page = 2;

  /// 🔹 الأيام الكاملة للشهر الحالي
  List<DateTime> get daysInMonth {
    final firstDay = DateTime(
      startOfWeek.value.year,
      startOfWeek.value.month,
      1,
    );
    final lastDay = DateTime(
      startOfWeek.value.year,
      startOfWeek.value.month + 1,
      0,
    );
    return List.generate(
      lastDay.day,
      (i) => DateTime(firstDay.year, firstDay.month, i + 1),
    );
  }

  //===================== Data ===================//
  var dataWallet = {}.obs;

  /// 🔹 الانتقال إلى الشهر التالي
  void nextMonth() {
    startOfWeek.value = DateTime(
      startOfWeek.value.year,
      startOfWeek.value.month + 1,
      1,
    );
  }

  /// 🔹 الانتقال إلى الشهر السابق
  void prevMonth() {
    startOfWeek.value = DateTime(
      startOfWeek.value.year,
      startOfWeek.value.month - 1,
      1,
    );
  }

  /// 🔹 اختيار يوم معين
  void selectDate(DateTime date) async {
    page = 2;
    selectedDate.value = date;
    statusRequestList.value = StatusRequest.loading;
    var response = await model.getTransactions(
      page: 1,
      specificDate: DateFormat(
        'yyyy-MM-dd',
      ).format(selectedDate.value!).toString(),
    );

    if (handlingData(response) == StatusRequest.success) {
      dataWallet.value = response;
    }
    statusRequestList.value = handlingData(response);
  }

  //===================== API ===================//
  getTransactions() async {
    page = 2;
    selectedDate.value = null;
    statusRequest.value = StatusRequest.loading;
    var response = await model.getTransactions(page: 1);

    if (handlingData(response) == StatusRequest.success) {
      dataWallet.value = response;
    }
    statusRequest.value = StatusRequest.success;
    statusRequestPagination.value = StatusRequest.success;

    statusRequest.value = handlingData(response);
    statusCode.value = handlingStatusCode(response);
  }

  pagination() async {
    statusRequestPagination.value = StatusRequest.loading;

    var response = await model.getTransactions(
      page: page,
      specificDate: selectedDate.value == null
          ? ""
          : DateFormat('yyyy-MM-dd').format(selectedDate.value!).toString(),
    );
    if (handlingData(response) == StatusRequest.success) {
      dataWallet['transactions'] += response['transactions'];
      page++;
    }
    statusRequestPagination.value = handlingData(response);
    print(DateFormat('yyyy-MM-dd').format(selectedDate.value!).toString());
    print(response['transactions'].length);
  }
}

// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/constant/assets/lottie.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/showConfirmationDialog.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/CartModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class CartController extends GetxController {
  CartModel model = CartModel(Get.find());
  @override
  void onInit() async {
    super.onInit();
    getCart();
    ever<DateTime?>(selectedDate, (date) async {
      if (date != null) {
        deliveryPeriods = {}.obs;
        deliveryDate = selectedDate.value!.toIso8601String().split('T').first;
        getDeliveryPeriods(deliveryDate);
      }
    });

    print("✅ staerted CartController");
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 STOP CartController");
  }

  //========var======================
  Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  Rx<StatusRequest> statusRequestDeliveryPeriods = StatusRequest.empty.obs;
  RxInt statusCode = 200.obs;
  var selectedDate = Rxn<DateTime>();
  String deliveryDate = "";

  var deliveryPeriods = {}.obs;

  RxInt deliveryFee = 0.obs;
  RxBool isPin = false.obs;
  RxList daysOfWeek = [].obs;

  //========data======================
  var dataCart = [].obs;
  var listDeliveryPeriods = [].obs;

  // ===============function=============

  String formatDaysOfWeek(List days) {
    const dayNames = [
      'السبت',
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
    ];

    final validDays = days.where((d) => d >= 0 && d <= 6).toList();

    if (validDays.isEmpty) return 'لم يتم تحديد أيام';

    final names = validDays.map((d) => dayNames[d]).toList();

    return names.join('، ');
  }

  changeTabPin(bool pin) async {
    isPin.value = pin;
    if (isPin.value == true) {
      final date = DateTime.now();

      deliveryDate = date
          .add(const Duration(days: 2))
          .toIso8601String()
          .split('T')
          .first;
      await getDeliveryPeriods(deliveryDate);
    } else {
      statusRequestDeliveryPeriods.value = StatusRequest.empty;
      if (selectedDate.value != null) {
        deliveryPeriods = {}.obs;
        deliveryDate = selectedDate.value!.toIso8601String().split('T').first;
        getDeliveryPeriods(deliveryDate);
      }
    }
    print(deliveryPeriods);
    print(deliveryDate);
  }

  changeDaysOfWeek(int index) {
    if (daysOfWeek.contains(index)) {
      daysOfWeek.remove(index);
    } else {
      daysOfWeek.add(index);
    }
  }

  String imageitem(int index) {
    try {
      final item = dataCart[index];
      final product = item['product'];
      if (product == null) return '';

      final images = product['images'];
      if (images == null || images.isEmpty) return '';

      int imageIndex = 0;

      if (item['packing'] != null && item['packing']['imageIndex'] != null) {
        imageIndex = item['packing']['imageIndex'];
      } else if (product['mainImageIndex'] != null) {
        imageIndex = product['mainImageIndex'];
      }

      // تأكد أن الفهرس ضمن حدود القائمة
      if (imageIndex < 0 || imageIndex >= images.length) {
        imageIndex = 0;
      }

      return images[imageIndex]['name'] ?? '';
    } catch (e) {
      print('❌ Error loading image at index $index: $e');
      return '';
    }
  }

  String packageName(int index) {
    try {
      return dataCart[index]['packing']['label'];
    } catch (e) {
      return "";
    }
  }

  int totalItemPrice(int index) {
    try {
      return (dataCart[index]['product']['price'] *
          (dataCart[index]['packing']['quantity'] *
              dataCart[index]['quantity']));
    } catch (e) {
      return (dataCart[index]['product']['price'] *
          dataCart[index]['quantity']);
    }
  }

  double calculateTotalCartPrice() {
    double total = 0.0;
    for (var item in dataCart) {
      final product = item['product'];
      final packing = item['packing'];
      final quantity = item['quantity'] ?? 1;

      final productPrice = (product?['price'] ?? 0).toDouble();
      final packingQuantity = (packing?['quantity'] ?? 1).toDouble();

      // السعر الإجمالي لكل عنصر
      final totalItemPrice = productPrice * packingQuantity * quantity;

      total += totalItemPrice;
    }

    return total;
  }

  selecteddeliveryPeriods(Map<dynamic, dynamic> item) {
    deliveryPeriods.value = item;
  }

  //=================api=================
  getCart() async {
    statusRequest.value = StatusRequest.loading;
    var response = await model.getCart();

    if (handlingData(response) == StatusRequest.success) {
      dataCart.value = response['cart'] ?? [];
      deliveryFee.value = response['deliveryFee'] ?? 0;
    }
    statusCode.value = handlingStatusCode(response);
    statusRequest.value = handlingData(response);
  }

  updateCartQuantity(int index, bool isAdd) async {
    if (isAdd) {
      dataCart[index]['quantity'] += 1;
      print(dataCart[index]['quantity']);
    } else if (dataCart[index]['quantity'] > 1) {
      --dataCart[index]['quantity'];
    }
    dataCart.refresh();
    await model.updateCartQuantity(
      dataCart[index]['productCartId'],
      dataCart[index]['quantity'],
    );
  }

  removeFromCart(int index) async {
    // تأكد من أن الفهرس صالح
    if (index < 0 || index >= dataCart.length) return;

    final item = dataCart[index]; // حفظ العنصر قبل الحذف

    // ✅ نتأكد أن التغليف موجود قبل استخدامه
    final product = item['product'];
    final packing = item['packing'];

    final productName = product?['name'] ?? 'منتج غير معروف';
    final packingLabel = packing != null ? packing['label'] ?? '' : '';

    bool? confirm = await showConfirmationDialog(
      Get.context!,
      title: "$productName${packingLabel.isNotEmpty ? " ($packingLabel)" : ""}",
      subtitle: "هل أنت متأكد من حذف هذا العنصر من السلة؟",
      icon: Lottie.asset(AppLottie.Delete, width: 100, height: 100),
    );

    if (confirm == null || !confirm) return;

    final productCartId = item['productCartId'];

    // حذف العنصر من القائمة
    dataCart.removeAt(index);
    dataCart.refresh();

    print("🛒 Removed: $productCartId");

    // استدعاء API
    await model.removeFromCart(productCartId);
  }

  getDeliveryPeriods(deliveryDate) async {
    statusRequestDeliveryPeriods.value = StatusRequest.loading;
    var response = await model.getDeliveryPeriods(deliveryDate);
    if (handlingData(response) == StatusRequest.success) {
      listDeliveryPeriods.value = response['periods'];
      if (listDeliveryPeriods.isEmpty) {
        return statusRequestDeliveryPeriods.value =
            StatusRequest.nameExestFailure;
      }
    }
    statusRequestDeliveryPeriods.value = handlingData(response);
  }

  createOrderFromCart() async {
    if (deliveryDate.isEmpty) {
      return AppSnackBar.error("يجب اختيار اليوم المحدد للاستلام");
    }
    if (deliveryPeriods.isEmpty) {
      return AppSnackBar.error("يجب تحدد فترة الاستلام");
    }
    if (isPin.value == true && daysOfWeek.isEmpty) {
      return AppSnackBar.error("اختر أيام التكرار قبل المتابعة");
    }

    if (isPin.value == true && daysOfWeek.isNotEmpty) {
      statusRequest.value = StatusRequest.loading;
      var response = await model.createPinnedOrder(
        deliveryPeriods['_id'],
        daysOfWeek,
      );
      if (handlingData(response) == StatusRequest.success) {
        bool? confirm = await showConfirmationDialog(
          colorActivButton: Color(0xff3C2313),
          textActivButton: 'الرجوع للرئيسية',
          showcancelBotton: false,
          Get.context!,
          title: " تم انشاء طلب مثبت بنجاح!",
          subtitle: "سيتم تكراره في الايام التي قمت بتحديدها ",
          icon: Image.asset(AppIcons.sendOrder, width: 64, height: 64),
        );
        handlingData(response);
        handlingStatusCode(response);
        if (confirm == null || !confirm) {
          return Get.offAllNamed('/MainScreen', arguments: {'current': 0});
        }
        return Get.offAllNamed('/MainScreen', arguments: {'current': 0});
      } else if (handlingStatusCode(response) == 400) {
        await showConfirmationDialog(
          colorActivButton: Color(0xff3C2313),
          textActivButton: 'موافق',
          showcancelBotton: false,
          Get.context!,
          title: "❌ لا يمكن إنشاء الطلب",
          subtitle: tryResponseMessage(response) ?? "حدث خطأ ما",
          icon: Image.asset(AppIcons.PaymentFailed, width: 64, height: 64),
        );
        return statusRequest.value = StatusRequest.success;
      } else {
        AppSnackBar.error(tryResponseMessage(response) ?? "حدث خطأ ما");
        statusRequest.value = handlingData(response);
        statusCode.value = handlingStatusCode(response);
      }
      return;
    }

    statusRequest.value = StatusRequest.loading;
    var response = await model.createOrderFromCart(
      deliveryPeriods['_id'],
      deliveryDate,
    );
    if (handlingData(response) == StatusRequest.success) {
      bool? confirm = await showConfirmationDialog(
        colorActivButton: Color(0xff3C2313),
        textActivButton: 'الرجوع للرئيسية',
        showcancelBotton: false,
        Get.context!,
        title: " تم إرسال طلبك بنجاح!",
        subtitle: "سيتم مراجعته و توصيلة في الفترة المحددة ",
        icon: Image.asset(AppIcons.sendOrder, width: 64, height: 64),
      );
      handlingData(response);
      handlingStatusCode(response);
      if (confirm == null || !confirm) {
        return Get.offAllNamed('/MainScreen', arguments: {'current': 0});
      }
      return Get.offAllNamed('/MainScreen', arguments: {'current': 0});
    } else if (handlingStatusCode(response) == 400) {
      await showConfirmationDialog(
        colorActivButton: Color(0xff3C2313),
        textActivButton: 'موافق',
        showcancelBotton: false,
        Get.context!,
        title: "❌ لا يمكن إنشاء الطلب",
        subtitle: tryResponseMessage(response) ?? "حدث خطأ ما",
        icon: Image.asset(AppIcons.PaymentFailed, width: 64, height: 64),
      );
      return statusRequest.value = StatusRequest.success;
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? "حدث خطأ ما");
      statusRequest.value = handlingData(response);
      statusCode.value = handlingStatusCode(response);
    }
  }
}

// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/constant/assets/lottie.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/showCodChoiceDialog.dart';
import 'package:customer/core/functions/showConfirmationDialog.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/CartModel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:customer/core/constant/payment_methods.dart';

import 'package:customer/core/functions/orderRounding.dart';
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
  /// ملاحظة الزبون على الطلب (صفحة إرسال الطلب) — تُفرَّغ بعد نجاح الإرسال.
  static const int kOrderNoteMaxLength = 500;
  /// نصّ الملاحظة — مصدر الحقيقة عند الإرسال.
  ///
  /// ⚠️ لا نملك هنا [TextEditingController]: هذا الكنترولر مسجَّل بـ `Get.create`
  /// (مصنع يُنتج نسخة لكل `Get.find`) وGetX يتخلّص منها عند إغلاق المسار، فأي
  /// TextEditingController يملكه ينتهي مُتلَفاً بينما الودجت ما زالت تستعمله.
  /// الودجت [OrderNoteField] تملك controller خاصاً بها وتكتب إلى هذا الـRx.
  final RxString orderNote = ''.obs;

  /// [pay-method] طريقة دفع الطلب: `wallet` (آجل) أو `cash` (نقد عند الاستلام).
  /// النقدي لا يُخصم من المحفظة ولا يخضع للحد المالي، ولا يُرجَع منه شيء.
  final RxString orderPaymentMethod = kPaymentWallet.obs;

  void setOrderPaymentMethod(String value) =>
      orderPaymentMethod.value = value == kPaymentCash
          ? kPaymentCash
          : kPaymentWallet;

  Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  Rx<StatusRequest> statusRequestDeliveryPeriods = StatusRequest.empty.obs;
  RxInt statusCode = 200.obs;
  var selectedDate = Rxn<DateTime>();
  String deliveryDate = "";

  var deliveryPeriods = {}.obs;

  RxInt deliveryFee = 0.obs;

  /// [round-250] خطوة تقريب الإجمالي من الخادم (`roundingStep` في رد السلة).
  final RxInt roundingStep = kOrderRoundingStep.obs;

  /// مجموع الأصناف بلا تقريب (تبويب السلة).
  int get cartSubtotal => calculateTotalCartPrice().round();

  /// [round-250] الإجمالي الذي سيُخصم فعلاً عند الإرسال:
  /// (الأصناف + التوصيل) مقرَّباً للأعلى إلى مضاعف الخطوة — يطابق الخادم.
  int get finalTotal => roundUpToStep(
        cartSubtotal + deliveryFee.value,
        step: roundingStep.value,
      );
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
      roundingStep.value = roundingStepOrDefault(response['roundingStep']); // [round-250]
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

  /// تعيين كمية مطلقة لعنصر السلة (من مربع إدخال الكمية).
  Future<void> setCartQuantity(int index, int quantity) async {
    if (index < 0 || index >= dataCart.length) return;
    final q = quantity.clamp(1, 9999);
    final current = dataCart[index]['quantity'];
    if (current is num && current.toInt() == q) return;
    dataCart[index]['quantity'] = q;
    dataCart.refresh();
    await model.updateCartQuantity(dataCart[index]['productCartId'], q);
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
        paymentMethod: orderPaymentMethod.value, // [pay-method]
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

    return _submitCartOrder();
  }

  static num _asNum(dynamic v) =>
      v is num ? v : (num.tryParse('${v ?? ''}') ?? 0);

  /// إرسال طلب عادي؛ [codMode] يُمرَّر فقط بعد اختيار الزبون الدفع نقداً عند الاستلام.
  Future<void> _submitCartOrder({String? codMode}) async {
    statusRequest.value = StatusRequest.loading;
    var response = await model.createOrderFromCart(
      deliveryPeriods['_id'],
      deliveryDate,
      note: orderNote.value,
      paymentMethod: orderPaymentMethod.value, // [pay-method]
      codMode: codMode,
    );
    if (handlingData(response) == StatusRequest.success) {
      orderNote.value = '';
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
        Get.offAllNamed('/MainScreen', arguments: {'current': 0});
        return;
      }
      Get.offAllNamed('/MainScreen', arguments: {'current': 0});
      return;
    } else if (handlingStatusCode(response) == 400) {
      final m = tryResponseMap(response);
      // تجاوز الحد الائتماني: الزبون يختار تسديد الفرق أو الدفع الكامل نقداً للسائق
      if (codMode == null && m?['code'] == 'CREDIT_LIMIT_EXCEEDED') {
        statusRequest.value = StatusRequest.success; // إظهار الصفحة قبل الحوار
        final choice = await showCodChoiceDialog(
          Get.context!,
          finalTotal: _asNum(m?['finalTotal']),
          balance: _asNum(m?['balance']),
          limit: _asNum(m?['limit']),
          excess: _asNum(m?['excess']),
        );
        if (choice != null) return _submitCartOrder(codMode: choice);
        return;
      }
      await showConfirmationDialog(
        colorActivButton: Color(0xff3C2313),
        textActivButton: 'موافق',
        showcancelBotton: false,
        Get.context!,
        title: "❌ لا يمكن إنشاء الطلب",
        subtitle: tryResponseMessage(response) ?? "حدث خطأ ما",
        icon: Image.asset(AppIcons.PaymentFailed, width: 64, height: 64),
      );
      statusRequest.value = StatusRequest.success;
      return;
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? "حدث خطأ ما");
      statusRequest.value = handlingData(response);
      statusCode.value = handlingStatusCode(response);
    }
  }
}

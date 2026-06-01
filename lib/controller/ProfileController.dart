// ignore_for_file: avoid_print

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/core/functions/validinput.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/model/LoginModel.dart';
import 'package:customer/model/ProfileModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';

class ProfileController extends GetxController {
  ProfileModel model = ProfileModel(Get.find());
  LoginModel loginModel = LoginModel(Get.find());

  Rx<StatusRequest> statusRequest = StatusRequest.success.obs;
  Rx<StatusRequest> statusRequestButton = StatusRequest.success.obs;
  RxInt statusCode = 200.obs;

  @override
  void onInit() {
    super.onInit();
    print("✅ staerted ProfileController");
    phoneController = TextEditingController();
    nameController = TextEditingController();
    loadAppVersion();
    getDataCustomer();
  }

  @override
  void onClose() {
    super.onClose();
    print("🧹 STOP ProfileController");
  }

  //==================controller====================

  late TextEditingController nameController;
  late TextEditingController phoneController;

  //=================var==================
  Rxn<Uint8List> imageElmint = Rxn<Uint8List>();

  /// رقم الإصدار فقط من pubspec (مثل 1.0.0) دون رقم البناء.
  final RxString appVersionLabel = ''.obs;

  //==================Data=====================
  var listDataCustomer = {}.obs;

  //================function====================

  Future<void> loadAppVersion() async {
    try {
      final p = await PackageInfo.fromPlatform();
      appVersionLabel.value = p.version;
    } catch (_) {
      appVersionLabel.value = '';
    }
  }

  Future<void> confirmAndSoftDeleteAccount() async {
    final go = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('حذف الحساب'),
        content: const Text(
          'سيتم حذف جميع بيانات ولن يمكن استعادتها نهائياً.\n\n'
          'هل أنت متأكد؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'حذف حسابي',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
    if (go != true) return;

    statusRequest.value = StatusRequest.loading;
    final response = await model.softDeleteMyAccount();

    if (handlingData(response) == StatusRequest.success) {
      final fcm = myServices.sharedPreferences.getString("tokinFCM");
      if (fcm != null && fcm.isNotEmpty) {
        await loginModel.removeToken(fcm);
      }
      myServices.sharedPreferences.remove("id");
      myServices.sharedPreferences.remove("Token");
      myServices.sharedPreferences.remove("refreshToken");
      myServices.sharedPreferences.remove("router");
      Get.offAllNamed("/");
      AppSnackBar.success(
        tryResponseMessage(response) ?? 'تم حذف الحساب بنجاح',
      );
    } else {
      AppSnackBar.error(
        tryResponseMessage(response) ?? 'تعذر تنفيذ الطلب',
      );
    }

    statusRequest.value = handlingData(response);
    statusCode.value = handlingStatusCode(response);
  }

  /// تسجيل الخروج — نحاول حذف FCM token من الـAPI أولاً، لكن
  /// لا نمنع المستخدم من الخروج لو فشل الطلب (مثلاً انتهاء التوكن أو الشبكة).
  logOut() async {
    statusRequest.value = StatusRequest.loading;

    final fcmToken = myServices.sharedPreferences.getString("tokinFCM");
    if (fcmToken != null && fcmToken.isNotEmpty) {
      try {
        await loginModel.removeToken(fcmToken);
      } catch (_) {
        // تجاهل الفشل — نُكمل تسجيل الخروج محلياً.
      }
    }

    // مسح كامل لضمان عدم بقاء أيّ بيانات جلسة قديمة.
    await myServices.sharedPreferences.remove("id");
    await myServices.sharedPreferences.remove("Token");
    await myServices.sharedPreferences.remove("refreshToken");
    await myServices.sharedPreferences.remove("router");
    await myServices.sharedPreferences.remove("userRole");
    await myServices.sharedPreferences.remove("tokinFCM");
    await myServices.sharedPreferences.remove("PASSWORD");

    statusRequest.value = StatusRequest.success;
    Get.offAllNamed("/");
    AppSnackBar.success("تم تسجيل الخروج");
  }

  //====================Api====================

  getDataCustomer() async {
    statusRequestButton.value = StatusRequest.success;
    statusRequest.value = StatusRequest.loading;
    var response = await model.getDataCustomer();
    if (handlingData(response) == StatusRequest.success) {
      final m = tryResponseMap(response);
      final data = m?['data'];
      if (data is Map) {
        listDataCustomer.value = Map<String, dynamic>.from(data);
        nameController.text =
            (listDataCustomer["customerName"] ?? listDataCustomer["name"] ?? "")
                .toString();
        phoneController.text =
            (listDataCustomer["secondaryPhone"] ?? "").toString();
      }
    }
    statusRequest.value = handlingData(response);
    statusCode.value = handlingStatusCode(response);
  }

  updateCustomer() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();
    if (name.isEmpty) {
      AppSnackBar.error("يرجى إدخال الاسم");
      return;
    }
    final phoneErr = validInput(phone, 0, 13, "phone", isrequired: true);
    if (phoneErr != null) {
      AppSnackBar.error(phoneErr);
      return;
    }
    statusRequestButton.value = StatusRequest.loading;
    var response = await model.updateCustomer(
      name,
      phone,
      imageElmint: imageElmint.value,
    );

    if (handlingData(response) == StatusRequest.success) {
      imageElmint.value = null;
      AppSnackBar.success(
        tryResponseMessage(response) ?? "تم تحديث البيانات بنجاح",
      );
      await getDataCustomer();
    } else {
      AppSnackBar.error(tryResponseMessage(response) ?? "خطاء غير معروف");
    }
    statusRequestButton.value = handlingData(response);
  }
}

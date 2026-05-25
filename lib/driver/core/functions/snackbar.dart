// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

import 'package:get/get.dart';



enum ContentType { success, failure, warning, help }

class AppSnackBar {
  static void _show({required String message, required ContentType type}) {
    Color stripeColor;
    IconData icon;

    switch (type) {
      case ContentType.success:
        stripeColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case ContentType.failure:
        stripeColor = Colors.redAccent;
        icon = Icons.error;
        break;
      case ContentType.warning:
        stripeColor = Colors.orangeAccent;
        icon = Icons.warning;
        break;
      case ContentType.help:
        stripeColor = Colors.blueAccent;
        icon = Icons.info;
        break;
    }

    // ✅ إغلاق جميع SnackBars السابقة
    Get.closeAllSnackbars();

    Get.snackbar(
      '',
      '',
      titleText: const SizedBox.shrink(),
      messageText: Row(
        textDirection: TextDirection.rtl, // لأن التطبيق عربي
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ الشريط الملون على الطرف الأيمن
          Container(
            width: 5,
            height: 40,
            decoration: BoxDecoration(
              color: stripeColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          // الأيقونة
          Icon(icon, color: stripeColor, size: 22),
          const SizedBox(width: 8),
          // النص
          Expanded(
            child: Text(
              message,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.black.withOpacity(0.50),
      borderRadius: 12,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      duration: const Duration(seconds: 3),
      overlayColor: Colors.black.withOpacity(0.2),
      isDismissible: true,
      dismissDirection: DismissDirection.up,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }

  // 🟢 دوال الاستخدام كما هي
  static void success(String message) {
    _show(message: message, type: ContentType.success);
  }

  static void error(String message) {
    _show(message: message, type: ContentType.failure);
  }

  static void warning(String message) {
    _show(message: message, type: ContentType.warning);
  }

  static void info(String message) {
    _show(message: message, type: ContentType.help);
  }
}

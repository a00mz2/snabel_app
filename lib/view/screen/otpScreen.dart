import 'package:customer/controller/SignUpControler.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/OtpCodeBox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة إدخال رمز التحقق عند التسجيل: الرمز يصل إلى واتساب الرقم (Meta Cloud API)،
/// وعند اكتماله (كتابةً أو لصقاً) أو ضغط الزر يُنشأ الحساب.
///
/// مؤشر التحميل على الزر لا على الشاشة كلها — حتى يبقى حقل الرمز مركّباً
/// (OtpFieldController يحمل مرجعاً لحالته).
class OtpScreen extends StatelessWidget {
  final SignUpControler controller = Get.find<SignUpControler>();

  OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "أدخل رمز التحقق",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4A2E1F),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    "رقمك: ${controller.phoneController.text}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 24),

                // المربعات الستّة + لصق + عدّاد إعادة الإرسال
                OtpCodeBox(
                  controller: controller,
                  phone: controller.phoneController.text,
                  onCompleted: (_) => controller.verifyCode(),
                ),

                const SizedBox(height: 24),
                Obx(
                  () => ButtonAppWidget(
                    statusRequest: controller.statusRequest.value,
                    lable: 'تأكيد وإنشاء الحساب',
                    onPressed: () => controller.verifyCode(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

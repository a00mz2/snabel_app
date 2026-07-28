import 'package:customer/controller/SignUpControler.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/view/widget/widgetApp/ReverseVerifyBox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة التحقق العكسي عند التسجيل: يُرسل المستخدم الرمز إلى رقم الخدمة على
/// واتساب، ويتم إنشاء الحساب تلقائياً فور التحقق.
class OtpScreen extends StatelessWidget {
  final SignUpControler controller = Get.find<SignUpControler>();

  OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Obx(
          () => SafeArea(
            child: controller.statusRequest.value == StatusRequest.loading
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
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
                            "تأكيد رقم الهاتف",
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

                        // واجهة التحقق العكسي (رمز + زر واتساب + حالة لحظية/يدوية)
                        ReverseVerifyBox(controller: controller),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

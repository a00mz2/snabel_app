// ignore_for_file: file_names

import 'package:customer/controller/SignUpControler.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// صفحة نجاح إنشاء الحساب — تظهر بعد التسجيل. بالضغط على «موافق» يُسجَّل
/// الدخول وينتقل المستخدم إلى صفحات التطبيق.
class RegistrationSuccessScreen extends StatelessWidget {
  RegistrationSuccessScreen({super.key});

  final SignUpControler controller = Get.find<SignUpControler>();

  static const Color _brown = Color(0xFF4A2E1F);
  static const Color _green = Color(0xFF25D366);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // لا رجوع لشاشة التحقق بعد النجاح
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(flex: 2),
                  Center(
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE9F9EF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: _green,
                        size: 84,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text(
                    'تم إنشاء حسابك بنجاح',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _brown,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Obx(
                    () => Text(
                      controller.successMessage.value.isEmpty
                          ? 'حسابك الآن قيد المراجعة من الإدارة وسيتم تفعيله قريباً. يمكنك الدخول والتصفّح الآن.'
                          : controller.successMessage.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF7C7C7C),
                        height: 1.6,
                      ),
                    ),
                  ),
                  const Spacer(flex: 3),
                  Obx(
                    () => SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed:
                            controller.statusRequest.value == StatusRequest.loading
                            ? null
                            : controller.proceedToApp,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child:
                            controller.statusRequest.value == StatusRequest.loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'موافق',
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

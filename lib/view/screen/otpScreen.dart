import 'package:customer/controller/SignUpControler.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

class OtpScreen extends StatelessWidget {
  final SignUpControler controller = Get.find<SignUpControler>();

  OtpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(
        () => SafeArea(
          child: controller.statusRequest.value == StatusRequest.loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () => Get.back(),
                            icon: Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          "تم إرسال رمز مكون من 6 أرقام إلى رقمك المسجل: ${controller.phoneController.text}",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.right,
                        ),
                      ),

                      // 👇 زر الاشتراك بخدمة واتساب — يظهر فقط عندما يكون الرقم
                      // غير مشترك بعد (pending): الرمز محجوز وسيصل فور إرسال
                      // كلمة الاشتراك إلى رقم الخدمة.
                      Obx(
                        () => controller.otpOptIn.value.showOptInButton
                            ? Container(
                                margin: const EdgeInsets.only(top: 20),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE9F9EF),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFF25D366),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      controller
                                          .otpOptIn.value.displayInstruction,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFF4A2E1F),
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(
                                      width: double.infinity,
                                      height: 46,
                                      child: ElevatedButton.icon(
                                        onPressed:
                                            controller.openWhatsAppForCode,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF25D366),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(30),
                                          ),
                                        ),
                                        icon: const Icon(
                                          Icons.chat,
                                          color: Colors.white,
                                        ),
                                        label: const Text(
                                          "اضغط للحصول على الكود",
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 40),

                      // 👇 OTP Field
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: OTPTextField(
                          keyboardType: TextInputType.number,
                          otpFieldStyle: OtpFieldStyle(),
                          controller: controller
                              .otpFieldController, // 👈 الربط مع الـ Controller
                          length: 6,
                          width: MediaQuery.of(context).size.width,
                          fieldWidth: 40,
                          style: const TextStyle(fontSize: 17),
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldStyle: FieldStyle.box,
                          onChanged: (pin) {
                            controller.otpCode.value = pin;
                          },
                          onCompleted: (pin) {
                            controller.otpCode.value = pin;
                            controller.verifyCode();
                          },
                        ),
                      ),

                      const SizedBox(height: 12),

                      Obx(
                        () => controller.enableResend.value
                            ? TextButton(
                                onPressed: controller.resendCode,
                                child: const Text(
                                  "إعادة إرسال الرمز",
                                  style: TextStyle(
                                    color: Color(0xFF4A2E1F),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                            : Text(
                                "يمكنك إعادة إرسال الرمز خلال 00:${controller.secondsRemaining.value.toString().padLeft(2, '0')}",
                                style: const TextStyle(color: Colors.grey),
                              ),
                      ),

                      const SizedBox(height: 32),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.verifyCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A2E1F),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "تحقق من الرمز",
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
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

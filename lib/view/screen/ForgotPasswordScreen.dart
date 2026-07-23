// ignore_for_file: file_names

import 'package:customer/controller/ForgotPasswordController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/constant/assets/images.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/textBox.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  static const Color _title = Color(0xff231F1E);
  static const Color _subtitle = Color(0xffA19491);
  static const Color _brown = Color(0xff4A2E1F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              AppImage.Union,
              alignment: Alignment.topRight,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Obx(
                () => controller.step.value == 0
                    ? _PhoneStep(
                        controller: controller,
                        titleColor: _title,
                        subtitleColor: _subtitle,
                      )
                    : _ResetStep(
                        controller: controller,
                        titleColor: _title,
                        subtitleColor: _subtitle,
                        brown: _brown,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhoneStep extends StatelessWidget {
  const _PhoneStep({
    required this.controller,
    required this.titleColor,
    required this.subtitleColor,
  });

  final ForgotPasswordController controller;
  final Color titleColor;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formPhoneKey,
      child: ListView(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: titleColor,
            ),
          ),
          const SizedBox(height: 16),
          Image.asset(
            AppImage.logoSplash,
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'نسيت كلمة المرور؟',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 20,
                    fontWeight: MyFontWeight.semiBold,
                    color: titleColor,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'أدخل رقم هاتفك المسجّل لإرسال رمز التحقق عبر واتساب.',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: MyFontWeight.regular,
                    color: subtitleColor,
                  ),
            ),
          ),
          const SizedBox(height: 24),
          TextBoxs(
            controller: controller.phoneController,
            typeVal: 'phone',
            maxLength: 11,
            maxLines: 1,
            type: TextInputType.number,
            suffixIcon: const Text('+964'),
            prefixIcon: Container(
              width: 20,
              height: 20,
              padding: const EdgeInsets.all(10),
              child: Image.asset(AppIcons.phone),
            ),
            hintText: 'رقم التليفون',
          ),
          const SizedBox(height: 24),
          Obx(
            () => ButtonAppWidget(
              statusRequest: controller.statusRequest.value,
              lable: 'إرسال رمز التحقق',
              onPressed: () => controller.requestOtp(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ResetStep extends StatelessWidget {
  const _ResetStep({
    required this.controller,
    required this.titleColor,
    required this.subtitleColor,
    required this.brown,
  });

  final ForgotPasswordController controller;
  final Color titleColor;
  final Color subtitleColor;
  final Color brown;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: controller.formResetKey,
      child: ListView(
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: IconButton(
              onPressed: () => controller.goBackStep(),
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'أدخل الرمز وكلمة المرور الجديدة',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 20,
                    fontWeight: MyFontWeight.semiBold,
                    color: titleColor,
                  ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'تم إرسال رمز مكوّن من 6 أرقام إلى واتساب: ${controller.phoneController.text}',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: subtitleColor,
                    fontSize: 14,
                  ),
            ),
          ),

          // زر الاشتراك بخدمة واتساب — يظهر فقط عندما يكون الرقم غير مشترك
          // بعد (pending): الرمز محجوز وسيصل فور إرسال كلمة الاشتراك.
          Obx(
            () => controller.otpOptIn.value.showOptInButton
                ? Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9F9EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF25D366)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          controller.otpOptIn.value.displayInstruction,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 46,
                          child: ElevatedButton.icon(
                            onPressed: controller.openWhatsAppForCode,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            icon: const Icon(Icons.chat, color: Colors.white),
                            label: const Text(
                              'اضغط للحصول على الكود',
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

          const SizedBox(height: 28),
          Directionality(
            textDirection: TextDirection.ltr,
            child: OTPTextField(
              keyboardType: TextInputType.number,
              otpFieldStyle: OtpFieldStyle(
                borderColor: subtitleColor.withValues(alpha: 0.5),
                focusBorderColor: brown,
              ),
              controller: controller.otpFieldController,
              length: 6,
              width: MediaQuery.of(context).size.width,
              fieldWidth: 42,
              style: const TextStyle(fontSize: 17),
              textFieldAlignment: MainAxisAlignment.spaceAround,
              fieldStyle: FieldStyle.box,
              onChanged: (pin) => controller.otpCode.value = pin,
              onCompleted: (pin) => controller.otpCode.value = pin,
            ),
          ),
          const SizedBox(height: 16),
          Obx(
            () {
              if (controller.enableResend.value) {
                return TextButton(
                  onPressed: controller.resendOtp,
                  child: Text(
                    'إعادة إرسال الرمز',
                    style: TextStyle(
                      color: brown,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }
              final s = controller.secondsRemaining.value;
              return Text(
                'يمكنك إعادة الإرسال خلال 00:${s.toString().padLeft(2, '0')}',
                textAlign: TextAlign.center,
                style: TextStyle(color: subtitleColor, fontSize: 13),
              );
            },
          ),
          const SizedBox(height: 20),
          Obx(
            () => TextBoxs(
              prefixIcon: Container(
                width: 20,
                height: 20,
                padding: const EdgeInsets.all(10),
                child: Image.asset(AppIcons.pass),
              ),
              hintText: 'كلمة المرور الجديدة',
              controller: controller.newPasswordController,
              obscureText: controller.obscureNew.value,
              showPassword: () => controller.toggleObscure(confirm: false),
            ),
          ),
          const SizedBox(height: 10),
          Obx(
            () => TextBoxs(
              prefixIcon: Container(
                width: 20,
                height: 20,
                padding: const EdgeInsets.all(10),
                child: Image.asset(AppIcons.pass),
              ),
              hintText: 'تأكيد كلمة المرور',
              controller: controller.confirmPasswordController,
              obscureText: controller.obscureConfirm.value,
              showPassword: () => controller.toggleObscure(confirm: true),
            ),
          ),
          const SizedBox(height: 28),
          Obx(
            () => ButtonAppWidget(
              statusRequest: controller.statusRequest.value,
              lable: 'تعيين كلمة المرور والدخول',
              onPressed: () => controller.submitNewPassword(),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ignore_for_file: file_names

import 'package:customer/core/class/otp_verify_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/otp_field_style.dart';
import 'package:otp_text_field/style.dart';

/// واجهة إدخال رمز التحقق (6 أرقام) المرسل إلى واتساب:
///  - ستّة مربعات + زر «لصق الرمز» (زر «نسخ الرمز» في رسالة واتساب يضعه في الحافظة).
///  - عدّاد إعادة الإرسال من قيمة الخادم، ثم زر «إعادة إرسال الرمز».
///  - يُستخدم في التسجيل ونسيت كلمة المرور؛ [onCompleted] يُستدعى عند اكتمال الرمز
///    (كتابةً أو لصقاً) ليقرّر الكنترولر الخطوة التالية.
class OtpCodeBox extends StatelessWidget {
  const OtpCodeBox({
    super.key,
    required this.controller,
    required this.phone,
    required this.onCompleted,
    this.accent = const Color(0xFF4A2E1F),
  });

  final OtpVerifyMixin controller;
  final String phone;
  final ValueChanged<String> onCompleted;
  final Color accent;

  static const Color _green = Color(0xFF25D366);
  static const Color _errorColor = Color(0xFFC62828);
  static const Color _border = Color(0xFFBDBDBD);

  OtpVerifyMixin get c => controller;

  String _formatSeconds(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'أرسلنا رمزاً من $kOtpLength أرقام إلى واتساب رقمك $phone.\n'
          'اضغط «نسخ الرمز» في الرسالة ثم «لصق الرمز» هنا، أو اكتبه يدوياً.',
          textAlign: TextAlign.center,
          style: TextStyle(color: accent, fontSize: 13.5, height: 1.6),
        ),
        const SizedBox(height: 20),

        // المربعات الستّة — اتجاه LTR حتى تُقرأ الأرقام بترتيبها
        Directionality(
          textDirection: TextDirection.ltr,
          child: OTPTextField(
            controller: c.otpFieldController,
            length: kOtpLength,
            width: MediaQuery.of(context).size.width,
            fieldWidth: 42,
            keyboardType: TextInputType.number,
            inputFormatter: [FilteringTextInputFormatter.digitsOnly],
            otpFieldStyle: OtpFieldStyle(
              borderColor: _border,
              enabledBorderColor: _border,
              focusBorderColor: accent,
            ),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textFieldAlignment: MainAxisAlignment.spaceAround,
            fieldStyle: FieldStyle.box,
            onChanged: (pin) => c.otpCode.value = pin,
            onCompleted: (pin) {
              c.otpCode.value = pin;
              onCompleted(pin);
            },
          ),
        ),
        const SizedBox(height: 14),

        // لصق من الحافظة (زر «نسخ الرمز» في واتساب)
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: c.pasteFromClipboard,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: _green),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.content_paste, size: 18, color: _green),
            label: const Text(
              'لصق الرمز',
              style: TextStyle(color: _green, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 10),

        // إعادة الإرسال: عدّاد من قيمة الخادم ثم زر
        Obx(() {
          if (c.enableResend.value) {
            final sending = c.otpSending.value;
            return TextButton(
              onPressed: sending ? null : c.resendOtp,
              child: Text(
                sending ? 'جارٍ الإرسال…' : 'إعادة إرسال الرمز',
                style: TextStyle(color: accent, fontWeight: FontWeight.w600),
              ),
            );
          }
          return Text(
            'يمكنك إعادة الإرسال خلال ${_formatSeconds(c.secondsRemaining.value)}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          );
        }),

        Obx(
          () => c.otpError.value.isEmpty
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    c.otpError.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: _errorColor, fontSize: 13),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        const Text(
          'لم يصلك الرمز؟ تأكد أن الرقم مفعّل على واتساب.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

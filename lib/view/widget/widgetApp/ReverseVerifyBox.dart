// ignore_for_file: file_names

import 'package:customer/core/class/reverse_verify_mixin.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// واجهة التحقق العكسي — خياران واضحان:
///  (1) واتساب مفتوح على هذا الجهاز → زر يفتح واتساب على رقم الخدمة مباشرة.
///  (2) واتساب على جهاز آخر → نسخ الرابط (رقم الخدمة + الرسالة) أو نسخ الكود فقط.
class ReverseVerifyBox extends StatefulWidget {
  const ReverseVerifyBox({super.key, required this.controller});

  final ReverseVerifyMixin controller;

  @override
  State<ReverseVerifyBox> createState() => _ReverseVerifyBoxState();
}

class _ReverseVerifyBoxState extends State<ReverseVerifyBox> {
  static const _green = Color(0xFF25D366);
  static const _brown = Color(0xFF4A2E1F);

  /// 0 = هذا الجهاز، 1 = جهاز آخر
  int _mode = 0;

  ReverseVerifyMixin get c => widget.controller;

  void _copy(String value, String label) {
    if (value.trim().isEmpty) return;
    Clipboard.setData(ClipboardData(text: value));
    AppSnackBar.success('تم نسخ $label');
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (c.reverseStarting.value && !c.hasReverseSession) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: CircularProgressIndicator()),
        );
      }

      if (!c.hasReverseSession) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            c.reverseError.value.isEmpty
                ? 'تعذّر بدء التحقق، حاول مجدداً'
                : c.reverseError.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFFC62828)),
          ),
        );
      }

      if (c.reverseVerified.value) return _verifiedCard();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'لتأكيد رقمك، أرسل رسالة تحقّق إلى واتساب خدمتنا. اختر الطريقة المناسبة:',
            textAlign: TextAlign.center,
            style: TextStyle(color: _brown, fontSize: 13.5, height: 1.5),
          ),
          const SizedBox(height: 14),

          // الخياران
          Row(
            children: [
              Expanded(
                child: _optionCard(
                  index: 0,
                  icon: Icons.phone_iphone,
                  title: 'واتساب على\nهذا الجهاز',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _optionCard(
                  index: 1,
                  icon: Icons.devices_other,
                  title: 'واتساب على\nجهاز آخر',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // المحتوى حسب الخيار
          _mode == 0 ? _thisDeviceContent() : _otherDeviceContent(),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // زر التحقق (يعمل تلقائياً بالخلفية أيضاً)
          SizedBox(
            height: 46,
            child: OutlinedButton.icon(
              onPressed: c.reverseChecking.value
                  ? null
                  : () => c.checkReverseStatus(),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _brown),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: c.reverseChecking.value
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.verified_outlined, color: _brown, size: 20),
              label: Text(
                c.reverseChecking.value
                    ? 'جارٍ التحقق…'
                    : 'أرسلتُ الرمز — تحقّق الآن',
                style: const TextStyle(color: _brown, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          if (c.reverseError.value.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              c.reverseError.value,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFFC62828), fontSize: 13),
            ),
          ],

          const SizedBox(height: 12),
          const Text(
            'يتم التحقق تلقائياً خلال ثوانٍ من إرسالك الرسالة.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      );
    });
  }

  // ── بطاقة خيار ──
  Widget _optionCard({
    required int index,
    required IconData icon,
    required String title,
  }) {
    final selected = _mode == index;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => setState(() => _mode = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEFFbf2) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? _green : const Color(0xFFE0E0E0),
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? _green : Colors.grey, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.3,
                fontWeight: FontWeight.bold,
                color: selected ? _brown : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── الخيار 1: هذا الجهاز ──
  Widget _thisDeviceContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'سيفتح واتساب على رقم الخدمة والرسالة جاهزة — فقط اضغط «إرسال» داخل واتساب.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF555555), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ElevatedButton.icon(
            onPressed: c.openReverseWhatsApp,
            style: ElevatedButton.styleFrom(
              backgroundColor: _green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            icon: const Icon(Icons.chat, color: Colors.white),
            label: const Text(
              'افتح واتساب وأرسل',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── الخيار 2: جهاز آخر ──
  Widget _otherDeviceContent() {
    final code = c.reverseCode.value;
    final message = c.reverseMessage;
    final link = c.reverseWaLink.value;
    final number = c.reverseServiceNumber.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'على الجهاز الذي فيه واتساب رقمك، اختر إحدى الطريقتين:',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFF555555), fontSize: 13, height: 1.5),
        ),
        const SizedBox(height: 12),

        // (أ) نسخ الرابط الجاهز
        _actionTile(
          num: '1',
          text: 'انسخ الرابط وافتحه على الجهاز الآخر — يفتح واتساب والرسالة جاهزة.',
          buttonLabel: 'نسخ الرابط',
          onTap: () => _copy(link, 'الرابط'),
        ),
        const SizedBox(height: 10),

        // (ب) نسخ الكود / الرسالة وإرسالها يدوياً
        _actionTile(
          num: '2',
          text: 'أو أرسل الرسالة التالية إلى رقم الخدمة يدوياً:',
          buttonLabel: 'نسخ الكود',
          onTap: () => _copy(code, 'الكود'),
          extra: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _miniCopyLine('الرسالة', message, () => _copy(message, 'الرسالة')),
              const SizedBox(height: 6),
              if (number.isNotEmpty)
                _miniCopyLine('رقم الخدمة', number, () => _copy(number, 'رقم الخدمة')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionTile({
    required String num,
    required String text,
    required String buttonLabel,
    required VoidCallback onTap,
    Widget? extra,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE6E6E6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 11,
                backgroundColor: _brown,
                child: Text(
                  num,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Color(0xFF444444),
                    fontSize: 12.5,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
          if (extra != null) ...[
            const SizedBox(height: 8),
            extra,
          ],
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: OutlinedButton.icon(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: _green),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              icon: const Icon(Icons.copy, size: 18, color: _green),
              label: Text(
                buttonLabel,
                style: const TextStyle(
                  color: _green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniCopyLine(String label, String value, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Text(
              '$label: ',
              style: const TextStyle(color: Color(0xFF9A9A9A), fontSize: 12),
            ),
            Expanded(
              child: Text(
                value,
                textDirection: TextDirection.ltr,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _brown,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
            ),
            const Icon(Icons.copy, size: 15, color: Color(0xFF9A9A9A)),
          ],
        ),
      ),
    );
  }

  Widget _verifiedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F9EF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _green),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: _green, size: 26),
          SizedBox(width: 8),
          Text(
            'تم التحقق بنجاح ✓',
            style: TextStyle(
              color: _green,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

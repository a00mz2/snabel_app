// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

/// شاشة "يجب التحديث" — تُعرض عند اكتشاف أن إصدار التطبيق غير مسموح به.
/// تحجب التنقل الخلفي وتُجبر المستخدم على التحديث.
class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  static const String routeName = '/ForceUpdate';

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final latestVersion = args['latestVersion'] as String? ?? '';
    final updateUrl = args['updateUrl'] as String? ?? '';

    return PopScope(
      // ← منع الرجوع للخلف
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFF8F0),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ─── أيقونة التحديث ────────────────────────────────────
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF39316).withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.system_update_alt_rounded,
                      size: 70,
                      color: Color(0xFFF39316),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── العنوان ───────────────────────────────────────────
                  const Text(
                    'يجب تحديث التطبيق',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                      fontFamily: 'Hanimation Arabic',
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── الوصف ────────────────────────────────────────────
                  const Text(
                    'نسخة التطبيق الحالية لم تعد مدعومة.\nيرجى التحديث للاستمرار في الاستخدام.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF555555),
                      fontFamily: 'Hanimation Arabic',
                      height: 1.7,
                    ),
                  ),

                  // ─── رقم الإصدار الجديد ────────────────────────────────
                  if (latestVersion.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF39316).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFF39316).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        'الإصدار الجديد: $latestVersion',
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFFF39316),
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Hanimation Arabic',
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 40),

                  // ─── زر التحديث ───────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed:
                          updateUrl.isNotEmpty
                              ? () => _launchUpdate(updateUrl)
                              : null,
                      icon: const Icon(Icons.download_rounded, size: 22),
                      label: const Text(
                        'تحديث التطبيق الآن',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Hanimation Arabic',
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF39316),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ─── نص توضيحي إضافي ──────────────────────────────────
                  const Text(
                    'التحديث مجاني وسيستغرق دقيقة واحدة فقط',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF999999),
                      fontFamily: 'Hanimation Arabic',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _launchUpdate(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

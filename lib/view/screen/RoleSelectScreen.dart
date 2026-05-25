// ignore_for_file: file_names

import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// صفحة البداية لاختيار دور المستخدم — تصميم مقسوم نصفين:
/// النصف الأيمن للتاجر (برتقالي)، الأيسر للسائق (بني داكن).
class RoleSelectScreen extends StatelessWidget {
  const RoleSelectScreen({super.key});

  // 🎨 ألوان الهوية
  static const Color _kOrange = Color(0xffF39316);
  static const Color _kDark = Color(0xff231209);
  static const Color _kDarker = Color(0xff1A0D04);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: _kDark,
      body: Column(
        children: [
          // ════════════════════════════════════════════════════════════
          // 🌑 القسم العلوي — الشعار والترحيب على خلفية داكنة
          // ════════════════════════════════════════════════════════════
          Container(
            width: double.infinity,
            color: _kDark,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // 🪧 شعار في دائرة
                    Container(
                      width: 86,
                      height: 86,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.35),
                        border: Border.all(
                          color: _kOrange.withValues(alpha: 0.55),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _kOrange.withValues(alpha: 0.18),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(AppImage.logoSplash),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // 🌐 الاسم بالإنكليزي
                    Text(
                      'SANABEL · TAHOONA',
                      style: TextStyle(
                        color: _kOrange.withValues(alpha: 0.75),
                        fontSize: 10,
                        letterSpacing: 4,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // ✨ الترحيب
                    Text(
                      'أهلاً بك في سنابل الطاحونة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: MyFontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'اختر نوع حسابك للمتابعة',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 13.5,
                        fontWeight: MyFontWeight.regular,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // ⚪ المؤشرات النقطية الزخرفية
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        _Dot(active: false),
                        SizedBox(width: 6),
                        _Dot(active: true),
                        SizedBox(width: 6),
                        _Dot(active: false),
                      ],
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
          // ════════════════════════════════════════════════════════════
          // 🟧🟫 القسم السفلي — البطاقتان المقسومتان
          // ════════════════════════════════════════════════════════════
          Expanded(
            child: Row(
              // 👇 ترتيب ثابت LTR: سائق على اليسار، تاجر على اليمين (مطابق للتصميم)
              textDirection: TextDirection.ltr,
              children: [
                // 🟫 جهة السائق — البني الداكن (السهم يتجه يساراً)
                Expanded(
                  child: _RolePanel(
                    bgColor: _kDarker,
                    iconBgColor: _kOrange.withValues(alpha: 0.15),
                    iconColor: _kOrange,
                    icon: Icons.pedal_bike_rounded,
                    labelEn: 'DRIVER',
                    labelEnColor: _kOrange,
                    titleAr: 'سائق',
                    subtitleAr: 'استلم الطلبات\nووصّلها للمتاجر',
                    arrowBgColor: _kOrange,
                    arrowIcon: Icons.chevron_right,
                    onTap: () => Get.toNamed('/driver/Login'),
                  ),
                ),
                // 🟧 جهة التاجر — البرتقالي الأساسي
                Expanded(
                  child: _RolePanel(
                    bgColor: _kOrange,
                    iconBgColor: Colors.white.withValues(alpha: 0.22),
                    iconColor: Colors.white,
                    icon: Icons.storefront_rounded,
                    labelEn: 'MERCHANT',
                    labelEnColor: Colors.white.withValues(alpha: 0.85),
                    titleAr: 'تاجر',
                    subtitleAr: 'تصفّح المنتجات\nوأنشئ طلباتك بسهولة',
                    arrowBgColor: _kDarker,
                    arrowIcon: Icons.chevron_left,
                    onTap: () => Get.toNamed('/Login'),
                  ),
                ),
              ],
            ),
          ),
          // 📝 توقيع سفلي
          Container(
            color: Colors.white,
            width: double.infinity,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'سنابل الطاحونة — نظام الطلبات والتوصيل',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xffA19491),
                    fontWeight: MyFontWeight.regular,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// نقطة زخرفية صغيرة — نقطة نشطة تكون أطول بلون برتقالي.
class _Dot extends StatelessWidget {
  final bool active;
  const _Dot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 22 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active
            ? const Color(0xffF39316)
            : Colors.white.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}

/// بطاقة نصف الشاشة لدور — أيقونة + label إنكليزي + عنوان عربي + وصف + زر سهم دائري.
class _RolePanel extends StatelessWidget {
  final Color bgColor;
  final Color iconBgColor;
  final Color iconColor;
  final IconData icon;
  final String labelEn;
  final Color labelEnColor;
  final String titleAr;
  final String subtitleAr;
  final Color arrowBgColor;
  final IconData arrowIcon;
  final VoidCallback onTap;

  const _RolePanel({
    required this.bgColor,
    required this.iconBgColor,
    required this.iconColor,
    required this.icon,
    required this.labelEn,
    required this.labelEnColor,
    required this.titleAr,
    required this.subtitleAr,
    required this.arrowBgColor,
    required this.arrowIcon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: bgColor,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.white.withValues(alpha: 0.10),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // 🟪 الأيقونة داخل مربع شبه شفاف
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: iconColor, size: 38),
              ),
              const SizedBox(height: 18),
              // 🌐 label إنكليزي
              Text(
                labelEn,
                style: TextStyle(
                  color: labelEnColor,
                  fontSize: 11,
                  letterSpacing: 4,
                  fontWeight: MyFontWeight.semiBold,
                ),
              ),
              const SizedBox(height: 6),
              // 🅰️ العنوان العربي الكبير
              Text(
                titleAr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 38,
                  fontWeight: MyFontWeight.bold,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 10),
              // 📝 وصف عربي
              Text(
                subtitleAr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.78),
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: MyFontWeight.regular,
                ),
              ),
              const Spacer(),
              // ⬅ زر السهم الدائري
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: arrowBgColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  arrowIcon,
                  color: Colors.white,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

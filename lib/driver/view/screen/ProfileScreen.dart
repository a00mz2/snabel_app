// ignore_for_file: file_names

import 'package:customer/driver/controller/ProfileController.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/services/services.dart';
import 'package:customer/driver/linkApi.dart';
import 'package:customer/driver/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة ملف السائق — مُعاد تصميمها بترتيب أنظف:
/// 1) بطاقة Hero (صورة + اسم + هاتف + شارة "سائق")
/// 2) قسم المعلومات الشخصية
/// 3) قسم الإعدادات (دعم / حول التطبيق)
/// 4) زر تسجيل الخروج
class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final DriverProfileController controller =
      Get.find<DriverProfileController>();

  // 🎨 ألوان الهوية
  static const Color _kOrange = Color(0xffF39316);
  static const Color _kDark = Color(0xff231F1E);
  static const Color _kDarkBrown = Color(0xff3C2313);
  static const Color _kMuted = Color(0xffA19491);
  static const Color _kBorder = Color(0xffF3F2F1);
  static const Color _kDanger = Color(0xffDC2626);

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      statusCode: controller.statusCode,
      statusRequest: controller.statusRequest,
      onRefresh: () => controller.getDriverProfile(),
      child: Obx(
        () => SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ════════════════════════════════════════════════
              // 1️⃣ بطاقة Hero — الصورة والاسم والهاتف
              // ════════════════════════════════════════════════
              _HeroCard(
                name: controller.dataAcoont['name']?.toString() ?? '',
                phone: controller.dataAcoont['phone']?.toString() ?? '',
                imagePath: controller.dataAcoont['image']?.toString(),
              ),

              const SizedBox(height: 28),

              // ════════════════════════════════════════════════
              // 2️⃣ المعلومات الشخصية
              // ════════════════════════════════════════════════
              _SectionTitle('المعلومات الشخصية'),
              const SizedBox(height: 10),
              _Card(
                children: [
                  _InfoRow(
                    icon: Icons.badge_outlined,
                    label: 'الاسم',
                    value: controller.dataAcoont['name']?.toString() ?? '—',
                  ),
                  const _RowDivider(),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'رقم الهاتف',
                    value: controller.dataAcoont['phone']?.toString() ?? '—',
                    valueLtr: true,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // ════════════════════════════════════════════════
              // 3️⃣ الإعدادات
              // ════════════════════════════════════════════════
              _SectionTitle('الإعدادات'),
              const SizedBox(height: 10),
              _Card(
                children: [
                  _MenuTile(
                    icon: Icons.support_agent_rounded,
                    iconBg: const Color(0xff01A850),
                    label: 'تواصل مع الدعم',
                    onTap: () => _showSupportDialog(context),
                  ),
                  const _RowDivider(),
                  _MenuTile(
                    icon: Icons.info_outline_rounded,
                    iconBg: _kOrange,
                    label: 'حول التطبيق',
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ════════════════════════════════════════════════
              // 4️⃣ زر تسجيل الخروج
              // ════════════════════════════════════════════════
              _LogoutButton(onTap: () => _handleLogout()),
            ],
          ),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // العمليات
  // ──────────────────────────────────────────────────────────

  void _handleLogout() {
    myServices.sharedPreferences.remove("id");
    myServices.sharedPreferences.remove("Token");
    myServices.sharedPreferences.remove("refreshToken");
    myServices.sharedPreferences.remove("router");
    myServices.sharedPreferences.remove("userRole");
    Get.offAllNamed("/");
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('تواصل مع الدعم'),
        content: const Text(
          'تواصل معنا عبر فريق الدعم الفنّي خلال ساعات العمل.\nسيتم التواصل معك خلال 24 ساعة.',
          style: TextStyle(height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('سنابل الطاحونة'),
        content: const Text(
          'تطبيق سائق سنابل الطاحونة\nنظام الطلبات والتوصيل\n\nالإصدار 1.0.0',
          style: TextStyle(height: 1.7),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// 🎨 المكوّنات المساعدة
// ════════════════════════════════════════════════════════════════

class _HeroCard extends StatelessWidget {
  final String name;
  final String phone;
  final String? imagePath;
  const _HeroCard({
    required this.name,
    required this.phone,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage =
        imagePath != null && imagePath!.isNotEmpty && imagePath != 'null';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [ProfileScreen._kDarkBrown, ProfileScreen._kDark],
        ),
        boxShadow: [
          BoxShadow(
            color: ProfileScreen._kDarkBrown.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🟧 الأفتار الدائري (المُعدل لقص الصورة هندسياً بشكل دائري)
          Container(
            width: 78,
            height: 78,
            padding: const EdgeInsets.all(3), // سُمك الإطار البرتقالي خارجي
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ProfileScreen._kOrange,
                  ProfileScreen._kOrange.withOpacity(0.55),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle, // إجبار المحتوى الداخلي على شكل دائرة
                color: ProfileScreen._kDarkBrown,
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(
                          DriverApplink.serverImage + imagePath!,
                        ),
                        fit: BoxFit
                            .cover, // قص حواف الصورة لتطابق الدائرة تماماً
                      )
                    : null,
              ),
              child: !hasImage
                  ? const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 38,
                    )
                  : null,
            ),
          ),

          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? '—' : name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    phone.isEmpty ? '—' : phone,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: ProfileScreen._kOrange,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pedal_bike_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'سائق',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: ProfileScreen._kOrange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: MyFontWeight.bold,
              color: ProfileScreen._kDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final List<Widget> children;
  const _Card({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: ProfileScreen._kBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Container(height: 1, color: ProfileScreen._kBorder),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool valueLtr;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueLtr = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ProfileScreen._kOrange.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: ProfileScreen._kOrange, size: 18),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: MyFontWeight.regular,
              color: ProfileScreen._kMuted,
            ),
          ),
          // Expanded + AlignmentDirectional.centerEnd يدفع القيمة لأقصى اليسار في RTL
          Expanded(
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Directionality(
                textDirection: valueLtr
                    ? TextDirection.ltr
                    : Directionality.of(context),
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: MyFontWeight.semiBold,
                    color: ProfileScreen._kDark,
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

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String label;
  final VoidCallback onTap;
  const _MenuTile({
    required this.icon,
    required this.iconBg,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: iconBg, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: MyFontWeight.semiBold,
                    color: ProfileScreen._kDark,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: ProfileScreen._kMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  final VoidCallback onTap;
  const _LogoutButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: ProfileScreen._kDanger.withOpacity(0.08),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ProfileScreen._kDanger.withOpacity(0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.logout_rounded,
                color: ProfileScreen._kDanger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  color: ProfileScreen._kDanger,
                  fontSize: 15,
                  fontWeight: MyFontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

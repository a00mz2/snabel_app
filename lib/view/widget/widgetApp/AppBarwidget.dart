// ignore_for_file: file_names, avoid_web_libraries_in_flutter, deprecated_member_use

import 'package:customer/controller/MainController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/constant/assets/images.dart';
import 'package:customer/core/functions/SetServer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(80);
  final bool? isSub;
  final bool? hideNotifications;
  final String? namePage;
  final Widget? iconPage;

  const AppBarWidget({
    super.key,
    this.isSub = false,
    this.hideNotifications = false,
    this.iconPage,
    this.namePage = "",
  });

  /// ⚠️ بحث كسول محروس، لا حقل نهائي.
  ///
  /// هذا الشريط يُستعمل في شاشات مشتركة يفتحها **السائق** أيضاً («تواصل مع الدعم»)،
  /// و`MainController` مسجَّل في `MainBinding` على مسار الزبون `/MainScreen` وحده.
  /// المُهيِّئ النهائي كان يُنفَّذ لحظة بناء الودجت — قبل تجميع `AppBar` أصلاً — فيُسقط
  /// جلسة السائق بشاشة GetX الحمراء، حتى حين لا يُعرض جرس الإشعارات إطلاقاً
  /// (`isSub: true` يُخفيه، وهو بالضبط ما تمرّره شاشة الدردشة).
  MainController? get _main =>
      Get.isRegistered<MainController>() ? Get.find<MainController>() : null;

  /// أيقونة الجرس: تتبدّل مع عدّاد غير المقروء حين يوجد الكنترولر.
  ///
  /// ⚠️ بلا كنترولر نُعيد صورة ساكنة **خارج** `Obx`: لفّ `Obx` حول بناء لا يقرأ أي
  /// متغيّر تفاعلي يرمي «improper use of a GetX» — أي نستبدل انهياراً بانهيار.
  Widget _notificationsIcon() {
    final controller = _main;
    if (controller == null) {
      return Image.asset(AppIcons.notificationAc, width: 22, height: 22);
    }
    return Obx(
      () => Image.asset(
        controller.countNotifications.value == 0
            ? AppIcons.notificationAc
            : AppIcons.notification,
        width: 22,
        height: 22,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      titleSpacing: -8,
      centerTitle: false,
      elevation: 4,
      toolbarHeight: 80,
      backgroundColor: Colors.white,
      title: isSub!
          ? Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                iconPage != null
                    ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xffEFEFEF)),
                          shape: BoxShape.circle,
                        ),
                        width: 40,
                        height: 40,
                        child: Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10000),
                            child: iconPage ?? SizedBox(),
                          ),
                        ),
                      )
                    : SizedBox(),
                SizedBox(width: 6),
                Text(
                  namePage ?? "",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: MyFontWeight.medium,
                    color: Color(0xff292929),
                  ),
                ),
              ],
            )
          : SizedBox(),
      leading: isSub!
          ? IconButton(
              onPressed: () {
                // Get.find()
                Get.back(result: true);
              },
              icon: Image.asset(AppIcons.arrow_back, width: 24, height: 24),
            )
          : InkWell(
              onLongPress: () => setServer(context),
              child: Image.asset(AppImage.logoAppbar),
            ),
      actions: [
        isSub!
            ? SizedBox()
            : Material(
                color: Colors
                    .transparent, // لازم علشان يظهر السبلـاش فوق اللون الحالي
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    50,
                  ), // نصف القطر كبير يكفي للدائرة
                  onTap: () => Get.toNamed("/Searching"),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color(0xffEFEFEF),
                      shape: BoxShape.circle,
                    ),
                    width: 40,
                    height: 40,
                    child: Center(
                      child: Image.asset(AppIcons.serch, width: 20, height: 20),
                    ),
                  ),
                ),
              ),
        SizedBox(width: 8),
        isSub!
            ? SizedBox()
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.toNamed('/Notifications'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffEFEFEF),
                      shape: BoxShape.circle,
                    ),
                    width: 40,
                    height: 40,

                    child: Center(child: _notificationsIcon()),
                  ),
                ),
              ),
        SizedBox(width: 12),
      ],
    );
  }
}

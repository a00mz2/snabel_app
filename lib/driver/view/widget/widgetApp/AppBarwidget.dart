// ignore_for_file: file_names, avoid_web_libraries_in_flutter, deprecated_member_use

import 'package:customer/driver/controller/MainController.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/constant/assets/icons.dart';
import 'package:customer/driver/core/constant/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(80);
  final bool? isSub;
  final bool? hideNotifications;
  final String? namePage;
  final Widget? iconPage;

  AppBarWidget({
    super.key,
    this.isSub = false,
    this.hideNotifications = false,
    this.iconPage,
    this.namePage = "",
  });

  final MainControlIer mainController = Get.find<MainControlIer>();

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
                        child: Center(child: iconPage ?? SizedBox()),
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
          : InkWell(child: Image.asset(AppImage.logoAppbar)),
      actions: [
        isSub!
            ? SizedBox()
            : Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.toNamed('/driver/Notifications'),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xffEFEFEF),
                      shape: BoxShape.circle,
                    ),
                    width: 40,
                    height: 40,

                    child: Center(
                      child: Obx(
                        () => Image.asset(
                          mainController.countNotifications.value == 0
                              ? AppIcons.notificationAc
                              : AppIcons.notification,
                          width: 22,
                          height: 22,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
        SizedBox(width: 12),
      ],
    );
  }
}

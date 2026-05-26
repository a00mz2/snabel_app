// ignore_for_file: deprecated_member_use, file_names

import 'package:customer/driver/controller/MainController.dart';
import 'package:customer/driver/core/constant/size.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/constant/assets/icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bouncing_widget/bouncing_widget.dart';

class CustomBottomBarCustomer extends GetView<MainControlIer> {
  const CustomBottomBarCustomer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: kMainBottomNavigationBarHeight,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          /// 🔹 الشريط الأبيض
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xffF6F6F6))),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 14,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Row(
                  children: [
                    _BottomItem(
                      assetIcon: AppIcons.homeIconnotAc,
                      label: "الرئيسية",
                      isActive: controller.currentIndex.value == 0,
                      onTap: () => controller.changeTab(0),
                    ),
                    _BottomItem(
                      assetIcon: AppIcons.ordericonnotAc,
                      label: "طلباتي",
                      isActive: controller.currentIndex.value == 1,
                      onTap: () => controller.changeTab(1),
                    ),
                    _BottomItem(
                      assetIcon: AppIcons.wallet,
                      label: "المحفظة",
                      isActive: controller.currentIndex.value == 2,
                      onTap: () => controller.changeTab(2),
                    ),
                    _BottomItem(
                      assetIcon: AppIcons.ProfilenotAc,
                      label: "ملفي",
                      isActive: controller.currentIndex.value == 3,
                      onTap: () => controller.changeTab(3),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final String? assetIcon;
  final IconData? materialIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _BottomItem({
    this.assetIcon,
    this.materialIcon,
    required this.label,
    required this.onTap,
    this.isActive = false,
  }) : assert((assetIcon != null) ^ (materialIcon != null));

  @override
  Widget build(BuildContext context) {
    final targetColor = isActive ? const Color(0xFFF39316) : Color(0xFFA19491);

    return Expanded(
      child: BouncingWidget(
        onPressed: onTap,
        child: TweenAnimationBuilder<Color?>(
          duration: const Duration(milliseconds: 200),
          curve: Curves.bounceIn,
          tween: ColorTween(end: targetColor),
          builder: (context, color, child) {
            final c = color ?? targetColor;
            return Container(
              color: Colors.white,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  materialIcon != null
                      ? Icon(materialIcon, size: 24, color: c)
                      : Image.asset(assetIcon!, width: 24, height: 24, color: c),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: c,
                      fontSize: 8,
                      fontWeight: MyFontWeight.semiBold,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

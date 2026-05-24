import 'package:customer/controller/MainController.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/view/screen/CartScreen.dart';
import 'package:customer/view/screen/HomeScreen.dart';
import 'package:customer/view/screen/OrdersScreen.dart';
import 'package:customer/view/screen/ProfileScreen.dart';
import 'package:customer/view/screen/WalletScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends GetView<MainController> {
  const MainScreen({super.key});

  Widget _walletCenterButton() {
    return Container(
      width: 64,
      height: 64,
      decoration: const BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Image.asset(
          AppIcons.wallet,
          width: 28,
          height: 28,
          // color: Colors.white,
        ),
      ),
    );
  }

  Widget _bottomItem({
    required String icon,
    required String activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              isActive ? activeIcon : icon,
              width: 24,
              height: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.orange : const Color(0xffA19491),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(),
      CartScreen(),
      WalletScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];

    final bottomBarHeight = 96.0;
    final systemBottom = MediaQuery.of(context).padding.bottom;
    final contentBottomPadding = bottomBarHeight + systemBottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: contentBottomPadding),
            child: Obx(() => pages[controller.currentIndex.value]),
          ),
          SafeArea(
            top: false,
            maintainBottomViewPadding: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                height: 96,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 76,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: const Border(
                          top: BorderSide(color: Color(0xffF6F6F6)),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Obx(
                        () => Row(
                          children: [
                            _bottomItem(
                              icon: AppIcons.homeIconnotAc,
                              activeIcon: AppIcons.homeIcon,
                              label: 'الرئيسية',
                              isActive: controller.currentIndex.value == 0,
                              onTap: () => controller.changePage(0),
                            ),
                            _bottomItem(
                              icon: AppIcons.cart,
                              activeIcon: AppIcons.cartAc,
                              label: 'السلة',
                              isActive: controller.currentIndex.value == 1,
                              onTap: () => controller.changePage(1),
                            ),
                            const SizedBox(width: 68),
                            _bottomItem(
                              icon: AppIcons.ordericonnotAc,
                              activeIcon: AppIcons.ordericon,
                              label: 'طلباتي',
                              isActive: controller.currentIndex.value == 3,
                              onTap: () => controller.changePage(3),
                            ),
                            _bottomItem(
                              icon: AppIcons.ProfilenotAc,
                              activeIcon: AppIcons.Profile,
                              label: 'ملفي',
                              isActive: controller.currentIndex.value == 4,
                              onTap: () => controller.changePage(4),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 22,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(40),
                        onTap: () => controller.changePage(2),
                        child: _walletCenterButton(),
                      ),
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

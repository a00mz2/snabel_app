import 'package:customer/controller/MainController.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/services/support_chat_service.dart';
import 'package:customer/view/screen/CartScreen.dart';
import 'package:customer/view/screen/HomeScreen.dart';
import 'package:customer/view/screen/OrdersScreen.dart';
import 'package:customer/view/screen/ProfileScreen.dart';
import 'package:customer/view/screen/WalletScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final List<Widget> _pages;
  late final MainController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<MainController>();
    // الصفحات تُبنى مرة واحدة فقط — IndexedStack يُبقي حالتها بدون إعادة تحميل عند التبديل.
    _pages = [
      HomeScreen(),
      CartScreen(),
      WalletScreen(),
      OrdersScreen(),
      ProfileScreen(),
    ];
  }

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
    final bottomBarHeight = 96.0;
    final systemBottom = MediaQuery.of(context).padding.bottom;
    final contentBottomPadding = bottomBarHeight + systemBottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: contentBottomPadding),
            child: Obx(
              () => IndexedStack(
                index: controller.currentIndex.value,
                sizing: StackFit.expand,
                children: _pages,
              ),
            ),
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
          // زر «تواصل مع الدعم» العائم — هنا لا داخل التبويبات عمداً:
          //  * ScaffoldWidget يستبدل جسم كل تبويب بشاشة الحالة عند أي حالة غير success،
          //    فزرّ داخل تبويب يختفي أثناء التحميل. هنا يبقى فوق التبويبات الخمسة.
          //  * إلى الجانب لا المنتصف: زر المحفظة يشغل منتصف الشريط ويرتفع فوقه.
          //  * متاح لكل تاجر بلا تفعيل من الإدارة.
          if (Get.isRegistered<SupportChatService>())
            Obx(
              () => PositionedDirectional(
                end: 16,
                bottom: contentBottomPadding + 12,
                child: _SupportChatFab(
                  unread: Get.find<SupportChatService>().unreadTotal.value,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// دائرة برتقالية بلون زر المحفظة، مع شارة حمراء بعدد غير المقروء في زاويتها.
class _SupportChatFab extends StatelessWidget {
  const _SupportChatFab({required this.unread});

  final int unread;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'تواصل مع الدعم',
      child: SizedBox(
        width: 62,
        height: 62,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Material(
                color: Colors.orange,
                shape: const CircleBorder(),
                elevation: 6,
                shadowColor: Colors.black.withValues(alpha: 0.25),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Get.toNamed('/SupportChat'),
                  child: const Center(
                    child: Icon(
                      Icons.support_agent_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
            if (unread > 0)
              PositionedDirectional(
                top: -4,
                start: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  constraints: const BoxConstraints(minWidth: 22),
                  decoration: BoxDecoration(
                    color: const Color(0xffF31616),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    unread > 99 ? '99+' : '$unread',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

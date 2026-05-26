// ignore_for_file: file_names

import 'package:customer/driver/Widget/CustomBottomBarCustomer.dart';
import 'package:customer/driver/controller/MainController.dart';
import 'package:customer/driver/core/constant/size.dart';
import 'package:customer/driver/core/services/notification_service.dart';
import 'package:customer/driver/view/screen/DriverWalletScreen.dart';
import 'package:customer/driver/view/screen/HomeScreen.dart';
import 'package:customer/driver/view/screen/OrdersScreen.dart';
import 'package:customer/driver/view/screen/ProfileScreen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late final List<Widget> _tabPages;

  @override
  void initState() {
    super.initState();
    _tabPages = [
      HomeScreen(),
      OrdersScreen(),
      const DriverWalletScreen(),
      ProfileScreen(),
    ];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NotificationService.consumePendingInitialTapIfAny();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainControlIer>();

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          /// 🔹 الصفحات — مسافة سفلية = الشريط + منطقة الإيماء/النظام
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: kMainBottomNavigationBarHeight + bottomInset,
              ),
              child: Obx(
                () => IndexedStack(
                  index: controller.currentIndex.value,
                  sizing: StackFit.expand,
                  children: _tabPages,
                ),
              ),
            ),
          ),

          /// 🔻 Bottom Bar
          SafeArea(
            top: false,
            maintainBottomViewPadding: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomBarCustomer(),
            ),
          ),
        ],
      ),
    );
  }
}

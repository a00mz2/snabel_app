// ignore_for_file: camel_case_types

import 'package:customer/driver/Binding/BindingApp.dart';
import 'package:customer/driver/view/screen/DriverSettlementDetailScreen.dart';
import 'package:customer/driver/view/screen/LoginScreen.dart';
import 'package:customer/driver/view/screen/MainScreen.dart';
import 'package:customer/driver/view/screen/NotificationsScreen.dart';
import 'package:customer/driver/view/screen/OrderDetelsScreen.dart';
import 'package:customer/driver/view/screen/SplashScreen.dart';
import 'package:get/get.dart';

/// مسارات تطبيق السائق — كلها مُسَبَّقة بـ `/driver/` لتجنّب التعارض مع مسارات الزبون.
/// تُستورد من `lib/core/constant/routes.dart` (الزبون) وتُضمّ إلى قائمة `routes`.
List<GetPage<dynamic>> driverRoutes = [
  GetPage(
    name: '/driver/Login',
    page: () => LoginScreen(),
    binding: DriverLoginBinding(),
  ),
  GetPage(
    name: '/driver/Splash',
    page: () => SplashScreen(),
    binding: DriverSplashBinding(),
  ),
  GetPage(
    name: '/driver/MainScreen',
    page: () => MainScreen(),
    binding: DriverMainBinding(),
  ),
  GetPage(
    name: '/driver/OrderDetels',
    page: () => OrderDetelsScreen(),
    binding: OrderDetelsBinding(),
  ),
  GetPage(
    name: '/driver/Notifications',
    page: () => NotificationsScreen(),
    binding: DriverNotificationsBinding(),
  ),
  GetPage(
    name: '/driver/DriverSettlementDetail',
    page: () => DriverSettlementDetailScreen(),
    binding: DriverSettlementDetailBinding(),
  ),
];

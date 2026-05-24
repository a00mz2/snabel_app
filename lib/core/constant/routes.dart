// ignore_for_file: camel_case_types

import 'package:customer/Binding/BindingApp.dart';
import 'package:customer/view/screen/ForgotPasswordScreen.dart';
import 'package:customer/view/screen/LoginScreen.dart';
import 'package:customer/view/screen/MainScreen.dart';
import 'package:customer/view/screen/NotificationsScreen.dart';
import 'package:customer/view/screen/ProductsDetailSecrren.dart';
import 'package:customer/view/screen/SectionProductsSecrren.dart';
import 'package:customer/view/screen/SectionsScreen.dart';
import 'package:customer/view/screen/SendOrderScreen.dart';
import 'package:customer/view/screen/SerchScreen.dart';
import 'package:customer/view/screen/SignUpScreen.dart';
import 'package:customer/view/screen/SplashScreen.dart';
import 'package:customer/view/screen/UpdateDataProfileScreen.dart';
import 'package:customer/view/screen/orderDetailSecrren.dart';
import 'package:customer/view/screen/otpScreen.dart';
import 'package:customer/view/screen/PinnedOrderDetailScreen.dart';
import 'package:customer/view/screen/PinnedOrderEditScreen.dart';
import 'package:customer/view/screen/PinnedOrdersScreen.dart';
import 'package:customer/view/screen/ContactUsScreen.dart';
import 'package:customer/view/screen/PrivacyPolicyScreen.dart';
import 'package:get/get.dart';

List<GetPage<dynamic>>? routes = [
  GetPage(
    name: '/',
    page: () => LoginScreen(),
    binding: LoginBinding(),

    transition: Transition.fade,
    transitionDuration: const Duration(milliseconds: 500),
  ),
  GetPage(
    name: '/ForgotPassword',
    page: () => const ForgotPasswordScreen(),
    binding: ForgotPasswordBinding(),
  ),
  GetPage(
    name: '/Splash',
    page: () => SplashScreen(),
    binding: SplashBinding(),
  ),
  GetPage(
    name: '/MainScreen',
    page: () => MainScreen(),
    binding: MainBinding(),
  ),
  GetPage(
    name: '/SignUp',
    page: () => SignUpScreen(),
    binding: SignUpBinding(),
  ),
  GetPage(name: '/Otp', page: () => OtpScreen(), binding: SignUpBinding()),

  GetPage(
    name: '/Searching',
    page: () => SearchingScreen(),
    binding: SearchingBinding(),
  ),
  GetPage(
    name: '/Notifications',
    page: () => NotificationsScreen(),
    binding: NotificationsBinding(),
  ),
  GetPage(
    name: '/Sections',
    page: () => SectionsScreen(),
    binding: SectionsBinding(),
  ),
  GetPage(
    name: '/SectionProducts',
    page: () => SectionProductsSecrren(),
    binding: SectionProductsBinding(),
  ),
  GetPage(
    name: '/ProductsDetailSecrren',
    page: () => ProductsDetailSecrren(),
    binding: ProductsDetailBinding(),
    preventDuplicates: false,
  ),
  GetPage(
    name: '/SendOrder',
    page: () => SendOrderScreen(),
    binding: SendOrderBinding(),
    preventDuplicates: false,
  ),
  GetPage(
    name: orderDetailSecrren.routeName,
    page: () => orderDetailSecrren(),
    binding: OrderDetailBinding(),
    preventDuplicates: false,
  ),
  GetPage(
    name: '/UpdateDataProfileScreen',
    page: () => UpdateDataProfileScreen(),
    binding: UpdateDataProfileBinding(),
    preventDuplicates: false,
  ),
  GetPage(
    name: '/PinnedOrders',
    page: () => const PinnedOrdersScreen(),
    binding: PinnedOrdersBinding(),
  ),
  GetPage(
    name: '/PinnedOrderDetail',
    page: () => const PinnedOrderDetailScreen(),
    binding: PinnedOrderDetailBinding(),
    preventDuplicates: false,
  ),
  GetPage(
    name: '/PinnedOrderEdit',
    page: () => const PinnedOrderEditScreen(),
    binding: PinnedOrderEditBinding(),
    preventDuplicates: false,
  ),
  GetPage(
    name: '/ContactUs',
    page: () => const ContactUsScreen(),
    binding: ContactUsBinding(),
  ),
  GetPage(
    name: '/PrivacyPolicy',
    page: () => const PrivacyPolicyScreen(),
  ),
];

  // GetPage(name: '/Order', page: () => OrdeScreen(), binding: (OrderBinding())),

  // GetPage(
  //   name: '/OrderDetails/:orderId',
  //   page: () {
  //     final orderId = Get.parameters['orderId'];
  //     print(orderId);
  //     return OrderDetailsScreen(indexOrder: orderId);
  //   },
  //   binding: OrderDetailsBinding(Get.parameters['orderId']),
  // ),
  // GetPage(name: '/Order', page: () => OrdeScreen(), binding: OrderBinding()),
  // GetPage(
  //   name: '/OrderDetails/:orderId',
  //   page: () {
  //     return OrderDetailsScreen();
  //   },
  // ),

  // GetPage(
  //   name: '/Section',
  //   page: () => SectionScreen(),
  //   binding: (SectionBinding()),
  // ),

  // GetPage(name: '/Users', page: () => UsersScreen(), binding: (UsersBinding())),

  // GetPage(
  //   name: '/JoiningOrder',
  //   page: () => JoiningOrderScreen(),
  //   binding: (JoiningOrderBinding()),
  // ),
  // GetPage(
  //   name: '/JoiningOrderDetails',
  //   page: () {
  //     final args = Get.arguments;
  //     return JoiningOrderDetailsScreen(args: args);
  //   },
  //   binding: (JoiningOrderDetailsBinding()),
  // ),

  // GetPage(
  //   name: '/Products',
  //   page: () => ProductsScreen(),
  //   binding: (ProductsBinding()),
  // ),

  // GetPage(
  //   name: '/ProductDetails',
  //   page: () {
  //     final args = Get.arguments;
  //     return ProductDetailsScreen(args: args);
  //   },
  //   binding: (ProductDetailsBinding()),
  // ),

  // GetPage(
  //   name: '/AddNewItem',
  //   page: () {
  //     final args = Get.arguments;
  //     return AddNewItemScreen(args: args);
  //   },
  //   binding: (AddNewItemBinding()),
  // ),

  // GetPage(
  //   name: '/AddOReditSection',
  //   page: () {
  //     final args = Get.arguments as Map;
  //     return AddOReditSectionScreen(args: args);
  //   },
  //   binding: (AddOrUpdateSectionBinding()),
  // ),
  // GetPage(
  //   name: '/Test',
  //   page: () {
  //     // final args = Get.arguments as Map;
  //     return TestScreen();
  //   },
  //   binding: (TestBinding()),
  // ),


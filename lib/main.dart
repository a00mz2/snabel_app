// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:customer/core/services/notification_service.dart';
import 'package:customer/core/functions/app_scaffold_messenger.dart';
import 'package:customer/core/constant/routes.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/firebase_options.dart';
import 'package:customer/Binding/InitialBindings.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

   switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      AndroidWebViewPlatform.registerWith();
      break;
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      WebKitWebViewPlatform.registerWith();
      break;
    default:
      break;
  }

  await initialservices();
  await NotificationService.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.white),
  );

  runApp(const MyApp());
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await Future.delayed(const Duration(milliseconds: 800));

    if (NotificationService.initialNotificationData != null) {
      print("🚀 تنفيذ الإشعار بعد تشغيل GetX بالكامل");
      NotificationService.onTapNotification(
        NotificationService.initialNotificationData!,
      );
      NotificationService.initialNotificationData = null;
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      scaffoldMessengerKey: appScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      title: "سنابل الطاحونة",
      theme: lightTheme,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialBinding: InitialBindings(),
      defaultTransition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
      initialRoute: "/Splash",
      getPages: routes,
    );
  }
}

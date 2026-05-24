// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:customer/controller/MainController.dart';
import 'package:customer/controller/WalletController.dart';
import 'package:customer/core/functions/notification_navigation.dart';
import 'package:customer/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// ✳️ تخزين بيانات الإشعار في حال فتح التطبيق من حالة مغلقة (terminated)
  static Map<String, dynamic>? initialNotificationData;

  //───────────────────────────────────────────────
  // 🟢 التهيئة الأساسية للنظام بالكامل
  //───────────────────────────────────────────────
  static Future<void> init() async {
    // Firebase يُهيأ في main() عبر DefaultFirebaseOptions

    // طلب إذن المستخدم للإشعارات (مطلوب في Android 13+)
    await FirebaseMessaging.instance.requestPermission();

    // إعداد الإشعارات المحلية (للعرض داخل التطبيق)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    // ✅ عند الضغط على الإشعار (من النظام المحلي)
    await _local.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          final data = _parsePayload(details.payload!);
          onTapNotification(data);
        } else {
          print("❌ لم يتم العثور على بيانات عند الضغط على الإشعار");
        }
      },
    );

    // ✅ عند استقبال إشعار أثناء فتح التطبيق (foreground)
    FirebaseMessaging.onMessage.listen((message) async {
      final notification = message.notification;
      final data = message.data;
      if (notification == null) return;

      if (defaultTargetPlatform == TargetPlatform.android) {
        final android = notification.android;
        if (android == null) return;
        await _local.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'سنابل الطاحونة',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          payload: data.isNotEmpty ? _encodeNotificationData(data) : '',
        );
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _local.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentBadge: true,
              presentSound: true,
            ),
          ),
          payload: data.isNotEmpty ? _encodeNotificationData(data) : '',
        );
      }

      onReceiveNotification(data);
    });

    // ✅ عند الضغط على الإشعار والتطبيق بالخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      if (message.data.isNotEmpty) {
        onTapNotification(message.data);
      }
    });

    // ✅ عند فتح التطبيق من إشعار وهو مغلق (terminated)
    final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null && initialMessage.data.isNotEmpty) {
      print("🚀 التطبيق فُتح من إشعار (terminated)");
      initialNotificationData = initialMessage.data;
    }

    // 💤 استقبال الإشعارات بالخلفية فقط (للتسجيل)
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
  }

  //───────────────────────────────────────────────
  // 🔹 معالج الإشعارات في الخلفية
  //───────────────────────────────────────────────
  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print('📩 إشعار بالخلفية: ${message.notification?.title}');
  }

  //───────────────────────────────────────────────
  // 🔹 تحويل الـ payload النصي إلى Map
  //───────────────────────────────────────────────
  static String _encodeNotificationData(Map<String, dynamic> data) {
    try {
      return jsonEncode(data);
    } catch (_) {
      return data.toString();
    }
  }

  static Map<String, dynamic> _parsePayload(String payload) {
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
    } catch (_) {}
    final clean = payload.replaceAll(RegExp(r'[\{\}]'), '');
    final pairs = clean.split(', ');
    final Map<String, dynamic> data = {};
    for (var pair in pairs) {
      final kv = pair.split(':');
      if (kv.length == 2) {
        data[kv[0].trim()] = kv[1].trim();
      }
    }
    return data;
  }

  //───────────────────────────────────────────────
  // 🟢 عند استلام إشعار جديد أثناء التشغيل (foreground)
  //───────────────────────────────────────────────
  static void onReceiveNotification(Map<String, dynamic> data) {
    print("📩 تم استلام إشعار جديد:");
    data.forEach((k, v) => print("➡️ $k : $v"));

    // مثال: تحديث عداد الإشعارات في MainController
    final MainController mainController = Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : Get.put(MainController());
    mainController.getUnreadCount();

    final WalletController walletController =
        Get.isRegistered<WalletController>()
        ? Get.find<WalletController>()
        : Get.put(WalletController());

    final type = data['type']?.toString();
    switch (type) {
      case 'WALLET_UPDATE':
        walletController.getTransactions();
        break;
      case 'ORDER':
      case 'ORDER_STATUS':
      case 'ORDER_STATUS_UPDATE':
        // التوجيه يتم عند الضغط على الإشعار (onTapNotification)، لا نغيّر الشاشة تلقائياً هنا
        break;

      default:
        print("🔔 إشعار عام أو غير معروف");
    }

    // من هنا يمكنك تنفيذ أكشنات لحظية بدون تنقل
    if (data['type'] == 'WALLET_UPDATE') {
      print("💰 تم استقبال إشعار تحديث المحفظة (foreground)");
    }
  }

  //───────────────────────────────────────────────
  // 🟡 عند ضغط المستخدم على الإشعار
  // (سواء من النظام، الخلفية، أو بعد الإغلاق)
  //───────────────────────────────────────────────
  static Future<void> onTapNotification(Map<String, dynamic> data) async {
    print("🖱️ تم الضغط على الإشعار:");
    data.forEach((k, v) => print("➡️ $k : $v"));

    // ننتظر قليلاً حتى يجهز GetX بالكامل
    await Future.delayed(const Duration(milliseconds: 300));

    final MainController mainController = Get.isRegistered<MainController>()
        ? Get.find<MainController>()
        : Get.put(MainController());

    mainController.getUnreadCount();

    final type = data['type']?.toString();

    switch (type) {
      case 'WALLET_UPDATE':
        mainController.changePage(2);
        Get.offAllNamed('/MainScreen', arguments: {'current': 2});
        break;

      case 'ORDER':
      case 'ORDER_STATUS':
      case 'ORDER_STATUS_UPDATE':
        navigateToOrderFromNotificationData(data);
        break;

      default:
        print("🔔 إشعار عام أو غير معروف");
        if (navigateToOrderFromNotificationData(data)) {
          return;
        }
        Get.toNamed('/Notifications');
    }
  }
}

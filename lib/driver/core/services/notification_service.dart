// ignore_for_file: avoid_print, unused_local_variable
import 'package:customer/driver/controller/driver_wallet_controller.dart';
import 'package:customer/driver/controller/MainController.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _local =
      FlutterLocalNotificationsPlugin();

  /// ✳️ تخزين بيانات الإشعار في حال فتح التطبيق من حالة مغلقة (terminated)
  static Map<String, dynamic>? initialNotificationData;

  /// يُملأ من [main] ثم يُستهلك عند أول ظهور لـ [MainScreen] (بعد تسجيل الدخول/السبلاش).
  static Map<String, dynamic>? pendingInitialTap;

  //───────────────────────────────────────────────
  // 🟢 التهيئة الأساسية للنظام بالكامل
  //───────────────────────────────────────────────
  static Future<void> init() async {
    // التهيئة في main.dart — تجنب الاستدعاء المزدوج هنا.

    // طلب إذن المستخدم للإشعارات (مطلوب في Android 13+)
    await FirebaseMessaging.instance.requestPermission();

    // إعداد الإشعارات المحلية (للعرض داخل التطبيق)
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

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
    FirebaseMessaging.onMessage.listen((message) {
      final notification = message.notification;
      final data = message.data;

      if (notification != null) {
        // عرض الإشعار محليًا (أندرويد و iOS)
        _local.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'default_channel',
              'App Notifications',
              importance: Importance.max,
              priority: Priority.high,
              playSound: true,
            ),
          ),
          payload: data.isNotEmpty ? data.toString() : '',
        );

        // تنفيذ دالة عند استلام الإشعار داخل التطبيق
        onReceiveNotification(data);
      }
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
  static Future<void> _backgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp();
    print('📩 إشعار بالخلفية: ${message.notification?.title}');
  }

  //───────────────────────────────────────────────
  // 🔹 تحويل الـ payload النصي إلى Map
  //───────────────────────────────────────────────
  static Map<String, dynamic> _parsePayload(String payload) {
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

    // // مثال: تحديث عداد الإشعارات في MainController
    // final MainController mainController = Get.isRegistered<MainController>()
    //     ? Get.find<MainController>()
    //     : Get.put(MainController());
    // mainController.getUnreadCount();

    // final WalletController walletController =
    //     Get.isRegistered<WalletController>()
    //     ? Get.find<WalletController>()
    //     : Get.put(WalletController());

    // final OrderDetailController orderDetailController =
    //     Get.isRegistered<OrderDetailController>()
    //     ? Get.find<OrderDetailController>()
    //     : Get.put(OrderDetailController());

    final type = data['type'];
    switch (type) {
      case 'WALLET_UPDATE':
        // walletController.getTransactions();
        break;
      case 'ORDER':
        // orderDetailController.getOrder();
        break;
      case 'DRIVER_SETTLEMENT_PENDING_APPROVAL':
        if (Get.isRegistered<DriverWalletController>()) {
          Get.find<DriverWalletController>().refreshList();
        }
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

    final MainControlIer mainController = Get.isRegistered<MainControlIer>()
        ? Get.find<MainControlIer>()
        : Get.put(MainControlIer());

    final type = data['type']?.toString();
    if (type == 'DRIVER_SETTLEMENT_PENDING_APPROVAL') {
      final sid = _stringFrom(data, 'settlementId') ??
          _stringFrom(data, 'settlement_id');
      await _openDriverMediatedSettlement(mainController, sid);
    }
  }

  /// يُستدعى مرة واحدة عند فتح [MainScreen] بعد أن يُخزَّن [pendingInitialTap] من إشعار التشغيل البارد.
  static Future<void> consumePendingInitialTapIfAny() async {
    if (pendingInitialTap == null) return;
    final d = Map<String, dynamic>.from(pendingInitialTap!);
    pendingInitialTap = null;
    await onTapNotification(d);
  }

  static String? _stringFrom(Map<String, dynamic> data, String key) {
    final v = data[key];
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  static Future<void> _openDriverMediatedSettlement(
    MainControlIer main,
    String? settlementId,
  ) async {
    main.changeTab(2);
    if (Get.currentRoute == '/driver/MainScreen') {
      if (settlementId != null && settlementId.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 150));
        Get.toNamed(
          '/driver/DriverSettlementDetail',
          arguments: {'settlementId': settlementId},
        );
      }
      return;
    }
    Get.offAllNamed('/driver/MainScreen', arguments: {'current': 2});
    await Future.delayed(const Duration(milliseconds: 400));
    if (settlementId != null && settlementId.isNotEmpty) {
      Get.toNamed(
        '/driver/DriverSettlementDetail',
        arguments: {'settlementId': settlementId},
      );
    }
  }
}

import 'dart:async';

import 'package:customer/core/services/services.dart';
import 'package:customer/core/services/support_http.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/model/SupportChatModel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// أنواع أحداث الدردشة الواصلة من الخادم.
enum SupportChatEventType { message, conversation, read, typing, unread, error }

class SupportChatEvent {
  const SupportChatEvent(this.type, this.data);
  final SupportChatEventType type;
  final Map<String, dynamic> data;
}

/// اتصال «تواصل مع الدعم» اللحظي — **للزبون والسائق معاً**.
///
/// خدمة دائمة (لا مرتبطة بالشاشة) حتى تبقى شارة غير المقروء صحيحة من أي تبويب.
///
/// نقاط تصميم تستحق الانتباه:
///  * **الدور**: التطبيق ملف تنفيذي واحد للدورين ويشتركان في مفتاح `Token`. الدور
///    (`userRole`) يحدّد قاعدة المسار وطبقة النقل ونقطة تجديد التوكن وغرفة السوكِت.
///    الخادم يشتقّ الطرف من التوكن نفسه، فلا يستطيع دور أن يصل محادثة الآخر.
///  * **`setAuthFn`**: توكن الوصول قصير العمر؛ تُقرأ قيمة طازجة عند كل اتصال وإعادة اتصال.
///  * **مهلة خلفية 25 ثانية**: القطع الفوري عند كل انتقال إلى الكاميرا أو مركز الإشعارات
///    يُنتج إعادة مصافحة متكررة بلا فائدة.
class SupportChatService extends GetxService with WidgetsBindingObserver {
  io.Socket? _socket;

  /// ⚠️ مُعيد البناء لا حقل نهائي: الخدمة `permanent` تُنشأ عند الإقلاع **قبل** أي تسجيل
  /// دخول، فحقلٌ نهائي كان سيُجمّد دور الجلسة على القيمة المخزَّنة وقتها. هذا يقرأ الدور
  /// عند كل نداء، فتنتقل الجلسة من زبون إلى سائق على الجهاز نفسه بلا إعادة تشغيل.
  SupportChatModel get _api => SupportChatModel();

  final RxBool isConnected = false.obs;
  final RxInt unreadTotal = 0.obs;
  final RxnString conversationId = RxnString();

  /// تُستخدم لكتم بانر الإشعار عندما تكون شاشة الدردشة مفتوحة أمام المستخدم.
  final RxBool isChatScreenOpen = false.obs;

  final StreamController<SupportChatEvent> _events =
      StreamController<SupportChatEvent>.broadcast();
  Stream<SupportChatEvent> get events => _events.stream;

  Timer? _backgroundTimer;
  Timer? _retryTimer;
  int _authRetries = 0;
  bool _started = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _backgroundTimer?.cancel();
    _retryTimer?.cancel();
    _teardown();
    _events.close();
    super.onClose();
  }

  // ───────────── الهوية ─────────────

  String? get _token {
    final t = myServices.sharedPreferences.getString('Token');
    return (t == null || t.isEmpty) ? null : t;
  }

  /// دور الجلسة: `customer` أو `driver`. كلاهما يملك دردشة دعم، ولكلٍّ مساراته وغرفته.
  String get sessionRole => Applink.sessionRole;

  /// جلسة قائمة لأحد الدورين. المفتاح `Token` مشترك بين الدورين في هذا التطبيق،
  /// فالدور وحده هو ما يحدّد إلى أي مسارات نتحدّث.
  bool get _eligible =>
      _token != null &&
      (sessionRole == 'customer' || sessionRole == 'driver');

  /// معرّف الطرف (الزبون أو السائق) من التوكن نفسه — الحمولة تحمل `Id` في الحالتين.
  String? get partyId {
    final t = _token;
    if (t == null) return null;
    try {
      final payload = JwtDecoder.decode(t);
      final id = payload['Id']?.toString();
      return (id == null || id.isEmpty) ? null : id;
    } catch (_) {
      return null;
    }
  }

  // ───────────── دورة الحياة ─────────────

  /// يُستدعى بعد تسجيل الدخول وعند الإقلاع بجلسة قائمة.
  void start() {
    if (!_eligible) return;
    _started = true;
    _connect();
    unawaited(syncUnread());
  }

  /// يُستدعى قبل مسح التفضيلات عند تسجيل الخروج، وعند انتهاء الجلسة.
  void stop() {
    _started = false;
    _backgroundTimer?.cancel();
    _retryTimer?.cancel();
    _teardown();
    unreadTotal.value = 0;
    conversationId.value = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_started) return;
    if (state == AppLifecycleState.resumed) {
      _backgroundTimer?.cancel();
      _backgroundTimer = null;
      if (_socket == null || !(_socket?.connected ?? false)) _connect();
      unawaited(syncUnread());
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      // مهلة قصيرة: التنقل إلى الكاميرا أو مركز الإشعارات ليس سبباً لقطع الاتصال
      _backgroundTimer?.cancel();
      _backgroundTimer = Timer(const Duration(seconds: 25), () {
        _socket?.disconnect();
      });
    }
  }

  void _connect() {
    if (!_eligible) return;
    if (_socket != null) {
      if (!(_socket!.connected)) _socket!.connect();
      return;
    }

    final options = io.OptionBuilder()
        .setTransports(<String>['websocket'])
        .disableAutoConnect()
        .enableForceNew()
        .setReconnectionDelay(1500)
        .setReconnectionDelayMax(20000)
        .setRandomizationFactor(0.5)
        .setAckTimeout(8000)
        .setAuthFn((cb) async {
          final token = await _freshToken();
          cb(<String, dynamic>{'token': token ?? ''});
        })
        .build();

    // hostNoSlash يحترم تجاوز الخادم من الإعدادات ولا يحمل لاحقة /api/v1
    final socket = io.io(Applink.hostNoSlash, options);
    _socket = socket;

    socket.onConnect((_) {
      _authRetries = 0;
      isConnected.value = true;
    });
    socket.onDisconnect((_) => isConnected.value = false);
    socket.onConnectError(_onConnectError);

    socket.on('chat:message', (d) => _push(SupportChatEventType.message, d));
    socket.on(
      'chat:conversation',
      (d) => _push(SupportChatEventType.conversation, d),
    );
    socket.on('chat:read', (d) => _push(SupportChatEventType.read, d));
    socket.on('chat:typing', (d) => _push(SupportChatEventType.typing, d));
    socket.on('chat:unread', (d) {
      final map = _asMap(d);
      // النطاق يحمل نوع الطرف (`customer` أو `driver`) — نقبل نطاق دورنا وحده
      if (map != null && map['scope'] == sessionRole) {
        unreadTotal.value = (map['total'] as num?)?.toInt() ?? 0;
        final cid = map['conversationId']?.toString();
        if (cid != null && cid.isNotEmpty) conversationId.value = cid;
      }
      _push(SupportChatEventType.unread, d);
    });
    socket.on('chat:error', (d) => _push(SupportChatEventType.error, d));
    socket.on('chat:token_expiring', (_) => _refreshSocketAuth());

    socket.connect();
  }

  void _teardown() {
    final socket = _socket;
    _socket = null;
    isConnected.value = false;
    if (socket == null) return;
    try {
      socket.clearListeners();
      socket.dispose();
    } catch (_) {
      /* الاتصال مقطوع أصلاً */
    }
  }

  void _push(SupportChatEventType type, dynamic raw) {
    final map = _asMap(raw);
    if (map == null || _events.isClosed) return;
    _events.add(SupportChatEvent(type, map));
  }

  static Map<String, dynamic>? _asMap(dynamic raw) {
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return raw.cast<String, dynamic>();
    return null;
  }

  // ───────────── التوكن ─────────────

  Future<String?> _freshToken() async {
    if (!_eligible) return null;
    final current = _token;
    if (current == null) return null;
    try {
      final exp = JwtDecoder.getExpirationDate(current);
      if (exp.difference(DateTime.now()).inSeconds > 60) return current;
    } catch (_) {
      return current;
    }
    // ⚠️ تجديد الدور الصحيح: للزبون `CustomersRefreshToken` وللسائق `DriverRefreshToken`.
    // استعمال تجديد الزبون في جلسة سائق يفشل دائماً ويُخرجه من التطبيق.
    // نمرّ عبر آلية القفل المشتركة في كل طبقة فلا يتسابق تجديدان.
    final ok = await SupportHttp.forCurrentRole().refreshToken();
    return ok ? _token : current;
  }

  Future<void> _refreshSocketAuth() async {
    final socket = _socket;
    if (socket == null || !socket.connected) return;
    final token = await _freshToken();
    if (token == null) return;
    socket.emit('chat:auth', <String, dynamic>{'token': token});
  }

  void _onConnectError(dynamic raw) {
    isConnected.value = false;
    final map = _asMap(raw);
    final isServerRejection = map != null && map['message'] != null;
    if (!isServerRejection) return; // خطأ نقل — المكتبة تعيد المحاولة

    final code = _asMap(map['data'])?['code']?.toString();
    if (code == 'ACCOUNT_INACTIVE' ||
        code == 'ACCOUNT_DELETED' ||
        code == 'ACCOUNT_NOT_FOUND' ||
        code == 'INSUFFICIENT_PERMISSIONS' ||
        code == 'TOKEN_INVALID') {
      // لا فائدة من إعادة المحاولة — رسائل الحساب تصل عبر مسارات REST العادية
      _teardown();
      return;
    }

    if (code == 'TOKEN_EXPIRED') {
      if (_authRetries >= 2) {
        _teardown();
        return;
      }
      _authRetries++;
      _retryTimer?.cancel();
      _retryTimer = Timer(Duration(seconds: _authRetries * 3), () async {
        final ok = await SupportHttp.forCurrentRole().refreshToken();
        if (!ok) {
          _teardown();
          return;
        }
        _socket?.connect();
      });
      return;
    }

    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 15), () => _socket?.connect());
  }

  // ───────────── الأحداث الصادرة ─────────────

  void emitOpen(String id) {
    _socket?.emit('chat:open', <String, dynamic>{'conversationId': id});
  }

  void emitClose(String id) {
    _socket?.emit('chat:close', <String, dynamic>{'conversationId': id});
  }

  void emitRead(String id, {String? upToMessageId}) {
    _socket?.emit('chat:read', <String, dynamic>{
      'conversationId': id,
      if (upToMessageId != null && upToMessageId.isNotEmpty)
        'upToMessageId': upToMessageId,
    });
  }

  void emitTyping(String id, bool isTyping) {
    if (!isConnected.value) return;
    _socket?.emit('chat:typing', <String, dynamic>{
      'conversationId': id,
      'isTyping': isTyping,
    });
  }

  /// إرسال عبر السوكِت؛ `null` تعني «لا اتصال» فيتحوّل المُستدعي إلى REST.
  Future<Map<String, dynamic>?> send({
    required String clientId,
    String? text,
    Map<String, dynamic>? attachment,
  }) async {
    final socket = _socket;
    if (socket == null || !socket.connected) return null;
    final completer = Completer<Map<String, dynamic>>();
    socket.emitWithAck(
      'chat:send',
      <String, dynamic>{
        'clientId': clientId,
        if (text != null && text.trim().isNotEmpty) 'text': text.trim(),
        'attachment': ?attachment,
      },
      // ⚠️ توقيع إلزامي: `(err, [res])` لا `(res)`.
      //
      // `setAckTimeout` يُبدّل اصطلاح المكتبة إلى «الخطأ أولاً»: عند وصول الردّ
      // تستدعي `Function.apply(ack, [null, res])` بوسيطين. مغلقٌ بوسيط واحد يرمي
      // NoSuchMethodError داخل microtask فيُبتلع بصمت، فلا يكتمل الـCompleter
      // ويبقى مؤشر الإرسال يدور حتى مهلة Dart — وهو العطب الذي ظهر للمستخدمين.
      ack: (dynamic err, [dynamic res]) {
        if (completer.isCompleted) return;
        if (err != null) {
          // مهلة المكتبة الحقيقية (8 ثوانٍ) — الردّ لم يصل
          completer.complete(<String, dynamic>{
            'ok': false,
            'message': 'تعذر إرسال الرسالة، تحقق من الاتصال',
          });
          return;
        }
        completer.complete(
          _asMap(res) ??
              <String, dynamic>{'ok': false, 'message': 'تعذر إرسال الرسالة'},
        );
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => <String, dynamic>{
        'ok': false,
        'message': 'انتهت مهلة الإرسال',
      },
    );
  }

  /// لحاق بعد انقطاع — يُرجع الرسائل التي وصلت بعد [afterMessageId] فقط.
  Future<List<dynamic>> sync({String? afterMessageId}) async {
    final socket = _socket;
    final id = conversationId.value;
    if (socket == null || !socket.connected || id == null) {
      return const <dynamic>[];
    }
    final completer = Completer<List<dynamic>>();
    socket.emitWithAck(
      'chat:sync',
      <String, dynamic>{
        'conversationId': id,
        if (afterMessageId != null && afterMessageId.isNotEmpty)
          'afterMessageId': afterMessageId,
      },
      // نفس اصطلاح «الخطأ أولاً» — راجع التعليق في [send]
      ack: (dynamic err, [dynamic res]) {
        if (completer.isCompleted) return;
        final map = err == null ? _asMap(res) : null;
        final raw = map?['messages'];
        completer.complete(raw is List ? raw : const <dynamic>[]);
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => const <dynamic>[],
    );
  }

  // ───────────── الشارة والإشعارات ─────────────

  /// مزامنة الشارة عبر REST — عند الإقلاع والعودة من الخلفية وعند وصول دفعة.
  Future<void> syncUnread() async {
    if (!_eligible) return;
    final response = await _api.unreadCount();
    if (response is! Map) return;

    final total = response['total'];
    if (total is num) unreadTotal.value = total.toInt();
    final cid = response['conversationId']?.toString();
    if (cid != null && cid.isNotEmpty) conversationId.value = cid;
  }

  /// دفعة FCM من نوع SUPPORT_CHAT وصلت — تُحدّث الشارة ما لم تكن الشاشة مفتوحة.
  void onPushReceived(Map<String, dynamic> data) {
    final cid = data['conversationId']?.toString();
    if (cid != null && cid.isNotEmpty) conversationId.value = cid;
    if (isChatScreenOpen.value) return;
    final unread = int.tryParse('${data['unread'] ?? ''}');
    if (unread != null && unread > 0) {
      unreadTotal.value = unread;
    } else {
      unreadTotal.value = unreadTotal.value + 1;
    }
    unawaited(syncUnread());
  }

  void clearUnreadLocally() => unreadTotal.value = 0;

  static void debugLog(String message) {
    if (kDebugMode) debugPrint('[supportChat] $message');
  }
}

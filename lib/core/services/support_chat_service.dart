import 'dart:async';
import 'dart:math' as math;

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
  Timer? _watchdog;
  Timer? _authRetryTimer;
  DateTime? _lastPingAt;
  int _attempt = 0;

  /// رفضٌ لا يُصلحه تكرار المحاولة (حساب موقوف/محذوف). يُلغى عند [start].
  String? _fatalCode;
  bool _started = false;

  static const int _backoffBaseMs = 1000;
  static const int _backoffMaxMs = 45000; // أطول من اللوحة حفاظاً على البطارية
  static final math.Random _rand = math.Random();

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
    _authRetryTimer?.cancel();
    _watchdog?.cancel();
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
    _fatalCode = null;
    _attempt = 0;
    _watchdog?.cancel();
    // حارس دوري: يلتقط السوكِت الميت بعد نوم الجهاز، والسوكِت نصف المفتوح الذي
    // تظنّه المكتبة حيّاً بينما لا يصل منه شيء.
    _watchdog = Timer.periodic(
      const Duration(seconds: 30),
      (_) => _heartbeat(),
    );
    _connect();
    unawaited(syncUnread());
  }

  /// يُستدعى قبل مسح التفضيلات عند تسجيل الخروج، وعند انتهاء الجلسة.
  void stop() {
    _started = false;
    _backgroundTimer?.cancel();
    _retryTimer?.cancel();
    _retryTimer = null;
    _authRetryTimer?.cancel();
    _authRetryTimer = null;
    _watchdog?.cancel();
    _watchdog = null;
    _attempt = 0;
    _fatalCode = null;
    _teardown();
    unreadTotal.value = 0;
    conversationId.value = null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (!_started) return;
    switch (state) {
      case AppLifecycleState.resumed:
        _backgroundTimer?.cancel();
        _backgroundTimer = null;
        _attempt = 0; // العودة إلى المقدّمة ليست فشلاً
        if (_socket?.connected != true) {
          _scheduleReconnect(immediate: true);
        } else if (_pingStale) {
          _hardReset();
        }
        unawaited(syncUnread());
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden: // أندرويد 14+ يمرّ بها قبل paused
      case AppLifecycleState.detached:
        // مهلة قصيرة: التنقل إلى الكاميرا أو مركز الإشعارات ليس سبباً لقطع الاتصال
        _backgroundTimer?.cancel();
        _backgroundTimer = Timer(const Duration(seconds: 25), () {
          _socket?.disconnect(); // سببه `io client disconnect` فلا يُجدوَل تعافٍ
        });
      case AppLifecycleState.inactive:
        break; // سحب مركز التحكم ليس خلفية
    }
  }

  // ───────────── آلة حالة إعادة الاتصال ─────────────

  static const Set<String> _fatalCodes = <String>{
    'ACCOUNT_DELETED',
    'ACCOUNT_INACTIVE',
    'ACCOUNT_NOT_FOUND',
    'INSUFFICIENT_PERMISSIONS',
  };

  /// ⚠️ `TOKEN_INVALID` **ليس** قاتلاً: الخادم يُعيده لأي توكن بائت أو مشوّه، وكلها
  /// يصلحها تجديد. وانتهاء الجلسة الحقيقي يُنهيه [stop] من طبقة تسجيل الخروج.
  static bool _isFatal(String? code) =>
      code != null && _fatalCodes.contains(code);

  /// **المدخل الوحيد** لبدء أي محاولة اتصال — وهذا وحده ما يمنع تزاحم المحفّزات
  /// (عودة التطبيق + الحارس + خطأ المصافحة) في عاصفة إعادة اتصال.
  void _scheduleReconnect({bool immediate = false}) {
    if (!_started || _fatalCode != null) return;
    if (_retryTimer?.isActive == true) return;
    if (_socket?.connected == true) return;
    final delay = immediate ? const Duration(milliseconds: 250) : _nextDelay();
    _attempt++;
    _retryTimer = Timer(delay, () {
      _retryTimer = null;
      if (!_started || _fatalCode != null) return;
      _connect();
    });
  }

  Duration _nextDelay() {
    final shift = _attempt > 5 ? 5 : _attempt;
    final ceil = math.min(_backoffMaxMs, _backoffBaseMs << shift);
    final floor = ceil ~/ 2;
    return Duration(milliseconds: floor + _rand.nextInt(ceil - floor + 1));
  }

  void _enterFatal(String code) {
    _fatalCode = code;
    _retryTimer?.cancel();
    _retryTimer = null;
    _authRetryTimer?.cancel();
    _authRetryTimer = null;
    isConnected.value = false;
  }

  void _heartbeat() {
    if (!_started || _fatalCode != null) return;
    if (_socket?.connected != true) {
      _scheduleReconnect();
      return;
    }
    if (_pingStale) _hardReset();
  }

  /// مضى أكثر من نبضتين بلا بينغ بينما المكتبة تظنّ الاتصال قائماً.
  bool get _pingStale {
    final last = _lastPingAt;
    if (last == null) return false;
    return DateTime.now().difference(last) > const Duration(seconds: 70);
  }

  void _hardReset() {
    final socket = _socket;
    isConnected.value = false;
    _lastPingAt = null;
    if (socket != null) {
      try {
        socket.disconnect();
      } catch (_) {
        /* تجاهل */
      }
    }
    _scheduleReconnect(immediate: true);
  }

  void _connect() {
    if (!_eligible) return;
    if (_socket != null) {
      if (!(_socket!.connected)) _socket!.connect();
      return;
    }

    final options = io.OptionBuilder()
        // ⚠️ polling أولاً: لا يوجد سقوط تلقائي بين الناقلات في engine.io — يُستعمل
        // `transports[0]` دائماً. فتثبيت websocket وحده خلف وسيط يُسقط ترويسة
        // الترقية يعني حلقة محاولات أبدية بدل اتصال يعمل. وpolling يترقّى تلقائياً.
        .setTransports(<String>['polling', 'websocket'])
        .disableAutoConnect()
        .enableForceNew()
        .setTimeout(20000)
        .setReconnectionDelay(1500)
        .setReconnectionDelayMax(20000)
        .setRandomizationFactor(0.5)
        .setAckTimeout(8000)
        .setAuthFn((cb) async {
          // ⚠️ ممنوع الرمي هنا: إن لم تُستدعَ `cb` لا تُرسَل حزمة CONNECT إطلاقاً،
          // فلا `connect` ولا `connect_error` — تعليق صامت أبدي بلا أي مهلة تغطّيه.
          String token = '';
          try {
            token = await _freshToken() ?? '';
          } catch (_) {
            // نترك الخادم يرفض ثم نُعيد المحاولة بتوكن طازج
          }
          cb(<String, dynamic>{'token': token});
        })
        .build();

    // hostNoSlash يحترم تجاوز الخادم من الإعدادات ولا يحمل لاحقة /api/v1
    final socket = io.io(Applink.hostNoSlash, options);
    _socket = socket;

    socket.onConnect((_) {
      _attempt = 0;
      _retryTimer?.cancel();
      _retryTimer = null;
      _fatalCode = null;
      _lastPingAt = DateTime.now();
      isConnected.value = true;
    });
    socket.onDisconnect((reason) {
      final r = reason?.toString() ?? '';
      isConnected.value = false;
      _lastPingAt = null;
      if (r == 'io client disconnect') return; // نحن من قطعنا (خلفية/تصفير)
      if (_fatalCode != null) return;
      // ⚠️ `io server disconnect` (مؤقّت انتهاء التوكن في البوابة) يضبط
      // `skipReconnect = true` في مدير المكتبة فلا تُعاد المحاولة أبداً.
      _scheduleReconnect();
    });
    socket.onConnectError(_onConnectError);
    socket.onPing((_) => _lastPingAt = DateTime.now());
    socket.onReconnectFailed((_) => _scheduleReconnect());

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
    socket.on('chat:error', (d) {
      final code = _asMap(d)?['code']?.toString();
      if (_isFatal(code)) _enterFatal(code!);
      _push(SupportChatEventType.error, d);
    });
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

  /// تجديد المصادقة على اتصال قائم.
  ///
  /// نجاحه **يُعيد تسليح مؤقّت القتل في الخادم**، فهو خطّ الدفاع الأول ضد دورة
  /// القطع عند كل انتهاء توكن.
  Future<void> _refreshSocketAuth() async {
    _authRetryTimer?.cancel();
    final socket = _socket;
    if (socket == null || !socket.connected) return;
    final token = await _freshToken();
    if (token == null) {
      _authRetryTimer = Timer(const Duration(seconds: 15), _refreshSocketAuth);
      return;
    }
    socket.emitWithAck(
      'chat:auth',
      <String, dynamic>{'token': token},
      // ⚠️ توقيع «الخطأ أولاً» إلزامي مع `setAckTimeout` — راجع بقية الملف.
      // وكان هذا الحدث يُرسَل **بلا ack إطلاقاً**، فرفضُ التجديد يمرّ بلا أثر ثم
      // يقطع الخادم الاتصال بعد دقيقة بلا أي إشارة للمستخدم.
      ack: (dynamic err, [dynamic res]) {
        if (err != null) {
          _authRetryTimer = Timer(
            const Duration(seconds: 5),
            _refreshSocketAuth,
          );
          return;
        }
        final map = _asMap(res);
        if (map?['ok'] == true) {
          // نجدّد بأنفسنا قبل انتهاء المدّة بدقيقة بدل انتظار `chat:token_expiring`
          final ms = (map!['expiresInMs'] as num?)?.toInt() ?? 0;
          final lead = ms - 60000;
          if (lead > 0) {
            _authRetryTimer = Timer(
              Duration(milliseconds: lead),
              _refreshSocketAuth,
            );
          }
          return;
        }
        final code = map?['code']?.toString();
        if (_isFatal(code)) {
          _enterFatal(code!);
          return;
        }
        _authRetryTimer = Timer(const Duration(seconds: 5), _refreshSocketAuth);
      },
    );
  }

  /// رفض المصافحة. القاتل يُوقف، وكل ما عداه يمرّ على آلة الحالة.
  ///
  /// ⚠️ لا `_teardown()` هنا بعد اليوم: كانت محاولتا مصادقة فاشلتان — أو فشل تجديد
  /// عابر واحد على شبكة الجوال — تقتل الدردشة **نهائياً** حتى إعادة تشغيل التطبيق.
  void _onConnectError(dynamic raw) {
    isConnected.value = false;
    final code = _asMap(_asMap(raw)?['data'])?['code']?.toString();
    if (_isFatal(code)) {
      _enterFatal(code!);
      return;
    }
    _scheduleReconnect();
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
  /// ⚠️ `hasMore` جزء من العقد: الخادم يسقف الصفحة بـ200 رسالة، فمن كان مقطوعاً
  /// عبر أكثر من ذلك يفقد الباقي بصمت ما لم يُستأنف السحب بالمؤشّر.
  Future<({List<dynamic> messages, bool hasMore})> sync({
    String? afterMessageId,
  }) async {
    const empty = (messages: <dynamic>[], hasMore: false);
    final socket = _socket;
    final id = conversationId.value;
    if (socket == null || !socket.connected || id == null) {
      return empty;
    }
    final completer = Completer<({List<dynamic> messages, bool hasMore})>();
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
        completer.complete((
          messages: raw is List ? raw : const <dynamic>[],
          hasMore: map?['hasMore'] == true,
        ));
      },
    );
    return completer.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => empty,
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

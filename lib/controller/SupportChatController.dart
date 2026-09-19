// ignore_for_file: file_names

import 'dart:async';
import 'dart:math';

import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/core/services/support_chat_service.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/model/SupportChatModel.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// رسالة دعم كما يعرضها التطبيق.
class SupportMessage {
  SupportMessage({
    required this.id,
    required this.senderType,
    required this.text,
    this.senderName = '',
    this.attachmentUrl,
    this.createdAt,
    this.readByAdminAt,
    this.readByCustomerAt,
    this.clientId,
    this.status = SupportMessageStatus.sent,
  });

  final String id;

  /// customer | driver | admin | system
  final String senderType;
  final String text;
  final String senderName;
  final String? attachmentUrl;
  final DateTime? createdAt;
  final DateTime? readByAdminAt;
  final DateTime? readByCustomerAt;
  final String? clientId;
  SupportMessageStatus status;

  /// رسالتي = كل ما ليس من الدعم ولا من النظام. تعمل للزبون والسائق معاً بلا فرع:
  /// الخادم لا يُرجع لطرفٍ رسائلَ طرف آخر أصلاً، فما ليس `admin`/`system` هو منّي.
  bool get isMine => senderType != 'admin' && senderType != 'system';
  bool get hasAttachment => (attachmentUrl ?? '').isNotEmpty;

  /// من منظور الزبون: رسالتي مقروءة عندما يفتحها الدعم.
  bool get seenBySupport => readByAdminAt != null;

  factory SupportMessage.fromJson(Map<String, dynamic> json) {
    final attachment = json['attachment'];
    return SupportMessage(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      senderType: (json['senderType'] ?? '').toString(),
      text: (json['text'] ?? '').toString(),
      senderName: (json['senderName'] ?? '').toString(),
      attachmentUrl: attachment is Map
          ? attachment['url']?.toString()
          : null,
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
      readByAdminAt: DateTime.tryParse('${json['readByAdminAt'] ?? ''}'),
      readByCustomerAt: DateTime.tryParse('${json['readByCustomerAt'] ?? ''}'),
      clientId: json['clientId']?.toString(),
    );
  }
}

enum SupportMessageStatus { sending, sent, failed }

/// شاشة «تواصل مع الدعم» — محادثة واحدة دائمة مع الإدارة.
///
/// الرسائل تُخزَّن **تصاعدياً** وتُعرض بقائمة معكوسة: إدراج صفحة أقدم في المقدمة
/// لا يُحرّك موضع القراءة، وإضافة رسالة جديدة تظهر في الأسفل مباشرةً.
class SupportChatController extends GetxController {
  /// مُعيد بناء لا حقل نهائي: الدور (زبون/سائق) يُقرأ عند كل نداء، فلا تعلق نسخة
  /// بمسارات الدور السابق لو تبدّلت الجلسة على الجهاز نفسه.
  SupportChatModel get _model => SupportChatModel();

  /// نوع المُرسِل لرسائلي المتفائلة قبل وصول ردّ الخادم
  String get _mySenderType => Applink.sessionRole;
  SupportChatService get _service => Get.find<SupportChatService>();

  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  final RxInt statusCode = 200.obs;
  final Rx<StatusRequest> statusSend = StatusRequest.success.obs;

  final RxList<SupportMessage> messages = <SupportMessage>[].obs;
  final RxBool isLoadingOlder = false.obs;
  final RxBool hasMore = false.obs;
  final RxString supportTyping = ''.obs;

  String? conversationId;
  String? _nextBefore;
  StreamSubscription<SupportChatEvent>? _sub;
  Timer? _typingExpiry;

  Worker? _connWorker;

  @override
  void onInit() {
    super.onInit();
    _service.isChatScreenOpen.value = true;
    _sub = _service.events.listen(_onEvent);
    // [chat-resync] عضوية غرفة الخيط لكل اتصال على حدة وتضيع مع أي انقطاع، ولا
    // يُعيدها شيء — فتتوقف مؤشّرات الكتابة وتعليم القراءة. واللحاق بما فات كان
    // مبنياً على الخادم بلا أي مُستدعٍ في التطبيق.
    _connWorker = ever<bool>(_service.isConnected, (connected) {
      if (connected) unawaited(_resumeAfterReconnect());
    });
    load();
  }

  @override
  void onClose() {
    _service.isChatScreenOpen.value = false;
    final id = conversationId;
    if (id != null) _service.emitClose(id);
    _sub?.cancel();
    _connWorker?.dispose();
    _typingExpiry?.cancel();
    super.onClose();
  }

  /// يُستدعى عند **كل** اتصال ناجح: إعادة دخول الغرفة ثم سحب ما فات.
  Future<void> _resumeAfterReconnect() async {
    final id = conversationId;
    if (id == null) return;
    _joinRoom(); // يُعيد الانضمام ويؤدّي القراءة في الخادم

    final after = _lastServerMessageId();
    if (after == null) {
      // ⚠️ `chat:sync` بلا مؤشّر يسقط في فرع «أحدث صفحة» على الخادم فيُرجع
      // `hasMore`/`nextBefore` الخاصَّين بالترقيم للخلف — إهمالهما يكسر «تحميل
      // الأقدم». نُعيد التحميل الكامل الذي يضبطهما.
      await load();
      return;
    }

    // ⚠️ حلقة لا نداء واحد: الخادم يسقف الصفحة بـ200 رسالة ويُعيد `hasMore`.
    var cursor = after;
    var merged = false;
    for (var round = 0; round < 5; round++) {
      final page = await _service.sync(afterMessageId: cursor);
      if (conversationId != id) return; // تبدّلت المحادثة أثناء الانتظار
      if (page.messages.isEmpty) break;
      String? last;
      for (final e in page.messages) {
        if (e is! Map) continue;
        final m = SupportMessage.fromJson(e.cast<String, dynamic>());
        _upsert(m);
        if (m.id.isNotEmpty) last = m.id;
      }
      merged = true;
      if (!page.hasMore || last == null) break;
      cursor = last;
    }
    if (merged) await _markRead();
  }

  /// آخر رسالة لها معرّف من الخادم — الرسائل المتفائلة قيد الإرسال بلا معرّف.
  String? _lastServerMessageId() {
    for (var i = messages.length - 1; i >= 0; i--) {
      final id = messages[i].id;
      if (id.isNotEmpty) return id;
    }
    return null;
  }

  // ───────────── التحميل ─────────────

  Future<void> load() async {
    statusRequest.value = StatusRequest.loading;
    final response = await _model.getConversation();
    statusCode.value = handlingStatusCode(response);

    if (handlingData(response) != StatusRequest.success) {
      statusRequest.value = handlingData(response);
      return;
    }

    final map = tryResponseMap(response);
    final conversation = map?['conversation'];
    if (conversation is Map) {
      conversationId = (conversation['_id'] ?? conversation['id'])?.toString();
      _service.conversationId.value = conversationId;
    }

    final raw = map?['messages'];
    if (raw is List) {
      messages.assignAll(<SupportMessage>[
        for (final e in raw)
          if (e is Map) SupportMessage.fromJson(e.cast<String, dynamic>()),
      ]);
    }
    hasMore.value = map?['hasMore'] == true;
    _nextBefore = map?['nextBefore']?.toString();

    // الشاشة مفتوحة ⇒ كل ما وصل مقروء
    await _markRead();
    _joinRoom();

    statusRequest.value = StatusRequest.success;
  }

  void _joinRoom() {
    final id = conversationId;
    if (id == null) return;
    _service.emitOpen(id);
  }

  Future<void> loadOlder() async {
    if (!hasMore.value || isLoadingOlder.value || _nextBefore == null) return;
    isLoadingOlder.value = true;
    try {
      final response = await _model.getMessages(before: _nextBefore);
      if (handlingData(response) != StatusRequest.success) return;
      final map = tryResponseMap(response);
      final raw = map?['messages'];
      if (raw is List && raw.isNotEmpty) {
        messages.insertAll(0, <SupportMessage>[
          for (final e in raw)
            if (e is Map) SupportMessage.fromJson(e.cast<String, dynamic>()),
        ]);
      }
      hasMore.value = map?['hasMore'] == true;
      _nextBefore = map?['nextBefore']?.toString();
    } finally {
      isLoadingOlder.value = false;
    }
  }

  // ───────────── الإرسال ─────────────

  static String _newClientId() {
    final rand = Random().nextInt(0xFFFFFF).toRadixString(16);
    return 'c${DateTime.now().microsecondsSinceEpoch}$rand';
  }

  /// إرسال تفاؤلي: الفقاعة تظهر فوراً وتُستبدل برد الخادم عبر `clientId`.
  Future<void> send(String text) async {
    final body = text.trim();
    if (body.isEmpty) return;
    final clientId = _newClientId();
    _upsert(
      SupportMessage(
        id: '',
        senderType: _mySenderType,
        text: body,
        clientId: clientId,
        createdAt: DateTime.now(),
        status: SupportMessageStatus.sending,
      ),
    );
    _emitTyping(false);
    await _dispatch(clientId: clientId, text: body);
  }

  /// إعادة إرسال فقاعة فاشلة بنفس `clientId` — الخادم يمنع التكرار فلا تتضاعف.
  Future<void> retry(SupportMessage failed) async {
    final clientId = failed.clientId;
    if (clientId == null) return;
    failed.status = SupportMessageStatus.sending;
    messages.refresh();
    await _dispatch(
      clientId: clientId,
      text: failed.text,
      attachmentUrl: failed.attachmentUrl,
    );
  }

  Future<void> _dispatch({
    required String clientId,
    String text = '',
    String? attachmentUrl,
  }) async {
    statusSend.value = StatusRequest.loading;
    final attachment = attachmentUrl == null
        ? null
        : <String, dynamic>{'url': attachmentUrl};
    try {
      // السوكِت أولاً؛ REST بديل كامل عند انقطاعه
      Map<String, dynamic>? ack = await _service.send(
        clientId: clientId,
        text: text,
        attachment: attachment,
      );

      if (ack == null) {
        final response = await _model.sendMessage(
          clientId: clientId,
          text: text,
          attachment: attachment,
        );
        if (handlingData(response) == StatusRequest.success) {
          final map = tryResponseMap(response);
          ack = <String, dynamic>{'ok': true, 'message': map?['message']};
        } else {
          ack = <String, dynamic>{
            'ok': false,
            'message':
                tryResponseMessage(response) ?? 'تعذر إرسال الرسالة، حاول مجدداً',
          };
        }
      }

      if (ack['ok'] == true) {
        final m = ack['message'];
        if (m is Map) _upsert(SupportMessage.fromJson(m.cast<String, dynamic>()));
        statusSend.value = StatusRequest.success;
        return;
      }

      _markFailed(clientId);
      statusSend.value = StatusRequest.failure;
      AppSnackBar.error(ack['message']?.toString() ?? 'تعذر إرسال الرسالة');
    } finally {
      if (statusSend.value == StatusRequest.loading) {
        statusSend.value = StatusRequest.success;
      }
    }
  }

  /// رفع صورة ثم إرسالها كرسالة.
  Future<void> sendImage(Uint8List bytes) async {
    statusSend.value = StatusRequest.loading;
    try {
      final response = await _model.uploadAttachment(bytes: bytes);
      if (handlingData(response) != StatusRequest.success) {
        AppSnackBar.error(tryResponseMessage(response) ?? 'تعذر رفع الصورة');
        statusSend.value = StatusRequest.failure;
        return;
      }
      final map = tryResponseMap(response);
      final attachment = map?['attachment'];
      final url = attachment is Map ? attachment['url']?.toString() : null;
      if (url == null || url.isEmpty) {
        AppSnackBar.error('تعذر رفع الصورة');
        statusSend.value = StatusRequest.failure;
        return;
      }
      final clientId = _newClientId();
      _upsert(
        SupportMessage(
          id: '',
          senderType: _mySenderType,
          text: '',
          attachmentUrl: url,
          clientId: clientId,
          createdAt: DateTime.now(),
          status: SupportMessageStatus.sending,
        ),
      );
      await _dispatch(clientId: clientId, attachmentUrl: url);
    } finally {
      if (statusSend.value == StatusRequest.loading) {
        statusSend.value = StatusRequest.success;
      }
    }
  }

  void _markFailed(String clientId) {
    final idx = messages.indexWhere((m) => m.clientId == clientId && m.id.isEmpty);
    if (idx == -1) return;
    messages[idx].status = SupportMessageStatus.failed;
    messages.refresh();
  }

  // ───────────── الإدراج ─────────────

  /// المسار الوحيد لإضافة رسالة: مطابقة بـ `_id` ثم `clientId` فلا تتكرر الفقاعات.
  void _upsert(SupportMessage message) {
    if (message.id.isNotEmpty) {
      final byId = messages.indexWhere((m) => m.id == message.id);
      if (byId != -1) {
        messages[byId] = message;
        messages.refresh();
        return;
      }
    }
    final cid = message.clientId;
    if (cid != null && cid.isNotEmpty) {
      final byClient = messages.indexWhere((m) => m.clientId == cid);
      if (byClient != -1) {
        messages[byClient] = message;
        messages.refresh();
        return;
      }
    }

    var insertAt = messages.length;
    if (message.id.isNotEmpty) {
      for (var i = messages.length - 1; i >= 0; i--) {
        final other = messages[i];
        if (other.id.isEmpty) continue;
        if (other.id.compareTo(message.id) <= 0) {
          insertAt = i + 1;
          break;
        }
        insertAt = i;
      }
    }
    messages.insert(insertAt, message);
    messages.refresh();
  }

  // ───────────── القراءة والكتابة ─────────────

  Future<void> _markRead() async {
    final newest = messages.isEmpty ? null : messages.last.id;
    final id = conversationId;
    if (id != null && _service.isConnected.value) {
      _service.emitRead(id, upToMessageId: newest);
    } else {
      await _model.markRead(upToMessageId: newest);
    }
    _service.clearUnreadLocally();
  }

  void notifyTyping() => _emitTyping(true);

  void _emitTyping(bool isTyping) {
    final id = conversationId;
    if (id == null) return;
    _service.emitTyping(id, isTyping);
  }

  // ───────────── أحداث السوكِت ─────────────

  void _onEvent(SupportChatEvent event) {
    switch (event.type) {
      case SupportChatEventType.message:
        final raw = event.data['message'];
        if (raw is! Map) return;
        final message = SupportMessage.fromJson(raw.cast<String, dynamic>());
        _upsert(message);
        // تحصين: البثّ تأكيد كافٍ لرسالتي. `statusSend` كان مرهوناً بالـack وحده،
        // فأي ack ضائع يُجمّد المؤشر عشر ثوانٍ ثم يُظهر خطأً كاذباً لرسالة وصلت فعلاً.
        if (message.isMine && statusSend.value == StatusRequest.loading) {
          statusSend.value = StatusRequest.success;
        }
        if (!message.isMine) {
          supportTyping.value = '';
          // الشاشة مفتوحة ⇒ قراءة فورية
          unawaited(_markRead());
        }
      case SupportChatEventType.read:
        _applyReadReceipt(event.data);
      case SupportChatEventType.typing:
        _applyTyping(event.data);
      case SupportChatEventType.conversation:
      case SupportChatEventType.unread:
      case SupportChatEventType.error:
        break;
    }
  }

  void _applyReadReceipt(Map<String, dynamic> data) {
    final by = data['by'];
    if (by is! Map || by['type']?.toString() != 'admin') return;
    final at = DateTime.tryParse('${data['at'] ?? ''}');
    if (at == null) return;
    var changed = false;
    for (var i = 0; i < messages.length; i++) {
      final m = messages[i];
      if (!m.isMine || m.readByAdminAt != null) continue;
      messages[i] = SupportMessage(
        id: m.id,
        senderType: m.senderType,
        text: m.text,
        senderName: m.senderName,
        attachmentUrl: m.attachmentUrl,
        createdAt: m.createdAt,
        readByAdminAt: at,
        readByCustomerAt: m.readByCustomerAt,
        clientId: m.clientId,
        status: m.status,
      );
      changed = true;
    }
    if (changed) messages.refresh();
  }

  void _applyTyping(Map<String, dynamic> data) {
    final by = data['by'];
    if (by is! Map || by['type']?.toString() != 'admin') return;
    if (data['isTyping'] == false) {
      supportTyping.value = '';
      return;
    }
    supportTyping.value = 'الدعم يكتب…';
    _typingExpiry?.cancel();
    // لا نعتمد على وصول isTyping:false — قد يُقتل التطبيق أثناء الكتابة
    _typingExpiry = Timer(
      const Duration(seconds: 4),
      () => supportTyping.value = '',
    );
  }
}

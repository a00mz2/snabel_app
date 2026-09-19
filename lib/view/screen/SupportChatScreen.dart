import 'package:customer/controller/SupportChatController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:customer/core/services/support_chat_service.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/AppBarwidget.dart';
import 'package:customer/view/widget/widgetApp/ListEmtyWidget.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

/// شاشة «تواصل مع الدعم».
///
/// لا تستخدم [ScaffoldWidget] عمداً: فهو يُخفي `child` و`footer` عندما تكون الحالة ليست
/// `success` (فيختفي حقل الكتابة عند أي إعادة تحميل)، ويغلّف الجسم بـ [RefreshIndicator]
/// الذي يتعارض مع قائمة رسائل معكوسة (السحب لأسفل عند أحدث رسالة يُطلق تحديثاً).
/// نُركّب بدلاً منه [AppBarWidget] و[ListEmtyWidget] وهما ما نحتاجه فعلاً.
class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final SupportChatController controller = Get.find<SupportChatController>();
  final SupportChatService service = Get.find<SupportChatService>();
  final TextEditingController _input = TextEditingController();
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      // القائمة معكوسة: أقصى الامتداد = أعلى الشاشة = الرسائل الأقدم
      if (_scroll.position.pixels >= _scroll.position.maxScrollExtent - 200) {
        controller.loadOlder();
      }
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    _input.clear();
    await controller.send(text);
  }

  /// اختيار صورة ثم رفعها وإرسالها.
  /// تحديد الأبعاد والجودة يقلّص حجم الملف بشدّة (صور الجوال قد تبلغ عدة ميغابايت)
  /// فيمنع رفض nginx (413) قبل وصول الطلب — نفس إعدادات [ImageUploadField].
  Future<void> _pickAndSendImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 70,
      maxWidth: 1600,
      maxHeight: 1600,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    await controller.sendImage(bytes);
  }

  Future<void> _openAttachSheet(BuildContext context) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xffE7E4E4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('الكاميرا'),
                onTap: () => Navigator.pop(ctx, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('المعرض'),
                onTap: () => Navigator.pop(ctx, ImageSource.gallery),
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
    if (source == null) return;
    await _pickAndSendImage(source);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBarWidget(isSub: true, namePage: 'تواصل مع الدعم'),
      body: SafeArea(
        child: Column(
          children: [
            Obx(
              () => service.isConnected.value
                  ? const SizedBox.shrink()
                  : const _OfflineBanner(),
            ),
            Obx(() {
              final typing = controller.supportTyping.value;
              if (typing.isEmpty) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Text(
                  typing,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xff12B76A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
            Expanded(
              child: Obx(() {
                if (controller.statusRequest.value != StatusRequest.success) {
                  return ListEmtyWidget(
                    statusRequest: controller.statusRequest,
                    statusCode: controller.statusCode,
                    onRefresh: controller.load,
                  );
                }
                if (controller.messages.isEmpty) return const _WelcomeState();
                return _messagesList();
              }),
            ),
            _composer(context),
          ],
        ),
      ),
    );
  }

  Widget _messagesList() {
    final items = controller.messages;
    return ListView.builder(
      controller: _scroll,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      itemCount: items.length + (controller.hasMore.value ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final realIndex = items.length - 1 - index;
        final message = items[realIndex];
        final previous = realIndex > 0 ? items[realIndex - 1] : null;
        final showDay =
            message.createdAt != null &&
            (previous?.createdAt == null ||
                !_sameDay(previous!.createdAt!, message.createdAt!));
        final bubble = _Bubble(
          message: message,
          onRetry: message.status == SupportMessageStatus.failed
              ? () => controller.retry(message)
              : null,
        );
        if (!showDay) return bubble;
        return Column(
          children: [_DayChip(date: message.createdAt!), bubble],
        );
      },
    );
  }

  Widget _composer(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffEFEFEF))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Obx(() {
            final busy = controller.statusSend.value == StatusRequest.loading;
            return IconButton(
              onPressed: busy ? null : () => _openAttachSheet(context),
              tooltip: 'إرسال صورة',
              icon: Icon(
                Icons.attach_file_rounded,
                color: busy
                    ? const Color(0xffC9C2BF)
                    : Theme.of(context).primaryColorDark,
              ),
            );
          }),
          Expanded(
            // TextField عادي لا TextBoxs: الأخير يفرض singleLineFormatter فيحذف الأسطر
            child: TextField(
              controller: _input,
              minLines: 1,
              maxLines: 5,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: (_) => controller.notifyTyping(),
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: MyFontWeight.regular,
              ),
              decoration: InputDecoration(
                hintText: 'اكتب رسالتك للدعم…',
                hintStyle: const TextStyle(
                  color: Color(0xff9C9C9C),
                  fontSize: 14,
                ),
                filled: true,
                fillColor: const Color(0xffF1F1F1),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Obx(() {
            final sending =
                controller.statusSend.value == StatusRequest.loading;
            return InkWell(
              onTap: sending ? null : _send,
              borderRadius: BorderRadius.circular(24),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  shape: BoxShape.circle,
                ),
                child: sending
                    ? const Padding(
                        padding: EdgeInsets.all(13),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              ),
            );
          }),
        ],
      ),
    );
  }

  static bool _sameDay(DateTime a, DateTime b) {
    final x = a.toLocal();
    final y = b.toLocal();
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, this.onRetry});

  final SupportMessage message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final mine = message.isMine;
    final failed = message.status == SupportMessageStatus.failed;
    final sending = message.status == SupportMessageStatus.sending;
    final primary = Theme.of(context).primaryColor;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: mine
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (failed && onRetry != null)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18, color: Color(0xffC62828)),
            ),
          Flexible(
            child: Opacity(
              opacity: sending ? 0.7 : 1,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                ),
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                decoration: BoxDecoration(
                  color: failed
                      ? const Color(0xffFDEDED)
                      : mine
                      ? primary
                      : const Color(0xffF3F2F1),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(14),
                    topRight: const Radius.circular(14),
                    bottomLeft: Radius.circular(mine ? 4 : 14),
                    bottomRight: Radius.circular(mine ? 14 : 4),
                  ),
                  border: failed
                      ? Border.all(color: const Color(0xffF0A9A9))
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!mine && message.senderName.trim().isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          message.senderName,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff7C7C7C),
                          ),
                        ),
                      ),
                    if (message.hasAttachment)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxHeight: 220),
                          child: AppNetworkImage(
                            imageUrl: Applink.imageUrl(message.attachmentUrl),
                            fit: BoxFit.cover,
                            width: 220,
                          ),
                        ),
                      ),
                    if (message.text.trim().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(
                          top: message.hasAttachment ? 8 : 0,
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            color: failed
                                ? const Color(0xffB91C1C)
                                : mine
                                ? Colors.white
                                : const Color(0xff292929),
                          ),
                        ),
                      ),
                    const SizedBox(height: 3),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          failed
                              ? 'لم تُرسل'
                              : message.createdAt == null
                              ? ''
                              : _time(message.createdAt!),
                          style: TextStyle(
                            fontSize: 10,
                            color: failed
                                ? const Color(0xffB91C1C)
                                : mine
                                ? Colors.white70
                                : const Color(0xff9C9C9C),
                          ),
                        ),
                        if (mine && !failed) ...[
                          const SizedBox(width: 4),
                          Icon(
                            sending
                                ? Icons.schedule
                                : message.seenBySupport
                                ? Icons.done_all
                                : Icons.done,
                            size: 13,
                            color: message.seenBySupport
                                ? const Color(0xff7FD1FF)
                                : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _time(DateTime d) {
    try {
      return formatDateTime(d.toIso8601String()).split(' - ').last;
    } catch (_) {
      return '';
    }
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final d = date.toLocal();
    final days = DateTime(
      now.year,
      now.month,
      now.day,
    ).difference(DateTime(d.year, d.month, d.day)).inDays;
    final label = days == 0
        ? 'اليوم'
        : days == 1
        ? 'أمس'
        : formatDate(d);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xffF9F8F8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xffEFEFEF)),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xff7C7C7C),
            ),
          ),
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xffFFF4E5),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: const Row(
        children: [
          Icon(Icons.cloud_off, size: 16, color: Color(0xffB45309)),
          SizedBox(width: 6),
          Expanded(
            child: Text(
              'لا يوجد اتصال لحظي — الرسائل تُرسل عبر الخادم مباشرةً.',
              style: TextStyle(fontSize: 11.5, color: Color(0xffB45309)),
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeState extends StatelessWidget {
  const _WelcomeState();

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.support_agent_rounded,
              size: 88,
              color: primary.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 16),
            const Text(
              'كيف يمكننا مساعدتك؟',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xff292929),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'اكتب رسالتك وسيصلك رد فريق الدعم هنا مباشرةً.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xff7C7C7C)),
            ),
          ],
        ),
      ),
    );
  }
}

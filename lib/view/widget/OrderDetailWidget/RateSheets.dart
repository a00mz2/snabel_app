import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/RatingStars.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';

/// أقصى طول لتعليق التقييم — مطابق لحد الخادم (RATING_COMMENT_MAX_CHARS).
const int kRatingCommentMaxLength = 500;

/// ورقة تقييم منتج. تعيد `{stars, comment}` أو `null` عند الإلغاء.
/// الورقة تجمع البيانات فقط ولا تنادي الـAPI — الشبكة تبقى في الكنترولر
/// (نفس عقد [showDriverRejectReasonSheet]).
Future<Map<String, dynamic>?> showRateProductSheet(
  BuildContext context, {
  required String productName,
  String? imageUrl,
  int initialStars = 0,
  String initialComment = '',
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RateSheet(
      title: 'قيّم المنتج',
      subtitle: productName,
      imageUrl: imageUrl,
      isCircleImage: false,
      hintText: 'اكتب رأيك بالمنتج (اختياري)',
      initialStars: initialStars,
      initialComment: initialComment,
    ),
  );
}

/// ورقة تقييم السائق. تعيد `{stars, comment}` أو `null`.
Future<Map<String, dynamic>?> showRateDriverSheet(
  BuildContext context, {
  required String driverName,
  String? imageUrl,
  int initialStars = 0,
  String initialComment = '',
}) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _RateSheet(
      title: 'قيّم السائق',
      subtitle: driverName,
      imageUrl: imageUrl,
      isCircleImage: true,
      hintText: 'كيف كان أداء السائق؟ (اختياري)',
      initialStars: initialStars,
      initialComment: initialComment,
    ),
  );
}

class _RateSheet extends StatefulWidget {
  const _RateSheet({
    required this.title,
    required this.subtitle,
    required this.hintText,
    required this.isCircleImage,
    this.imageUrl,
    this.initialStars = 0,
    this.initialComment = '',
  });

  final String title;
  final String subtitle;
  final String hintText;
  final bool isCircleImage;
  final String? imageUrl;
  final int initialStars;
  final String initialComment;

  @override
  State<_RateSheet> createState() => _RateSheetState();
}

class _RateSheetState extends State<_RateSheet> {
  late final TextEditingController _comment = TextEditingController(
    text: widget.initialComment,
  );
  late int _stars = widget.initialStars;
  String? _error;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    if (_stars < 1) {
      setState(() => _error = 'اختر عدد النجوم');
      return;
    }
    Navigator.pop(context, <String, dynamic>{
      'stars': _stars,
      'comment': _comment.text.trim(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = widget.imageUrl ?? '';
    return Padding(
      // يرفع الورقة فوق لوحة المفاتيح
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffE7E4E4),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 17,
                  fontWeight: MyFontWeight.bold,
                  color: const Color(0xff231F1E),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  if (url.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        widget.isCircleImage ? 24 : 8,
                      ),
                      child: AppNetworkImage(
                        imageUrl: url,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        compact: true,
                      ),
                    ),
                  if (url.isNotEmpty) const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge!.copyWith(
                        fontSize: 15,
                        fontWeight: MyFontWeight.medium,
                        color: const Color(0xff231F1E),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              RatingStarsInput(
                value: _stars,
                onChanged: (v) => setState(() {
                  _stars = v;
                  _error = null;
                }),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontSize: 12,
                      fontWeight: MyFontWeight.regular,
                      color: const Color(0xffF31616),
                    ),
                  ),
                ),
              const SizedBox(height: 14),
              // TextField خام لا TextBoxs — الأخير يفرض سطراً واحداً ويحذف الأسطر الجديدة
              TextField(
                controller: _comment,
                minLines: 3,
                maxLines: 4,
                maxLength: kRatingCommentMaxLength,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.newline,
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 14,
                  fontWeight: MyFontWeight.regular,
                  color: const Color(0xff231F1E),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 241, 241, 241),
                  hintText: widget.hintText,
                  hintStyle: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 13,
                    fontWeight: MyFontWeight.light,
                    color: const Color(0xffA19491),
                  ),
                  contentPadding: const EdgeInsets.all(14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: theme.primaryColor, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              ButtonAppWidget(lable: 'إرسال التقييم', onPressed: _submit),
            ],
          ),
        ),
      ),
    );
  }
}

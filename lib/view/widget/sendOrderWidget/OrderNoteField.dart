import 'package:customer/controller/CartController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';

/// حقل ملاحظة الطلب في صفحة إرسال الطلب (اختياري، متعدد الأسطر).
///
/// لا يستعمل [TextBoxs] لأنه يفرض سطراً واحداً / أرقاماً فقط.
///
/// ⚠️ **الودجت تملك [TextEditingController] الخاص بها عمداً** ولا تستقبله من كنترولر GetX:
/// `CartController` مسجَّل بـ `Get.create` (مصنع يُنتج نسخة لكل `Get.find`)، وGetX يتخلّص
/// من النسخ المُنشأة عند إغلاق المسار فيُنفَّذ `onClose`. أي controller يملكه كنترولر GetX
/// ويُمرَّر إلى ودجت ينتهي به الأمر مُتلَفاً بينما الودجت ما زالت تستعمله
/// («A TextEditingController was used after being disposed»).
/// مصدر الحقيقة هو `CartController.orderNote` (RxString)، وهذه الودجت تكتب إليه.
class OrderNoteField extends StatefulWidget {
  const OrderNoteField({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;

  @override
  State<OrderNoteField> createState() => _OrderNoteFieldState();
}

class _OrderNoteFieldState extends State<OrderNoteField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant OrderNoteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تُفرَّغ الملاحظة بعد نجاح الإرسال — نعكس ذلك في الحقل بلا تحريك المؤشر عبثاً
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffE7E4E4)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sticky_note_2_outlined,
                size: 18,
                color: Color(0xff6E615E),
              ),
              const SizedBox(width: 6),
              Text(
                'ملاحظة للطلب (اختياري)',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                  color: const Color(0xff231F1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _controller,
            minLines: 3,
            maxLines: 3,
            maxLength: CartController.kOrderNoteMaxLength,
            keyboardType: TextInputType.multiline,
            textInputAction: TextInputAction.newline,
            onChanged: widget.onChanged,
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: 14,
              fontWeight: MyFontWeight.regular,
              color: const Color(0xff231F1E),
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(255, 241, 241, 241),
              hintText: 'مثال: الرجاء الاتصال قبل الوصول',
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
        ],
      ),
    );
  }
}

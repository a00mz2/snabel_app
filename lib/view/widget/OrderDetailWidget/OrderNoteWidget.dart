import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';

/// بطاقة «ملاحظة الطلب» في تفاصيل الطلب (الملاحظة التي كتبها الزبون عند الإرسال).
class OrderNoteWidget extends StatelessWidget {
  const OrderNoteWidget({super.key, required this.note});

  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF9F8F8),
        border: Border.all(color: const Color(0xffE7E4E4)),
        borderRadius: BorderRadius.circular(8),
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
                'ملاحظة الطلب',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 14,
                  fontWeight: MyFontWeight.semiBold,
                  color: const Color(0xff231F1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            note,
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: 13,
              fontWeight: MyFontWeight.regular,
              color: const Color(0xff6E615E),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

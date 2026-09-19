import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';

/// زر التقييم في ذيل سطر المنتج داخل تفاصيل الطلب.
///
/// هدف لمس 44×44 يتّسع داخل ارتفاع السطر الثابت (68) بلا تعديل عليه.
/// - غير مقيَّم: نجمة فارغة + «قيّم».
/// - مقيَّم: نجمة ممتلئة + عدد النجوم (الضغط يعيد فتح الورقة مُعبّأة).
/// - [enabled] = false للسطر المكرر لنفس المنتج (تقييم واحد لكل منتج في الطلب).
class ItemRatingButton extends StatelessWidget {
  const ItemRatingButton({
    super.key,
    required this.myStars,
    required this.onTap,
    this.isSubmitting = false,
    this.enabled = true,
  });

  final int myStars;
  final VoidCallback onTap;
  final bool isSubmitting;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rated = myStars > 0;

    if (isSubmitting) {
      return const SizedBox(
        width: 44,
        height: 44,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 44,
        height: 44,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              rated ? Icons.star_rounded : Icons.star_border_rounded,
              size: 22,
              color: enabled
                  ? theme.primaryColor
                  : const Color(0xffD0CAC8),
            ),
            const SizedBox(height: 1),
            Text(
              rated ? '$myStars' : 'قيّم',
              style: theme.textTheme.titleLarge!.copyWith(
                fontSize: 10,
                fontWeight: MyFontWeight.medium,
                color: enabled
                    ? const Color(0xff6E615E)
                    : const Color(0xffA19491),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

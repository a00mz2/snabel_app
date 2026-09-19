import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/order_rejection_reasons.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:flutter/material.dart';

/// بطاقة «سبب الرفض» في تفاصيل الطلب — تظهر عندما تكون حالة الطلب «مرفوض».
class OrderRejectionWidget extends StatelessWidget {
  const OrderRejectionWidget({super.key, required this.rejection});

  final Map rejection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final details = rejection['details']?.toString().trim() ?? '';
    final by = rejectionByLabelAr(rejection);
    final at = rejection['at'];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffFFF1F0),
        border: Border.all(color: const Color(0xffFFCDC9)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cancel_outlined,
                size: 18,
                color: Color(0xffD32F2F),
              ),
              const SizedBox(width: 6),
              Text(
                'سبب الرفض',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 14,
                  fontWeight: MyFontWeight.semiBold,
                  color: const Color(0xffB3261E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            rejectionDisplayLabel(rejection),
            style: theme.textTheme.titleLarge!.copyWith(
              fontSize: 14,
              fontWeight: MyFontWeight.medium,
              color: const Color(0xff231F1E),
            ),
          ),
          if (details.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              details,
              style: theme.textTheme.titleLarge!.copyWith(
                fontSize: 13,
                fontWeight: MyFontWeight.regular,
                color: const Color(0xff6E615E),
                height: 1.4,
              ),
            ),
          ],
          if (by.isNotEmpty || at != null) ...[
            const SizedBox(height: 6),
            Text(
              [
                if (by.isNotEmpty) 'بواسطة: $by',
                if (at != null) formatDate(at),
              ].join('  ·  '),
              style: theme.textTheme.titleLarge!.copyWith(
                fontSize: 12,
                fontWeight: MyFontWeight.light,
                color: const Color(0xffA19491),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

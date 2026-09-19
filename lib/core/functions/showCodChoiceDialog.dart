import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:flutter/material.dart';

const String kCodModeExcess = 'excess';
const String kCodModeFull = 'full';

/// عند تجاوز الحد الائتماني: يختار الزبون تسديد الفرق أو الدفع الكامل نقداً للسائق.
/// يعيد `"excess"` أو `"full"` أو `null` عند الإلغاء.
Future<String?> showCodChoiceDialog(
  BuildContext context, {
  required num finalTotal,
  required num balance,
  required num limit,
  required num excess,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: 320,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 56,
                color: Color(0xffF39316),
              ),
              const SizedBox(height: 12),
              Text(
                'تجاوز الحد المالي',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleLarge!.copyWith(
                  fontSize: 16,
                  fontWeight: MyFontWeight.bold,
                  color: const Color(0xff292929),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'قيمة الطلب ${formatNumberNum(finalTotal)} د.ع، ورصيدك الحالي '
                '${formatNumberNum(balance)} د.ع، والحد المسموح '
                '${formatNumberNum(limit)} د.ع.\n'
                'تجاوز الحد بمقدار ${formatNumberNum(excess)} د.ع — يمكنك الدفع نقداً للسائق عند الاستلام.',
                textAlign: TextAlign.center,
                style: Theme.of(ctx).textTheme.titleLarge!.copyWith(
                  fontSize: 14,
                  fontWeight: MyFontWeight.regular,
                  color: const Color(0xff7C7C7C),
                ),
              ),
              const SizedBox(height: 18),
              _CodButton(
                label:
                    'تسديد الفرق عند الاستلام (${formatNumberNum(excess)} د.ع)',
                color: const Color(0xffF39316),
                onTap: () => Navigator.pop(ctx, kCodModeExcess),
              ),
              const SizedBox(height: 8),
              _CodButton(
                label:
                    'الدفع الكامل عند الاستلام (${formatNumberNum(finalTotal)} د.ع)',
                color: const Color(0xff3C2313),
                onTap: () => Navigator.pop(ctx, kCodModeFull),
              ),
              const SizedBox(height: 8),
              _CodButton(
                label: 'إلغاء',
                color: const Color(0xffEEEEEE),
                textColor: Colors.black87,
                onTap: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _CodButton extends StatelessWidget {
  const _CodButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });

  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontSize: 13,
            fontWeight: MyFontWeight.semiBold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

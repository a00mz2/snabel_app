import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/payment_methods.dart';
import 'package:flutter/material.dart';

/// اختيار طريقة دفع الطلب في صفحة إرسال الطلب.
///
/// «آجل» يُخصم من محفظة المتجر ويخضع للحد المالي، ويُعاد المبلغ عند الرفض أو
/// الحذف. «دفع عند الاستلام» لا يمسّ المحفظة إطلاقاً: لا دين ولا حد مالي، ولا
/// يوجد مبلغ يُرجَع إن أُلغي الطلب.
///
/// بلا حالة داخلية عمداً — مصدر الحقيقة `CartController.orderPaymentMethod`.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final String value;
  final ValueChanged<String> onChanged;

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
                Icons.account_balance_wallet_outlined,
                size: 18,
                color: Color(0xff6E615E),
              ),
              const SizedBox(width: 6),
              Text(
                'طريقة الدفع',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                  color: const Color(0xff231F1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _Option(
            selected: !isCashPaymentMethod(value),
            title: 'آجل — من المحفظة',
            subtitle: 'يُضاف إلى حسابك ويخضع للحد المالي',
            icon: Icons.account_balance_wallet_outlined,
            onTap: () => onChanged(kPaymentWallet),
          ),
          const SizedBox(height: 8),
          _Option(
            selected: isCashPaymentMethod(value),
            title: 'دفع عند الاستلام',
            subtitle: 'تدفع كامل المبلغ نقداً للسائق، بلا أي أثر على حسابك',
            icon: Icons.payments_outlined,
            onTap: () => onChanged(kPaymentCash),
          ),
        ],
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = selected
        ? const Color(0xffF39316)
        : const Color(0xffE7E4E4);
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xffFFF7E6) : Colors.white,
          border: Border.all(color: accent, width: selected ? 1.4 : 1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 20,
              color: selected
                  ? const Color(0xffE65100)
                  : const Color(0xff9E9E9E),
            ),
            const SizedBox(width: 10),
            Icon(
              icon,
              size: 20,
              color: selected
                  ? const Color(0xffE65100)
                  : const Color(0xff6E615E),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontSize: 13.5,
                      fontWeight: MyFontWeight.medium,
                      color: const Color(0xff231F1E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontSize: 11.5,
                      fontWeight: MyFontWeight.regular,
                      color: const Color(0xff8C827B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

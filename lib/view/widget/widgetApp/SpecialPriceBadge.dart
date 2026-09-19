import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';

/// `true` فقط عندما يرسل الخادم `isSpecialPrice: true` لهذا المنتج/البند —
/// آمن مع الخوادم القديمة (الحقل غائب → لا شارة).
bool hasSpecialPrice(dynamic raw) => raw is Map && raw['isSpecialPrice'] == true;

/// شارة «سعر خاص» صغيرة تُعرض بجوار السعر (بلا سعر مشطوب).
class SpecialPriceBadge extends StatelessWidget {
  const SpecialPriceBadge({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 1.5 : 2.5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorDark,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'سعر خاص',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Colors.white,
          fontSize: compact ? 9 : 10,
          fontWeight: MyFontWeight.semiBold,
          height: 1.2,
        ),
      ),
    );
  }
}

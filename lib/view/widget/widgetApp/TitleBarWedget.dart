import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';

class TitleBarWedget extends StatelessWidget {
  const TitleBarWedget({super.key, required this.lable, this.onPressed});

  final String lable;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            lable,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff0E0C0C),
              fontSize: 22,
              fontWeight: MyFontWeight.medium,
            ),
          ),
          TextButton(
            onPressed: onPressed,
            child: Text(
              "عرض الكل",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).primaryColor,
                fontSize: 12,
                fontWeight: MyFontWeight.light,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

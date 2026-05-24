import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';

class TitleBar extends StatelessWidget {
  const TitleBar({super.key, required this.itemCount});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          Text(
            "المنتجات",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff0E0C0C),
              fontSize: 20,
              fontWeight: MyFontWeight.medium,
            ),
          ),
          SizedBox(width: 5),
          Text(
            "($itemCount منتجات)",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff0E0C0C),
              fontSize: 12,
              fontWeight: MyFontWeight.light,
            ),
          ),
        ],
      ),
    );
  }
}

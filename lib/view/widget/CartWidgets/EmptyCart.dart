import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/lottie.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class EmptyCart extends StatelessWidget {
  const EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(AppLottie.emptyCart),
          Text(
            textAlign: TextAlign.center,
            "سلتك فارغة",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 16,
              fontWeight: MyFontWeight.bold,
              color: Color(0xff292929),
            ),
          ),
          Text(
            "لا توجد منتجات في سلتك حتا الان .\n ابدء في اكتشاف افضل المنتجات واضفها الى سلتك الان ",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontSize: 14,
              fontWeight: MyFontWeight.regular,
              color: Color(0xff7C7C7C),
            ),
          ),
        ],
      ),
    );
  }
}

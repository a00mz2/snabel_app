import 'package:customer/controller/CartController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';

class PriceFltatBar extends StatelessWidget {
  final bool showDeliveryFee;
  PriceFltatBar({super.key, this.showDeliveryFee = false});
  final controller = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Color(0xffF9F8F8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عدد المنتجات',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff6E615E),
                  fontSize: 12,
                  fontWeight: MyFontWeight.light,
                ),
              ),

              Row(
                children: [
                  Text(
                    controller.dataCart.length.toString(),
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Color(0xff231F1E),
                      fontSize: 12,
                      fontWeight: MyFontWeight.medium,
                    ),
                  ),
                  Text(
                    " منتجات",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Color(0xff231F1E),
                      fontSize: 12,
                      fontWeight: MyFontWeight.light,
                    ),
                  ),
                ],
              ),
            ],
          ),
          showDeliveryFee
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تكلفة التوصيل',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 14,
                        fontWeight: MyFontWeight.medium,
                      ),
                    ),
                    Text(
                      "${formatNumber(controller.deliveryFee.value)}  د.ع",

                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.medium,
                      ),
                    ),
                  ],
                )
              : SizedBox.shrink(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'السعر النهائي',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
              Text(
                "${formatNumber(controller.calculateTotalCartPrice().toInt())}  د.ع",

                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 16,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

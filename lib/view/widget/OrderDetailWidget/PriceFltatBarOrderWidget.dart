import 'package:customer/controller/orderDetailController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:flutter/material.dart';
import 'package:get/instance_manager.dart';

class PriceFltatBarOrderWidget extends StatelessWidget {
  final bool showDeliveryFee;
  PriceFltatBarOrderWidget({super.key, this.showDeliveryFee = false});
  final controller = Get.find<OrderDetailController>();

  static num _num(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    return num.tryParse(v.toString()) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final total = _num(controller.dataOrder['totalPrice']);
    final fee = _num(controller.dataOrder['deliveryFee']);
    final subtotal = total - fee;

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        color: Color(0xffF9F8F8),
      ),
      child: Column(
        spacing: 10,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'المجموع',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
              Text(
                "${formatNumberNum(subtotal)}  د.ع",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 16,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
            ],
          ),

          Row(
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
                "${formatNumberNum(fee)}  د.ع",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 16,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
            ],
          ),

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
                "${formatNumberNum(total)}  د.ع",
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

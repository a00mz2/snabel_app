import 'package:customer/controller/CartController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

class CartProduct extends StatelessWidget {
  final controller = Get.find<CartController>();
  final int index;

  CartProduct({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        border: index == controller.dataCart.length - 1
            ? null
            : Border(bottom: BorderSide(color: Color(0xffE7E4E4))),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Color(0xffF9F8F8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: AppNetworkImage(
              imageUrl:
                  Applink.productImage(controller.imageitem(index).toString()),
              fit: BoxFit.cover,
              width: 52,
              height: 52,
              compact: true,
            ),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        controller.dataCart[index]['product']['name'] +
                            // ignore: prefer_interpolation_to_compose_strings
                            "   (" +
                            controller.packageName(index) +
                            ")",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Color(0xff0E0C0C),
                          fontSize: 14,
                          fontWeight: MyFontWeight.light,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 238, 238, 238),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () =>
                                controller.updateCartQuantity(index, false),
                            child: Icon(Icons.remove, color: Color(0xff6E615E)),
                          ),
                          SizedBox(width: 6),
                          Obx(
                            () => Text(
                              (controller.dataCart[index]['quantity'])
                                  .toString(),
                              style: Theme.of(context).textTheme.titleLarge!
                                  .copyWith(
                                    color: Color(0xff231F1E),
                                    fontSize: 16,
                                    fontWeight: MyFontWeight.regular,
                                  ),
                            ),
                          ),
                          SizedBox(width: 6),
                          InkWell(
                            onTap: () =>
                                controller.updateCartQuantity(index, true),
                            child: Icon(Icons.add, color: Color(0xff6E615E)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatNumber(controller.totalItemPrice(index)),
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Color(0xff231F1E),
                                fontSize: 16,
                                fontWeight: MyFontWeight.semiBold,
                              ),
                        ),
                        Text(
                          "  د.ع",
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Color(0xff231F1E),
                                fontSize: 12,
                                fontWeight: MyFontWeight.light,
                              ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () => controller.removeFromCart(index),
                      child: Image.asset(
                        width: 20,
                        height: 20,
                        AppIcons.delete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

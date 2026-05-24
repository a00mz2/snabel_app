import 'package:customer/controller/CartController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SendOrderProductWidget extends StatelessWidget {
  final controller = Get.find<CartController>();
  final int index;

  SendOrderProductWidget({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        border: index == controller.dataCart.length - 1
            ? null
            : const Border(bottom: BorderSide(color: Color(0xffE7E4E4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xffF9F8F8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: AppNetworkImage(
                  imageUrl: Applink.productImage(
                    controller.imageitem(index).toString(),
                  ),
                  fit: BoxFit.cover,
                  width: 52,
                  height: 52,
                  compact: true,
                ),
              ),

              /// 🔴 العدد فوق الصورة
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "x${controller.dataCart[index]['quantity']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          /// 🧾 تفاصيل المنتج (الاسم + السعر)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🥖 اسم المنتج + نوع التغليف
                Text(
                  controller.dataCart[index]['product']['name'],
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: const Color(0xff0E0C0C),
                    fontSize: 14,
                    fontWeight: MyFontWeight.light,
                  ),
                ),
                const SizedBox(height: 6),

                /// 💰 السعر و زر الحذف
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${controller.dataCart[index]['quantity']}   ${controller.packageName(index)} ",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          formatNumber(controller.totalItemPrice(index)),
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: const Color(0xff231F1E),
                                fontSize: 16,
                                fontWeight: MyFontWeight.semiBold,
                              ),
                        ),
                        Text(
                          "  د.ع",
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: const Color(0xff231F1E),
                                fontSize: 12,
                                fontWeight: MyFontWeight.light,
                              ),
                        ),
                      ],
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

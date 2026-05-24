// ignore_for_file: avoid_print

import 'package:customer/controller/MainController.dart';
import 'package:customer/controller/ProductsDetailController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/view/widget/ProductsDetailWidget/ExpandableTextWidget.dart';
import 'package:customer/view/widget/ProductsDetailWidget/NamePriceWidget.dart';
import 'package:customer/view/widget/ProductsDetailWidget/ProductImages.dart';
import 'package:customer/view/widget/ProductsDetailWidget/packingsWidget.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductsDetailSecrren extends StatelessWidget {
  ProductsDetailSecrren({super.key});

  final controller = Get.find<ProductsDetailController>();
  final mainController = Get.put(MainController(current: 1));

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      onRefresh: () => controller.getProduct(),
      horizontalPadding: 16,
      statusCode: controller.statusCode,
      statusRequest: controller.statusRequest,
      isSub: true,
      namePage: "تفاصيل المنتج",
      bottomNavigationBar: Obx(
        () => Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xffE7E4E4))),
          ),
          child: ButtonAppWidget(
            primaryButton: !controller.isInCart.value,
            onPressed: () async {
              if (controller.isInCart.value) {
                mainController.changePage(1);
                Get.offAllNamed('/MainScreen', arguments: {'current': 1});
              } else {
                controller.addToCart();
              }
            },

            icon: Image.asset(
              AppIcons.addTocart,
              color: Theme.of(context).primaryColorDark,
              width: 20,
            ),

            lable: controller.isInCart.value
                ? "  عرض السلة   "
                : "  اضف الي السلة   "
                      "${controller.packings.isEmpty ? formatNumber(controller.dataProduct['price'] * controller.count.value) : formatNumber((controller.dataProduct['price'] * controller.packings[controller.selectedPackingIndex.value]['quantity']) * controller.count.value)}"
                      "  د.ع   ",
          ),
        ),
      ),
      child: ListView(
        children: [
          ProductImages(),
          SizedBox(height: 16),
          NamePriceWidget(),
          SizedBox(height: 16),
          PackingsWidget(),
          SizedBox(height: 16),
          Obx(
            () => ExpandableTextWidget(
              text: controller.dataProduct['description'].toString(),
              trimLines: 2,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 60,
            decoration: BoxDecoration(
              color: Color(0xffF9F8F8),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(AppIcons.count, width: 20, height: 20),
                SizedBox(width: 8),
                Text(
                  "الكمية",
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Color(0xffA19491),
                    fontSize: 16,
                    fontWeight: MyFontWeight.light,
                  ),
                ),
                Expanded(child: SizedBox()),
                Container(
                  height: 40,
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(
                    () => Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () => controller.cartEdt(true),
                          icon: Icon(Icons.add, size: 24),
                        ),
                        Text(
                          controller.count.value.toString(),
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                color: Color(0xff231F1E),
                                fontSize: 24,
                                fontWeight: MyFontWeight.medium,
                              ),
                        ),
                        IconButton(
                          onPressed: () => controller.cartEdt(false),
                          icon: Icon(Icons.remove, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

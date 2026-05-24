import 'package:customer/controller/CartController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/view/widget/CartWidgets/CartProduct.dart';
import 'package:customer/view/widget/CartWidgets/EmptyCart.dart';
import 'package:customer/view/widget/CartWidgets/PriceFltatBar.dart';
import 'package:customer/view/widget/CartWidgets/TitleBar.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';

import 'package:customer/view/widget/widgetApp/DashedDividerWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  CartScreen({super.key});

  final CartController controller = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      bottomNavigationBar: Obx(
        () => controller.dataCart.isEmpty
            ? SizedBox()
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ButtonAppWidget(
                      onPressed: () {
                        controller.statusRequestDeliveryPeriods.value =
                            StatusRequest.empty;
                        controller.deliveryPeriods = {}.obs;
                        controller.selectedDate.value = null;
                        controller.deliveryDate = "";
                        controller.getCart();
                        Get.toNamed('SendOrder');
                      },
                      lable: "اتمام الطلب",
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
      ),
      horizontalPadding: 16,
      onRefresh: () => controller.getCart(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      child: Obx(
        () => controller.dataCart.isEmpty
            ? EmptyCart()
            : ListView(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xffE7E4E4)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TitleBar(itemCount: controller.dataCart.length),
                        SizedBox(height: 10),
                        DashedDividerWidget(color: Color(0xffE7E4E4)),
                        Obx(
                          () => AnimationLimiter(
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: controller.dataCart.length,
                              itemBuilder: (context, index) =>
                                  AnimationConfiguration.staggeredList(
                                    position: index,
                                    duration: const Duration(seconds: 1),
                                    child: FadeInAnimation(
                                      child: FadeInAnimation(
                                        child: CartProduct(index: index),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        PriceFltatBar(),
                      ],
                    ),
                  ),
                  SizedBox(height: 50),
                ],
              ),
      ),
    );
  }
}

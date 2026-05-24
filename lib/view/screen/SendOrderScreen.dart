// ignore_for_file: invalid_use_of_protected_member

import 'package:customer/controller/CartController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/constant/assets/lottie.dart';
import 'package:customer/view/widget/CartWidgets/PriceFltatBar.dart';
import 'package:customer/view/widget/CartWidgets/SendOrderProductWidget.dart';
import 'package:customer/view/widget/CartWidgets/TitleBar.dart';
import 'package:customer/view/widget/sendOrderWidget/SchedulingWidget.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/DashedDividerWidget.dart';
import 'package:customer/view/widget/widgetApp/DropdownWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class SendOrderScreen extends StatelessWidget {
  SendOrderScreen({super.key});

  final CartController controller = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      backgroundColor: Color(0xffF9FAFB),
      namePage: "ارسال الطلب",
      isSub: true,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: ButtonAppWidget(
          onPressed: () => controller.createOrderFromCart(),
          lable: "ارسال الطلب",
        ),
      ),

      horizontalPadding: 16,
      onRefresh: () => controller.getCart(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      child: ListView(
        children: [
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xffE7E4E4)),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TitleBar(itemCount: controller.dataCart.length),
                SizedBox(height: 10),
                DashedDividerWidget(color: Color(0xffE7E4E4)),
                AnimationLimiter(
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
                              child: SendOrderProductWidget(index: index),
                            ),
                          ),
                        ),
                  ),
                ),

                PriceFltatBar(showDeliveryFee: true),
              ],
            ),
          ),
          SizedBox(height: 20),
          SchedulingWidget(),
          SizedBox(height: 25),
          Center(
            child: Obx(
              () =>
                  controller.statusRequestDeliveryPeriods.value ==
                      StatusRequest.loading
                  ? CircularProgressIndicator()
                  : controller.statusRequestDeliveryPeriods.value ==
                        StatusRequest.nameExestFailure
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Lottie.asset(AppLottie.endWorking),
                        SizedBox(height: 10),
                        Text(" انتهت فترات التوصيل لليوم! ⏰"),
                      ],
                    )
                  : controller.statusRequestDeliveryPeriods.value ==
                        StatusRequest.success
                  ? DropdownWidget(
                      validator: false,
                      hintText: "اختر فترة استلام الطلب",
                      items: controller.listDeliveryPeriods,
                      itemLabelBuilder: (item) => item["name"],
                      selectedItem: controller.deliveryPeriods.isEmpty
                          ? null
                          : controller.deliveryPeriods.value,
                      onChanged: (value) =>
                          controller.selecteddeliveryPeriods(value),
                      prefixIcon: Container(
                        width: 10,
                        height: 10,
                        padding: EdgeInsets.all(9.5),
                        child: Icon(Icons.timelapse_rounded),
                      ),
                    )
                  : SizedBox(),
            ),
          ),
          SizedBox(height: 12),
        ],
      ),
    );
  }
}

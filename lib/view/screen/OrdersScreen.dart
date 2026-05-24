import 'package:customer/controller/OrdersController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/lottie.dart';
import 'package:customer/view/widget/orderWidget/OrderItemWidget.dart';
import 'package:customer/view/widget/widgetApp/ListButtonTab.dart';
import 'package:customer/view/widget/widgetApp/PaginationIndicator.dart';
import 'package:customer/view/screen/orderDetailSecrren.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});
  final OrdersController controller = Get.put(OrdersController());

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      onRefresh: () => controller.getOrders(),
      bottomNavigationBar: Obx(
        () => PaginationIndicator(
          index: controller.listOrders.length - 1,
          listlength: controller.listOrders.length,
          statusRequestPagination: controller.statusRequestPagination.value,
        ),
      ),
      statusCode: controller.statusCode,
      statusRequest: controller.statusRequest,
      heder: Obx(
        () => ListButtonTab(
          status: controller.statusTabBar.value,
          children: const [
            'الكل',
            "انتضار",
            'قيد التجهيز',
            'جاري التوصيل',
            'مكتمل',
            'مرفوض',
          ],
          onTap: (p0) => controller.selcteingStatusTabBar(p0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Obx(
          () => controller.listOrders.isEmpty
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: Lottie.asset(AppLottie.noOrders),
                    ),
                    Text(
                      "لا يوجد طلبات حالياً",
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 14,
                        fontWeight: MyFontWeight.medium,
                        color: const Color.fromARGB(124, 0, 0, 0),
                      ),
                    ),
                  ],
                )
              : ListView.separated(
                  controller: controller.scrollController,
                  physics: const BouncingScrollPhysics(),
                  itemCount: controller.listOrders.length,
                  separatorBuilder: (context, index) => SizedBox(height: 5),
                  itemBuilder: (context, index) => OrderItemWidget(
                    orderTitle: controller.listOrders[index]['orderNumber'],
                    orderPrice: controller.listOrders[index]['totalPrice'],
                    orderDate: controller.listOrders[index]['deliveryDate'],
                    productImages: controller.listOrders[index]['items'],
                    status: controller.listOrders[index]['status'],
                    index: index,
                    onTap: () => orderDetailSecrren.navigateWithOrderNumber(
                          controller.listOrders[index]['orderNumber']
                              .toString(),
                        ),
                  ),
                ),
        ),
      ),
    );
  }
}

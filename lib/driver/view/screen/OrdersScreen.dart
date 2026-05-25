// ignore_for_file: file_names

import 'package:customer/driver/controller/orders_controller.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/constant/assets/icons.dart';
import 'package:customer/driver/core/functions/formatDate.dart';
import 'package:customer/driver/core/functions/formatNumber.dart';
import 'package:customer/driver/core/functions/statusColors.dart';
import 'package:customer/driver/view/widget/widgetApp/ListButtonTab.dart';
import 'package:customer/driver/view/widget/widgetApp/StoreAvatarCircle.dart';
import 'package:customer/driver/view/widget/widgetApp/NoDataAvailableWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrdersScreen extends StatelessWidget {
  OrdersScreen({super.key});

  final DriverOrdersController controller = Get.find<DriverOrdersController>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      onRefresh: () => controller.getOrders(),
      statusCode: controller.statusCode,
      statusRequest: controller.statusRequest,
      heder: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ListButtonTab(
            status: controller.statusTabBar.value,
            children: const [
              'الكل',
              "قيد التجهيز",
              "جاهز للاستلام",
              "قيد الاستلام",
              "قيد التوصيل",
              'واصل',
              'مرفوض',
            ],
            onTap: (p0) => controller.selcteingStatusTabBar(p0),
          ),
        ),
      ),
      child: Obx(
        () => controller.listOrder.isNotEmpty
            ? Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: controller.scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      shrinkWrap: true,
                      itemCount: controller.listOrder.length,
                      itemBuilder: (context, index) => InkWell(
                        onTap: () => Get.toNamed(
                          "/driver/OrderDetels",
                          arguments: controller.listOrder[index],
                        ),
                        child: Container(
                          margin: EdgeInsets.only(top: index == 0 ? 5 : 0),
                          height: 60,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xffF3F2F1)),
                            ),
                          ),
                          child: Row(
                            children: [
                              StoreAvatarCircle(
                                customers: controller.listOrder[index]
                                    ["customers"],
                              ),
                              SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          controller
                                                  .listOrder[index]['customers']['name'] ??
                                              "حساب محذوف",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                color: Color(0xff292929),
                                                fontWeight:
                                                    MyFontWeight.regular,
                                                fontSize: 12,
                                              ),
                                        ),
                                        SizedBox(width: 5),
                                        Text(
                                          "# ${controller.listOrder[index]['orderNumber']}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                color: Color(0xff292929),
                                                fontWeight:
                                                    MyFontWeight.regular,
                                                fontSize: 12,
                                              ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Image.asset(
                                          AppIcons.star,
                                          width: 10,
                                          height: 10,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          "${formatNumber(controller.listOrder[index]['totalPrice'])} د.ع",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                color: Color(0xff7C7C7C),
                                                fontWeight: MyFontWeight.light,
                                                fontSize: 10,
                                              ),
                                        ),
                                        SizedBox(width: 16),
                                        Image.asset(
                                          AppIcons.calendar,
                                          width: 10,
                                          height: 10,
                                        ),
                                        SizedBox(width: 2),
                                        Text(
                                          formatDateTime(
                                            controller
                                                .listOrder[index]['deliveryDate'],
                                          ),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                color: Color(0xff7C7C7C),
                                                fontWeight: MyFontWeight.light,
                                                fontSize: 10,
                                              ),
                                        ),
                                        Expanded(child: SizedBox()),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                            color: statusOrderColors(
                                              controller
                                                  .listOrder[index]['status'],
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              statusName(
                                                controller
                                                    .listOrder[index]['status'],
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge!
                                                  .copyWith(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        MyFontWeight.regular,
                                                    fontSize: 12,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  controller.statusRequestPagination.value ==
                          StatusRequest.loading
                      ? Center(
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            color: Theme.of(context).primaryColor,
                          ),
                        )
                      : SizedBox(height: 3),
                  SizedBox(height: 80),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 100),
                  NoDataAvailableWidget(
                    title: ' لا توجد طلبات متوفرة حاليًا',
                    bodyText: "تابعنا باستمرار، نقوم بتحديث الطلبات بانتظام",
                  ),
                ],
              ),
      ),
    );
  }
}

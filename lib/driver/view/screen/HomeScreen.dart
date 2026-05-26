// ignore_for_file: prefer_interpolation_to_compose_strings, file_names

import 'package:customer/driver/controller/HomeController.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/constant/assets/icons.dart';
import 'package:customer/driver/core/functions/formatDate.dart';
import 'package:customer/driver/core/functions/formatNumber.dart';
import 'package:customer/driver/core/functions/statusColors.dart';
import 'package:customer/driver/view/widget/widgetApp/NoDataAvailableWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/StoreAvatarCircle.dart';
import 'package:customer/driver/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/StatusCard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final DriverHomeController controller = Get.find<DriverHomeController>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      statusRequest: controller.statusRequest,
      onRefresh: () => controller.getOrders(),
      statusCode: controller.statusCode,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 16),

        children: [
          Obx(
            () => StatusCardLarge(
              lable: "الطلبات المستلمة",
              value: (controller.statsOrder["مع السائق"] ?? 0).toString(),
              actionCild: InkWell(
                onTap: () {},
                child: Column(
                  children: [
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100000),
                        color: Color(0xffF3F2F1),
                      ),
                      child: Image.asset(AppIcons.hugeicons_transactionhistory),
                    ),
                    Text(
                      "عرض الطلبات",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 11,
                        fontWeight: MyFontWeight.light,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 16),

          Obx(
            () => Row(
              children: [
                Expanded(
                  child: StatusCard(
                    lable: "جديد",
                    value: controller.nweOrders.toString(),
                    icon: AppIcons.orderNew,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: StatusCard(
                    lable: "قيد الاستلام",
                    value: (controller.statsOrder["قيد التوصيل"] ?? 0).toString(),
                    icon: AppIcons.orderOngoing,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "احدث الطلبات",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Color(0xff0E0E0E),
                fontWeight: MyFontWeight.semiBold,
                fontSize: 17,
              ),
            ),
          ),
          SizedBox(height: 10),

          Obx(
            () => controller.listOrder.isNotEmpty
                ? ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
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
                                              fontWeight: MyFontWeight.regular,
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
                                              fontWeight: MyFontWeight.regular,
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
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 100),
                      NoDataAvailableWidget(
                        title: ' لا توجد طلبات متوفرة حاليًا',
                        bodyText:
                            "تابعنا باستمرار، نقوم بتحديث الطلبات بانتظام",
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

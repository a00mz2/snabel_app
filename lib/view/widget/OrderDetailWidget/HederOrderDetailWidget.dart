import 'package:customer/controller/orderDetailController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:customer/core/functions/statusColors.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';

class HederOrderDetailWidget extends StatelessWidget {
  const HederOrderDetailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderDetailController>();
    return Obx(
      () {
        final raw = controller.dataOrder;
        if (raw.isEmpty) {
          return const SizedBox.shrink();
        }
        final status = raw['status']?.toString() ?? '';
        final deliveryPeriod = raw['deliveryPeriod'];
        final dpName = deliveryPeriod is Map
            ? (deliveryPeriod['name']?.toString() ?? '')
            : '';
        final startT = deliveryPeriod is Map
            ? deliveryPeriod['startTime']
            : null;
        final endT =
            deliveryPeriod is Map ? deliveryPeriod['endTime'] : null;

        return Container(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            border: Border.all(color: const Color(0xffE7E4E4)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "تاريخ الاستلام المحدد",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Color(0xff6E615E),
                            fontSize: 14,
                            fontWeight: MyFontWeight.light,
                          ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      formatDate(raw['deliveryDate']),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Color(0xff6E615E),
                            fontSize: 15,
                            fontWeight: MyFontWeight.regular,
                          ),
                    ),
                    SizedBox(height: 5),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: Divider(color: Color(0xffE7E4E4)),
                        ),
                        if (dpName.isNotEmpty)
                          Text(
                            "$dpName  ",
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  color: Color(0xff6E615E),
                                  fontSize: 15,
                                  fontWeight: MyFontWeight.regular,
                                ),
                          ),
                        if (startT != null && endT != null)
                          Row(
                            children: [
                              Text(
                                "(${convertTo12Hour(startT)}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Color(0xff6E615E),
                                      fontSize: 15,
                                      fontWeight: MyFontWeight.regular,
                                    ),
                              ),
                              Text(
                                " - ",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Color(0xff6E615E),
                                      fontSize: 15,
                                      fontWeight: MyFontWeight.regular,
                                    ),
                              ),
                              Text(
                                "${convertTo12Hour(endT)})",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                      color: Color(0xff6E615E),
                                      fontSize: 15,
                                      fontWeight: MyFontWeight.regular,
                                    ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 20),
              Container(
                height: 28,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusOrderColors(status),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    status == "جديد" ? "قيد المراجعة" : status,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: MyFontWeight.medium,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ignore_for_file: camel_case_types

import 'package:customer/controller/orderDetailController.dart';
import 'package:customer/view/widget/CartWidgets/TitleBar.dart';
import 'package:customer/view/widget/OrderDetailWidget/HederOrderDetailWidget.dart';
import 'package:customer/view/widget/OrderDetailWidget/OrderProductWidget.dart';
import 'package:customer/view/widget/OrderDetailWidget/PriceFltatBarOrderWidget.dart';
import 'package:customer/view/widget/widgetApp/DashedDividerWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class orderDetailSecrren extends GetView<OrderDetailController> {
  const orderDetailSecrren({super.key});

  /// مسار GetX الوحيد لشاشة تفاصيل الطلب — لا تُضف شاشة بديلة لهذا الغرض.
  static const String routeName = '/orderDetails';

  /// التوجيه إلى هذه الشاشة ([orderDetailSecrren]) عبر المسار المعرّف في `routes.dart`.
  static void navigateWithOrderNumber(String orderNumber) {
    final id = orderNumber.trim();
    OrderDetailPendingRouteArgs.stash(id);
    Get.toNamed(routeName, arguments: {'orderNumber': id});
  }

  /// من بيانات الإشعار: يمرّر [orderNumber] و [orderId] بشكل منفصل (لا يضع ObjectId تحت مفتاح orderNumber).
  static void navigateWithOrderPayload(Map<String, dynamic> payload) {
    final m = Map<String, dynamic>.from(payload);
    final num = (m['orderNumber'] ?? m['order_number'])?.toString().trim();
    final oid = (m['orderId'] ?? m['order_id'])?.toString().trim();
    final primary = (num != null && num.isNotEmpty)
        ? num
        : (oid ?? '');
    if (primary.isEmpty) return;
    OrderDetailPendingRouteArgs.stash(primary);
    Get.toNamed(routeName, arguments: {
      if (num != null && num.isNotEmpty) 'orderNumber': num,
      if (oid != null && oid.isNotEmpty) 'orderId': oid,
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderLabel = resolveOrderIdentifierFromArguments(Get.arguments) ??
        controller.orderId;
    return ScaffoldWidget(
      namePage: "تفاصيل الطلب #$orderLabel",
      isSub: true,
      horizontalPadding: 16,
      onRefresh: () => controller.getOrder(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      child: ListView(
        children: [
          HederOrderDetailWidget(),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffE7E4E4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(
              () {
                final items = controller.dataOrder['items'] as List?;
                final n = items?.length ?? 0;
                return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleBar(itemCount: n),
                  SizedBox(height: 10),
                  DashedDividerWidget(color: Color(0xffE7E4E4)),
                  AnimationLimiter(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: n,
                      itemBuilder: (context, index) =>
                          AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(seconds: 1),
                            child: FadeInAnimation(
                              child: FadeInAnimation(
                                child: OrderProductWidget(index: index),
                              ),
                            ),
                          ),
                    ),
                  ),
                  SizedBox(height: 50),
                  PriceFltatBarOrderWidget(showDeliveryFee: true),
                ],
              );
              },
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }
}

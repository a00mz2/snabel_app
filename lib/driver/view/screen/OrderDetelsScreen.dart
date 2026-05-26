import 'package:customer/driver/Widget/OrderProductWidget.dart';
import 'package:customer/driver/controller/OrderDetelsController.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/functions/formatDate.dart';
import 'package:customer/driver/core/functions/formatNumber.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/StoreAvatarCircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constant/assets/icons.dart';
import '../../core/functions/GuidanceExternalapp.dart';
import '../../core/functions/statusColors.dart';

class OrderDetelsScreen extends StatelessWidget {
  OrderDetelsScreen({super.key});

  final OrderDetelsController controller = Get.find<OrderDetelsController>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBarWidget: appbar(context),
      appBar: true,
      namePage: controller.dataOrder['orderNumber'].toString(),
      statusRequest: controller.scaffoldBodyStatus,
      statusCode: controller.statusCode,
      bottomNavigationBar: Obx(() => statusUpdateBotton(context)),

      child: Obx(
        () => ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            orderInfo(context),
            SizedBox(height: 10),
            locationInfo(context),
            SizedBox(height: 16),
            periodInfo(context),
            SizedBox(height: 10),
            priceAndProducts(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget appbar(context) {
    return AppBar(
      leading: InkWell(
        child: Icon(Icons.arrow_back_ios, size: 20),
        onTap: () => Get.back(),
      ),

      title: Text(
        controller.dataOrder['orderNumber'].toString(),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Color(0xff6C6C6C),
          fontSize: 16,
          fontWeight: MyFontWeight.regular,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget orderInfo(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              StoreAvatarCircle(
                size: 36,
                customers: controller.dataOrder['customers'],
              ),
              SizedBox(width: 8),
              Text(
                controller.dataOrder['customers']['name'].toString(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 16,
                  fontWeight: MyFontWeight.regular,
                ),
              ),
              Expanded(child: SizedBox()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: statusOrderColors(controller.dataOrder["status"]),
                ),
                child: Center(
                  child: Text(
                    statusName(controller.dataOrder['status']),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: MyFontWeight.regular,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Color(0xffE7E4E4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "رقم التليفون",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff6E615E),
                  fontSize: 12,
                  fontWeight: MyFontWeight.light,
                ),
              ),
              Text(
                controller.dataOrder['customers']['phone'].toString(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff6E615E),
                  fontSize: 12,
                  fontWeight: MyFontWeight.light,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ButtonAppWidget(
              icon: Image.asset(AppIcons.phone, color: Colors.white),
              lable: "اتصل بالزبون",
              onPressed: () => openWhatsAppToPhone(
                phone: controller.dataOrder['customers']['phone'].toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget locationInfo(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "موقع التسليم",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff0E0C0C),
              fontSize: 20,
              fontWeight: MyFontWeight.medium,
            ),
          ),
          Divider(color: Color(0xffE7E4E4)),
          SizedBox(height: 10),
          Row(
            children: [
              Image.asset(AppIcons.Frame21, width: 16, height: 16),
              SizedBox(width: 8),
              Text(
                "موقع التسليم : ",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff999999),
                  fontSize: 14,
                  fontWeight: MyFontWeight.regular,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  controller.dataOrder['customers']['address'],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Color(0xff666666),
                    fontSize: 14,
                    fontWeight: MyFontWeight.regular,
                  ),
                ),
              ),

              Image.asset(AppIcons.OrderLocation, width: 20, height: 20),
            ],
          ),

          SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ButtonAppWidget(
              primaryButton: false,
              icon: Image.asset(
                AppIcons.OrderLocation,
                width: 20,
                height: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              lable: "عرض الموقع",
              onPressed: () {
                final customer = controller.dataOrder['customers'];
                if (customer is! Map) {
                  AppSnackBar.error("الموقع غير متوفر");
                  return;
                }
                final storeLocation = customer['storeLocation'];
                if (storeLocation is! String || storeLocation.trim().isEmpty) {
                  AppSnackBar.error("الموقع غير متوفر");
                  return;
                }

                final loc = parseGoogleMapsDestination(storeLocation);
                if (loc.isEmpty) {
                  AppSnackBar.error("الموقع غير متوفر");
                  return;
                }

                openInMapsFromData(loc);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget periodInfo(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "موعد التسليم",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff0E0C0C),
              fontSize: 20,
              fontWeight: MyFontWeight.medium,
            ),
          ),

          Divider(color: Color(0xffE7E4E4)),
          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                overflow: TextOverflow.ellipsis,
                "موعد التسليم",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
              Text(
                overflow: TextOverflow.ellipsis,
                formatDate(controller.dataOrder['deliveryDate']),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                overflow: TextOverflow.ellipsis,
                "الفترة",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
              Text(
                overflow: TextOverflow.ellipsis,
                "${controller.dataOrder['deliveryPeriod']['name']}",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget priceAndProducts(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "المنتجات",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff0E0C0C),
                  fontSize: 20,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
              Text(
                "(${controller.dataOrder["items"].length} منتجات)",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff0E0C0C),
                  fontSize: 14,
                  fontWeight: MyFontWeight.regular,
                ),
              ),
            ],
          ),
          Divider(color: Color(0xffE7E4E4)),
          SizedBox(height: 10),
          ListView.builder(
            itemCount: controller.dataOrder['items'].length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => OrderProductWidget(
              index: index,
              length: controller.dataOrder['items'].length,
              dataOrder: controller.dataOrder['items'][index],
            ),
          ),

          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xffF9F8F8),
              borderRadius: BorderRadius.circular(4),
            ),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "المجموع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 14,
                        fontWeight: MyFontWeight.medium,
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "${formatNumber(controller.dataOrder['totalPrice'])}  د.ع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "تكلفة التوصيل",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 14,
                        fontWeight: MyFontWeight.medium,
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "${formatNumber(controller.dataOrder['deliveryFee'])}  د.ع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "المجموع الكلي",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 14,
                        fontWeight: MyFontWeight.medium,
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "${formatNumber(controller.dataOrder['deliveryFee'] + controller.dataOrder['totalPrice'])}  د.ع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
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

  Widget statusUpdateBotton(BuildContext context) {
    final raw =
        controller.dataOrder['status']?.toString().trim() ?? '';
    return SafeArea(
      child: Container(
        height: 64,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: raw == 'تم التجهيز'
            ? Obx(
                () => ButtonAppWidget(
                  statusRequest: controller.statusRequest.value,
                  lable: "استلام الطلب",
                  onPressed: () =>
                      AppSnackBar.info("اضغط مطولا لاتمام الاجراء"),
                  onLongPress: () => controller.updateStatusOrder(
                    controller.dataOrder['_id'],
                    "قيد التوصيل",
                  ),
                ),
              )
            : raw == 'قيد التوصيل'
            ? Obx(
                () => ButtonAppWidget(
                  statusRequest: controller.statusRequest.value,
                  primaryButton: false,
                  color: Colors.grey,
                  lable: "تم الاستلام",
                  onPressed: () =>
                      AppSnackBar.info("اضغط مطولا لاتمام الاجراء"),
                  onLongPress: () => controller.updateStatusOrder(
                    controller.dataOrder['_id'],
                    "مع السائق",
                  ),
                ),
              )
            : raw == 'مع السائق'
            ? Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => ButtonAppWidget(
                        statusRequest:
                            controller.statusRequestButtonreject.value,
                        color: Colors.red,
                        primaryButton: false,
                        lable: "مرفوض",
                        textColor: Colors.red,
                        onPressed: () =>
                            AppSnackBar.info("اضغط مطولا لاتمام الاجراء"),
                        onLongPress: () => controller.updateStatusOrder(
                          isReject: true,
                          controller.dataOrder['_id'],
                          "مرفوض",
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Obx(
                      () => ButtonAppWidget(
                        statusRequest: controller.statusRequest.value,
                        color: Colors.green,
                        lable: "تم التسليم",
                        onPressed: () =>
                            AppSnackBar.info("اضغط مطولا لاتمام الاجراء"),
                        onLongPress: () => controller.updateStatusOrder(
                          controller.dataOrder['_id'],
                          "تم التسليم",
                        ),
                      ),
                    ),
                  ),
                ],
              )
            : SizedBox(),
      ),
    );
  }
}

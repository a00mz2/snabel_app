import 'package:customer/controller/CartController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:customer/view/widget/sendOrderWidget/DaysWidget.dart';
import 'package:customer/view/widget/sendOrderWidget/TabsPin.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/DateSelectorWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SchedulingWidget extends StatelessWidget {
  SchedulingWidget({super.key});

  final CartController controller = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        height: 70,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xffE7E4E4)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(0xffF3F4F6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.date_range,
                color: const Color.fromARGB(255, 105, 105, 105),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "جدولة الطلب",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: MyFontWeight.light,
                      color: Color(0xff0E0C0C),
                    ),
                  ),

                  Obx(
                    () => controller.isPin.value
                        ? Text(
                            controller.formatDaysOfWeek(controller.daysOfWeek),
                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: MyFontWeight.light,
                                  color: Color(0xff0E0C0C).withAlpha(150),
                                ),
                          )
                        : Text(
                            controller.selectedDate.value != null
                                ? "اليوم المحدد: ${formatDate(controller.selectedDate.value!.toLocal())}"
                                : "حدّد يوم الاستلام",

                            style: Theme.of(context).textTheme.titleLarge!
                                .copyWith(
                                  fontSize: 14,
                                  fontWeight: MyFontWeight.light,
                                  color: Color(0xff0E0C0C).withAlpha(150),
                                ),
                          ),
                  ),
                ],
              ),
            ),
            Image.asset(AppIcons.arrow_forward, width: 20, height: 20),
          ],
        ),
      ),
      onTap: () => showDialog(
        context: context,
        builder: (context) => Dialog(
          insetPadding: EdgeInsets.all(20),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListView(
              shrinkWrap: true,
              children: [
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Color(0xffE7E4E4)),
                    ),
                  ),
                  child: Text(
                    "ارسال الطلب",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                SizedBox(height: 16),
                TabsPin(),
                SizedBox(height: 25),
                Obx(
                  () => controller.isPin.value
                      ? DaysWidget()
                      : DateSelectorWidget(
                          selectedDate: controller.selectedDate,
                        ),
                ),
                SizedBox(height: 16),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: Color(0xffE7E4E4))),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: ButtonAppWidget(
                      color: Theme.of(context).primaryColor,
                      onPressed: () => Get.back(),
                      lable: "حفظ",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

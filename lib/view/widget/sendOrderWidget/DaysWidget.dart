import 'package:customer/controller/CartController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DaysWidget extends StatelessWidget {
  DaysWidget({super.key});
  final CartController controller = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "اختر الأيام التي ترغب بتكرار الطلب فيها ضمن الفترة المحددة",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.black,
              fontWeight: MyFontWeight.light,
            ),
          ),
        ),
        SizedBox(height: 16),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFFF1F1F1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              Divider(height: 1, color: Color.fromARGB(255, 225, 225, 225)),
              Obx(
                () => InkWell(
                  onTap: () => controller.changeDaysOfWeek(0),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: controller.daysOfWeek.contains(0),
                        onChanged: (value) => controller.changeDaysOfWeek(0),
                      ),
                      Text("الاحد"),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Color.fromARGB(255, 225, 225, 225)),
              Obx(
                () => InkWell(
                  onTap: () => controller.changeDaysOfWeek(1),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: controller.daysOfWeek.contains(1),
                        onChanged: (value) => controller.changeDaysOfWeek(1),
                      ),
                      Text("الاثنين"),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Color.fromARGB(255, 225, 225, 225)),
              Obx(
                () => InkWell(
                  onTap: () => controller.changeDaysOfWeek(2),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: controller.daysOfWeek.contains(2),
                        onChanged: (value) => controller.changeDaysOfWeek(2),
                      ),
                      Text("الثلاثاء"),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Color.fromARGB(255, 225, 225, 225)),
              Obx(
                () => InkWell(
                  onTap: () => controller.changeDaysOfWeek(3),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: controller.daysOfWeek.contains(3),
                        onChanged: (value) => controller.changeDaysOfWeek(3),
                      ),
                      Text("الاربعاء"),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Color.fromARGB(255, 225, 225, 225)),
              Obx(
                () => InkWell(
                  onTap: () => controller.changeDaysOfWeek(4),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: controller.daysOfWeek.contains(4),
                        onChanged: (value) => controller.changeDaysOfWeek(4),
                      ),
                      Text("الخميس"),
                    ],
                  ),
                ),
              ),
              Divider(height: 1, color: Color.fromARGB(255, 225, 225, 225)),
              Obx(
                () => InkWell(
                  onTap: () => controller.changeDaysOfWeek(5),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: controller.daysOfWeek.contains(5),
                        onChanged: (value) => controller.changeDaysOfWeek(5),
                      ),
                      Text("الجمعة"),
                    ],
                  ),
                ),
              ),
              Obx(
                () => InkWell(
                  onTap: () => controller.changeDaysOfWeek(6),
                  child: Row(
                    children: [
                      Checkbox(
                        activeColor: Theme.of(context).primaryColor,
                        value: controller.daysOfWeek.contains(6),
                        onChanged: (value) => controller.changeDaysOfWeek(6),
                      ),
                      Text("السبت"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

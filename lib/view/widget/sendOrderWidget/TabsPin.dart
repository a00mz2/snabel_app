import 'package:customer/controller/CartController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TabsPin extends StatelessWidget {
  final CartController controller = Get.find<CartController>();

  TabsPin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xffE7E4E4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => controller.changeTabPin(false),
              child: Obx(
                () => Container(
                  height: 40,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: controller.isPin.value
                        ? null
                        : Theme.of(context).primaryColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.date_range_outlined,
                        color: !controller.isPin.value
                            ? Colors.white
                            : const Color(0xFF7C7C7C),
                        size: 18,
                      ),
                      Text(
                        "جدولة",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: !controller.isPin.value
                              ? Colors.white
                              : const Color(0xFF7C7C7C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(
              () => GestureDetector(
                onTap: () => controller.changeTabPin(true),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: controller.isPin.value
                        ? Theme.of(context).primaryColor
                        : null,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.loop,
                        color: controller.isPin.value
                            ? Colors.white
                            : const Color(0xFF7C7C7C),
                        size: 18,
                      ),
                      Text(
                        "تثبيت",
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                          color: controller.isPin.value
                              ? Colors.white
                              : const Color(0xFF7C7C7C),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:customer/controller/ProductsDetailController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PackingsWidget extends StatelessWidget {
  final controller = Get.find<ProductsDetailController>();

  PackingsWidget({super.key});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 35,
      child: Obx(
        () => ListView.builder(
          itemCount: controller.packings.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) => Obx(
            () => GestureDetector(
              onTap: () => controller.onPackingChanged(index),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                margin: EdgeInsets.only(left: 4),

                decoration: BoxDecoration(
                  color: index == controller.selectedPackingIndex.value
                      ? Theme.of(context).primaryColor
                      : Color(0xffF3F2F1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  controller.packings[index]['label'],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 14,
                    fontWeight: MyFontWeight.regular,
                    color: index == controller.selectedPackingIndex.value
                        ? Colors.white
                        : Color(0xff6E615E),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

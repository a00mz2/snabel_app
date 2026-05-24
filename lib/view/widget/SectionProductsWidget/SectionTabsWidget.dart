import 'package:customer/controller/HomeController.dart';
import 'package:customer/controller/SectionProductsController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SectionTabsWidget extends GetView<SectionProductsController> {
  const SectionTabsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return SizedBox(
      height: 32,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: homeController.listCategories.length,
          itemBuilder: (context, index) {
            return InkWell(
              onTap: () {
                controller.getProducts(
                  thisCategoryId: homeController.listCategories[index]['_id'],
                  newIndex: index,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Obx(
                () => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.only(right: index == 0 ? 16 : 0, left: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 32,
                  decoration: BoxDecoration(
                    color: controller.indexCategory.value == index
                        ? Get.theme.primaryColor
                        : const Color(0xffF9F8F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      homeController.listCategories[index]['name'],
                      style: TextStyle(
                        color: controller.indexCategory.value == index
                            ? Colors.white
                            : const Color(0xff37312F),
                        fontWeight: controller.indexCategory.value == index
                            ? MyFontWeight.bold
                            : MyFontWeight.light,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

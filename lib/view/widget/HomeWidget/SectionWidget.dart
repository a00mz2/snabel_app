// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:customer/controller/HomeController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SectionWidget extends StatelessWidget {
  final controller = Get.find<HomeController>();

  SectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: Obx(
        () => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.listCategories.length,
          itemBuilder: (context, index) => InkWell(
            onTap: () => Get.toNamed(
              '/SectionProducts',
              arguments: {
                'categoryId': controller.listCategories[index]['_id'],
                'name': controller.listCategories[index]['name'],
                'image': controller.listCategories[index]['image'].toString(),
                'sliderImage': controller.listCategories[index]['sliderImage']
                    .toString(),
              },
            ),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              margin: EdgeInsets.only(right: index == 0 ? 16 : 0, left: 10),
              padding: EdgeInsets.symmetric(horizontal: 16),
              height: 32,
              decoration: BoxDecoration(
                color: Color(0xffF9F8F8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  controller.listCategories[index]['name'],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Color(0xff37312F),
                    fontWeight: MyFontWeight.light,
                    fontSize: 12,
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

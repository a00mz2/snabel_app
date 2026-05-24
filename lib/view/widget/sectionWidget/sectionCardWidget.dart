// ignore_for_file: camel_case_types

import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class sectionCardWidget extends StatelessWidget {
  const sectionCardWidget({
    super.key,
    required this.nameSection,
    required this.imageSection,
    required this.idSection,
    required this.sliderImage,
  });

  final String nameSection, imageSection, sliderImage;
  final String idSection;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Get.toNamed(
          '/SectionProducts',
          arguments: {
            'categoryId': idSection,
            'name': nameSection,
            'image': imageSection,
            'sliderImage': sliderImage,
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 78.25,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xffF9F8F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: AppNetworkImage(
                imageUrl: Applink.categoryImage(imageSection),
                fit: BoxFit.contain,
                width: 48,
                height: 48,
                compact: true,
              ),
            ),
          ),
          Text(
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            textAlign: TextAlign.center,
            nameSection,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff231F1E),
              fontWeight: MyFontWeight.light,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

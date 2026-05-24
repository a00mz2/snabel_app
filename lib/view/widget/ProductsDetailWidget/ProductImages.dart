// ignore_for_file: prefer_interpolation_to_compose_strings, deprecated_member_use

import 'package:customer/controller/ProductsDetailController.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductImages extends StatelessWidget {
  final controller = Get.find<ProductsDetailController>();

  ProductImages({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(0xffF1F1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Obx(
            () => AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: SizedBox(
                key: ValueKey(controller.selectedImageIndex.value),
                width: double.infinity,
                child: AppNetworkImage(
                  imageUrl: Applink.productImage(
                    controller.images[controller.selectedImageIndex.value]['name']
                        ?.toString(),
                  ),
                  height: 220,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          SizedBox(height: 10),
          Container(
            padding: EdgeInsets.all(8),
            height: 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),

            child: ListView.builder(
              itemCount: controller.images.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () => controller.onImageChanged(index),
                child: Obx(
                  () => Container(
                    margin: EdgeInsets.only(left: 8),
                    width: 52.6,
                    height: 56,
                    decoration: BoxDecoration(
                      border: index != controller.selectedImageIndex.value
                          ? null
                          : Border.all(color: Theme.of(context).primaryColor),
                      color: Color(0xffF1F1F1),
                      borderRadius: BorderRadius.circular(8),
                    ),

                    child: AppNetworkImage(
                      imageUrl: Applink.productImage(
                        controller.images[index]['name']?.toString(),
                      ),
                      fit: BoxFit.cover,
                      width: 52.6,
                      height: 56,
                      compact: true,
                    ),
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

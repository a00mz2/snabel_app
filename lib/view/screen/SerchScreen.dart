// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:customer/controller/SearchController.dart';
import 'package:customer/core/constant/assets/lottie.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/ProductGridWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/view/widget/widgetApp/textBox.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/instance_manager.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:lottie/lottie.dart';

class SearchingScreen extends StatelessWidget {
  SearchingScreen({super.key});

  final controller = Get.put(SearchingController());

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = 135;
    final double sidePadding = 16;
    final double spacing = 10;
    final int crossAxisCount =
        ((screenWidth - 2 * sidePadding + spacing) / (itemWidth + spacing))
            .floor();

    return ScaffoldWidget(
      namePage: "بحث",
      isSub: true,
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      heder: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextBoxs(
              focusNode: controller.focusNode,
              onChanged: (p0) => controller.onSearchChanged(),
              controller: controller.textSearchController,
              hintText: "ابحث بأسم المنتج ...",
              suffixIcon: IconButton(
                onPressed: () => controller.textSearchController.clear(),
                icon: Icon(Icons.close),
              ),
              prefixIcon: Icon(Icons.search),
            ),
          ),
          SizedBox(height: 24),
        ],
      ),

      child: Obx(
        () => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: controller.listProducts.isEmpty
              ? Center(child: Lottie.asset(AppLottie.search))
              : AnimationLimiter(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.listProducts.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisExtent: 226,
                      crossAxisSpacing: spacing,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(seconds: 1),
                        columnCount: crossAxisCount,
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: ProductGridWidget(
                              productId: controller.listProducts[index]['_id'],
                              inFavorites:
                                  controller.listProducts[index]['isFavorite'],
                              index: index,
                              image: Applink.productImage(
                                controller
                                    .listProducts[index]['images'][controller
                                        .listProducts[index]['mainImageIndex']]['name']
                                    ?.toString(),
                              ),
                              available: true,
                              name: controller.listProducts[index]['name'],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

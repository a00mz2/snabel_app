import 'package:customer/controller/SectionsController.dart';
import 'package:customer/view/widget/sectionWidget/sectionCardWidget.dart';
import 'package:customer/view/widget/widgetApp/PaginationIndicator.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class SectionsScreen extends StatelessWidget {
  final SectionsController controller = Get.put(SectionsController());

  SectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double itemWidth = 78.25;
    final double sidePadding = 16;
    final double spacing = 10;
    final int crossAxisCount =
        ((screenWidth - 2 * sidePadding + spacing) / (itemWidth + spacing))
            .floor();

    return ScaffoldWidget(
      onRefresh: () => controller.getSection(),
      horizontalPadding: 16,
      isSub: true,
      namePage: "الاقسام",
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      bottomNavigationBar: Obx(
        () => SizedBox(
          width: Get.width,
          child: PaginationIndicator(
            index: controller.listSection.length - 1,
            listlength: controller.listSection.length,
            statusRequestPagination: controller.statusRequestPagination.value,
          ),
        ),
      ),

      child: AnimationLimiter(
        child: Obx(
          () => Column(
            children: [
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  controller: controller.scrollController,
                  itemCount: controller.listSection.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    mainAxisExtent: 130,
                    crossAxisSpacing: spacing,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(seconds: 1),
                      columnCount: crossAxisCount,
                      child: FadeInAnimation(
                        child: FadeInAnimation(
                          child: sectionCardWidget(
                            sliderImage: controller
                                .listSection[index]['sliderImage']
                                .toString(),
                            idSection: controller.listSection[index]['_id'],
                            nameSection: controller.listSection[index]['name'],
                            imageSection:
                                controller.listSection[index]['image'],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:carousel_slider/carousel_slider.dart';
import 'package:customer/controller/HomeController.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SliderWidget extends StatelessWidget {
  final controller = Get.find<HomeController>();

  SliderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        if (controller.listSliders.isEmpty) {
          return const SizedBox.shrink();
        }
        return Column(
        children: [
          CarouselSlider.builder(
            carouselController: controller.slidercontroller,
            itemCount: controller.listSliders.length,
            itemBuilder: (context, index, realIndex) => LayoutBuilder(
              builder: (context, constraints) {
                double width = constraints.maxWidth;
                double height = (width) * 168 / 343;

                final slide = controller.listSliders[index];
                final slideMap = slide is Map ? Map<String, dynamic>.from(slide) : null;
                final t = slideMap == null
                    ? 'none'
                    : (slideMap['type'] ?? 'none').toString().trim();
                final tid = slideMap == null
                    ? null
                    : HomeController.sliderTargetIdString(slideMap['targetId']);
                final canNavigate =
                    t != 'none' && tid != null && tid.isNotEmpty;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: canNavigate
                            ? () => controller.openSliderAt(index)
                            : null,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: SizedBox(
                            width: width,
                            height: height,
                            child: AppNetworkImage(
                              imageUrl: Applink.sliderImage(
                                slideMap?['image']?.toString(),
                              ),
                              fit: BoxFit.fill,
                              width: width,
                              height: height,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            options: CarouselOptions(
              viewportFraction: 1,
              padEnds: false,
              autoPlay: true,
              autoPlayInterval: const Duration(seconds: 5),
              pageSnapping: true,
              height: null,
              onPageChanged: (index, reason) {
                controller.sliderCurrent.value = index; // ✅ تحديث المؤشر هنا
              },
            ),
          ),

          // 🔘 مؤشرات أسفل السلايدر
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: controller.listSliders.asMap().entries.map((entry) {
              return GestureDetector(
                onTap: () =>
                    controller.slidercontroller.animateToPage(entry.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: controller.sliderCurrent.value == entry.key
                      ? 18.0
                      : 12.0,
                  height: 4.0,
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: controller.sliderCurrent.value == entry.key
                        ? Theme.of(context).primaryColorDark
                        : Color(0xffD0CAC8),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
      },
    );
  }
}

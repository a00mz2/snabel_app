// ignore_for_file: must_be_immutable, invalid_use_of_protected_member, prefer_interpolation_to_compose_strings

import 'package:customer/controller/HomeController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/HomeWidget/SectionWidget.dart';
import 'package:customer/view/widget/HomeWidget/SliderWidget.dart';
import 'package:customer/view/widget/HomeWidget/WaltCardWidget.dart';
import 'package:customer/view/widget/widgetApp/ProductWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/view/widget/widgetApp/TitleBarWedget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      horizontalPadding: 0,
      onRefresh: () => controller.getDataHome(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      child: AnimationLimiter(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          children: AnimationConfiguration.toStaggeredList(
            duration: const Duration(milliseconds: 600),
            childAnimationBuilder: (widget) =>
                ScaleAnimation(child: ScaleAnimation(child: widget)),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Obx(
                  () => WaltCardWidget(
                    onTap: () async {
                      Get.offAllNamed('/MainScreen', arguments: {'current': 2});
                    },
                    balance: num.parse(
                      controller.walletData['balance'].toString(),
                    ),
                  ),
                ),
              ),
              Obx(
                () => controller.listSliders.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SliderWidget(),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
              TitleBarWedget(
                lable: "الاقسام",
                onPressed: () => Get.toNamed("/Sections"),
              ),
              const SizedBox(height: 10),
              SectionWidget(),
              const SizedBox(height: 16),
              Obx(
                () => controller.listTopProducts.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TitleBarWedget(
                            lable: "المنتجات الاكثر طلباً",
                            onPressed: () => Get.toNamed(
                              '/SectionProducts',
                              arguments: {
                                'categoryId': "",
                                'name': "المنتجات الاكثر طلباً",
                                'image': "",
                                "isMostRequested": true,
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 226,
                            child: ListView.builder(
                              itemCount: controller.listTopProducts.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => ProductWidget(
                                productId: controller
                                    .listTopProducts[index]['_id'],
                                inFavorites: controller
                                    .listTopProducts[index]['inFavorites'],
                                index: index,
                                image: Applink.productImage(
                                  controller.listTopProducts[index]['images']
                                          [controller.listTopProducts[index]
                                              ['mainImageIndex']]['name']
                                      ?.toString(),
                                ),
                                available: true,
                                name: controller.listTopProducts[index]
                                    ['name'],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),
              Obx(
                () => controller.listallProducts.isEmpty
                    ? const SizedBox.shrink()
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TitleBarWedget(
                            lable: "المنتجات",
                            onPressed: () => Get.toNamed(
                              '/SectionProducts',
                              arguments: {
                                'name': "جميع المنتجات",
                                'image': "",
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 226,
                            child: ListView.builder(
                              itemCount: controller.listallProducts.length,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) => ProductWidget(
                                productId: controller
                                    .listallProducts[index]['_id'],
                                inFavorites: controller
                                    .listallProducts[index]['inFavorites'],
                                index: index,
                                image: Applink.productImage(
                                  controller.listallProducts[index]['images']
                                          [controller.listallProducts[index]
                                              ['mainImageIndex']]['name']
                                      ?.toString(),
                                ),
                                available: true,
                                name: controller.listallProducts[index]
                                    ['name'],
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                width: double.infinity,
                color: Theme.of(context).primaryColorDark,
                child: Column(
                  children: [
                    Text(
                      "نحن لا نخبز فقط؛ بل نرتقي بكل قضمة. وإليك ما يميزنا",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xffFFFFFF),
                        fontSize: 16,
                        fontWeight: MyFontWeight.regular,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              Image.asset(
                                AppIcons.fact1,
                                width: 40,
                                height: 40,
                              ),
                              SizedBox(height: 5),
                              Text(
                                textAlign: TextAlign.center,
                                "ثقة وجودة",
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      color: const Color(0xffFFFFFF),
                                      fontSize: 16,
                                      fontWeight: MyFontWeight.regular,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 2,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Image.asset(
                                AppIcons.fact2,
                                width: 40,
                                height: 40,
                              ),
                              SizedBox(height: 5),

                              Text(
                                "وصفات خاصة",
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      color: const Color(0xffFFFFFF),
                                      fontSize: 16,
                                      fontWeight: MyFontWeight.regular,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            children: [
                              Image.asset(
                                AppIcons.fact3,
                                width: 40,
                                height: 40,
                              ),
                              SizedBox(height: 5),

                              Text(
                                "وصفات خاصة",
                                style: Theme.of(context).textTheme.titleLarge!
                                    .copyWith(
                                      color: const Color(0xffFFFFFF),
                                      fontSize: 16,
                                      fontWeight: MyFontWeight.regular,
                                    ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

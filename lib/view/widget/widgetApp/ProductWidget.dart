// ignore_for_file: deprecated_member_use

import 'package:customer/controller/HomeController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProductWidget extends StatelessWidget {
  ProductWidget({
    super.key,
    required this.index,
    required this.image,
    required this.name,
    required this.available,
    required this.inFavorites,
    required this.productId,
  });
  final int index;
  final String image, name, productId;
  final bool available;
  final bool inFavorites;

  final controller = Get.find<HomeController>();

  @override
  Widget build(BuildContext context) {
    RxBool favorites = inFavorites.obs;
    return Container(
      margin: EdgeInsets.only(right: index == 0 ? 16 : 10),
      padding: EdgeInsets.all(8),
      width: 146,
      height: 226,
      decoration: BoxDecoration(
        color: const Color(0xffF9F8F8),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            children: [
              Container(
                width: double.infinity,
                height: 146,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AppNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Obx(
                () => Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      favorites.value = !favorites.value;
                      controller.toggleFavorite(productId, favorites.value);
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            AppIcons.Vector,
                            color: favorites.value
                                ? Colors.orange
                                : Color(0xffD0CAC8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: const Color(0xff0E0C0C),
                    fontSize: 14,
                    fontWeight: MyFontWeight.light,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                available ? "متوفر" : "غير متوفر",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: available ? const Color(0xff12B76A) : Colors.red,
                  fontSize: 10,
                  fontWeight: MyFontWeight.light,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          InkWell(
            onTap: () {
              Get.toNamed(
                '/ProductsDetailSecrren',
                arguments: {'productId': productId},
              );
              print({'productId': productId});
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColorDark,
                borderRadius: BorderRadius.circular(32),
              ),
              width: double.infinity,
              height: 32,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      width: 16,
                      height: 16,
                      AppIcons.leadingicon,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    "عرض التفاصيل",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: MyFontWeight.light,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

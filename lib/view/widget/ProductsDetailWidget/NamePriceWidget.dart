import 'package:customer/controller/ProductsDetailController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/view/widget/widgetApp/RatingStars.dart';
import 'package:customer/view/widget/widgetApp/SpecialPriceBadge.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NamePriceWidget extends StatelessWidget {
  final controller = Get.find<ProductsDetailController>();

  NamePriceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  controller.dataProduct['name'],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 18,
                    fontWeight: MyFontWeight.regular,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                const SizedBox(height: 6),
                RatingSummaryRow(
                  rating: parseRating(controller.dataProduct),
                ),
              ],
            ),
          ),
          SizedBox(width: 100),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Obx(
                    () => Text(
                      '(${formatNumberNum(controller.count.value * (controller.packings.isEmpty ? 1 : (controller.packings[controller.selectedPackingIndex.value]['quantity'])))} قطعة)',
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontSize: 12,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  Text(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    "${controller.packings.isEmpty ? formatNumber(controller.dataProduct['price'] * controller.count.value) : formatNumber((controller.dataProduct['price'] * controller.packings[controller.selectedPackingIndex.value]['quantity']) * controller.count.value)}  د.ع",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 16,
                      fontWeight: MyFontWeight.semiBold,
                      color: Theme.of(context).primaryColorDark,
                    ),
                  ),
                ],
              ),
              // شارة «سعر خاص» تحت السعر (بلا سعر مشطوب) عندما يرسلها الخادم لهذا الزبون
              if (hasSpecialPrice(controller.dataProduct)) ...[
                const SizedBox(height: 4),
                const SpecialPriceBadge(),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

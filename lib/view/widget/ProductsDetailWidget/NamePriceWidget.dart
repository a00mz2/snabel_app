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

  static num _asNum(dynamic v) =>
      v is num ? v : num.tryParse('${v ?? ''}') ?? 0;

  @override
  Widget build(BuildContext context) {
    // كل قراءات Rx تتم هنا داخل جسم Obx مباشرة. القراءة داخل ودجت ابن لا تسجّل
    // اشتراكاً فيتجمّد السطر بصمت — كان هنا Obx متداخل يقرأ `count` وحده.
    return Obx(() {
      final packQty = controller.packings.isEmpty
          ? 1
          : _asNum(
              controller.packings[controller.selectedPackingIndex.value]['quantity'],
            );
      final count = controller.count.value;
      final price = _asNum(controller.dataProduct['price']);

      return ProductNamePriceLayout(
        name: '${controller.dataProduct['name'] ?? ''}',
        rating: parseRating(controller.dataProduct),
        piecesLabel: '(${formatNumberNum(count * packQty)} قطعة)',
        priceLabel: '${formatNumber(price * packQty * count)}  د.ع',
        showSpecialBadge: hasSpecialPrice(controller.dataProduct),
      );
    });
  }
}

/// سطر «الاسم + التقييم» مقابل «عدد القطع + السعر» في صفحة تفاصيل المنتج.
///
/// مفصول عن المتحكّم ليُختبر بلا GetX ولا شبكة، فالعطل الذي أنتجه تخطيط بحت:
/// فاصل ثابت `SizedBox(width: 100)` كان يبتلع عرض عمود الاسم، وعمود السعر بلا
/// حدّ أعلى فيأخذ عرضه الطبيعي كاملاً — فتجاوز صفّ التقييم بـ٢٣ بكسل.
///
/// القاعدة الآن: عمود السعر مسقوف بـ45% من الصفّ ويُقلَّص إن تجاوزها (السعر صار
/// يقبل الكسور فقد يطول)، وما تبقّى كلّه لعمود الاسم لا حصّة ثابتة منه.
class ProductNamePriceLayout extends StatelessWidget {
  const ProductNamePriceLayout({
    super.key,
    required this.name,
    required this.piecesLabel,
    required this.priceLabel,
    this.rating,
    this.showSpecialBadge = false,
  });

  final String name;
  final String piecesLabel;
  final String priceLabel;
  final RatingSummary? rating;
  final bool showSpecialBadge;

  /// أقصى ما يأخذه عمود السعر من عرض الصفّ.
  static const double priceShare = 0.45;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 18,
                    fontWeight: MyFontWeight.regular,
                    color: theme.primaryColorDark,
                  ),
                ),
                const SizedBox(height: 6),
                RatingSummaryRow(rating: rating),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: constraints.maxWidth * priceShare,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        piecesLabel,
                        style: theme.textTheme.titleLarge!.copyWith(
                          color: theme.primaryColor,
                          fontSize: 12,
                          fontWeight: MyFontWeight.semiBold,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        priceLabel,
                        maxLines: 1,
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: 16,
                          fontWeight: MyFontWeight.semiBold,
                          color: theme.primaryColorDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // شارة «سعر خاص» تحت السعر (بلا سعر مشطوب) عندما يرسلها الخادم
                if (showSpecialBadge) ...[
                  const SizedBox(height: 4),
                  const SpecialPriceBadge(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

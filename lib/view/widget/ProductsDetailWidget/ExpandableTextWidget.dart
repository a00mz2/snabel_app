import 'package:customer/controller/ProductsDetailController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpandableTextWidget extends StatelessWidget {
  final String text;
  final int trimLines;
  final controller = Get.find<ProductsDetailController>();

  ExpandableTextWidget({super.key, required this.text, this.trimLines = 3});

  @override
  Widget build(BuildContext context) {
    final textStyle = TextStyle(
      fontSize: 14,
      color: Color(0xff6E615E),
      fontWeight: MyFontWeight.light,
    );

    return Obx(() {
      final isExpanded = controller.isExpanded.value;

      return LayoutBuilder(
        builder: (context, constraints) {
          // استخدم TextPainter لحساب طول النص وهل يحتاج "عرض المزيد"
          final span = TextSpan(text: text, style: textStyle);
          final tp = TextPainter(
            text: span,
            maxLines: trimLines,
            textDirection: TextDirection.rtl,
          )..layout(maxWidth: constraints.maxWidth);

          final isOverflow = tp.didExceedMaxLines;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                text,
                style: textStyle,
                maxLines: isExpanded ? null : trimLines,
                overflow: isExpanded
                    ? TextOverflow.visible
                    : TextOverflow.ellipsis,
                textDirection: TextDirection.rtl,
              ),
              if (isOverflow)
                GestureDetector(
                  onTap: controller.toggle,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      isExpanded ? "عرض أقل" : "عرض المزيد",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xFF231F1E),
                        fontWeight: MyFontWeight.medium,
                        fontSize: 14,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                  ),
                ),
            ],
          );
        },
      );
    });
  }
}

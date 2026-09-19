import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/linkApi.dart';
import 'package:flutter/material.dart';

import '../core/constant/assets/icons.dart';
import '../core/functions/formatNumber.dart';

/// بند من بنود الطلب في تفاصيل الطلب (سائق).
/// في وضع التعديل ([editing]) تظهر أزرار «−» / «+» / حذف عبر الاستدعاءات الاختيارية.
class OrderProductWidget extends StatelessWidget {
  final int index;

  final dataOrder;
  final int length;

  final bool editing;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;
  final VoidCallback? onRemove;

  const OrderProductWidget({
    super.key,
    required this.index,
    this.dataOrder,
    required this.length,
    this.editing = false,
    this.onDecrement,
    this.onIncrement,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        border: index == length - 1
            ? null
            : const Border(bottom: BorderSide(color: Color(0xffE7E4E4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xffF9F8F8),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadiusGeometry.circular(5),
                    child: CachedNetworkImage(
                      imageUrl:
                          "${DriverApplink.serverImage}ProductImages/${dataOrder['image']}",
                      width: 52,
                      height: 52,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => SizedBox(),
                      errorWidget: (context, url, error) => Center(
                        child: Image.asset(
                          AppIcons.ordericonnotAc,
                          width: 52,
                          height: 52,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              /// 🔴 العدد فوق الصورة
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "x${dataOrder['quantity']}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 10),

          // 🧾 تفاصيل المنتج (الاسم + السعر)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// 🥖 اسم المنتج + نوع التغليف
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        dataOrder['name']?.toString() ?? '',
                        maxLines: editing ? 1 : 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: const Color(0xff0E0C0C),
                          fontSize: 14,
                          fontWeight: MyFontWeight.light,
                        ),
                      ),
                    ),
                    SizedBox(width: 5),
                    Text(
                      "(${packageName(dataOrder)})",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Text(
                      formatNumber(totalItemPrice(dataOrder)),
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                    Text(
                      "  د.ع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xff231F1E),
                        fontSize: 12,
                        fontWeight: MyFontWeight.light,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (editing) _editControls(context),
        ],
      ),
    );
  }

  /// أزرار التعديل: تقليل (حتى الصفر = حذف) / زيادة (حتى الكمية الأصلية) / حذف.
  Widget _editControls(BuildContext context) {
    const compact = BoxConstraints(minWidth: 32, minHeight: 32);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: onDecrement,
          padding: EdgeInsets.zero,
          constraints: compact,
          iconSize: 22,
          tooltip: 'تقليل',
          icon: const Icon(Icons.remove_circle_outline, color: Color(0xffF39316)),
        ),
        Text(
          "${dataOrder['quantity']}",
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: const Color(0xff231F1E),
            fontSize: 14,
            fontWeight: MyFontWeight.semiBold,
          ),
        ),
        IconButton(
          onPressed: onIncrement,
          padding: EdgeInsets.zero,
          constraints: compact,
          iconSize: 22,
          tooltip: 'زيادة (حتى الكمية الأصلية)',
          icon: const Icon(Icons.add_circle_outline),
        ),
        IconButton(
          onPressed: onRemove,
          padding: EdgeInsets.zero,
          constraints: compact,
          iconSize: 22,
          tooltip: 'حذف الصنف',
          icon: const Icon(Icons.delete_outline, color: Colors.red),
        ),
      ],
    );
  }

  String packageName(dynamic item) {
    final packing = item['packing'];

    if (packing == null) return "";

    if (packing is String) {
      return packing; // packing نفسه اسم التغليف
    }
    if (packing is Map) {
      final label = packing['label'];
      return label is String ? label : "";
    }
    return "";
  }

  int totalItemPrice(dynamic item) {
    final price = item['price'];
    final qty = item['quantity'];

    if (price is! num || qty is! num) return 0;

    final packing = item['packing'];
    int packingQty = 1;

    if (packing is Map && packing['quantity'] is num) {
      packingQty = (packing['quantity'] as num).toInt();
    }
    return (price * (packingQty * qty)).toInt();
  }
}

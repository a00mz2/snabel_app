import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/linkApi.dart';
import 'package:flutter/material.dart';

import '../core/constant/assets/icons.dart';
import '../core/functions/formatNumber.dart';

class OrderProductWidget extends StatelessWidget {
  final int index;

  final dataOrder;
  final int length;

  const OrderProductWidget({
    super.key,
    required this.index,
    this.dataOrder,
    required this.length,
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
                    Text(
                      dataOrder['name'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xff0E0C0C),
                        fontSize: 14,
                        fontWeight: MyFontWeight.light,
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
        ],
      ),
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

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/core/functions/statusColors.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';

class OrderItemWidget extends StatelessWidget {
  final VoidCallback? onTap;

  final List productImages; // روابط صور المنتجات (2–3 صور)
  final String orderTitle; // "طلب رقم #5234"
  final String orderDate; // "2025 يوليو، 23"
  final int orderPrice; // "128.000 د.ع"
  final String status; // لون الدائرة في اليمين
  final int index;
  const OrderItemWidget({
    super.key,
    this.onTap,
    this.productImages = const [],
    this.orderTitle = '',
    this.orderDate = '',
    this.orderPrice = 0,

    required this.index,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffF3F2F1))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 242, 239, 239),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(AppIcons.order, width: 24, height: 24),
                  ),
                ),

                Positioned(bottom: 0, left: 0, child: statusOrderIcon(status)),
              ],
            ),
            SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "طلب رقم # $orderTitle",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontSize: 14,
                      fontWeight: MyFontWeight.regular,
                      color: Color(0xff292929),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "${formatNumber(orderPrice)} د.ع",
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 13,
                          fontWeight: MyFontWeight.light,
                          color: Color(0xff7C7C7C),
                        ),
                      ),
                      SizedBox(width: 4),
                      Image.asset(AppIcons.calendar, width: 15, height: 15),
                      SizedBox(width: 4),
                      Text(
                        formatDate(orderDate),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 12,
                          fontWeight: MyFontWeight.light,
                          color: Color(0xff7C7C7C),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _OverlappedThumbs(imageUrls: productImages),
          ],
        ),
      ),
    );
  }
}

class _OverlappedThumbs extends StatelessWidget {
  final List imageUrls;
  const _OverlappedThumbs({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    // نعرض حتى 3 صور كحد أقصى
    final imgs = imageUrls.take(3).toList();

    return SizedBox(
      width: 74, // عرض يكفي للتداخل
      height: 24,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(imgs.length, (i) {
          final left = (imgs.length - 1 - i) * 22.0; // تداخل لطيف
          return Positioned(
            left: left,
            top: 0,
            child: _thumb(Applink.productImage(imgs[i]['image']?.toString())),
          );
        }),
      ),
    );
  }

  Widget _thumb(String url) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xffF9F8F8),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFEDEDED)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: url,
          fit: BoxFit.cover,
          width: 24,
          height: 24,
          compact: true,
        ),
      ),
    );
  }
}

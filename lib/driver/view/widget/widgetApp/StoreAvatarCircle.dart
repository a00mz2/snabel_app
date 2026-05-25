import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/driver/core/functions/resolveServerImageUrl.dart';
import 'package:flutter/material.dart';

/// صورة المتجر الدائرية في قوائم الطلبات؛ عند غياب الرابط أو فشل التحميل تُعرض أيقونة متجر.
class StoreAvatarCircle extends StatelessWidget {
  const StoreAvatarCircle({
    super.key,
    required this.customers,
    this.size = 40,
  });

  final dynamic customers;
  final double size;

  @override
  Widget build(BuildContext context) {
    final raw = customers is Map ? customers['storeImage'] : null;
    final url = resolveServerImageUrl(raw);
    final dim = size.round();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: url.isEmpty
            ? _fallback()
            : CachedNetworkImage(
                imageUrl: url,
                fit: BoxFit.cover,
                memCacheWidth: dim * 2,
                memCacheHeight: dim * 2,
                placeholder: (_, __) => _loading(),
                errorWidget: (_, __, ___) => _fallback(),
              ),
      ),
    );
  }

  Widget _loading() => Center(
        child: SizedBox(
          width: size * 0.35,
          height: size * 0.35,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xffA19491),
          ),
        ),
      );

  Widget _fallback() => ColoredBox(
        color: Colors.grey.shade200,
        child: Icon(
          Icons.storefront_outlined,
          size: size * 0.48,
          color: Color(0xffA19491),
        ),
      );
}

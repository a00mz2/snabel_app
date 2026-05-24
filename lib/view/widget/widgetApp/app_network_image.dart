// ignore_for_file: file_names

import 'package:flutter/material.dart';

/// بديل عند رابط فارغ أو فشل تحميل الصورة.
class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({
    super.key,
    this.width,
    this.height,
    this.compact = false,
  });

  final double? width;
  final double? height;

  /// أيقونة فقط بدون نص (مناسب للمصغرات).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final iconSize = compact ? 18.0 : 36.0;
    return Container(
      width: width,
      height: height,
      color: const Color(0xffEDEDED),
      alignment: Alignment.center,
      child: compact
          ? Icon(
              Icons.image_not_supported_outlined,
              size: iconSize,
              color: Colors.grey.shade500,
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported_outlined,
                    size: iconSize,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'لا توجد صورة',
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

/// صورة من الشبكة مع بديل عند الرابط الفارغ أو المسار الخاطئ.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.compact,
  });

  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  /// إن لم يُحدَّد: يُستنتج من الحجم (أبعاد أصغر من 64).
  final bool? compact;

  bool _effectiveCompact() {
    if (compact != null) return compact!;
    final w = width;
    final h = height;
    if (w != null && h != null) return w < 64 && h < 64;
    if (w != null) return w < 64;
    if (h != null) return h < 64;
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final u = imageUrl.trim();
    final ph = ImagePlaceholder(
      width: width,
      height: height,
      compact: _effectiveCompact(),
    );
    if (u.isEmpty) {
      return ph;
    }
    return Image.network(
      u,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (_, __, ___) => ph,
    );
  }
}

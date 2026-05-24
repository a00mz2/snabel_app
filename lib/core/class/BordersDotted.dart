// ignore_for_file: file_names

import 'dart:ui';

import 'package:flutter/material.dart';

class BordersDotted extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xffEFEFEF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final double dashWidth = 6;
    final double dashSpace = 4;
    final radius = Radius.circular(16);

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      radius,
    );

    final Path path = Path()..addRRect(rRect);

    final PathMetrics metrics = path.computeMetrics();
    for (final PathMetric metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final double next = distance + dashWidth;
        final Path extractPath = metric.extractPath(
          distance,
          next.clamp(0.0, metric.length),
        );
        canvas.drawPath(extractPath, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

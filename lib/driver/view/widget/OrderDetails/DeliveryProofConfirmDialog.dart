import 'dart:typed_data';

import 'package:flutter/material.dart';

/// معاينة صورة تأكيد التسليم قبل إرسالها.
/// يعيد `true` للإرسال، `false` لإعادة الالتقاط، `null` عند الإلغاء.
Future<bool?> showDeliveryProofConfirmDialog(
  BuildContext context,
  Uint8List bytes,
) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      title: const Text('تأكيد صورة التسليم'),
      content: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          bytes,
          height: 280,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('إعادة الالتقاط'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('إرسال التأكيد'),
        ),
      ],
    ),
  );
}

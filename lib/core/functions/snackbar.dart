// ignore_for_file: deprecated_member_use

import 'package:customer/core/functions/app_scaffold_messenger.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum ContentType { success, failure, warning, help }

class AppSnackBar {
  static OverlayEntry? _activeEntry;

  /// يفضّل [Navigator.overlay] الجذر لأن سياق GetX أحياناً يكون تحت [_Theater] ولا يجد [Overlay].
  static OverlayState? _resolveOverlayState() {
    final navState = Get.key.currentState;
    if (navState is NavigatorState) {
      final o = navState.overlay;
      if (o != null) return o;
    }
    final ctx =
        appScaffoldMessengerKey.currentContext ?? Get.context ?? Get.key.currentContext;
    if (ctx == null) return null;
    final rootNav = Navigator.maybeOf(ctx, rootNavigator: true);
    if (rootNav != null && rootNav.overlay != null) {
      return rootNav.overlay;
    }
    return Overlay.maybeOf(ctx, rootOverlay: true);
  }

  static void _show({
    required String message,
    required ContentType type,
  }) {
    if (message.trim().isEmpty) return;

    Color stripeColor;
    IconData icon;

    switch (type) {
      case ContentType.success:
        stripeColor = Colors.green;
        icon = Icons.check_circle;
        break;
      case ContentType.failure:
        stripeColor = Colors.redAccent;
        icon = Icons.error;
        break;
      case ContentType.warning:
        stripeColor = Colors.orangeAccent;
        icon = Icons.warning;
        break;
      case ContentType.help:
        stripeColor = Colors.blueAccent;
        icon = Icons.info;
        break;
    }

    final content = Row(
      textDirection: TextDirection.rtl,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 5,
          height: 40,
          decoration: BoxDecoration(
            color: stripeColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: stripeColor, size: 22),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            message,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
        ),
      ],
    );

    void insertInto(OverlayState overlay) {
      _activeEntry?.remove();
      _activeEntry = null;

      late OverlayEntry entry;
      entry = OverlayEntry(
        builder: (context) => Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 10,
          right: 10,
          child: Material(
            color: Colors.transparent,
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.50),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: content,
            ),
          ),
        ),
      );

      _activeEntry = entry;
      overlay.insert(entry);

      Future.delayed(const Duration(seconds: 3), () {
        if (_activeEntry == entry) {
          entry.remove();
          _activeEntry = null;
        }
      });
    }

    void tryShow(int remainingFrames) {
      final overlay = _resolveOverlayState();
      if (overlay != null) {
        insertInto(overlay);
        return;
      }
      if (remainingFrames <= 0) {
        _fallbackScaffoldMessenger(message, stripeColor, icon);
        return;
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        tryShow(remainingFrames - 1);
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) => tryShow(4));
  }

  /// بدون [Overlay] — لا يستخدم Get.snackbar (نفس مشكلة عدم وجود Overlay).
  static void _fallbackScaffoldMessenger(
    String message,
    Color stripeColor,
    IconData icon,
  ) {
    final messenger = appScaffoldMessengerKey.currentState;
    final ctx = appScaffoldMessengerKey.currentContext;
    if (messenger == null || ctx == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        elevation: 6,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.black.withOpacity(0.72),
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 3),
        content: Row(
          textDirection: TextDirection.rtl,
          children: [
            Container(
              width: 5,
              height: 40,
              decoration: BoxDecoration(
                color: stripeColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: stripeColor, size: 22),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(String message) {
    _show(message: message, type: ContentType.success);
  }

  static void error(String message) {
    _show(message: message, type: ContentType.failure);
  }

  static void warning(String message) {
    _show(message: message, type: ContentType.warning);
  }

  static void info(String message) {
    _show(message: message, type: ContentType.help);
  }
}

// ignore_for_file: avoid_print

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/handlingData.dart';
import 'package:customer/core/functions/response_map.dart';
import 'package:customer/core/functions/snackbar.dart';
import 'package:customer/model/ContactModel.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsController extends GetxController {
  final ContactModel _model = ContactModel(Get.find());

  final Rx<StatusRequest> statusRequest = StatusRequest.loading.obs;
  final RxInt statusCode = 200.obs;
  final RxList<Map<String, dynamic>> contactMethods =
      <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    statusRequest.value = StatusRequest.loading;
    final res = await _model.getContactMethods();
    statusCode.value = handlingStatusCode(res);

    if (handlingData(res) == StatusRequest.success) {
      final m = tryResponseMap(res);
      if (m != null && m['ok'] == false) {
        contactMethods.clear();
        statusRequest.value = StatusRequest.failure;
        return;
      }
      final raw = m?['contactMethods'];
      final list = <Map<String, dynamic>>[];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) list.add(Map<String, dynamic>.from(e));
        }
      }
      list.sort((a, b) {
        final oa = a['order'];
        final ob = b['order'];
        final na = oa is num ? oa.toInt() : int.tryParse('$oa') ?? 0;
        final nb = ob is num ? ob.toInt() : int.tryParse('$ob') ?? 0;
        return na.compareTo(nb);
      });
      contactMethods.assignAll(list);
    }

    statusRequest.value = handlingData(res);
  }

  bool get _isAndroid =>
      !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  /// فتح الرابط: [url_launcher] أولاً، ثم على أندرويد [AndroidIntent] عند فشل قناة Pigeon (مثلاً MIUI).
  Future<void> _openUri(Uri uri) async {
    try {
      final ok = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (ok) return;
      if (_isAndroid) {
        await _launchAndroidViewFallback(uri);
        return;
      }
      AppSnackBar.warning('تعذر فتح الرابط على هذا الجهاز');
      return;
    } on PlatformException catch (e) {
      print('url_launcher: $e');
      if (_isAndroid) {
        await _launchAndroidViewFallback(uri);
        return;
      }
      AppSnackBar.warning('تعذر فتح الرابط');
      return;
    } catch (e) {
      print('url_launcher: $e');
      if (_isAndroid) {
        await _launchAndroidViewFallback(uri);
        return;
      }
      AppSnackBar.warning('تعذر فتح الرابط');
      return;
    }
  }

  Future<void> _launchAndroidViewFallback(Uri uri) async {
    final s = uri.toString();
    try {
      await AndroidIntent(
        action: 'android.intent.action.VIEW',
        data: s,
        flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
      ).launch();
    } catch (e) {
      print('AndroidIntent VIEW: $e');
      try {
        await AndroidIntent.parseAndLaunch(s);
      } catch (e2) {
        print('parseAndLaunch: $e2');
        rethrow;
      }
    }
  }

  static String _digitsOnly(String s) =>
      s.replaceAll(RegExp(r'\D'), '');

  static bool _looksLikeUrl(String v) {
    final s = v.toLowerCase().trim();
    return s.startsWith('http://') ||
        s.startsWith('https://') ||
        s.startsWith('tel:') ||
        s.startsWith('mailto:');
  }

  /// يبني رابط المنصة من [platformKey] و [value] دون الاعتماد على النسخ.
  Uri? _uriForPlatform(String key, String value) {
    final v = value.trim();
    if (v.isEmpty) return null;

    switch (key) {
      case 'phone':
      case 'mobile':
      case 'tel':
        final cleaned = v.replaceAll(RegExp(r'\s'), '');
        if (cleaned.isEmpty) return null;
        return Uri.parse('tel:$cleaned');

      case 'whatsapp':
      case 'whats_app':
        if (_looksLikeUrl(v)) return Uri.tryParse(v);
        final d = _digitsOnly(v);
        if (d.isEmpty) return null;
        return Uri.parse('https://wa.me/$d');

      case 'email':
      case 'mail':
        final addr =
            v.replaceFirst(RegExp(r'^mailto:', caseSensitive: false), '').trim();
        if (addr.isEmpty) return null;
        return Uri.parse('mailto:$addr');

      case 'telegram':
      case 'tg':
        if (v.toLowerCase().startsWith('http')) return Uri.tryParse(v);
        final u = v.replaceFirst(RegExp(r'^@'), '').trim();
        if (u.isEmpty) return null;
        return Uri.parse('https://t.me/$u');

      case 'sms':
        final d = _digitsOnly(v);
        if (d.isEmpty) return null;
        return Uri(scheme: 'sms', path: d);

      case 'instagram':
        if (_looksLikeUrl(v)) return Uri.tryParse(v);
        final u = v.replaceFirst(RegExp(r'^@'), '').trim();
        if (u.isEmpty) return null;
        return Uri.parse('https://www.instagram.com/$u/');

      case 'facebook':
      case 'fb':
        if (_looksLikeUrl(v)) return Uri.tryParse(v);
        final path = v.replaceFirst(RegExp(r'^@'), '').trim();
        if (path.isEmpty) return null;
        return Uri.parse('https://www.facebook.com/$path');

      case 'twitter':
        if (_looksLikeUrl(v)) return Uri.tryParse(v);
        final h = v.replaceFirst(RegExp(r'^@'), '').trim();
        if (h.isEmpty) return null;
        return Uri.parse('https://twitter.com/$h');

      case 'x':
        if (_looksLikeUrl(v)) return Uri.tryParse(v);
        final h = v.replaceFirst(RegExp(r'^@'), '').trim();
        if (h.isEmpty) return null;
        return Uri.parse('https://x.com/$h');

      case 'youtube':
      case 'yt':
        if (_looksLikeUrl(v)) return Uri.tryParse(v);
        final p = v.trim();
        if (p.isEmpty) return null;
        return Uri.parse('https://www.youtube.com/$p');

      case 'website':
      case 'web':
      case 'link':
      case 'url':
        if (_looksLikeUrl(v)) return Uri.tryParse(v);
        if (v.contains('.') && !v.contains(' ')) {
          return Uri.parse('https://$v');
        }
        return Uri.tryParse(v);

      default:
        if (_looksLikeUrl(v)) return Uri.tryParse(v);
        if (v.contains('.') && !v.contains(' ') && !v.contains('@')) {
          return Uri.parse('https://$v');
        }
        return null;
    }
  }

  Future<void> openMethod(Map<String, dynamic> row) async {
    final value = (row['value'] ?? '').toString().trim();
    if (value.isEmpty) {
      AppSnackBar.warning('لا يوجد رقم أو رابط لهذه الوسيلة');
      return;
    }

    final key = (row['platformKey'] ?? '').toString().toLowerCase().trim();
    final uri = _uriForPlatform(key, value);

    if (uri == null) {
      AppSnackBar.warning('تعذر فتح هذه الوسيلة');
      return;
    }

    try {
      await _openUri(uri);
    } catch (e) {
      print('openMethod: $e');
      AppSnackBar.warning('تعذر فتح الرابط');
    }
  }

  IconData iconForKey(String? platformKey) {
    final k = (platformKey ?? '').toLowerCase();
    switch (k) {
      case 'phone':
      case 'mobile':
      case 'tel':
        return Icons.phone_rounded;
      case 'whatsapp':
      case 'whats_app':
        return Icons.chat_rounded;
      case 'email':
      case 'mail':
        return Icons.email_outlined;
      case 'telegram':
      case 'tg':
        return Icons.send_rounded;
      case 'instagram':
        return Icons.camera_alt_outlined;
      case 'facebook':
        return Icons.thumb_up_alt_outlined;
      case 'twitter':
      case 'x':
        return Icons.tag_rounded;
      case 'youtube':
        return Icons.play_circle_outline_rounded;
      case 'website':
      case 'web':
      case 'link':
        return Icons.language_rounded;
      case 'sms':
        return Icons.sms_outlined;
      default:
        return Icons.contact_support_outlined;
    }
  }
}

// ignore_for_file: file_names

import 'package:latlong2/latlong.dart';

/// تحليل قيمة `storeLocation` (موقع متجر الزبون) إلى إحداثيات صالحة.
///
/// تدعم جميع الصيغ المعروفة في النظام:
/// 1) `"lat,lng"` نص مباشر (مع/بدون مسافات).
/// 2) URL Google Maps يحوي `destination=lat,lng` في query params
///    (الصيغة المرسلة حالياً من تطبيق الزبون عند التسجيل).
/// 3) URL Google Maps يحوي `q=lat,lng` أو `query=lat,lng`.
/// 4) URL Google Maps يحوي نمط `@lat,lng,zoom`.
/// 5) Geo URI: `geo:lat,lng?q=...`.
///
/// تُعيد [LatLng] عند النجاح أو `null` عند الفشل.
LatLng? parseStoreLocation(String? input) {
  if (input == null) return null;
  final raw = input.trim();
  if (raw.isEmpty) return null;

  // 1) "lat,lng" مباشر — لا يحوي URL scheme.
  if (!raw.contains('://') && raw.contains(',')) {
    final parts = raw.split(',');
    if (parts.length >= 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null && _isValidCoord(lat, lng)) {
        return LatLng(lat, lng);
      }
    }
  }

  // 2) محاولة تحليل كـURL.
  try {
    final uri = Uri.parse(raw);

    for (final key in const ['destination', 'q', 'query']) {
      final value = uri.queryParameters[key];
      if (value != null && value.contains(',')) {
        final parts = value.split(',');
        if (parts.length >= 2) {
          final lat = double.tryParse(parts[0].trim());
          final lng = double.tryParse(parts[1].trim());
          if (lat != null && lng != null && _isValidCoord(lat, lng)) {
            return LatLng(lat, lng);
          }
        }
      }
    }

    if (uri.scheme == 'geo') {
      final pathParts = uri.path.split(',');
      if (pathParts.length >= 2) {
        final lat = double.tryParse(pathParts[0].trim());
        final lng = double.tryParse(pathParts[1].trim());
        if (lat != null && lng != null && _isValidCoord(lat, lng)) {
          return LatLng(lat, lng);
        }
      }
    }
  } catch (_) {
    // متابعة لمحاولة نمط @lat,lng.
  }

  // 3) نمط @lat,lng في الـURL (Google Maps web).
  final atPattern = RegExp(r'@(-?\d+\.?\d*),(-?\d+\.?\d*)');
  final match = atPattern.firstMatch(raw);
  if (match != null) {
    final lat = double.tryParse(match.group(1)!);
    final lng = double.tryParse(match.group(2)!);
    if (lat != null && lng != null && _isValidCoord(lat, lng)) {
      return LatLng(lat, lng);
    }
  }

  return null;
}

/// تنسيق إحداثيات لحفظها بصيغة `"lat,lng"` البسيطة.
String formatStoreLocation(double lat, double lng) {
  return '${lat.toStringAsFixed(6)},${lng.toStringAsFixed(6)}';
}

bool _isValidCoord(double lat, double lng) {
  return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
}

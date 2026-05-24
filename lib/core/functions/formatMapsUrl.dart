// ignore_for_file: file_names, avoid_print

import 'package:latlong2/latlong.dart';

LatLng? formatMapsUrl(String url) {
  try {
    final uri = Uri.parse(url);

    // ✅ الحالة الأولى: destination=lat,lng
    final destination = uri.queryParameters['destination'];
    if (destination != null && destination.contains(',')) {
      final parts = destination.split(',');
      final latitude = double.tryParse(parts[0].trim());
      final longitude = double.tryParse(parts[1].trim());

      if (latitude != null && longitude != null) {
        return LatLng(latitude, longitude);
      }
    }

    // ✅ الحالة الثانية: @lat,lng,zoom
    final regExp = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    final match = regExp.firstMatch(url);
    if (match != null) {
      final latitude = double.tryParse(match.group(1)!);
      final longitude = double.tryParse(match.group(2)!);

      if (latitude != null && longitude != null) {
        return LatLng(latitude, longitude);
      }
    }
  } catch (e) {
    print("Error parsing URL: $e");
  }

  return null;
}

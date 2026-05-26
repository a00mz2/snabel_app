import 'package:customer/core/functions/store_location_parser.dart';
import 'package:url_launcher/url_launcher.dart';

double normalizeCoord(dynamic v) {
  if (v == null) return 0.0;
  final n = (v is num) ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;

  // إذا القيم كبيرة جدًا غالبًا مضروبة
  if (n.abs() > 180) return n / 10000.0; // عدلها إذا عندك /100000
  return n;
}

/// تحليل أي صيغة `storeLocation` (URL Google Maps أو "lat,lng" أو Geo URI …)
/// وإعادة Map بصيغة `{'lat': .., 'lng': ..}` المطلوبة في [openInMapsFromData].
///
/// يستخدم [parseStoreLocation] الموحَّد ليطابق سلوك تطبيق الأدمن.
Map<String, double> parseGoogleMapsDestination(String input) {
  final latLng = parseStoreLocation(input);
  if (latLng == null) return {};
  return {'lat': latLng.latitude, 'lng': latLng.longitude};
}

Future<void> openInMapsFromData(Map location) async {
  final lat = normalizeCoord(location['lat']);
  final lng = normalizeCoord(location['lng']);

  if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
    throw "إحداثيات غير صالحة: ($lat, $lng)";
  }

  // ✅ هذا غالبًا يظهر قائمة تطبيقات الخرائط إذا ماكو افتراضي
  final geo = Uri.parse('geo:$lat,$lng?q=$lat,$lng');

  final ok = await launchUrl(geo, mode: LaunchMode.externalApplication);

  if (!ok) {
    final web = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }
}

openWhatsAppToPhone({
  required String phone, // مثال: 9647712345678
  String? text,          // اختياري
}) async {
  final cleanPhone = phone.replaceAll(RegExp(r'[^0-9]'), '') ; // يشيل + والمسافات

  // ✅ إذا ماكو نص: افتح محادثة فقط
  if (text == null || text.trim().isEmpty) {
    final uri = Uri.parse('whatsapp://send?phone=$cleanPhone');
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);

    if (!ok) {
      final web = Uri.parse('https://wa.me/$cleanPhone');
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
    return;
  }

  // ✅ إذا يوجد نص
  final encoded = Uri.encodeComponent(text);
  final uri = Uri.parse('whatsapp://send?phone=$cleanPhone&text=$encoded');

  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!ok) {
    final web = Uri.parse('https://wa.me/$cleanPhone?text=$encoded');
    await launchUrl(web, mode: LaunchMode.externalApplication);
  }
}
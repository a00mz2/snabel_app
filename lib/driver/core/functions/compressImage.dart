import 'dart:typed_data';
import 'package:image/image.dart' as img;

Future<Uint8List> compressImage(
  Uint8List original, {
  int maxWidth = 800,
}) async {
  // تحويل Uint8List إلى صورة قابلة للمعالجة
  img.Image? image = img.decodeImage(original);
  if (image == null) return original;

  // تغيير حجم الصورة إذا كانت أكبر من maxWidth
  if (image.width > maxWidth) {
    image = img.copyResize(image, width: maxWidth);
  }

  // ضغط الصورة إلى JPEG بجودة محددة
  Uint8List compressed = Uint8List.fromList(img.encodePng(image));

  return compressed;
}

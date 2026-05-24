// ignore_for_file: file_names, deprecated_member_use

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';

// Obx(() => ImageUploadField(
//       imageBytes: controller.imageElmint.value,
//       fileName: controller.fileName.value,
//       onImagePicked: (Uint8List newImage, String name) {
//         controller.imageElmint.value = newImage;
//         controller.fileName.value = name;
//       },
//     )),

//     class UploadController extends GetxController {
//   Rxn<Uint8List> imageElmint = Rxn<Uint8List>();
//   RxString fileName = ''.obs;
// }

class ImageUploadField extends StatelessWidget {
  const ImageUploadField({
    super.key,
    required this.imageBytes,
    required this.onImagePicked,
    required this.fileName,
    this.hintText = "تحميل وثائق الاعتماد...",
    this.prefixIcon,
  });

  final Uint8List? imageBytes;
  final String fileName;
  final Function(Uint8List, String) onImagePicked;
  final String hintText;
  final Widget? prefixIcon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(32),
      onTap: () async {
        final ImagePicker picker = ImagePicker();
        final XFile? picked = await picker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 80,
        );
        if (picked != null) {
          final bytes = await picked.readAsBytes();
          onImagePicked(bytes, picked.name);
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 241, 241, 241),
          borderRadius: BorderRadius.circular(32),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          children: [
            prefixIcon ??
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(AppIcons.docx, width: 22, height: 22),
                ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName.isEmpty ? hintText : fileName,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  fontSize: 16,
                  color: const Color(0xFF7C7C7C),
                  fontFamily: "Hanimation Arabic",
                  fontWeight: MyFontWeight.light,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Image.asset(
              AppIcons.addDocx,
              width: 22,
              height: 22,
              color: const Color(0xFF7C7C7C),
            ),
          ],
        ),
      ),
    );
  }
}

// ignore_for_file: avoid_print, unnecessary_null_comparison, must_be_immutable, file_names

//in controller
// Rxn<File> imageElmint = Rxn<File>();

//in view

// image: controller.imageElmint.value,
// onImagePicked: (File newImage) {
// controller.imageElmint.value = newImage;  // update observable
// },

import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class ImageInput extends StatelessWidget {
  const ImageInput({
    super.key,
    required this.image,
    required this.onImagePicked,
    this.height,
    this.pathImage,
  });

  final Uint8List? image;
  final void Function(Uint8List) onImagePicked;
  final double? height;
  final String? pathImage;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final XFile? images = await ImagePicker().pickImage(
          source: ImageSource.gallery,
        );

        if (images != null) {
          final bytes = await images.readAsBytes();
          onImagePicked(bytes);
        }
      },
      child: Center(
        child: SizedBox(
          width: 92,
          height: 108,
          child: Stack(
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: Theme.of(context).primaryColorDark,
                  ),
                ),
                child: image != null
                    ? Container(
                        width: 92,
                        height: 92,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: MemoryImage(image!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(50000),

                        child: AppNetworkImage(
                          imageUrl: pathImage ?? '',
                          fit: BoxFit.cover,
                          width: 92,
                          height: 92,
                          compact: true,
                        ),
                      ),
              ),
              Positioned(
                bottom: 0,
                right: 30,
                child: Image.asset(AppIcons.addImage, width: 32, height: 32),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

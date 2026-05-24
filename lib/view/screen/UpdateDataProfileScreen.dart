import 'package:customer/controller/ProfileController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/ImageInput.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/view/widget/widgetApp/textBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class UpdateDataProfileScreen extends StatelessWidget {
  UpdateDataProfileScreen({super.key});

  final ProfileController controller = Get.find<ProfileController>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      horizontalPadding: 16,
      onRefresh: () => controller.getDataCustomer(),
      statusCode: controller.statusCode,
      statusRequest: controller.statusRequest,
      isSub: true,
      namePage: "تعديل البيانات",
      child: ListView(
        children: [
          Obx(
            () => ImageInput(
              pathImage: Applink.customerImage(
                controller.listDataCustomer["storeImage"]?.toString(),
              ),
              image: controller.imageElmint.value,
              onImagePicked: (Uint8List newImage) {
                controller.imageElmint.value = newImage;
              },
            ),
          ),
          SizedBox(height: 20),
          TextBoxs(
            controller: controller.nameController,
            prefixIcon: Container(
              width: 20,
              height: 20,
              padding: const EdgeInsets.all(10),
              child: Image.asset(AppIcons.person),
            ),
            hintText: "الاسم",
          ),
          SizedBox(height: 10),
          TextBoxs(
            controller: controller.phoneController,
            typeVal: "phone",
            maxLength: 13,
            maxLines: 1,
            type: TextInputType.number,
            suffixIcon: Text("+964"),
            prefixIcon: Container(
              width: 20,
              height: 20,
              padding: const EdgeInsets.all(10),
              child: Image.asset(AppIcons.phone),
            ),
            hintText: "رقم تليفون المستلم",
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              "رقم التليفون المستلم هو الرقم الذي سيتم التواصل معه عند توصيل الطلب",
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: MyFontWeight.light,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 30),
          Obx(
            () => ButtonAppWidget(
              statusRequest: controller.statusRequestButton.value,
              onPressed: () => controller.updateCustomer(),
              lable: "حفظ التعديلات",
            ),
          ),
        ],
      ),
    );
  }
}

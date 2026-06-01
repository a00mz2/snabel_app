// ignore_for_file: file_names, invalid_use_of_protected_member

import 'package:customer/controller/SignUpControler.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/constant/assets/images.dart';
import 'package:customer/core/functions/openMapBottomSheet.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/DropdownWidget.dart';
import 'package:customer/view/widget/widgetApp/ImageInputMobile.dart';
import 'package:customer/view/widget/widgetApp/textBox.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({super.key});
  final SignUpControler controller = Get.find<SignUpControler>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    return Scaffold(
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Form(
              key: controller.formstate.value,
              child: ListView(
                children: [
                  SizedBox(height: 10),
                  Image.asset(AppImage.logoSplash, width: 100, height: 100),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "إنشاء حساب جديد ",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: MyFontWeight.semiBold,
                          color: Color(0xff572E12),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          "أنشئ حسابًا لمطعمك أو متجرك وابدأ في انشاء طلبات الصمون، الخبز، والمعجنات بسهولة وسرعة.",
                          textAlign: TextAlign.right,
                          maxLines: 2,

                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                fontSize: 16,
                                fontWeight: MyFontWeight.regular,
                                color: Color(0xffA19491),
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  TextBoxs(
                    controller: controller.customerNameController,
                    prefixIcon: Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(AppIcons.person),
                    ),
                    hintText: "اسم صاحب المتجر",
                  ),
                  SizedBox(height: 10),
                  TextBoxs(
                    controller: controller.storeNameController,
                    prefixIcon: Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(AppIcons.store),
                    ),
                    hintText: "اسم المتجر",
                  ),

                  SizedBox(height: 10),
                  TextBoxs(
                    controller: controller.phoneController,
                    typeVal: "phone",
                    maxLength: 11,
                    maxLines: 1,
                    type: TextInputType.number,
                    suffixIcon: Text("+964"),
                    prefixIcon: Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(AppIcons.phone),
                    ),
                    hintText: "رقم التليفون",
                  ),

                  SizedBox(height: 10),
                  DropdownWidget(
                    validator: false,
                    hintText: "المحافظة",
                    items: controller.listprovince,
                    itemLabelBuilder: (item) => item["name"],
                    selectedItem: controller.province.isEmpty
                        ? null
                        : controller.province.value,
                    onChanged: (value) => controller.selectedProvince(value),
                    prefixIcon: Container(
                      width: 10,
                      height: 10,
                      padding: EdgeInsets.all(9.5),
                      child: Image.asset(
                        AppIcons.store,
                        color: Color(0xff525252),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),

                  TextBoxs(
                    controller: controller.addressController,
                    prefixIcon: Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(AppIcons.locationMap),
                    ),
                    hintText: "العنوان",
                  ),
                  SizedBox(height: 10),
                  TextBoxs(
                    readOnly: true,
                    controller: controller.locationController,
                    prefixIcon: Container(
                      width: 20,
                      height: 20,
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(AppIcons.locationMap),
                    ),
                    hintText: "حدد موقع متجرك على الخريطة",
                    suffixIcon: Obx(
                      () => InkWell(
                        onTap: controller.isLoading.value
                            ? null // لا تعمل أثناء التحميل
                            : () async {
                                controller.isLoading.value = true;

                                // نعرض مؤشر التحميل أثناء التحضير
                                await openMapBottomSheet(controller);

                                controller.isLoading.value = false;
                              },
                        child: controller.isLoading.value
                            ? SizedBox(
                                width: 25,
                                height: 25,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: Theme.of(context).primaryColor,
                                ),
                              )
                            : Image.asset(AppIcons.map),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownWidget(
                    validator: false,
                    hintText: "نوع المتجر",
                    items: controller.listCustomerType,
                    itemLabelBuilder: (item) => item["name"],
                    selectedItem: controller.customerType.isEmpty
                        ? null
                        : controller.customerType.value,
                    onChanged: (value) =>
                        controller.selectedcustomerType(value),
                    prefixIcon: Container(
                      width: 10,
                      height: 10,
                      padding: EdgeInsets.all(9.5),
                      child: Image.asset(
                        AppIcons.store,
                        color: Color(0xff525252),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Obx(
                    () => ImageUploadField(
                      imageBytes: controller.imageElmint.value,
                      fileName: controller.fileName.value,
                      onImagePicked: (Uint8List newImage, String name) {
                        controller.imageElmint.value = newImage;
                        controller.fileName.value = name;
                      },
                    ),
                  ),
                  SizedBox(height: 10),
                  Obx(
                    () => TextBoxs(
                      prefixIcon: Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(AppIcons.pass),
                      ),
                      hintText: "كلمة مرور",
                      controller: controller.passwordController,
                      obscureText: controller.obscureText.value,
                      showPassword: () => controller.showPassword(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Obx(
                    () => TextBoxs(
                      prefixIcon: Container(
                        width: 20,
                        height: 20,
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(AppIcons.pass),
                      ),
                      hintText: "تأكيد كلمة المرور",
                      controller: controller.rEpasswordController,
                      obscureText: controller.rEobscureText.value,
                      showPassword: () =>
                          controller.showPassword(isRePassword: true),
                    ),
                  ),
                  SizedBox(height: 24),
                  Obx(
                    () => ButtonAppWidget(
                      statusRequest: controller.buttonStatusRequest.value,
                      lable: "انشاء حساب",
                      onPressed: () => controller.verification(),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "لديكِ حساب؟ ",
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                          color: Color(0xffA19491),
                          fontSize: 14,
                          fontWeight: MyFontWeight.light,
                        ),
                      ),
                      InkWell(
                        onTap: () => Get.back(),
                        child: Text(
                          "تسجيل الدخول",
                          style: Theme.of(context).textTheme.bodyLarge!
                              .copyWith(
                                color: Color(0xff231F1E),
                                fontSize: 14,
                                fontWeight: MyFontWeight.regular,
                              ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

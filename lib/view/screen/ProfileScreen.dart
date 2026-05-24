import 'package:customer/controller/ProfileController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/constant/assets/images.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfileScreen extends StatelessWidget {
  ProfileScreen({super.key});

  final ProfileController controller = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      onRefresh: () => controller.getDataCustomer(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            Obx(
              () => GestureDetector(
                onTap: () => Get.toNamed('/UpdateDataProfileScreen'),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Theme.of(context).primaryColor,
                    image: DecorationImage(
                      image: AssetImage(AppImage.backgroondProfileCard),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Container(
                          width: 60,
                          height: 60,
                          color: Colors.white,
                          child: AppNetworkImage(
                            imageUrl: Applink.customerImage(
                              controller.listDataCustomer["storeImage"]
                                  ?.toString(),
                            ),
                            fit: BoxFit.cover,
                            width: 60,
                            height: 60,
                            compact: true,
                          ),
                        ),
                      ),

                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              (controller.listDataCustomer['customerName'] ??
                                      controller.listDataCustomer['name'] ??
                                      myServices.sharedPreferences.getString(
                                        "name",
                                      ) ??
                                      '')
                                  .toString(),
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: Colors.white,
                                    fontWeight: MyFontWeight.semiBold,
                                    fontSize: 17,
                                  ),
                            ),
                            Text(
                              controller.listDataCustomer['phone'] ??
                                  myServices.sharedPreferences
                                      .getString("phone")
                                      .toString(),
                              style: Theme.of(context).textTheme.bodyLarge!
                                  .copyWith(
                                    color: Color(0xffE7E4E4),
                                    fontWeight: MyFontWeight.light,
                                    fontSize: 12,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      Image.asset(
                        AppIcons.arrow_forward,
                        width: 30,
                        height: 30,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 22),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    listTileWidget(
                      context,
                      "المفضلة",
                      AppIcons.favorites,
                      onTap: () => Get.toNamed(
                        '/SectionProducts',
                        arguments: {
                          'categoryId': "",
                          'image': "",
                          'sliderImage': "",
                          'name': "المفضلة",
                          "favoritesOnly": true,
                        },
                      ),
                    ),
                    listTileWidget(
                      context,
                      "الطلبات المثبتة",
                      AppIcons.tabler_pin,
                      onTap: () => Get.toNamed('/PinnedOrders'),
                    ),
                    listTileWidget(
                      context,
                      "وسائل الاتصال",
                      AppIcons.call,
                      onTap: () => Get.toNamed('/ContactUs'),
                    ),
                    listTileWidget(
                      context,
                      "سياسة الخصوصية",
                      AppIcons.docx,
                      onTap: () => Get.toNamed('/PrivacyPolicy'),
                    ),
                    listTileWidget(
                      context,
                      "حذف حسابي",
                      Icons.delete_outline,
                      isLogOun: true,
                      onTap: () => controller.confirmAndSoftDeleteAccount(),
                    ),
                  ],
                ),

                listTileWidget(
                  context,
                  "تسجيل خروج",
                  AppImage.logoAppbar,
                  isLogOun: true,
                  onTap: () => controller.logOut(),
                ),
                SizedBox(height: 12),
                Obx(() {
                  final v = controller.appVersionLabel.value;
                  if (v.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Center(
                      child: Text(
                        v,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: const Color(0xff6C6C6C),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget listTileWidget(
    BuildContext context,
    String lable,
    icon, {
    void Function()? onTap,
    bool? isLogOun,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16),
        margin: EdgeInsets.only(bottom: 8),
        height: 48,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isLogOun == null ? Color(0xffF9F8F8) : Color(0xffFEF5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                isLogOun == null
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: icon is IconData
                            ? Icon(icon, size: 22, color: Colors.red.shade700)
                            : Image.asset(icon),
                      )
                    : SizedBox(),
                SizedBox(width: isLogOun == null ? 8 : 0),
                Text(
                  lable,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: isLogOun == null ? Color(0xff231F1E) : Colors.red,
                    fontWeight: MyFontWeight.regular,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            SizedBox(
              width: 20,
              height: 20,
              child: isLogOun == null
                  ? Image.asset(AppIcons.arrow_forward)
                  : Image.asset(AppIcons.logOut),
            ),
          ],
        ),
      ),
    );
  }
}

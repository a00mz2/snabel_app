// ignore_for_file: unused_local_variable

import 'package:customer/controller/WalletController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/view/widget/HomeWidget/WaltCardWidget.dart';
import 'package:customer/view/widget/WalletWidget/WeekDateSelector.dart';
import 'package:customer/view/widget/WalletWidget/transactionWidget.dart';
import 'package:customer/view/widget/widgetApp/PaginationIndicator.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';

class WalletScreen extends StatelessWidget {
  WalletScreen({super.key});
  final WalletController controller = Get.put(WalletController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());
    return ScaffoldWidget(
      verticalPadding: 0,
      bottomNavigationBar: Obx(
        () => PaginationIndicator(
          index: controller.dataWallet['transactions'].length - 1,
          listlength: controller.dataWallet['transactions'].length,
          statusRequestPagination: controller.statusRequestPagination.value,
        ),
      ),
      onRefresh: () => controller.getTransactions(),
      statusCode: controller.statusCode,
      statusRequest: controller.statusRequest,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          controller: controller.scrollController,
          children: [
            Obx(
              () => WaltCardWidget(
                showRegistericon: false,
                balance: controller.dataWallet['wallet']['balance'],
              ),
            ),

            const SizedBox(height: 20),
            Text(
              "سجل المعاملات",
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).primaryColorDark,
                fontSize: 16,
                fontWeight: MyFontWeight.medium,
              ),
            ),
            const SizedBox(height: 5),
            const WalletDateSelector(),
            const SizedBox(height: 16),

            Obx(
              () => controller.statusRequestList.value == StatusRequest.loading
                  ? Center(
                      child: SpinKitFadingCircle(
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: controller.dataWallet['transactions'].length,
                      itemBuilder: (context, index) =>
                          TransactionWidget(index: index),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

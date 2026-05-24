// ignore_for_file: file_names, unrelated_type_equality_checks

import 'dart:ui';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/view/widget/widgetApp/AppBarwidget.dart';
import 'package:customer/view/widget/widgetApp/ListEmtyWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ScaffoldWidget extends StatelessWidget {
  const ScaffoldWidget({
    super.key,
    this.isSub = false,
    this.hideNotifications = false,
    this.onRefresh,
    this.child,
    required this.statusRequest,
    this.heder,
    this.bottomNavigationBar,
    this.footer,
    this.appBar = true,
    this.horizontalPadding = 0.0,
    this.verticalPadding = 0.0,
    this.isPublicRoutes = false,
    required this.statusCode,
    this.namePage,
    this.iconPage,
    this.backgroundColor,
  });
  final bool? isSub;
  final bool? isPublicRoutes;
  final RxInt statusCode;

  final bool? hideNotifications;
  final Future<void> Function()? onRefresh;
  final Widget? child;
  final Widget? heder;
  final Widget? footer;
  final Rx<StatusRequest> statusRequest;
  final bool appBar;
  final double horizontalPadding;
  final double verticalPadding;
  final String? namePage;
  final Widget? iconPage;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar
          ? AppBarWidget(
              isSub: isSub,
              hideNotifications: hideNotifications,
              namePage: namePage,
              iconPage: iconPage,
            )
          : null,

      body: RefreshIndicator(
        onRefresh: onRefresh ?? () async {},
        color: Theme.of(context).primaryColor,
        child: ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: horizontalPadding,
              vertical: verticalPadding,
            ),
            child: Column(
              children: [
                if (heder != null) heder!,
                Expanded(
                  child: Obx(
                    () =>
                        statusRequest.value != StatusRequest.success &&
                            statusCode.value != 400
                        ? ListEmtyWidget(
                            onRefresh: onRefresh,
                            statusRequest: statusRequest,
                            statusCode: statusCode,
                          )
                        : statusCode.value == 400
                        ? child ?? SizedBox()
                        : child ?? SizedBox(),
                  ),
                ),
                if (footer != null)
                  Obx(
                    () => statusRequest.value == StatusRequest.success
                        ? footer!
                        : const SizedBox.shrink(),
                  ),
              ],
            ),
          ),
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Obx(
        () => statusRequest.value != StatusRequest.success
            ? const SizedBox.shrink()
            : bottomNavigationBar ?? const SizedBox.shrink(),
      ),
    );
  }
}

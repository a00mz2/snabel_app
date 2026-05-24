import 'package:customer/controller/NotificationsController.dart';
import 'package:customer/view/widget/Notifications/CardNotificationsWidget.dart';
import 'package:customer/view/widget/widgetApp/PaginationIndicator.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class NotificationsScreen extends StatelessWidget {
  NotificationsScreen({super.key});

  final NotificationsController controller = Get.put(NotificationsController());

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      namePage: "الإشعارات",
      isSub: true,
      onRefresh: () => controller.getNotifications(),
      appBar: true,
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,

      child: Obx(
        () => AnimationLimiter(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            controller: controller.scrollController,
            itemCount: controller.listNotifications.length,
            itemBuilder: (context, index) {
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(seconds: 1),
                child: FadeInAnimation(
                  child: FadeInAnimation(
                    child: Column(
                      children: [
                        CardNotificationsWidget(
                          index: index,
                          title: controller.listNotifications[index]['title'],
                          body: controller.listNotifications[index]['message'],
                          date:
                              controller.listNotifications[index]['createdAt'],
                          isRead: controller.listNotifications[index]['isRead'],
                          onTap: () => controller.onNotificationTap(index),
                        ),
                        Obx(
                          () => PaginationIndicator(
                            index: index,
                            listlength: controller.listNotifications.length,
                            statusRequestPagination:
                                controller.statusRequestPagination.value,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

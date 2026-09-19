import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

class ListEmtyWidget extends StatelessWidget {
  const ListEmtyWidget({
    super.key,
    required this.statusRequest,
    required this.statusCode,
    this.onRefresh,
    this.emptyChild,
  });
  final Rx<StatusRequest> statusRequest;
  final RxInt statusCode;
  final Future<void> Function()? onRefresh;

  /// محتوى مخصص لحالة [StatusRequest.empty] (لا بيانات — ليس خطأ خادم).
  /// عند تمريره لا يُعرض زر «اعد المحاولة»؛ الشاشة تقرّر الإجراء المناسب.
  final Widget? emptyChild;

  bool get _showsEmptyChild =>
      statusRequest.value == StatusRequest.empty && emptyChild != null;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => statusRequest.value == StatusRequest.loading
                ? Center(
                    child: SpinKitFadingCircle(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : statusRequest.value == StatusRequest.offlineFailure
                ? Container(
                    width: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off_rounded,
                          color: Theme.of(context).primaryColor.withAlpha(80),
                          size: 100,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "لا يوجد اتصال بالشبكة",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontSize: 14,
                                fontWeight: MyFontWeight.medium,
                                color: const Color.fromARGB(124, 0, 0, 0),
                              ),
                        ),
                      ],
                    ),
                  )
                : statusCode.value == 402
                ? Container(
                    width: 200,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.pending,
                          color: Theme.of(context).primaryColor.withAlpha(80),
                          size: 100,
                        ),
                        Text(
                          textAlign: TextAlign.center,
                          "نعمل حاليًا على مراجعة حسابك، سيتم تفعيله فور الموافقة عليه",
                          style: Theme.of(context).textTheme.bodyMedium!
                              .copyWith(
                                fontSize: 14,
                                fontWeight: MyFontWeight.medium,
                                color: const Color.fromARGB(124, 0, 0, 0),
                              ),
                        ),
                      ],
                    ),
                  )
                : statusCode.value == 403
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.redAccent.withAlpha(80),
                          size: 100,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "تم تعطيل حسابك",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "يرجى التواصل مع الدعم الفني لإعادة تفعيل حسابك.",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : _showsEmptyChild
                ? emptyChild!
                : Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_outlined,
                          color: Theme.of(context).primaryColor.withAlpha(80),
                          size: 100,
                        ),
                        SizedBox(height: 20),
                        Text(
                          "خطاء في الخادم",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          "حاول مجددا في وقت لاحق",
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
          ),
          statusRequest.value != StatusRequest.loading &&
                  statusRequest.value != StatusRequest.success &&
                  !_showsEmptyChild
              ? TextButton(
                  onPressed: onRefresh,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "اعد المحاولة",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}

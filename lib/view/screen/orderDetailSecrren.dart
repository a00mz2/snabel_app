// ignore_for_file: camel_case_types

import 'package:customer/controller/orderDetailController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/core/functions/statusColors.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/OrderDetailWidget/ItemRatingButton.dart';
import 'package:customer/view/widget/OrderDetailWidget/RateSheets.dart';
import 'package:customer/view/widget/widgetApp/RatingStars.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/CartWidgets/TitleBar.dart';
import 'package:customer/view/widget/OrderDetailWidget/HederOrderDetailWidget.dart';
import 'package:customer/view/widget/OrderDetailWidget/OrderNoteWidget.dart';
import 'package:customer/view/widget/OrderDetailWidget/OrderProductWidget.dart';
import 'package:customer/view/widget/OrderDetailWidget/OrderRejectionWidget.dart';
import 'package:customer/view/widget/OrderDetailWidget/PriceFltatBarOrderWidget.dart';
import 'package:customer/view/widget/widgetApp/DashedDividerWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';

class orderDetailSecrren extends GetView<OrderDetailController> {
  const orderDetailSecrren({super.key});

  /// مسار GetX الوحيد لشاشة تفاصيل الطلب — لا تُضف شاشة بديلة لهذا الغرض.
  static const String routeName = '/orderDetails';

  /// التوجيه إلى هذه الشاشة ([orderDetailSecrren]) عبر المسار المعرّف في `routes.dart`.
  static void navigateWithOrderNumber(String orderNumber) {
    final id = orderNumber.trim();
    OrderDetailPendingRouteArgs.stash(id);
    Get.toNamed(routeName, arguments: {'orderNumber': id});
  }

  /// من بيانات الإشعار: يمرّر [orderNumber] و [orderId] بشكل منفصل (لا يضع ObjectId تحت مفتاح orderNumber).
  static void navigateWithOrderPayload(Map<String, dynamic> payload) {
    final m = Map<String, dynamic>.from(payload);
    final num = (m['orderNumber'] ?? m['order_number'])?.toString().trim();
    final oid = (m['orderId'] ?? m['order_id'])?.toString().trim();
    final primary = (num != null && num.isNotEmpty) ? num : (oid ?? '');
    if (primary.isEmpty) return;
    OrderDetailPendingRouteArgs.stash(primary);
    Get.toNamed(
      routeName,
      arguments: {
        if (num != null && num.isNotEmpty) 'orderNumber': num,
        if (oid != null && oid.isNotEmpty) 'orderId': oid,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderLabel =
        resolveOrderIdentifierFromArguments(Get.arguments) ??
        controller.orderId;
    return ScaffoldWidget(
      namePage: "تفاصيل الطلب #$orderLabel",
      isSub: true,
      horizontalPadding: 16,
      onRefresh: () => controller.getOrder(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      emptyStateChild: _OrderNotFoundWidget(orderLabel: orderLabel),
      // تعديل المحتوى متاح ما دام الطلب «جديد» (قيد المراجعة)
      footer: Obx(() {
        final status = controller.dataOrder['status']?.toString() ?? '';
        if (status == 'جديد') {
          return Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 12),
            child: ButtonAppWidget(
              lable: 'تعديل الطلب',
              onPressed: _openEditor,
            ),
          );
        }
        // «جديد» و«مُسلَّم» متنافيان، فلا تعارض بين الزرّين
        if (isDeliveredStatus(status)) {
          final pending = controller.pendingRatingsCount;
          if (pending > 0) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              child: ButtonAppWidget(
                lable: 'قيّم منتجات الطلب ($pending)',
                onPressed: () {
                  final i = controller.firstUnratedItemIndex;
                  if (i != null) _rateItem(i);
                },
              ),
            );
          }
        }
        return const SizedBox.shrink();
      }),
      child: ListView(
        children: [
          HederOrderDetailWidget(),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Color(0xffE7E4E4)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Obx(() {
              final items = controller.dataOrder['items'] as List?;
              final n = items?.length ?? 0;
              final note = controller.dataOrder['note']?.toString().trim() ?? '';
              final rejRaw = controller.dataOrder['rejection'];
              final rejection =
                  (rejRaw is Map && controller.dataOrder['status'] == 'مرفوض')
                  ? rejRaw
                  : null;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TitleBar(itemCount: n),
                  SizedBox(height: 10),
                  DashedDividerWidget(color: Color(0xffE7E4E4)),
                  AnimationLimiter(
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: n,
                      itemBuilder: (context, index) =>
                          AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(seconds: 1),
                            child: FadeInAnimation(
                              child: FadeInAnimation(
                                child: Obx(
                                  () => OrderProductWidget(
                                    index: index,
                                    trailing:
                                        controller.isDelivered &&
                                            controller
                                                .productIdOfItem(index)
                                                .isNotEmpty
                                        ? ItemRatingButton(
                                            myStars: controller.myStarsOfItem(
                                              index,
                                            ),
                                            isSubmitting:
                                                controller
                                                    .submittingItemIndex
                                                    .value ==
                                                index,
                                            enabled: !controller
                                                .isDuplicateProductLine(index),
                                            onTap: () => _rateItem(index),
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                    ),
                  ),
                  if (note.isNotEmpty) ...[
                    SizedBox(height: 16),
                    OrderNoteWidget(note: note),
                  ],
                  if (rejection != null) ...[
                    SizedBox(height: 12),
                    OrderRejectionWidget(rejection: rejection),
                  ],
                  SizedBox(
                    height: (note.isNotEmpty || rejection != null) ? 24 : 50,
                  ),
                  PriceFltatBarOrderWidget(showDeliveryFee: true),
                ],
              );
            }),
          ),
          SizedBox(height: 16),
          const _OrderDriverRatingSection(),
          SizedBox(height: 16),
          const _OrderContentEditsSection(),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  /// يفتح ورقة تقييم بند ثم يرسل النتيجة. لا تسلسل تلقائي للبند التالي:
  /// الورقة لا تُغلق إلا بسحب، فالتسلسل يحبس المستخدم في حلقة بلا مخرج واضح.
  Future<void> _rateItem(int index) async {
    final productId = controller.productIdOfItem(index);
    if (productId.isEmpty) return;
    final existing = controller.myStarsOfItem(index);
    final draft = controller.draftFor(productId);
    final image = controller.imageOfItem(index);

    final result = await showRateProductSheet(
      Get.context!,
      productName: controller.nameOfItem(index),
      imageUrl: image.isEmpty ? null : Applink.productImage(image),
      initialStars: existing,
      initialComment: draft.isNotEmpty
          ? draft
          : (controller.myRatingOfItem(index)?['comment']?.toString() ?? ''),
    );
    if (result == null) return;

    await controller.submitProductRating(
      index: index,
      stars: result['stars'] as int,
      comment: (result['comment'] ?? '').toString(),
    );
  }

  Future<void> _openEditor() async {
    final raw = controller.dataOrder;
    if (raw.isEmpty) return;
    final result = await Get.toNamed(
      '/OrderEdit',
      arguments: {'order': Map<String, dynamic>.from(raw)},
    );
    if (result == true) controller.getOrder();
  }
}

/// سجل تعديلات محتوى الطلب (`contentEdits` من الخادم) — الأحدث أولاً.
class _OrderContentEditsSection extends StatelessWidget {
  const _OrderContentEditsSection();

  static String _byLabel(Map<String, dynamic> edit) {
    final by = edit['by'];
    final role = by is Map ? by['role']?.toString() : null;
    final name = by is Map ? (by['name']?.toString() ?? '') : '';
    switch (role) {
      case 'customer':
        return 'أنت';
      case 'driver':
        return name.isEmpty ? 'السائق' : 'السائق $name';
      default:
        return 'الإدارة';
    }
  }

  static String _walletLabel(Map<String, dynamic> edit) {
    final d = edit['delta'];
    final delta = d is num ? d : num.tryParse('${d ?? ''}') ?? 0;
    final skipped = edit['walletSkippedReason']?.toString() ?? '';
    if (delta == 0) return 'دون تغيير في الإجمالي';
    if (skipped.isNotEmpty) return 'لم يُعدَّل رصيد المحفظة';
    if (delta < 0) {
      return 'أُرجع ${formatNumber((-delta).round())} د.ع إلى محفظتك';
    }
    return 'خُصم ${formatNumber(delta.round())} د.ع من محفظتك';
  }

  static String _when(Map<String, dynamic> edit) {
    final at = edit['at']?.toString();
    if (at == null || at.isEmpty) return '';
    try {
      return formatDateTime(at);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderDetailController>();
    return Obx(() {
      final raw = controller.dataOrder['contentEdits'];
      if (raw is! List || raw.isEmpty) return const SizedBox.shrink();
      final edits = <Map<String, dynamic>>[
        for (final e in raw)
          if (e is Map) Map<String, dynamic>.from(e),
      ].reversed.toList();
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffE7E4E4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تعديلات الطلب',
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < edits.length; i++) ...[
              if (i > 0) const Divider(color: Color(0xffE7E4E4)),
              Text(
                edits[i]['textAr']?.toString() ?? '',
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: const Color(0xff292929),
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${_byLabel(edits[i])} · ${_when(edits[i])} · ${_walletLabel(edits[i])}',
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: const Color(0xff7C7C7C),
                    ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

/// حالة «الطلب غير موجود» — الخادم يعيد 200 بقائمة فارغة عندما يكون الطلب
/// محذوفاً (حذف ناعم من الإدارة) أو الرقم غير صحيح. تصل غالباً من إشعار قديم.
class _OrderNotFoundWidget extends StatelessWidget {
  const _OrderNotFoundWidget({required this.orderLabel});

  final String orderLabel;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 100,
              color: primary.withAlpha(80),
            ),
            const SizedBox(height: 20),
            Text(
              'لم يتم العثور على الطلب #$orderLabel',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'ربما تم إلغاؤه أو حذفه من قبل الإدارة، أو أن رقم الطلب غير صحيح.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: () {
                // من إشعار عند تشغيل التطبيق البارد قد لا توجد شاشة سابقة
                if (Navigator.of(context).canPop()) {
                  Get.back();
                } else {
                  Get.offAllNamed('/MainScreen');
                }
              },
              icon: Icon(Icons.arrow_back, color: primary),
              label: Text('العودة', style: TextStyle(color: primary)),
            ),
          ],
        ),
      ),
    );
  }
}

/// تقييم السائق — يظهر فقط بعد التسليم وعندما يكون للطلب سائق.
/// مبني على نموذج [_OrderContentEditsSection]: يجلب الكنترولر بنفسه، يغلّف بـ Obx،
/// وينسحب بـ SizedBox.shrink() عند عدم انطباق الشرط.
class _OrderDriverRatingSection extends StatelessWidget {
  const _OrderDriverRatingSection();

  static String _when(dynamic raw) {
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '';
    // formatTimeAgo يرمي على مدخل فارغ أو غير صالح
    try {
      return formatTimeAgo(s);
    } catch (_) {
      return '';
    }
  }

  Future<void> _rate(OrderDetailController controller, int initialStars) async {
    final driver = controller.orderDriver;
    if (driver == null) return;
    final image = driver['image']?.toString() ?? '';
    final draft = controller.draftFor('__driver__');

    final result = await showRateDriverSheet(
      Get.context!,
      driverName: driver['name']?.toString() ?? 'السائق',
      imageUrl: image.isEmpty ? null : Applink.driverImage(image),
      initialStars: initialStars,
      initialComment: draft.isNotEmpty
          ? draft
          : (controller.myDriverRating?['comment']?.toString() ?? ''),
    );
    if (result == null) return;

    await controller.submitDriverRating(
      stars: result['stars'] as int,
      comment: (result['comment'] ?? '').toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<OrderDetailController>();
    return Obx(() {
      final driver = controller.orderDriver;
      if (!controller.isDelivered || driver == null) {
        return const SizedBox.shrink();
      }

      final theme = Theme.of(context);
      final stars = controller.myDriverStars;
      final rating = controller.myDriverRating;
      final image = driver['image']?.toString() ?? '';
      final name = driver['name']?.toString() ?? 'السائق';

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xffE7E4E4)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: image.isEmpty
                      ? Container(
                          width: 40,
                          height: 40,
                          color: const Color(0xffF3F2F1),
                          child: const Icon(
                            Icons.person_outline,
                            size: 22,
                            color: Color(0xffA19491),
                          ),
                        )
                      : AppNetworkImage(
                          imageUrl: Applink.driverImage(image),
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          compact: true,
                        ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: 15,
                          fontWeight: MyFontWeight.medium,
                          color: const Color(0xff231F1E),
                        ),
                      ),
                      Text(
                        stars > 0 ? 'تقييمك للسائق' : 'كيف كان أداء السائق؟',
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: 12,
                          fontWeight: MyFontWeight.light,
                          color: const Color(0xff7C7C7C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (stars > 0) ...[
              Row(
                children: [
                  RatingStarsDisplay(value: stars.toDouble(), size: 20),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.isSubmittingDriverRating.value
                        ? null
                        : () => _rate(controller, stars),
                    child: const Text('تعديل التقييم'),
                  ),
                ],
              ),
              if ((rating?['comment']?.toString() ?? '').trim().isNotEmpty)
                Text(
                  rating!['comment'].toString(),
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 13,
                    fontWeight: MyFontWeight.regular,
                    color: const Color(0xff292929),
                  ),
                ),
              if (_when(rating?['ratedAt']).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _when(rating?['ratedAt']),
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontSize: 11,
                      fontWeight: MyFontWeight.light,
                      color: const Color(0xff7C7C7C),
                    ),
                  ),
                ),
            ] else if (controller.isSubmittingDriverRating.value)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              // النجوم داخلياً هنا: القسم غير مقيَّد رأسياً، والضغط يفتح الورقة
              // مباشرةً بنفس التقييم لإضافة التعليق — نقرة واحدة أقل.
              RatingStarsInput(
                value: 0,
                size: 32,
                onChanged: (v) => _rate(controller, v),
              ),
          ],
        ),
      );
    });
  }
}

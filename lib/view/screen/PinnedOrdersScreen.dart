import 'package:customer/controller/PinnedOrdersListController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/pinned_order_utils.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinnedOrdersScreen extends GetView<PinnedOrdersListController> {
  const PinnedOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      isSub: true,
      namePage: 'الطلبات المثبتة',
      onRefresh: () => controller.refreshList(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      horizontalPadding: 16,
      heder: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filterChips(context),
          const SizedBox(height: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Obx(() {
              if (controller.listPinned.isEmpty &&
                  controller.statusRequest.value == StatusRequest.success) {
                return Center(
                  child: Text(
                    'لا توجد طلبات مثبتة',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: const Color(0xff7C7C7C),
                        ),
                  ),
                );
              }
              return ListView.separated(
                controller: controller.scrollController,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.listPinned.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final item = controller.listPinned[index];
                  return _PinnedOrderCard(
                    data: item,
                    onTap: () async {
                      final id = pinnedOrderIdFromMap(item);
                      if (id == null) return;
                      final r = await Get.toNamed(
                        '/PinnedOrderDetail',
                        arguments: {'pinnedOrderId': id},
                      );
                      if (r == true) controller.refreshList();
                    },
                  );
                },
              );
            }),
          ),
          Obx(
            () => controller.statusRequestPagination.value ==
                    StatusRequest.loading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(
                      child: SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _filterChips(BuildContext context) {
    return Obx(() {
      final v = controller.filterActive.value;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(
              context,
              label: 'الكل',
              selected: v == null,
              onTap: () => controller.setFilter(null),
            ),
            const SizedBox(width: 8),
            _chip(
              context,
              label: 'نشط',
              selected: v == true,
              onTap: () => controller.setFilter(true),
            ),
            const SizedBox(width: 8),
            _chip(
              context,
              label: 'متوقف',
              selected: v == false,
              onTap: () => controller.setFilter(false),
            ),
          ],
        ),
      );
    });
  }

  Widget _chip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).primaryColor;
    return Material(
      color: selected ? primary.withValues(alpha: 0.15) : const Color(0xffF9F8F8),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: selected ? primary : const Color(0xffEFEFEF),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? primary : const Color(0xff292929),
                ),
          ),
        ),
      ),
    );
  }
}

class _PinnedOrderCard extends StatelessWidget {
  const _PinnedOrderCard({required this.data, required this.onTap});

  final Map<String, dynamic> data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = data['isActive'] == true;
    final repeat = data['repeat'];
    final preview = data['pricingPreview'];
    num? total;
    if (preview is Map && preview['valid'] == true) {
      final t = preview['estimatedTotal'];
      if (t is num) total = t;
    }

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xffEFEFEF)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.push_pin_rounded,
                    size: 22,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      orderNumberLabel(data),
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xff292929),
                          ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: active
                          ? const Color(0xff01A850).withValues(alpha: 0.12)
                          : const Color(0xff7C7C7C).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      active ? 'نشط' : 'متوقف',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? const Color(0xff01A850)
                            : const Color(0xff7C7C7C),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                repeatSummary(repeat is Map ? Map<String, dynamic>.from(repeat) : null),
                style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: const Color(0xff7C7C7C),
                      fontSize: 13,
                    ),
              ),
              if (total != null) ...[
                const SizedBox(height: 8),
                Text(
                  'تقدير: ${formatNumberNum(total)} د.ع',
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xff3C2313),
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

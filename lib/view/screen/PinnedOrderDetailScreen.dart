import 'package:customer/controller/PinnedOrderDetailController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/pinned_order_utils.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinnedOrderDetailScreen extends GetView<PinnedOrderDetailController> {
  const PinnedOrderDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      isSub: true,
      namePage: 'تفاصيل الطلب المثبت',
      onRefresh: () => controller.load(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      horizontalPadding: 16,
      footer: Obx(
        () => controller.order.value == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ButtonAppWidget(
                            primaryButton: false,
                            lable: 'تعديل',
                            color: const Color(0xff3C2313),
                            onPressed: controller.openEdit,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ButtonAppWidget(
                            lable: 'حذف',
                            color: const Color(0xffC62828),
                            onPressed: () => controller.confirmDelete(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final active = controller.order.value?['isActive'] == true;
                      return SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          active ? 'الطلب نشط' : 'الطلب متوقف',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        value: active,
                        activeThumbColor: const Color(0xff01A850),
                        onChanged: controller.statusButton.value ==
                                StatusRequest.loading
                            ? null
                            : (v) => controller.toggleActive(v),
                      );
                    }),
                  ],
                ),
              ),
      ),
      child: Obx(() {
        final data = controller.order.value;
        if (data == null) return const SizedBox.shrink();
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: _DetailBody(data: data),
        );
      }),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.data});

  final Map<String, dynamic> data;

  @override
  Widget build(BuildContext context) {
    final isActive = data['isActive'] == true;
    final repeat = data['repeat'];
    final period = data['deliveryPeriod'];
    final items = data['items'];
    final preview = data['pricingPreview'];
    final created = data['createdAt']?.toString();
    final updated = data['updatedAt']?.toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hero(context, isActive),
        const SizedBox(height: 12),
        _section(
          context,
          title: 'التواريخ',
          icon: Icons.schedule_outlined,
          children: [
            _kv('تاريخ الإنشاء', formatPinnedDate(created)),
            _kv('آخر تحديث', formatPinnedDate(updated)),
          ],
        ),
        if (repeat is Map) ...[
          const SizedBox(height: 12),
          _section(
            context,
            title: 'التكرار',
            icon: Icons.repeat_rounded,
            children: [
              Text(
                repeatSummary(Map<String, dynamic>.from(repeat)),
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ],
        if (period is Map || data['deliveryPeriodId'] != null) ...[
          const SizedBox(height: 12),
          _section(
            context,
            title: 'فترة التوصيل',
            icon: Icons.access_time_rounded,
            children: [
              if (period is Map) ...[
                _kv('الفترة', '${period['name'] ?? period['label'] ?? '—'}'),
                _kv(
                  'الوقت',
                  '${period['startTime'] ?? '—'} — ${period['endTime'] ?? '—'}',
                ),
              ] else
                _kv('المعرّف', '${data['deliveryPeriodId'] ?? '—'}'),
            ],
          ),
        ],
        if (preview is Map && preview['valid'] == true) ...[
          const SizedBox(height: 12),
          _pricingSection(context, preview),
        ],
        if (items is List && items.isNotEmpty) ...[
          const SizedBox(height: 12),
          _section(
            context,
            title: 'محتوى الطلب (${items.length})',
            icon: Icons.inventory_2_outlined,
            children: [
              for (final e in items)
                if (e is Map) _lineTile(context, Map<String, dynamic>.from(e)),
            ],
          ),
        ],
        if (data['order'] is Map) ...[
          const SizedBox(height: 12),
          _section(
            context,
            title: 'الطلب المرتبط',
            icon: Icons.receipt_long_outlined,
            children: [
              _kv(
                'رقم الطلب',
                '${(data['order'] as Map)['orderNumber'] ?? '—'}',
              ),
              _kv('الحالة', '${(data['order'] as Map)['status'] ?? '—'}'),
            ],
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _hero(BuildContext context, bool active) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? const Color(0xffFFF8F0) : const Color(0xffFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active
              ? const Color(0xffF39316).withValues(alpha: 0.4)
              : const Color(0xffE57373),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              orderNumberLabel(data),
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.w700,
                    color: active ? const Color(0xff3C2313) : const Color(0xffB71C1C),
                  ),
            ),
          ),
          Icon(
            active ? Icons.play_circle_outline : Icons.pause_circle_outline,
            color: active ? const Color(0xff01A850) : const Color(0xffC62828),
          ),
        ],
      ),
    );
  }

  Widget _pricingSection(BuildContext context, Map preview) {
    final sub = preview['subtotal'];
    final fee = preview['deliveryFee'];
    final est = preview['estimatedTotal'];
    return _section(
      context,
      title: 'تقدير التكلفة',
      icon: Icons.payments_outlined,
      children: [
        if (sub is num) _kv('المجموع الفرعي', formatMoney(sub)),
        if (fee is num) _kv('التوصيل', formatMoney(fee)),
        if (est is num)
          Text(
            'الإجمالي التقديري: ${formatMoney(est)}',
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xff3C2313),
                ),
          ),
      ],
    );
  }

  Widget _lineTile(BuildContext context, Map<String, dynamic> item) {
    final name = productLineName(item);
    final img = productLineImageUrl(item);
    final packingText = productPackingDisplayLine(item);
    final q = item['quantity'];
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: img != null && img.isNotEmpty
                ? AppNetworkImage(
                    imageUrl: img,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    compact: true,
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: const Color(0xffF3F2F1),
                    child: const Icon(Icons.inventory_2_outlined, size: 22),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                if (packingText.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    packingText,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          fontSize: 13,
                          color: const Color(0xff3C2313),
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
                Text(
                  'الكمية: $q',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontSize: 13,
                        color: const Color(0xff7C7C7C),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xffEFEFEF)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              k,
              style: const TextStyle(
                color: Color(0xff7C7C7C),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              v,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:customer/controller/PinnedOrderEditController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/pinned_order_utils.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PinnedOrderEditScreen extends GetView<PinnedOrderEditController> {
  const PinnedOrderEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      isSub: true,
      namePage: 'تعديل الطلب المثبت',
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      horizontalPadding: 16,
      footer: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Obx(
          () => ButtonAppWidget(
            lable: 'حفظ التعديلات',
            statusRequest: controller.statusSave.value,
            onPressed: controller.save,
          ),
        ),
      ),
      child: Obx(() {
        if (controller.statusRequest.value != StatusRequest.success) {
          return const SizedBox.shrink();
        }
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'التكرار',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final t = controller.repeatType.value;
                return Row(
                  children: [
                    Expanded(
                      child: _segBtn(
                        context,
                        label: 'يومي',
                        selected: t == 'daily',
                        onTap: () => controller.setRepeatType('daily'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _segBtn(
                        context,
                        label: 'أيام محددة',
                        selected: t == 'custom',
                        onTap: () => controller.setRepeatType('custom'),
                      ),
                    ),
                  ],
                );
              }),
              Obx(() {
                if (controller.repeatType.value != 'custom') {
                  return const SizedBox.shrink();
                }
                final selectedDays = List<int>.from(controller.customDays);
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (var d = 0; d < 7; d++)
                        Builder(builder: (context) {
                          final sel = selectedDays.contains(d);
                          return Material(
                            color: sel
                                ? Theme.of(context).primaryColor
                                : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () => controller.toggleDay(d),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: sel
                                        ? Theme.of(context).primaryColor
                                        : const Color(0xffEFEFEF),
                                  ),
                                ),
                                child: Text(
                                  PinnedOrderEditController.arWeekday(d),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                    color: sel
                                        ? Colors.white
                                        : const Color(0xff292929),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 20),
              Text(
                'فترة التوصيل',
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final cur = controller.selectedPeriodId.value;
                return DropdownButtonFormField<String>(
                  initialValue: cur != null &&
                          controller.deliveryPeriods.any(
                            (p) => '${p['_id'] ?? p['id']}' == cur,
                          )
                      ? cur
                      : null,
                  isExpanded: true,
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w400,
                        color: const Color(0xff292929),
                      ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xffF1F1F1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(32),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  items: controller.deliveryPeriods
                      .map((p) {
                        final id = '${p['_id'] ?? p['id'] ?? ''}';
                        final name = (p['name'] ?? p['label'] ?? id).toString();
                        return DropdownMenuItem<String>(
                          value: id.isEmpty ? null : id,
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  fontWeight: FontWeight.w400,
                                ),
                          ),
                        );
                      })
                      .where((e) => e.value != null && e.value!.isNotEmpty)
                      .toList(),
                  onChanged: (v) => controller.setPeriod(v),
                );
              }),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'محتوى الطلب',
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => _openAddSheet(context),
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('إضافة منتج'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() {
                if (controller.lines.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'لا توجد أصناف. اضغط «إضافة منتج».',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: const Color(0xff7C7C7C),
                          ),
                    ),
                  );
                }
                return Column(
                  children: [
                    for (var i = 0; i < controller.lines.length; i++)
                      _lineCard(context, i),
                  ],
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _segBtn(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = Theme.of(context).primaryColor;
    return Material(
      color: selected ? primary.withValues(alpha: 0.12) : const Color(0xffF9F8F8),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: selected ? primary : const Color(0xffEFEFEF)),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: selected ? primary : const Color(0xff292929),
            ),
          ),
        ),
      ),
    );
  }

  Widget _lineCard(BuildContext context, int index) {
    final line = controller.lines[index];
    final url = line.imageFileName != null && line.imageFileName!.isNotEmpty
        ? Applink.productImage(line.imageFileName)
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffFCFCFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffEFEFEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: url.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: url,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        compact: true,
                      )
                    : Container(
                        width: 52,
                        height: 52,
                        color: const Color(0xffF3F2F1),
                        child: const Icon(Icons.inventory_2_outlined),
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      line.name,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    if (line.availablePackings.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: DropdownButtonFormField<String>(
                          key: ValueKey(
                            'pk_${index}_${line.productId}_${line.availablePackings.length}_${resolvePackingDropdownValue(available: line.availablePackings, raw: line.packingRaw)}',
                          ),
                          initialValue: resolvePackingDropdownValue(
                            available: line.availablePackings,
                            raw: line.packingRaw,
                          ),
                          isExpanded: true,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: const Color(0xffF5F5F5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                          ),
                          iconEnabledColor: const Color(0xff3C2313),
                          dropdownColor: Colors.white,
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                fontWeight: FontWeight.w400,
                                color: const Color(0xff3C2313),
                              ),
                          items: line.availablePackings.map((p) {
                            final key = packingKey(Map<String, dynamic>.from(p));
                            final label =
                                '${p['label'] ?? ''} (×${p['quantity'] ?? ''})';
                            return DropdownMenuItem<String>(
                              value: key,
                              child: Text(
                                label,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: const TextStyle(
                                  color: Color(0xff3C2313),
                                  fontSize: 13,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v == null) return;
                            final sel = line.availablePackings
                                .map((e) => Map<String, dynamic>.from(e))
                                .firstWhere(
                                  (p) => packingKey(p) == v,
                                  orElse: () => Map<String, dynamic>.from(
                                    line.availablePackings.first,
                                  ),
                                );
                            controller.selectPackingLine(index, sel);
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton(
                onPressed: () => controller.removeLine(index),
                icon: const Icon(Icons.delete_outline, color: Color(0xffC62828)),
              ),
              const Spacer(),
              const Text('الكمية'),
              IconButton(
                onPressed: line.quantity > 1
                    ? () => controller.bumpQty(index, -1)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                '${line.quantity}',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              IconButton(
                onPressed: () => controller.bumpQty(index, 1),
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _openAddSheet(BuildContext context) async {
    var q = '';
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModal) {
            final filtered = q.trim().isEmpty
                ? controller.productCatalog
                : controller.productCatalog
                    .where(
                      (p) => (p['name'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(q.toLowerCase()),
                    )
                    .toList();
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.7,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      'إضافة منتج',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        decoration: const InputDecoration(
                          labelText: 'بحث',
                          prefixIcon: Icon(Icons.search),
                        ),
                        onChanged: (v) => setModal(() => q = v),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: filtered.length,
                        itemBuilder: (c, i) {
                          final p = filtered[i];
                          final img = p['mainImage']?.toString();
                          final url = img != null && img.isNotEmpty
                              ? Applink.productImage(img)
                              : '';
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: url.isNotEmpty
                                  ? AppNetworkImage(
                                      imageUrl: url,
                                      width: 44,
                                      height: 44,
                                      fit: BoxFit.cover,
                                      compact: true,
                                    )
                                  : const SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: Icon(Icons.image_not_supported),
                                    ),
                            ),
                            title: Text((p['name'] ?? '').toString()),
                            onTap: () {
                              Navigator.pop(ctx);
                              controller.addProductFromCatalog(
                                Map<String, dynamic>.from(p),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

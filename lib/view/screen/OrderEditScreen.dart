import 'package:customer/controller/OrderEditController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/core/functions/pinned_order_utils.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// تعديل محتوى طلب «جديد»: كميات / حذف / إضافة، مع معاينة الإجمالي والفرق على المحفظة.
class OrderEditScreen extends GetView<OrderEditController> {
  const OrderEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      isSub: true,
      namePage: 'تعديل الطلب #${controller.orderNumber}',
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
              const SizedBox(height: 8),
              _summaryCard(context),
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
                      'لا توجد أصناف. أعد صنفاً محذوفاً أو اضغط «إضافة منتج».',
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
              Obx(() {
                if (controller.removed.isEmpty) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'أصناف محذوفة (ستُزال عند الحفظ)',
                        style: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.w700,
                              color: const Color(0xffC62828),
                            ),
                      ),
                      const SizedBox(height: 8),
                      for (var i = 0; i < controller.removed.length; i++)
                        _removedTile(context, i),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _summaryCard(BuildContext context) {
    final primary = Theme.of(context).primaryColor;
    return Obx(() {
      // قراءة القوائم داخل Obx حتى تتحدث المعاينة مع كل تغيير
      final _ = controller.lines.length + controller.removed.length;
      final delta = controller.delta;
      final newTotal = controller.newTotal;
      final String deltaText;
      final Color deltaColor;
      if (delta < 0) {
        deltaText = 'سيُرجع ${formatNumber(-delta)} د.ع إلى محفظتك';
        deltaColor = const Color(0xff12B76A);
      } else if (delta > 0) {
        deltaText = 'سيُخصم ${formatNumber(delta)} د.ع من محفظتك';
        deltaColor = const Color(0xffC62828);
      } else {
        deltaText = 'لا تغيير في الإجمالي';
        deltaColor = const Color(0xff7C7C7C);
      }
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: primary.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryRow(
              context,
              'الإجمالي الحالي',
              '${formatNumber(controller.originalTotal)} د.ع',
            ),
            const SizedBox(height: 6),
            _summaryRow(
              context,
              'الإجمالي بعد التعديل',
              '${formatNumber(newTotal)} د.ع',
              bold: true,
            ),
            const SizedBox(height: 8),
            Text(
              deltaText,
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: deltaColor,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'التعديل متاح ما دام الطلب قيد المراجعة. الأسعار النهائية تُحدَّد من الخادم.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: const Color(0xff7C7C7C),
                    fontSize: 11,
                  ),
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    String value, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: const Color(0xff292929),
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w400,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              ),
        ),
      ],
    );
  }

  Widget _lineImage(String? fileName) {
    final url = fileName != null && fileName.isNotEmpty
        ? Applink.productImage(fileName)
        : '';
    return ClipRRect(
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
    );
  }

  Widget _lineCard(BuildContext context, int index) {
    final line = controller.lines[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffFCFCFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: line.isChanged
              ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
              : const Color(0xffEFEFEF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _lineImage(line.imageFileName),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            line.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall!
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (line.isNew)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xffE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'جديد',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xff2E7D32),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatNumber(line.price)} د.ع'
                      '${line.packQty > 1 ? ' × ${line.packQty}' : ''}'
                      ' = ${formatNumber(line.lineTotal)} د.ع',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: const Color(0xff7C7C7C),
                          ),
                    ),
                    if (line.isNew && line.availablePackings.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: _packingDropdown(context, index, line),
                      )
                    else if (line.packingLabel.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'التعبئة: ${line.packingLabel} (×${line.packQty})',
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: const Color(0xff3C2313),
                              ),
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
                tooltip: 'حذف الصنف',
                icon: const Icon(Icons.delete_outline, color: Color(0xffC62828)),
              ),
              const Spacer(),
              if (!line.isNew && line.quantity != line.originalQuantity)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    'كان ${line.originalQuantity}',
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: const Color(0xff7C7C7C),
                        ),
                  ),
                ),
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

  Widget _packingDropdown(BuildContext context, int index, OrderLineEdit line) {
    return DropdownButtonFormField<String>(
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      ),
      iconEnabledColor: const Color(0xff3C2313),
      dropdownColor: Colors.white,
      style: Theme.of(context).textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w400,
            color: const Color(0xff3C2313),
          ),
      items: line.availablePackings.map((p) {
        final key = packingKey(Map<String, dynamic>.from(p));
        final label = '${p['label'] ?? ''} (×${p['quantity'] ?? ''})';
        return DropdownMenuItem<String>(
          value: key,
          child: Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
            style: const TextStyle(color: Color(0xff3C2313), fontSize: 13),
          ),
        );
      }).toList(),
      onChanged: (v) {
        if (v == null) return;
        final sel = line.availablePackings
            .map((e) => Map<String, dynamic>.from(e))
            .firstWhere(
              (p) => packingKey(p) == v,
              orElse: () => Map<String, dynamic>.from(line.availablePackings.first),
            );
        controller.selectPackingLine(index, sel);
      },
    );
  }

  Widget _removedTile(BuildContext context, int index) {
    final line = controller.removed[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xffFFF5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xffFFCDD2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${line.name} × ${line.originalQuantity}',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: const Color(0xff7C7C7C),
                  ),
            ),
          ),
          TextButton.icon(
            onPressed: () => controller.restoreRemoved(index),
            icon: const Icon(Icons.undo, size: 18),
            label: const Text('تراجع'),
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
                      child: filtered.isEmpty
                          ? const Center(child: Text('لا توجد منتجات'))
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              itemCount: filtered.length,
                              itemBuilder: (c, i) {
                                final p = filtered[i];
                                final img = productMainImageFileName(
                                      Map<String, dynamic>.from(p),
                                    ) ??
                                    p['mainImage']?.toString();
                                return ListTile(
                                  leading: _lineImage(img),
                                  title: Text((p['name'] ?? '').toString()),
                                  subtitle: p['price'] is num
                                      ? Text(
                                          '${formatNumber(p['price'] as num)} د.ع',
                                        )
                                      : null,
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

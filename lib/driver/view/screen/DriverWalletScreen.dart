// ignore_for_file: file_names

import 'package:customer/driver/controller/driver_wallet_controller.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/functions/formatNumber.dart';
import 'package:customer/driver/core/functions/mediated_settlement_labels.dart';
import 'package:customer/driver/view/widget/widgetApp/AppBarwidget.dart';
import 'package:customer/driver/view/widget/widgetApp/NoDataAvailableWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverWalletScreen extends GetView<DriverWalletController> {
  const DriverWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBarWidget(
        hideNotifications: false,
        isSub: false,
        namePage: '',
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _balanceCard(context),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Text(
              'سجل الطلبات',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: MyFontWeight.medium,
                    color: Color(0xff0E0C0C),
                  ),
            ),
          ),
          _filterChips(context),
          Expanded(
            child: Obx(() {
              final req = controller.statusRequest.value;
              final list = controller.settlements;
              final empty = list.isEmpty;
              if (req == StatusRequest.loading && empty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 24),
                    Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Color(0xff9E9E9E),
                        ),
                      ),
                    ),
                  ],
                );
              }
              if (empty && req != StatusRequest.loading) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 40),
                    NoDataAvailableWidget(
                      title: 'لا توجد طلبات',
                      bodyText: 'ستظهر هنا طلبات التحصيل عند إنشائها من الإدارة',
                    ),
                  ],
                );
              }
              return RefreshIndicator(
                color: Theme.of(context).primaryColor,
                onRefresh: controller.refreshList,
                child: ListView.builder(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: controller.settlements.length,
                  itemBuilder: (context, index) {
                    final item = controller.settlements[index];
                    if (item is! Map) return const SizedBox.shrink();
                    final m = Map<String, dynamic>.from(item);
                    return _SettlementTile(
                      data: m,
                      onTap: () => Get.toNamed(
                        '/driver/DriverSettlementDetail',
                        arguments: {'settlement': m},
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  /// أثناء التحديث بعد أول جلب: يبقى المبلغ ظاهراً ومؤشر صغير بجانبه؛ أول مرة فقط مؤشر كبير بدون رقم.
  Widget _balanceAmountRow(BuildContext context, bool loading, int bal) {
    final first = !controller.balanceHasBeenLoaded;
    if (loading && first) {
      return const SizedBox(
        height: 28,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(
            '${formatNumber(bal)} د.ع',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontSize: 22,
                  fontWeight: MyFontWeight.semiBold,
                  color: Color(0xff231F1E),
                ),
          ),
        ),
        if (loading && !first)
          const Padding(
            padding: EdgeInsetsDirectional.only(start: 8),
            child: SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
      ],
    );
  }

  Widget _balanceCard(BuildContext context) {
    return Obx(() {
      final loading = controller.balanceLoading.value;
      final bal = controller.collectionBalance.value;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Color(0xffE7E4E4)),
          color: Colors.white,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xffF39316).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                color: Color(0xffF39316),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'رصيد محفظة التحصيل',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          fontSize: 13,
                          fontWeight: MyFontWeight.light,
                          color: Color(0xff6E615E),
                        ),
                  ),
                  const SizedBox(height: 6),
                  _balanceAmountRow(context, loading, bal),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _filterChips(BuildContext context) {
    return Obx(() {
      final meta = controller.statusMeta;
      final selected = controller.selectedStatus.value;
      return SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          children: [
            _chip(context, 'الكل', 'all', selected),
            ...meta.map((e) {
              final v = e['value']?.toString() ?? '';
              final l = e['labelAr']?.toString() ?? v;
              return _chip(context, l, v, selected);
            }),
          ],
        ),
      );
    });
  }

  Widget _chip(
    BuildContext context,
    String label,
    String value,
    String selected,
  ) {
    final sel = selected == value;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: MyFontWeight.regular,
            color: sel ? Colors.white : Color(0xff5C4F4A),
          ),
        ),
        selected: sel,
        onSelected: (_) => controller.setStatusFilter(value),
        selectedColor: Color(0xffF39316),
        checkmarkColor: Colors.white,
        backgroundColor: Color(0xffF3F2F1),
      ),
    );
  }
}

class _SettlementTile extends StatelessWidget {
  const _SettlementTile({required this.data, required this.onTap});

  final Map<String, dynamic> data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final customer = data['customer'];
    Map<String, dynamic>? c;
    if (customer is Map) c = Map<String, dynamic>.from(customer);

    final store = c?['StoreName']?.toString() ??
        c?['customerName']?.toString() ??
        '—';
    final amount = data['amount'];
    final amtStr = amount is num ? formatNumber(amount.toInt()) : '${amount ?? '—'}';
    final statusLabel = mediatedSettlementDisplayLabelAr(data);
    final statusCode = data['status']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xffE7E4E4)),
        color: Colors.white,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        store,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontSize: 15,
                              fontWeight: MyFontWeight.semiBold,
                              color: Color(0xff231F1E),
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$amtStr د.ع',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontSize: 16,
                              fontWeight: MyFontWeight.semiBold,
                              color: Color(0xffF39316),
                            ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor(statusCode).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: _statusColor(statusCode),
                      fontWeight: MyFontWeight.regular,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'pending_driver_approval':
        return Color(0xff2196F3);
      case 'pending_receipt':
        return Color(0xff9C27B0);
      case 'awaiting_admin_settlement':
        return Color(0xffF39316);
      case 'settled_to_admin':
        return Color(0xff4CAF50);
      case 'rejected':
      case 'cancelled':
        return Color(0xffE53935);
      default:
        return Color(0xff7C7C7C);
    }
  }
}

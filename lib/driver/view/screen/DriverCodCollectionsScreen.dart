// ignore_for_file: file_names

import 'package:customer/driver/controller/driver_cod_collections_controller.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/functions/formatNumber.dart';
import 'package:customer/driver/view/widget/widgetApp/AppBarwidget.dart';
import 'package:customer/driver/view/widget/widgetApp/NoDataAvailableWidget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kOutstanding = Color(0xFFD97706);
const Color _kSettled = Color(0xFF1DBE73);

/// مبالغ «الدفع عند الاستلام»: ما في ذمتي وما تم تسديده للإدارة.
///
/// شاشة مستقلة (لا تبويب داخل المحفظة) — تُفتح من زر في شاشة المحفظة ومن
/// إشعار `DRIVER_COD_SETTLED`.
class DriverCodCollectionsScreen
    extends GetView<DriverCodCollectionsController> {
  const DriverCodCollectionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBarWidget(
          hideNotifications: false,
          isSub: true,
          namePage: 'مبالغ الطلبات النقدية',
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _summaryCards(context),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xffE6E3E1)),
              ),
              child: TabBar(
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: const Color(0xff8C827B),
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: MyFontWeight.semiBold,
                ),
                tabs: const [
                  Tab(text: 'في ذمتي'),
                  Tab(text: 'تم التسديد'),
                ],
              ),
            ),
            Expanded(
              child: Obx(() {
                final req = controller.statusRequest.value;
                if (req == StatusRequest.loading) {
                  return const Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                  );
                }
                return TabBarView(
                  children: [
                    _list(
                      context,
                      rows: controller.outstandingRows,
                      settled: false,
                    ),
                    _list(
                      context,
                      rows: controller.settledRows,
                      settled: true,
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryCards(BuildContext context) {
    return Obx(
      () => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(
          children: [
            Expanded(
              child: _SummaryCard(
                title: 'في ذمتي',
                amount: controller.outstandingAmount.value,
                count: controller.outstandingCount.value,
                color: _kOutstanding,
                icon: Icons.account_balance_wallet_outlined,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryCard(
                title: 'تم التسديد',
                amount: controller.settledAmount.value,
                count: controller.settledCount.value,
                color: _kSettled,
                icon: Icons.task_alt_outlined,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _list(
    BuildContext context, {
    required List<Map<String, dynamic>> rows,
    required bool settled,
  }) {
    if (rows.isEmpty) {
      return RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: controller.refreshData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 40),
            NoDataAvailableWidget(
              title: settled ? 'لا توجد مبالغ مسدَّدة' : 'لا توجد مبالغ في ذمتك',
              bodyText: settled
                  ? 'ستظهر هنا الطلبات بعد أن تستلم الإدارة مبالغها منك'
                  : 'ستظهر هنا مبالغ الطلبات المدفوعة نقداً عند الاستلام',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: controller.refreshData,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: rows.length,
        itemBuilder: (context, index) =>
            _CollectionTile(data: rows[index], settled: settled),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String title;
  final int amount;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xff6B625C),
                  fontWeight: MyFontWeight.medium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${formatNumber(amount)} د.ع',
            style: TextStyle(
              fontSize: 17,
              fontWeight: MyFontWeight.bold,
              color: color,
            ),
          ),
          Text(
            '$count طلب',
            style: const TextStyle(fontSize: 11, color: Color(0xff8C827B)),
          ),
        ],
      ),
    );
  }
}

class _CollectionTile extends StatelessWidget {
  const _CollectionTile({required this.data, required this.settled});

  final Map<String, dynamic> data;
  final bool settled;

  String _text(dynamic v, {String fallback = '—'}) {
    final s = v?.toString().trim() ?? '';
    return s.isEmpty ? fallback : s;
  }

  int _amount() {
    final v = data['amount'];
    if (v is num) return v.round();
    return (double.tryParse(v?.toString() ?? '') ?? 0).round();
  }

  String _dateText() {
    final raw = settled ? data['settledAt'] : data['collectedAt'];
    final s = raw?.toString() ?? '';
    if (s.isEmpty) return '—';
    final d = DateTime.tryParse(s);
    if (d == null) return s;
    final local = d.toLocal();
    final y = local.year;
    final m = local.month.toString().padLeft(2, '0');
    final day = local.day.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$y-$m-$day  $hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final color = settled ? _kSettled : _kOutstanding;
    final orderNumber = _text(data['orderNumber']);
    final deleted = data['orderDeleted'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffE6E3E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  orderNumber == '—' ? 'طلب' : 'طلب #$orderNumber',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: MyFontWeight.semiBold,
                    color: color,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${formatNumber(_amount())} د.ع',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: MyFontWeight.bold,
                  color: const Color(0xff231F1E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 15,
                color: Color(0xff8C827B),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  _text(data['storeName']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xff4A423D),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(
                settled ? Icons.verified_outlined : Icons.schedule,
                size: 15,
                color: const Color(0xff8C827B),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  settled
                      ? 'تم الاستلام: ${_dateText()}'
                      : 'تاريخ التحصيل: ${_dateText()}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xff8C827B),
                  ),
                ),
              ),
            ],
          ),
          if (deleted) ...[
            const SizedBox(height: 5),
            const Text(
              'الطلب محذوف من النظام',
              style: TextStyle(fontSize: 11, color: Color(0xFFDC2626)),
            ),
          ],
        ],
      ),
    );
  }
}

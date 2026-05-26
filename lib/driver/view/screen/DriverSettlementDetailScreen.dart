// ignore_for_file: file_names

import 'package:customer/driver/controller/driver_settlement_detail_controller.dart';
import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/functions/GuidanceExternalapp.dart';
import 'package:customer/driver/core/functions/formatNumber.dart';
import 'package:customer/driver/core/functions/mediated_settlement_labels.dart';
import 'package:customer/driver/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/StoreAvatarCircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DriverSettlementDetailScreen extends GetView<DriverSettlementDetailController> {
  DriverSettlementDetailScreen({super.key});

  PreferredSizeWidget _appBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      leading: InkWell(
        onTap: () => Get.back(),
        child: Icon(Icons.arrow_back_ios, size: 20, color: Color(0xff6C6C6C)),
      ),
      title: Text(
        'تفاصيل التحصيل',
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff6C6C6C),
              fontSize: 16,
              fontWeight: MyFontWeight.regular,
            ),
      ),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _appBar(context),
      body: Obx(() {
        final s = controller.settlement.value;
        final loading = controller.loading.value;

        if (loading && s == null) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: const LinearProgressIndicator(
                  minHeight: 3,
                  color: Color(0xffF39316),
                  backgroundColor: Color(0xffF3F2F1),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'جاري التحميل…',
                  style: TextStyle(
                    color: Color(0xff7C7C7C),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          );
        }

        if (s == null) {
          return Center(
            child: Text(
              'تعذر تحميل الطلب',
              style: TextStyle(color: Color(0xff7C7C7C)),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 8),
            if (_isFailed(s)) _failedBanner(s),
            if (_isFailed(s)) const SizedBox(height: 10),
            _storeCard(context, s),
            const SizedBox(height: 10),
            _detailsCard(context, s),
            const SizedBox(height: 24),
          ],
        );
      }),
      bottomNavigationBar: Obx(() => _bottomBar(context)),
    );
  }

  bool _isFailed(Map<String, dynamic> s) {
    final st = s['status']?.toString() ?? '';
    return st == 'rejected' || st == 'cancelled';
  }

  Widget _failedBanner(Map<String, dynamic> s) {
    final st = s['status']?.toString() ?? '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Color(0xffFFEBEE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Color(0xffE57373).withValues(alpha: 0.5)),
      ),
      child: Text(
        st == 'rejected' ? 'الطلب مرفوض.' : 'الطلب ملغى.',
        style: TextStyle(fontSize: 13, color: Color(0xffC62828)),
      ),
    );
  }

  Map<String, dynamic> _customerForAvatar(Map<String, dynamic> s) {
    final c = s['customer'];
    if (c is! Map) {
      return {'name': '—', 'phone': '', 'storeImage': null};
    }
    final m = Map<String, dynamic>.from(c);
    final name = m['StoreName']?.toString() ?? m['customerName']?.toString() ?? '—';
    return {
      'name': name,
      'phone': m['phone']?.toString() ?? '',
      'storeImage': m['storeImage'],
    };
  }

  Widget _storeCard(BuildContext context, Map<String, dynamic> s) {
    final cust = _customerForAvatar(s);
    final phone = cust['phone']?.toString() ?? '';
    final statusLabel = mediatedSettlementDisplayLabelAr(s);
    final statusCode = s['status']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              StoreAvatarCircle(customers: cust, size: 36),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  cust['name'].toString(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.regular,
                      ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: _statusBadgeColor(statusCode),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white,
                        fontWeight: MyFontWeight.regular,
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xffE7E4E4)),
          if (phone.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'رقم التليفون',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff6E615E),
                        fontSize: 12,
                        fontWeight: MyFontWeight.light,
                      ),
                ),
                Text(
                  phone,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff6E615E),
                        fontSize: 12,
                        fontWeight: MyFontWeight.light,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ButtonAppWidget(
                lable: 'اتصل بالزبون',
                color: Color(0xffF39316),
                onPressed: () => openWhatsAppToPhone(phone: phone),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailsCard(BuildContext context, Map<String, dynamic> s) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xffE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تفاصيل إضافية',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff0E0C0C),
                  fontSize: 20,
                  fontWeight: MyFontWeight.medium,
                ),
          ),
          const Divider(color: Color(0xffE7E4E4)),
          const SizedBox(height: 6),
          _detailLine(context, 'المبلغ', '${formatNumber(_amount(s))} د.ع'),
          _detailLine(context, 'تاريخ الإنشاء', _fmtDate(s['createdAt'])),
          if (s['driverApprovedAt'] != null)
            _detailLine(context, 'موافقة السائق', _fmtDate(s['driverApprovedAt'])),
          if (s['cashReceivedAt'] != null)
            _detailLine(context, 'استلام النقد', _fmtDate(s['cashReceivedAt'])),
          if ((s['note']?.toString() ?? '').isNotEmpty)
            _detailLine(context, 'ملاحظة', s['note'].toString()),
        ],
      ),
    );
  }

  Widget _detailLine(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff999999),
                  fontSize: 14,
                  fontWeight: MyFontWeight.regular,
                ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Color(0xff666666),
                    fontSize: 14,
                    fontWeight: MyFontWeight.regular,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  int _amount(Map<String, dynamic> s) {
    final a = s['amount'];
    if (a is num) return a.toInt();
    return int.tryParse(a?.toString() ?? '') ?? 0;
  }

  String _fmtDate(dynamic v) {
    if (v == null) return '—';
    try {
      final d = DateTime.tryParse(v.toString());
      if (d == null) return v.toString();
      return '${d.year}/${d.month}/${d.day} ${d.hour}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return v.toString();
    }
  }

  Color _statusBadgeColor(String code) {
    switch (code) {
      case 'pending_driver_approval':
        return Color(0xff2196F3);
      case 'pending_receipt':
        return Color(0xff9C27B0);
      case 'awaiting_admin_settlement':
        return Color(0xffF39316);
      case 'settled_to_admin':
        return Color(0xff2E7D32);
      case 'rejected':
      case 'cancelled':
        return Color(0xffE53935);
      default:
        return Color(0xff6E615E);
    }
  }

  Widget _bottomBar(BuildContext context) {
    final snap = controller.settlement.value;
    if (snap == null) return const SizedBox.shrink();

    final status = snap['status']?.toString() ?? '';

    if (status == 'pending_driver_approval') {
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ButtonAppWidget(
                lable: 'الموافقة على الطلب',
                color: Color(0xffF39316),
                onPressed: () => controller.approve(),
                statusRequest:
                    controller.approving.value ? StatusRequest.loading : null,
              ),
            ),
          ],
        ),
      );
    }

    if (status == 'pending_receipt') {
      return SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: ButtonAppWidget(
                lable: 'تم الاستلام من المتجر',
                color: Color(0xffE65100),
                onPressed: () async {
                  if (controller.confirming.value) return;
                  final ok = await Get.dialog<bool>(
                    AlertDialog(
                      title: const Text('تأكيد الاستلام'),
                      content: const Text(
                        'سيتم خصم المبلغ من محفظة الزبون في النظام. هل استلمت المبلغ نقداً من المتجر؟',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(result: false),
                          child: const Text('إلغاء'),
                        ),
                        FilledButton(
                          onPressed: () => Get.back(result: true),
                          child: const Text('تأكيد'),
                        ),
                      ],
                    ),
                    barrierDismissible: false,
                  );
                  if (ok == true) await controller.confirm();
                },
                statusRequest:
                    controller.confirming.value ? StatusRequest.loading : null,
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

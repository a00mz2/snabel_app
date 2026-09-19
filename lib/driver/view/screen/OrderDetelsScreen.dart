import 'package:customer/core/constant/order_rejection_reasons.dart';
import 'package:customer/driver/Widget/OrderProductWidget.dart';
import 'package:customer/driver/controller/OrderDetelsController.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/functions/formatDate.dart';
import 'package:customer/driver/core/functions/formatNumber.dart';
import 'package:customer/driver/core/functions/resolveServerImageUrl.dart';
import 'package:customer/driver/core/functions/snackbar.dart';
import 'package:customer/driver/view/widget/OrderDetails/DeliveryProofConfirmDialog.dart';
import 'package:customer/driver/view/widget/OrderDetails/RejectReasonSheet.dart';
import 'package:customer/driver/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/driver/view/widget/widgetApp/StoreAvatarCircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constant/assets/icons.dart';
import '../../core/functions/GuidanceExternalapp.dart';
import '../../core/functions/statusColors.dart';
import 'package:customer/core/constant/payment_methods.dart';

class OrderDetelsScreen extends StatelessWidget {
  OrderDetelsScreen({super.key});

  final OrderDetelsController controller = Get.find<OrderDetelsController>();

  @override
  Widget build(BuildContext context) {
    return ScaffoldWidget(
      appBarWidget: appbar(context),
      appBar: true,
      namePage: controller.dataOrder['orderNumber'].toString(),
      statusRequest: controller.scaffoldBodyStatus,
      statusCode: controller.statusCode,
      bottomNavigationBar: Obx(() => statusUpdateBotton(context)),

      child: Obx(
        () => ListView(
          padding: EdgeInsets.symmetric(horizontal: 16),
          children: [
            orderInfo(context),
            if (controller.customerNote != null) ...[
              SizedBox(height: 10),
              customerNoteCard(context),
            ],
            if (controller.rejection != null &&
                controller.dataOrder['status'] == 'مرفوض') ...[
              SizedBox(height: 10),
              rejectionCard(context),
            ],
            if (controller.codPending || controller.codCollected) ...[
              SizedBox(height: 10),
              cashOnDeliveryCard(context),
            ],
            if (controller.deliveryProofImage != null) ...[
              SizedBox(height: 10),
              deliveryProofCard(context),
            ],
            SizedBox(height: 10),
            locationInfo(context),
            SizedBox(height: 16),
            periodInfo(context),
            SizedBox(height: 10),
            priceAndProducts(context),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget appbar(context) {
    return AppBar(
      leading: InkWell(
        child: Icon(Icons.arrow_back_ios, size: 20),
        onTap: () => Get.back(),
      ),

      title: Text(
        controller.dataOrder['orderNumber'].toString(),
        style: Theme.of(context).textTheme.titleLarge!.copyWith(
          color: Color(0xff6C6C6C),
          fontSize: 16,
          fontWeight: MyFontWeight.regular,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget orderInfo(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            children: [
              StoreAvatarCircle(
                size: 36,
                customers: controller.dataOrder['customers'],
              ),
              SizedBox(width: 8),
              Text(
                controller.dataOrder['customers']['name'].toString(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 16,
                  fontWeight: MyFontWeight.regular,
                ),
              ),
              Expanded(child: SizedBox()),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: statusOrderColors(controller.dataOrder["status"]),
                ),
                child: Center(
                  child: Text(
                    statusName(controller.dataOrder['status']),
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: MyFontWeight.regular,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Color(0xffE7E4E4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "رقم التليفون",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff6E615E),
                  fontSize: 12,
                  fontWeight: MyFontWeight.light,
                ),
              ),
              Text(
                controller.dataOrder['customers']['phone'].toString(),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff6E615E),
                  fontSize: 12,
                  fontWeight: MyFontWeight.light,
                ),
              ),
            ],
          ),
          // [pay-method] السائق يحتاج معرفة هل يقبض نقداً أم الطلب آجل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "طريقة الدفع",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff6E615E),
                  fontSize: 12,
                  fontWeight: MyFontWeight.light,
                ),
              ),
              Text(
                paymentMethodLabelAr(controller.paymentMethod),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: controller.isCashOrder
                      ? Color(0xffB45309)
                      : Color(0xff6E615E),
                  fontSize: 12,
                  fontWeight: controller.isCashOrder
                      ? MyFontWeight.medium
                      : MyFontWeight.light,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ButtonAppWidget(
              icon: Image.asset(AppIcons.phone, color: Colors.white),
              lable: "اتصل بالزبون",
              onPressed: () => openWhatsAppToPhone(
                phone: controller.dataOrder['customers']['phone'].toString(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDeco({Color? border, Color? fill}) => BoxDecoration(
    color: fill,
    border: Border.all(color: border ?? const Color(0xFFE7E4E4)),
    borderRadius: BorderRadius.circular(8),
  );

  Widget _cardTitle(BuildContext context, String text, IconData icon,
      {Color color = const Color(0xff231F1E)}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        SizedBox(width: 6),
        Text(
          text,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: color,
            fontSize: 14,
            fontWeight: MyFontWeight.medium,
          ),
        ),
      ],
    );
  }

  /// ملاحظة الزبون المرفقة بالطلب.
  Widget customerNoteCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(context, 'ملاحظة الزبون', Icons.sticky_note_2_outlined),
          SizedBox(height: 6),
          Text(
            controller.customerNote ?? '',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff6E615E),
              fontSize: 13,
              fontWeight: MyFontWeight.light,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  /// سبب الرفض المسجَّل على الطلب.
  Widget rejectionCard(BuildContext context) {
    final rej = controller.rejection!;
    final details = rej['details']?.toString().trim() ?? '';
    final by = rejectionByLabelAr(rej);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDeco(
        border: Color(0xffFFCDC9),
        fill: Color(0xffFFF1F0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            context,
            'سبب الرفض',
            Icons.cancel_outlined,
            color: Color(0xffB3261E),
          ),
          SizedBox(height: 6),
          Text(
            rejectionDisplayLabel(rej),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff231F1E),
              fontSize: 14,
              fontWeight: MyFontWeight.regular,
            ),
          ),
          if (details.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              details,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Color(0xff6E615E),
                fontSize: 13,
                fontWeight: MyFontWeight.light,
                height: 1.4,
              ),
            ),
          ],
          if (by.isNotEmpty) ...[
            SizedBox(height: 6),
            Text(
              'بواسطة: $by',
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Color(0xffA19491),
                fontSize: 12,
                fontWeight: MyFontWeight.light,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// تحصيل نقدي مطلوب عند الاستلام (تجاوز الحد الائتماني) + زر التأكيد.
  Widget cashOnDeliveryCard(BuildContext context) {
    final collected = controller.codCollected;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDeco(
        border: collected ? Color(0xff008000) : Color(0xffF39316),
        fill: collected ? Color(0xffE8F5E9) : Color(0xffFFF7E6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(
            context,
            collected
                ? 'تم استلام ${formatNumber(controller.codAmount)} د.ع'
                : 'تحصيل نقدي مطلوب: ${formatNumber(controller.codAmount)} د.ع',
            collected ? Icons.check_circle : Icons.payments_outlined,
            color: collected ? Color(0xff1B5E20) : Color(0xffE65100),
          ),
          SizedBox(height: 4),
          Text(
            collected
                ? 'سُجّل المبلغ في ذمتك بانتظار التسديد للإدارة'
                : '${controller.codPurposeLabel} — يجب تأكيد استلام المبلغ قبل التسليم',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff6E615E),
              fontSize: 12,
              fontWeight: MyFontWeight.light,
            ),
          ),
          if (!collected) ...[
            SizedBox(height: 10),
            SizedBox(
              height: 42,
              child: Obx(
                () => ButtonAppWidget(
                  statusRequest: controller.statusRequestCash.value,
                  color: Color(0xffE65100),
                  lable: 'تأكيد استلام المبلغ',
                  onPressed: () =>
                      AppSnackBar.info("اضغط مطولا لاتمام الاجراء"),
                  onLongPress: () => _confirmCash(context),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// صورة تأكيد التسليم (بعد التسليم).
  Widget deliveryProofCard(BuildContext context) {
    final url = resolveOrderProofUrl(controller.deliveryProofImage);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: _cardDeco(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardTitle(context, 'صورة التسليم', Icons.photo_camera_outlined),
          SizedBox(height: 8),
          InkWell(
            onTap: url.isEmpty
                ? null
                : () => Get.dialog(
                    Dialog(
                      insetPadding: EdgeInsets.all(16),
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4,
                        child: Image.network(url, fit: BoxFit.contain),
                      ),
                    ),
                  ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                url,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  height: 160,
                  alignment: Alignment.center,
                  color: Color(0xffF3F2F1),
                  child: Text('تعذر تحميل الصورة'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// تأكيد استلام المبلغ النقدي من الزبون.
  Future<void> _confirmCash(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('تأكيد استلام المبلغ'),
        content: Text(
          'هل استلمت ${formatNumber(controller.codAmount)} د.ع نقداً من الزبون؟ '
          'سيُسجَّل المبلغ في حساب الزبون وفي ذمتك.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('تأكيد'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await controller.confirmCashCollection(
        controller.dataOrder['_id'].toString(),
      );
    }
  }

  /// رفض الطلب: ورقة أسباب إلزامية ثم الإرسال.
  Future<void> _onRejectLongPress(BuildContext context) async {
    final choice = await showDriverRejectReasonSheet(context);
    if (choice == null) return;
    await controller.updateStatusOrder(
      controller.dataOrder['_id'],
      "مرفوض",
      isReject: true,
      rejection: choice,
    );
  }

  /// التسليم: التقاط صورة بالكاميرا فقط ثم معاينة ثم إرسال.
  Future<void> _onDeliverLongPress(BuildContext context) async {
    XFile? shot;
    try {
      shot = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1600,
      );
    } catch (e) {
      AppSnackBar.error('تعذر فتح الكاميرا');
      return;
    }
    if (shot == null) {
      AppSnackBar.info('يجب التقاط صورة لتأكيد التسليم');
      return;
    }
    final bytes = await shot.readAsBytes();
    if (!context.mounted) return;
    final decision = await showDeliveryProofConfirmDialog(context, bytes);
    if (decision == null) return;
    if (decision == false) {
      if (!context.mounted) return;
      return _onDeliverLongPress(context); // إعادة الالتقاط
    }
    await controller.deliverOrder(
      controller.dataOrder['_id'].toString(),
      bytes,
    );
  }

  Widget locationInfo(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "موقع التسليم",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff0E0C0C),
              fontSize: 20,
              fontWeight: MyFontWeight.medium,
            ),
          ),
          Divider(color: Color(0xffE7E4E4)),
          SizedBox(height: 10),
          Row(
            children: [
              Image.asset(AppIcons.Frame21, width: 16, height: 16),
              SizedBox(width: 8),
              Text(
                "موقع التسليم : ",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff999999),
                  fontSize: 14,
                  fontWeight: MyFontWeight.regular,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  controller.dataOrder['customers']['address'],
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Color(0xff666666),
                    fontSize: 14,
                    fontWeight: MyFontWeight.regular,
                  ),
                ),
              ),

              Image.asset(AppIcons.OrderLocation, width: 20, height: 20),
            ],
          ),

          SizedBox(height: 16),
          SizedBox(
            height: 40,
            child: ButtonAppWidget(
              primaryButton: false,
              icon: Image.asset(
                AppIcons.OrderLocation,
                width: 20,
                height: 20,
                color: Theme.of(context).primaryColorDark,
              ),
              lable: "عرض الموقع",
              onPressed: () {
                final customer = controller.dataOrder['customers'];
                if (customer is! Map) {
                  AppSnackBar.error("الموقع غير متوفر");
                  return;
                }
                final storeLocation = customer['storeLocation'];
                if (storeLocation is! String || storeLocation.trim().isEmpty) {
                  AppSnackBar.error("الموقع غير متوفر");
                  return;
                }

                final loc = parseGoogleMapsDestination(storeLocation);
                if (loc.isEmpty) {
                  AppSnackBar.error("الموقع غير متوفر");
                  return;
                }

                openInMapsFromData(loc);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget periodInfo(context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "موعد التسليم",
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Color(0xff0E0C0C),
              fontSize: 20,
              fontWeight: MyFontWeight.medium,
            ),
          ),

          Divider(color: Color(0xffE7E4E4)),
          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                overflow: TextOverflow.ellipsis,
                "موعد التسليم",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
              Text(
                overflow: TextOverflow.ellipsis,
                formatDate(controller.dataOrder['deliveryDate']),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                overflow: TextOverflow.ellipsis,
                "الفترة",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
              Text(
                overflow: TextOverflow.ellipsis,
                "${controller.dataOrder['deliveryPeriod']['name']}",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff231F1E),
                  fontSize: 14,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget priceAndProducts(context) {
    final editing = controller.editMode.value;
    final items = controller.visibleItems;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFE7E4E4)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "المنتجات",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Color(0xff0E0C0C),
                  fontSize: 20,
                  fontWeight: MyFontWeight.medium,
                ),
              ),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "(${items.length} منتجات)",
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Color(0xff0E0C0C),
                    fontSize: 14,
                    fontWeight: MyFontWeight.regular,
                  ),
                ),
              ),
              // تعديل المحتوى قبل التسليم (قيد التوصيل / مع السائق فقط)
              if (controller.canEditContent)
                TextButton.icon(
                  onPressed: editing
                      ? controller.cancelEdit
                      : controller.startEdit,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    visualDensity: VisualDensity.compact,
                  ),
                  icon: Icon(
                    editing ? Icons.close : Icons.edit_outlined,
                    size: 18,
                  ),
                  label: Text(
                    editing ? "إلغاء" : "تعديل المحتوى",
                    style: TextStyle(fontSize: 13),
                  ),
                ),
            ],
          ),
          if (editing)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                "قلّل الكميات أو احذف الأصناف غير المستلمة ثم احفظ. لا يمكن زيادة الكميات أو إضافة أصناف.",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Color(0xffF39316),
                  fontSize: 12,
                ),
              ),
            )
          else if (controller.partialDelivery && controller.canEditContent)
            Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Text(
                "عُدِّل محتوى الطلب قبل التسليم — سيُسجَّل «واصل جزئي» عند التسليم.",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Color(0xff0E9F6E),
                  fontSize: 12,
                ),
              ),
            ),
          Divider(color: Color(0xffE7E4E4)),
          SizedBox(height: 10),
          ListView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => OrderProductWidget(
              index: index,
              length: items.length,
              dataOrder: items[index],
              editing: editing,
              onDecrement: editing
                  ? () => controller.decrementItem(index)
                  : null,
              onIncrement: editing && controller.canIncrement(index)
                  ? () => controller.incrementItem(index)
                  : null,
              onRemove: editing ? () => controller.removeItem(index) : null,
            ),
          ),

          SizedBox(height: 16),

          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Color(0xffF9F8F8),
              borderRadius: BorderRadius.circular(4),
            ),

            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "المجموع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 14,
                        fontWeight: MyFontWeight.medium,
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "${formatNumber(controller.previewSubtotal)}  د.ع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "تكلفة التوصيل",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 14,
                        fontWeight: MyFontWeight.medium,
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "${formatNumber(controller.deliveryFee)}  د.ع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      overflow: TextOverflow.ellipsis,
                      "المجموع الكلي",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 14,
                        fontWeight: MyFontWeight.medium,
                      ),
                    ),
                    Text(
                      overflow: TextOverflow.ellipsis,
                      // totalPrice يشمل رسوم التوصيل أصلاً (كان يُجمع مرتين)
                      "${formatNumber(controller.previewTotal)}  د.ع",
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Color(0xff231F1E),
                        fontSize: 16,
                        fontWeight: MyFontWeight.semiBold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget statusUpdateBotton(BuildContext context) {
    final raw =
        controller.dataOrder['status']?.toString().trim() ?? '';
    // وضع تعديل المحتوى: زر الحفظ بدل أزرار الحالة
    if (controller.editMode.value) {
      return SafeArea(
        child: Container(
          height: 64,
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Obx(
            () => ButtonAppWidget(
              statusRequest: controller.statusSaveContent.value,
              lable: "حفظ التعديلات",
              onPressed: controller.saveContentEdit,
            ),
          ),
        ),
      );
    }
    return SafeArea(
      child: Container(
        height: 64,
        width: double.infinity,
        color: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: raw == 'تم التجهيز'
            ? Obx(
                () => ButtonAppWidget(
                  statusRequest: controller.statusRequest.value,
                  lable: "استلام الطلب",
                  onPressed: () =>
                      AppSnackBar.info("اضغط مطولا لاتمام الاجراء"),
                  onLongPress: () => controller.updateStatusOrder(
                    controller.dataOrder['_id'],
                    "قيد التوصيل",
                  ),
                ),
              )
            : raw == 'قيد التوصيل'
            ? Obx(
                () => ButtonAppWidget(
                  statusRequest: controller.statusRequest.value,
                  primaryButton: false,
                  color: Colors.grey,
                  lable: "تم الاستلام",
                  onPressed: () =>
                      AppSnackBar.info("اضغط مطولا لاتمام الاجراء"),
                  onLongPress: () => controller.updateStatusOrder(
                    controller.dataOrder['_id'],
                    "مع السائق",
                  ),
                ),
              )
            : raw == 'مع السائق'
            ? Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => ButtonAppWidget(
                        statusRequest:
                            controller.statusRequestButtonreject.value,
                        color: Colors.red,
                        primaryButton: false,
                        lable: "مرفوض",
                        textColor: Colors.red,
                        onPressed: () =>
                            AppSnackBar.info("اضغط مطولا لاتمام الاجراء"),
                        onLongPress: () => _onRejectLongPress(context),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Obx(() {
                      // التحصيل النقدي أولاً، ثم التسليم بصورة تأكيد من الكاميرا
                      final blocked = controller.codPending;
                      return ButtonAppWidget(
                        statusRequest: controller.statusRequest.value,
                        color: blocked ? Colors.grey : Colors.green,
                        lable: blocked
                            ? "أكّد استلام المبلغ أولاً"
                            // بعد تعديل المحتوى يسجّل الخادم «واصل جزئي»
                            : controller.partialDelivery
                            ? "تسليم جزئي"
                            : "تم التسليم",
                        onPressed: () => AppSnackBar.info(
                          blocked
                              ? "يجب تأكيد استلام المبلغ النقدي قبل التسليم"
                              : "اضغط مطولا لاتمام الاجراء",
                        ),
                        onLongPress: blocked
                            ? () => AppSnackBar.info(
                                "يجب تأكيد استلام المبلغ النقدي قبل التسليم",
                              )
                            : () => _onDeliverLongPress(context),
                      );
                    }),
                  ),
                ],
              )
            : SizedBox(),
      ),
    );
  }
}

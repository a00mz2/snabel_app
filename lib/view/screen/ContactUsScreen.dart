import 'package:customer/controller/ContactUsController.dart';
import 'package:customer/core/class/statusRequest.dart';
import 'package:customer/linkApi.dart';
import 'package:customer/view/widget/widgetApp/ScaffoldWidget.dart';
import 'package:customer/view/widget/widgetApp/app_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

const Color _kTextMain = Color(0xff292929);
const Color _kTextMuted = Color(0xff7C7C7C);
const Color _kCardBorder = Color(0xffEFEFEF);
const Color _kChipBg = Color(0xffF9F8F8);

class ContactUsScreen extends GetView<ContactUsController> {
  const ContactUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).primaryColor;

    return ScaffoldWidget(
      isSub: true,
      namePage: 'تواصل معنا',
      onRefresh: () => controller.load(),
      statusRequest: controller.statusRequest,
      statusCode: controller.statusCode,
      horizontalPadding: 16,
      child: Obx(() {
        if (controller.statusRequest.value == StatusRequest.success &&
            controller.contactMethods.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Text(
                'لا توجد وسائل تواصل متاحة حالياً',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: _kTextMuted,
                    ),
              ),
            ),
          );
        }

        return ListView(
          physics: const BouncingScrollPhysics(),
          children: [
            _introBanner(primary: primary),
            const SizedBox(height: 18),
            ...controller.contactMethods.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _ContactMethodTile(
                  data: row,
                  primary: primary,
                  onTap: () => controller.openMethod(row),
                  fallbackIcon: controller.iconForKey(
                    row['platformKey']?.toString(),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        );
      }),
    );
  }

  Widget _introBanner({required Color primary}) {
    return Builder(
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.22)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.support_agent_rounded,
              size: 40,
              color: primary,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'نسعد بخدمتك',
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _kTextMain,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اختر وسيلة التواصل المناسبة؛ سنرد عليك بأسرع وقت ممكن.',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: _kTextMuted,
                          height: 1.45,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactMethodTile extends StatelessWidget {
  const _ContactMethodTile({
    required this.data,
    required this.primary,
    required this.onTap,
    required this.fallbackIcon,
  });

  final Map<String, dynamic> data;
  final Color primary;
  final VoidCallback onTap;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    final title = (data['title'] ?? 'وسيلة تواصل').toString();
    final value = (data['value'] ?? '').toString();
    final iconPath = data['icon']?.toString().trim() ?? '';
    final imageUrl =
        iconPath.isNotEmpty ? Applink.imageUrl(iconPath) : '';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kCardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imageUrl.isNotEmpty
                    ? AppNetworkImage(
                        imageUrl: imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        compact: true,
                      )
                    : Container(
                        width: 52,
                        height: 52,
                        color: _kChipBg,
                        alignment: Alignment.center,
                        child: Icon(
                          fallbackIcon,
                          color: primary,
                          size: 28,
                        ),
                      ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.w700,
                            color: _kTextMain,
                          ),
                    ),
                    if (value.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        value,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: _kTextMuted,
                              fontSize: 13,
                            ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right_rounded,
                color: primary.withValues(alpha: 0.7),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

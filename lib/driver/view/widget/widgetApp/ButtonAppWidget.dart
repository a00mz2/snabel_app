// ignore_for_file: sort_child_properties_last, deprecated_member_use, file_names

import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';

class ButtonAppWidget extends StatelessWidget {
  const ButtonAppWidget({
    super.key,
    this.onPressed,
    this.primaryButton = true,
    this.lable,
    this.statusRequest,
    this.color = const Color(0xff3C2313),
    this.icon,
    this.textColor,
    this.radius = 12,
    this.fontWeight,
    this.fontSize = 14,
    this.elevation,
    this.onLongPress,
  });

  final bool? primaryButton;
  final String? lable;
  final Function()? onPressed;
  final Function()? onLongPress;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final StatusRequest? statusRequest;

  final double? radius;

  final FontWeight? fontWeight;
  final double? fontSize;
  final double? elevation;

  @override
  Widget build(BuildContext context) {
    final loading = statusRequest == StatusRequest.loading;

    // داخل bottomNavigationBar قد يُمرَّر ارتفاع غير محدود فيُوسّع MaterialButton ليملأ الشاشة
    // ويظهر كـ «شاشة برتقالية» مع المؤشر في المنتصف — نفرض ارتفاعاً ثابتاً من الخارج.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;
        return SizedBox(
          height: 48,
          width: w,
          child: MaterialButton(
            elevation: elevation,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            color: (primaryButton == false
                ? null
                : color ?? Theme.of(context).primaryColorDark),
            onPressed: loading ? null : onPressed,
            onLongPress: loading ? null : onLongPress,
            height: 48,
            minWidth: 0,
            shape: color != null && primaryButton != false
                ? RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(radius!),
                  )
                : RoundedRectangleBorder(
                    side: primaryButton == false
                        ? BorderSide(
                            color: color ?? Theme.of(context).primaryColorDark,
                          )
                        : BorderSide.none,
                    borderRadius: BorderRadius.circular(radius!),
                  ),
            child: loading
                ? Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: textColor ??
                            (primaryButton!
                                ? Colors.white
                                : Theme.of(context).primaryColorDark),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 4,
                    children: [
                      icon ?? SizedBox(),
                      Text(
                        lable.toString(),
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              fontSize: fontSize,
                              fontWeight: fontWeight ?? MyFontWeight.semiBold,
                              color: primaryButton == false
                                  ? textColor ??
                                      Theme.of(context).primaryColorDark
                                  : textColor ?? Colors.white,
                            ),
                      ),
                    ],
                  ),
            disabledColor: primaryButton!
                ? color!.withOpacity(0.6)
                : Colors.transparent,
          ),
        );
      },
    );
  }
}

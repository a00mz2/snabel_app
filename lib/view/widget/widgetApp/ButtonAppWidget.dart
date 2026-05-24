// ignore_for_file: sort_child_properties_last, deprecated_member_use, file_names

import 'package:customer/core/class/statusRequest.dart';
import 'package:flutter/material.dart';

class ButtonAppWidget extends StatelessWidget {
  const ButtonAppWidget({
    super.key,
    this.onPressed,
    this.primaryButton = true,
    this.lable,
    this.statusRequest,
    this.color,
    this.icon,
    this.textColor,
  });

  final bool? primaryButton;
  final String? lable;
  final Function()? onPressed;
  final Color? color;
  final Color? textColor;
  final Widget? icon;
  final StatusRequest? statusRequest;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      color: (primaryButton == false
          ? null
          : color ?? Theme.of(context).primaryColorDark),
      onPressed: statusRequest != StatusRequest.loading ? onPressed : null,
      height: 52,
      minWidth: double.infinity,
      shape: color != null && primaryButton != false
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(32))
          : RoundedRectangleBorder(
              side: primaryButton == false
                  ? BorderSide(
                      color: color ?? Theme.of(context).primaryColorDark,
                    )
                  : BorderSide.none,
              borderRadius: BorderRadius.circular(32),
            ),

      child: statusRequest != StatusRequest.loading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                icon ?? SizedBox(),
                Text(
                  lable.toString(),
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryButton == false
                        ? textColor ?? Theme.of(context).primaryColorDark
                        : textColor ?? Colors.white,
                  ),
                ),
              ],
            )
          : Center(
              child: CircularProgressIndicator(
                color:
                    textColor ??
                    (primaryButton!
                        ? Colors.white
                        : Theme.of(context).primaryColorDark),
              ),
            ),

      disabledColor: primaryButton!
          ? Theme.of(context).primaryColorDark.withOpacity(0.6)
          : Colors.transparent,
    );
  }
}

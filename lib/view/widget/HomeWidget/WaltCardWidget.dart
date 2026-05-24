import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:customer/view/widget/widgetApp/StatusCard.dart';
import 'package:flutter/material.dart';

class WaltCardWidget extends StatelessWidget {
  const WaltCardWidget({
    super.key,
    required this.balance,
    this.showRegistericon = true,
    this.onTap,
  });

  final num balance;
  final bool? showRegistericon;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return StatusCardLarge(
      lable: "رصيد المحفظة",
      value: formatNumberNum(balance),
      actionCild: showRegistericon!
          ? InkWell(
              onTap: onTap,
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100000),
                      color: Color(0xffF3F2F1),
                    ),
                    child: Center(
                      child: Image.asset(
                        width: 20,
                        height: 20,
                        AppIcons.hugeicons_transactionhistory,
                      ),
                    ),
                  ),
                  Text(
                    "عرض السجل",
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Color(0xff231F1E),
                      fontSize: 11,
                      fontWeight: MyFontWeight.light,
                    ),
                  ),
                ],
              ),
            )
          : SizedBox(),
    );
  }
}

import 'package:customer/controller/WalletController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:customer/core/functions/formatNumber.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TransactionWidget extends StatelessWidget {
  const TransactionWidget({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Container(
      padding: EdgeInsets.only(top: 8, bottom: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xffF3F2F1))),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 44,
            height: 40,
            child: Stack(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xffEDEBE9),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      controller.dataWallet['transactions'][index]['type'] ==
                              'deduct'
                          ? AppIcons.projectIcon
                          : controller
                                    .dataWallet['transactions'][index]['type'] ==
                                'transfer'
                          ? AppIcons.amountIcon
                          : AppIcons.dateIcon,
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: Container(
                    width: 13.33,
                    height: 13.33,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          controller
                                  .dataWallet['transactions'][index]['type'] ==
                              'deduct'
                          ? Colors.red
                          : controller
                                    .dataWallet['transactions'][index]['type'] ==
                                'transfer'
                          ? Color(0xff12B76A)
                          : Colors.black,
                    ),
                    child: Icon(
                      controller.dataWallet['transactions'][index]['type'] ==
                              'deduct'
                          ? Icons.remove
                          : Icons.add,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  "${controller.dataWallet['transactions'][index]['description']}",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Color(0xff231F1E),
                    fontWeight: MyFontWeight.regular,
                    fontSize: 14,
                  ),
                ),
                Text(
                  overflow: TextOverflow.ellipsis,
                  formatDate(
                    controller.dataWallet['transactions'][index]['createdAt'],
                  ),
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Color(0xff6E615E),
                    fontWeight: MyFontWeight.regular,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6),
          Text(
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            "${formatNumber(controller.dataWallet['transactions'][index]['amount'])}  د.ع",
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Color(0xff231F1E),
              fontWeight: MyFontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

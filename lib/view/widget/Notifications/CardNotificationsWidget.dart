import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:flutter/material.dart';

class CardNotificationsWidget extends StatelessWidget {
  const CardNotificationsWidget({
    super.key,
    required this.index,
    required this.title,
    required this.body,
    required this.date,
    required this.isRead,
    this.onTap,
  });
  final int index;
  final String title, body, date;
  final bool isRead;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isRead ? null : Color(0xffF5F5F5),
            border: Border(
              bottom: BorderSide(
                color: isRead ? Color(0xffD3D3D3) : Colors.white,
              ),
            ),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                child: Image.asset(
                  width: 30,
                  height: 30,
                  isRead ? AppIcons.notificationAc : AppIcons.notification,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            maxLines: 2,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontSize: 16,
                                  fontWeight: MyFontWeight.medium,
                                  color: Color(0xff3C2313),
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ),
                        ),
                        Text(
                          formatTimeAgo(date),
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                fontSize: 14,
                                fontWeight: MyFontWeight.light,
                                color: Color(0xff6C6C6C),
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontSize: 14,
                            fontWeight: MyFontWeight.light,
                            color: Color(0xff6C6C6C),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

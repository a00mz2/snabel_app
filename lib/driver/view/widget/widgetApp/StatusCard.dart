// ignore_for_file: deprecated_member_use

import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/core/constant/assets/images.dart';
import 'package:flutter/material.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.lable,
    required this.value,
    required this.icon,
  });
  final String lable, value, icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),

        color: Theme.of(context).primaryColorDark,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white.withOpacity(0.1),
            child: Image.asset(icon),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lable,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: MyFontWeight.regular,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value != "null" ? value : "",
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: MyFontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatusCardLarge extends StatelessWidget {
  const StatusCardLarge({
    super.key,
    required this.lable,
    required this.value,
    this.actionCild,
  });
  final String lable, value;
  final Widget? actionCild;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 85,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),

        color: Color(0xffF9F8F8),
        image: DecorationImage(
          image: AssetImage(AppImage.backgroondStatusCard),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                lable,
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Color(0xffA19491),
                  fontSize: 12,
                  fontWeight: MyFontWeight.light,
                ),
              ),
              Text(
                value != "null" ? value : "",
                style: Theme.of(context).textTheme.titleSmall!.copyWith(
                  color: Theme.of(context).primaryColorDark,
                  fontSize: 28,
                  fontWeight: MyFontWeight.semiBold,
                ),
              ),
            ],
          ),
          actionCild ?? SizedBox(),
        ],
      ),
    );
  }
}

class ListStatusCard extends StatelessWidget {
  const ListStatusCard({
    super.key,
    required this.data,
    this.marginhorizontal = 16,
  });
  final List data;
  final double? marginhorizontal;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      width: double.infinity,
      child: ListView.separated(
        shrinkWrap: false,
        physics: ClampingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        itemBuilder: (context, index) => Container(
          margin: EdgeInsets.only(
            right: index == 0 ? marginhorizontal! : 0,
            left: index == data.length - 1 ? marginhorizontal! : 0,
          ),
          child: StatusCard(
            lable: data[index]["lable"],
            value: data[index]["value"].toString(),
            icon: data[index]["icon"],
          ),
        ),

        separatorBuilder: (context, index) => SizedBox(width: 8),
      ),
    );
  }
}

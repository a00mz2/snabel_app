import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';

class ListButtonTab extends StatelessWidget {
  final int status;
  final Function(int) onTap;

  final List children;

  const ListButtonTab({
    super.key,
    required this.status,
    required this.children,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 45,
          width: double.infinity,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            itemBuilder: (context, index) => Container(
              margin: EdgeInsets.only(),
              child: ButtonTab(
                index: index,
                lapel: children[index],
                status: status,
                onTap: () => onTap(index),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ButtonTab extends StatelessWidget {
  final int index, status;
  final String lapel;
  final void Function()? onTap;

  const ButtonTab({
    super.key,
    required this.index,
    required this.lapel,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isActive = index == status;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: IntrinsicWidth(
        child: Container(
          alignment: Alignment.center,
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white, // الخلفية بيضاء دائماً
            border: Border(
              bottom: BorderSide(
                color: isActive
                    ? Theme.of(context).primaryColorDark
                    : Color(0xffB8AFAD),
                width: 2.5,
              ),
            ),
          ),
          child: Text(
            lapel,
            style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontSize: 14,
              fontWeight: isActive ? MyFontWeight.bold : MyFontWeight.regular,
              color: isActive
                  ? Theme.of(context)
                        .primaryColorDark // لون البرتقالي للتبويب النشط
                  : const Color(0xff7A7A7A), // رمادي لغير النشط
            ),
          ),
        ),
      ),
    );
  }
}

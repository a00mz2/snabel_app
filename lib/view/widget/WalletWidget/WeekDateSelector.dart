import 'package:customer/controller/WalletController.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletDateSelector extends StatelessWidget {
  const WalletDateSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xffF3F2F1)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 العنوان + الشهر + أزرار التبديل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => Row(
                  children: [
                    Image.asset(AppIcons.dateIcon, width: 20, height: 20),
                    const SizedBox(width: 4),
                    Text(
                      controller.monthName,
                      style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: const Color(0xff231F1E),
                        fontWeight: MyFontWeight.light,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: controller.prevMonth,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffF3F2F1),
                      ),
                      child: const Icon(
                        Icons.chevron_left,
                        size: 16,
                        color: Color(0xff231F1E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: controller.nextMonth,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xffF3F2F1),
                      ),
                      child: const Icon(
                        Icons.chevron_right,
                        size: 16,
                        color: Color(0xff231F1E),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 🔹 شريط أيام الشهر (قابل للتمرير أفقياً)
          Obx(() {
            final days = controller.daysInMonth;

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: days.map((day) {
                  final isSelected =
                      controller.selectedDate.value != null &&
                      DateFormat('yyyy-MM-dd').format(day) ==
                          DateFormat(
                            'yyyy-MM-dd',
                          ).format(controller.selectedDate.value!);

                  return GestureDetector(
                    onTap: () => controller.selectDate(day),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).primaryColorDark
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEE', 'ar').format(day),
                            style: Theme.of(context).textTheme.bodyMedium!
                                .copyWith(
                                  fontSize: 13,
                                  fontWeight: MyFontWeight.light,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xff989898),
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${day.day}',
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

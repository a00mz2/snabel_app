// ignore_for_file: file_names

import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:customer/core/functions/formatDate.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

class DateSelectorWidget extends StatelessWidget {
  final Rxn<DateTime> selectedDate;
  final Function()? onTap;

  const DateSelectorWidget({super.key, required this.selectedDate, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ✅ العنوان
          Row(
            children: [
              Image.asset(AppIcons.dateIcon, width: 20, height: 20),
              const SizedBox(width: 8),
              Obx(
                () => Text(
                  selectedDate.value != null
                      ? "اليوم المحدد: ${formatDate(selectedDate.value!.toLocal())}"
                      : "حدّد يوم الاستلام",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    fontSize: 16,
                    color: const Color(0xFF7C7C7C),
                    fontFamily: "Hanimation Arabic",
                    fontWeight: MyFontWeight.light,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ✅ التقويم مع تعديل الارتفاع
          Obx(() {
            return TableCalendar(
              locale: 'ar',
              firstDay: DateTime.now(),
              lastDay: DateTime(2035),
              focusedDay: selectedDate.value ?? DateTime.now(),
              selectedDayPredicate: (day) =>
                  selectedDate.value != null &&
                  isSameDay(day, selectedDate.value),
              onDaySelected: (selectedDay, focusedDay) {
                selectedDate.value = selectedDay;
                onTap?.call();
              },
              rowHeight: 46, // 👈 زيادة المسافة العمودية لكل صف من أيام الأسبوع
              daysOfWeekHeight: 32, // 👈 لتوسيع صف أسماء الأيام (الأعلى)
              calendarStyle: CalendarStyle(
                isTodayHighlighted: true,
                todayDecoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: const BoxDecoration(
                  color: Color(0xffF39316),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                defaultTextStyle: const TextStyle(color: Colors.black),
                weekendTextStyle: const TextStyle(color: Colors.black87),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff231F1E),
                ),
                weekendStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xff231F1E),
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Color(0xff231F1E),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: Color(0xff231F1E),
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Color(0xff231F1E),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

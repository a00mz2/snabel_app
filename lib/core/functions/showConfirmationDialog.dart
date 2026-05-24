import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/constant/assets/icons.dart';
import 'package:flutter/material.dart';

Future<bool?> showConfirmationDialog(
  BuildContext context, {
  String title = "هل أنت متأكد من حذف هذه العنصر ؟",
  String subtitle = "لا يمكن التراجع عن هذه الخطوة",
  Widget? icon,
  bool showcancelBotton = true,
  String? textActivButton = "نعم",

  Color? colorActivButton = const Color(0xffF39316),
}) async {
  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: 320,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // أيقونة الحذف
                icon ?? Image.asset(AppIcons.delete),
                const SizedBox(height: 12),
                // العنوان
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: MyFontWeight.bold,
                    color: Color(0xff292929),
                  ),
                ),
                const SizedBox(height: 4),

                // النص الثانوي
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 14,
                    fontWeight: MyFontWeight.regular,
                    color: Color(0xff7C7C7C),
                  ),
                ),
                const SizedBox(height: 12),

                // الأزرار
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorActivButton,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(true),
                        child: Text(
                          textActivButton!,
                          style: Theme.of(context).textTheme.titleLarge!
                              .copyWith(
                                fontSize: 14,
                                fontWeight: MyFontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    showcancelBotton
                        ? Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.shade200,
                                foregroundColor: Colors.black87,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text("إلغاء"),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

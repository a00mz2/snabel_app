// ignore_for_file: library_private_types_in_public_api

import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:customer/core/services/services.dart';
import 'package:customer/view/widget/widgetApp/textBox.dart';
import 'package:flutter/material.dart';

TextEditingController serverAddressTextController = TextEditingController();

Future setServer(BuildContext context) async {
  serverAddressTextController.text = myServices.sharedPreferences
      .getString("server")
      .toString();

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
                const SizedBox(height: 12),
                // العنوان
                Text(
                  "ادخل عنوان الخادم",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    fontSize: 16,
                    fontWeight: MyFontWeight.bold,
                    color: Color(0xff292929),
                  ),
                ),
                const SizedBox(height: 4),
                // النص الثانوي
                TextBoxs(
                  controller: serverAddressTextController,
                  hintText: "ادخل عنوان الخادم",
                ),
                const SizedBox(height: 12),
                // الأزرار
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          myServices.sharedPreferences.setString(
                            "server",
                            serverAddressTextController.text,
                          );
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "حفض",
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
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade200,
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: const Text("إلغاء"),
                      ),
                    ),
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

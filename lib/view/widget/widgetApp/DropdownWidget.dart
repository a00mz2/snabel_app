// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:customer/core/constant/Themes/lightThem.dart';

class DropdownWidget<T> extends StatelessWidget {
  const DropdownWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemLabelBuilder,
    this.hintText = "اختر عنصرًا",
    this.prefixIcon,
    this.validator = true,
  });

  final List<T> items;
  final T? selectedItem;
  final void Function(T value) onChanged;
  final String Function(T item) itemLabelBuilder;
  final String hintText;
  final Widget? prefixIcon;
  final bool? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: ValueKey(selectedItem),
      initialValue: selectedItem,
      isExpanded: true,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 241, 241, 241),
        prefixIcon: prefixIcon,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.transparent, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: BorderSide(
            color: Theme.of(context).primaryColor,
            width: 1.2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(32),
          borderSide: const BorderSide(color: Colors.red, width: 1.2),
        ),
      ),

      hint: Text(
        hintText,
        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          fontSize: 16,
          color: const Color(0xFF7C7C7C),
          fontFamily: "Hanimation Arabic",
          fontWeight: MyFontWeight.light,
          height: 1.0,
        ),
      ),

      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF7C7C7C)),

      validator: (value) {
        if (items.isEmpty || (value == null && validator!)) {
          return "لا يمكن ترك الحقل فارغ";
        }
        return null;
      },

      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(
            itemLabelBuilder(item),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 16,
              color: Colors.black87,
              fontFamily: "Hanimation Arabic",
              fontWeight: MyFontWeight.light,
            ),
          ),
        );
      }).toList(),

      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}

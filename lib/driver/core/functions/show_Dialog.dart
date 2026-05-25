// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';

void show_Dialog(BuildContext context, StatelessWidget child, double height) {
  showDialog(
    context: context,
    builder: (_) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
        backgroundColor: Theme.of(context).primaryColorLight,
        surfaceTintColor: Colors.transparent,
        content: Container(
          alignment: Alignment.center,
          width: 478,
          height: height,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context).primaryColorLight,
          ),
          child: child,
        ),
      ),
    ),
  );
}

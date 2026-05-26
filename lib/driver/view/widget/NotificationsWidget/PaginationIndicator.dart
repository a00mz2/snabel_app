import 'package:customer/driver/core/class/statusRequest.dart';
import 'package:flutter/material.dart';

class PaginationIndicator extends StatelessWidget {
  const PaginationIndicator({
    super.key,
    required this.index,
    required this.listlength,
    required this.statusRequestPagination,
  });

  final int index, listlength;
  final StatusRequest statusRequestPagination;

  @override
  Widget build(BuildContext context) {
    return index == listlength - 1
        ? SizedBox(
            height: 5,
            child: statusRequestPagination == StatusRequest.loading
                ? Center(
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : const SizedBox(),
          )
        : const SizedBox();
  }
}

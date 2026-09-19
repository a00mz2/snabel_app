import 'package:customer/core/constant/Themes/lightThem.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// حوار كتابة الكمية رقمياً (بديل أزرار + / −). يعيد الكمية أو `null` عند الإلغاء.
Future<int?> showQuantityInputDialog(
  BuildContext context, {
  required int current,
  int min = 1,
  int max = 9999,
}) {
  return showDialog<int>(
    context: context,
    builder: (_) => _QuantityInputDialog(current: current, min: min, max: max),
  );
}

class _QuantityInputDialog extends StatefulWidget {
  const _QuantityInputDialog({
    required this.current,
    required this.min,
    required this.max,
  });

  final int current;
  final int min;
  final int max;

  @override
  State<_QuantityInputDialog> createState() => _QuantityInputDialogState();
}

class _QuantityInputDialogState extends State<_QuantityInputDialog> {
  late final TextEditingController _ctrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    final text = '${widget.current}';
    _ctrl = TextEditingController(text: text)
      ..selection = TextSelection(baseOffset: 0, extentOffset: text.length);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirm() {
    final n = int.tryParse(_ctrl.text.trim());
    if (n == null || n < widget.min || n > widget.max) {
      setState(
        () => _error = 'أدخل كمية بين ${widget.min} و ${widget.max}',
      );
      return;
    }
    Navigator.pop(context, n);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
              Text(
                'تحديد الكمية',
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 16,
                  fontWeight: MyFontWeight.bold,
                  color: const Color(0xff292929),
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _ctrl,
                autofocus: true,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onSubmitted: (_) => _confirm(),
                onChanged: (_) {
                  if (_error != null) setState(() => _error = null);
                },
                style: theme.textTheme.titleLarge!.copyWith(
                  fontSize: 22,
                  fontWeight: MyFontWeight.semiBold,
                  color: const Color(0xff231F1E),
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xffF1F1F1),
                  errorText: _error,
                  helperText: 'بين ${widget.min} و ${widget.max}',
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.primaryColor,
                      width: 1.2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _confirm,
                        child: const Text('تأكيد'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffEEEEEE),
                          foregroundColor: Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('إلغاء'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

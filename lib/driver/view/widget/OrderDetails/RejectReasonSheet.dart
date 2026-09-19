import 'package:customer/core/constant/order_rejection_reasons.dart';
import 'package:customer/driver/core/constant/Themes/lightThem.dart';
import 'package:customer/driver/view/widget/widgetApp/ButtonAppWidget.dart';
import 'package:flutter/material.dart';

/// ورقة اختيار سبب رفض الطلب (إلزامي). تعيد `{code, details?}` أو `null` عند الإلغاء.
Future<Map<String, dynamic>?> showDriverRejectReasonSheet(
  BuildContext context,
) {
  return showModalBottomSheet<Map<String, dynamic>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _RejectReasonSheet(),
  );
}

class _RejectReasonSheet extends StatefulWidget {
  const _RejectReasonSheet();

  @override
  State<_RejectReasonSheet> createState() => _RejectReasonSheetState();
}

class _RejectReasonSheetState extends State<_RejectReasonSheet> {
  final TextEditingController _details = TextEditingController();
  String? _code;
  String? _error;

  bool get _needsDetails => _code == kRejectionOtherCode;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  void _submit() {
    if (_code == null) {
      setState(() => _error = 'اختر سبب الرفض');
      return;
    }
    final d = _details.text.trim();
    if (_needsDetails && d.isEmpty) {
      setState(() => _error = 'اكتب تفاصيل سبب الرفض');
      return;
    }
    Navigator.pop(context, <String, dynamic>{
      'code': _code,
      if (d.isNotEmpty) 'details': d,
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xffE7E4E4),
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  'سبب رفض الطلب',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 18,
                    fontWeight: MyFontWeight.medium,
                    color: const Color(0xff231F1E),
                  ),
                ),
              ),
              ...kDriverRejectionReasons.map(
                (r) => RadioListTile<String>(
                  value: r.code,
                  // ignore: deprecated_member_use
                  groupValue: _code,
                  activeColor: Colors.red,
                  dense: true,
                  title: Text(
                    r.label,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontSize: 14,
                      fontWeight: MyFontWeight.regular,
                      color: const Color(0xff231F1E),
                    ),
                  ),
                  // ignore: deprecated_member_use
                  onChanged: (v) => setState(() {
                    _code = v;
                    _error = null;
                  }),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _details,
                  minLines: 2,
                  maxLines: 3,
                  maxLength: kRejectionDetailsMaxLength,
                  onChanged: (_) {
                    if (_error != null) setState(() => _error = null);
                  },
                  decoration: InputDecoration(
                    labelText: _needsDetails
                        ? 'التفاصيل (مطلوبة)'
                        : 'التفاصيل (اختياري)',
                    errorText: _error,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  height: 48,
                  child: ButtonAppWidget(
                    color: Colors.red,
                    lable: 'تأكيد الرفض',
                    onPressed: _submit,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

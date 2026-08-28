import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Small shared building blocks for the callable-backed finance write forms
/// (audit areas 3–4). Deliberately thin — plain Material fields styled to
/// the existing black-and-white finance look, no new design language.

/// A labelled text field. [moneyUgx] switches on integer-only input with a
/// "UGX" prefix.
class FinanceField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool moneyUgx;
  final bool required;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? hint;

  const FinanceField({
    super.key,
    required this.controller,
    required this.label,
    this.moneyUgx = false,
    this.required = false,
    this.maxLines = 1,
    this.keyboardType,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: moneyUgx
            ? const TextInputType.numberWithOptions(decimal: false)
            : keyboardType,
        inputFormatters: moneyUgx
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          prefixText: moneyUgx ? 'UGX ' : null,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
        validator: !required
            ? null
            : (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (moneyUgx && (int.tryParse(v.trim()) ?? 0) <= 0) {
                  return 'Enter a positive amount';
                }
                return null;
              },
      ),
    );
  }
}

/// A submit button that shows a spinner while [onPressed] runs and disables
/// itself so a form can't be double-submitted.
class FinanceSubmitButton extends StatefulWidget {
  final String label;
  final Future<void> Function() onPressed;
  final bool danger;

  const FinanceSubmitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.danger = false,
  });

  @override
  State<FinanceSubmitButton> createState() => _FinanceSubmitButtonState();
}

class _FinanceSubmitButtonState extends State<FinanceSubmitButton> {
  bool _busy = false;

  Future<void> _run() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await widget.onPressed();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = widget.danger ? AppColors.danger(context) : null;
    return SizedBox(
      height: 46,
      child: ElevatedButton(
        onPressed: _busy ? null : _run,
        style: ElevatedButton.styleFrom(foregroundColor: fg),
        child: _busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(widget.label),
      ),
    );
  }
}

/// Run [action], showing a success or error SnackBar and popping [popOnDone]
/// routes on success. Returns true on success.
Future<bool> runFinanceAction(
  BuildContext context, {
  required Future<void> Function() action,
  required String successMessage,
  int popOnDone = 0,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final dangerColor = AppColors.danger(context);
  try {
    await action();
    messenger.showSnackBar(SnackBar(content: Text(successMessage)));
    for (var i = 0; i < popOnDone; i++) {
      if (navigator.canPop()) navigator.pop();
    }
    return true;
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text(_friendlyError(e)), backgroundColor: dangerColor),
    );
    return false;
  }
}

String _friendlyError(Object e) {
  final s = e.toString();
  // FirebaseFunctionsException.toString() is
  // "[firebase_functions/<code>] <message>" — show just the message.
  final idx = s.indexOf('] ');
  if (s.startsWith('[firebase_functions/') && idx != -1) {
    return s.substring(idx + 2);
  }
  return 'Something went wrong. Please try again.';
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PhoneNumberEntryField extends StatelessWidget {
  const PhoneNumberEntryField({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.phone,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
        LengthLimitingTextInputFormatter(16),
      ],
      decoration: const InputDecoration(
        labelText: 'MTN Mobile Money number',
        hintText: '07XXXXXXXX',
        prefixIcon: Icon(Icons.phone_android_rounded),
        border: OutlineInputBorder(),
      ),
    );
  }
}

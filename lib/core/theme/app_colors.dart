import 'package:flutter/material.dart';

class AppColors {
  // Global School Pulse Branding
  static const Color pulseBlue = Color(0xFF000000);
  static const Color pulseNavy = Color(0xFF000000);
  static const Color pulseAccent = Color(0xFF000000);

  // Generic background colors
  static const Color scaffoldBackground = Color(0xFFFFFFFF);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF000000);

  /// Tenant colour metadata is retained as data but cannot paint app chrome.
  static Color? fromHex(String? hexString) =>
      hexString == null || hexString.isEmpty ? null : pulseBlue;
}

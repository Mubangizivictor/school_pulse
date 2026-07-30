import 'package:flutter/material.dart';

class AppColors {
  // Global School Pulse Branding
  static const Color pulseBlue = Color(0xFF0052CC);
  static const Color pulseNavy = Color(0xFF0747A6);
  static const Color pulseAccent = Color(0xFF00B8D9);
  
  // Generic background colors
  static const Color scaffoldBackground = Color(0xFFF4F5F7);
  static const Color white = Colors.white;
  static const Color grey = Colors.grey;

  // Helper to parse hex string to Color
  static Color? fromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

import 'package:flutter/material.dart';

/// Colors for the public school-registration wizard only. The app-wide
/// AppColors.electricBlue is black (this app has no blue accent), but the
/// registration reference design is a near-black scaffold with a light-blue
/// primary accent — scoped here so no other screen is affected.
class RegColors {
  RegColors._();

  static const Color background = Color(0xFF0B0D10);
  static const Color surface = Color(0xFF15181D);
  static const Color surfaceElevated = Color(0xFF1C2026);
  static const Color border = Color(0xFF2A2F37);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFF9AA3AF);
  static const Color blue = Color(0xFF3B82F6);
  static const Color blueSoft = Color(0xFF1E3A5F);
  static const Color green = Color(0xFF22C55E);
  static const Color greenSoft = Color(0xFF14291D);
  static const Color amber = Color(0xFFF59E0B);
  static const Color amberSoft = Color(0xFF2E2410);
  static const Color red = Color(0xFFEF4444);
  static const Color redSoft = Color(0xFF2E1616);
}

ThemeData regTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RegColors.background,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.dark(
      primary: RegColors.blue,
      surface: RegColors.surface,
      error: RegColors.red,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: RegColors.surface,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      hintStyle: const TextStyle(color: RegColors.textMuted, fontSize: 14.5),
      labelStyle: const TextStyle(color: RegColors.textMuted, fontSize: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: RegColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: RegColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: RegColors.blue, width: 1.4),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: RegColors.red, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: RegColors.red, width: 1.4),
      ),
      errorStyle: const TextStyle(color: RegColors.red, fontSize: 11.5),
    ),
    textTheme: const TextTheme().apply(
      bodyColor: RegColors.textPrimary,
      displayColor: RegColors.textPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: RegColors.blue,
        foregroundColor: Colors.white,
        disabledBackgroundColor: RegColors.blue.withValues(alpha: 0.4),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RegColors.textPrimary,
        side: const BorderSide(color: RegColors.border),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(11),
        ),
        textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: RegColors.blue),
    ),
    dividerColor: RegColors.border,
  );
}

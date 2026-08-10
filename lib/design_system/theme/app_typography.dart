import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static const String _fontFamily = 'Inter';

  static TextStyle get displayLarge => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
  );

  static TextStyle get displayMedium => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 45,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get displaySmall => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 36,
    fontWeight: FontWeight.w400,
  );

  static TextStyle get headlineLarge => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get headlineMedium => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get headlineSmall => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
  );

  static TextStyle get titleLarge => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get titleMedium => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.15,
  );

  static TextStyle get titleSmall => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
  );

  static TextStyle get bodyLarge => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
  );

  static TextStyle get bodyMedium => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
  );

  static TextStyle get bodySmall => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
  );

  static TextStyle get labelLarge => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
  );

  static TextStyle get labelMedium => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle get labelSmall => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );

  static TextStyle get kpiStyle => GoogleFonts.getFont(
    _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w800,
    letterSpacing: -1.0,
  );
}

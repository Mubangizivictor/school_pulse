import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart';

/// Compatibility names backed by generated parent-theme typography.
class AppTypography {
  AppTypography._();
  static TextStyle get displayLarge => AppText.display;
  static TextStyle get displayMedium => AppText.h1;
  static TextStyle get displaySmall => AppText.h2;
  static TextStyle get headlineLarge => AppText.h2;
  static TextStyle get headlineMedium => AppText.h3;
  static TextStyle get headlineSmall => AppText.h3;
  static TextStyle get titleLarge => AppText.title;
  static TextStyle get titleMedium => AppText.title;
  static TextStyle get titleSmall => AppText.label;
  static TextStyle get bodyLarge => AppText.body;
  static TextStyle get bodyMedium => AppText.body;
  static TextStyle get bodySmall => AppText.bodySmall;
  static TextStyle get labelLarge => AppText.label;
  static TextStyle get labelMedium => AppText.label;
  static TextStyle get labelSmall => AppText.label;
  static TextStyle get kpiStyle => AppText.h2;
}

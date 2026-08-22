import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart' as monochrome;

/// Legacy import façade. The implementation lives in the authoritative theme.
class AppTheme {
  static ThemeData getTheme(
    Brightness brightness, {
    Color? primary,
    Color? secondary,
  }) => brightness == Brightness.dark ? dark() : light();

  static ThemeData light({Color? primary, Color? secondary}) =>
      monochrome.AppTheme.light();

  static ThemeData dark({Color? primary, Color? secondary}) =>
      monochrome.AppTheme.dark();
}

/// Compatibility bridge for feature modules that still consume named status
/// tokens. Status is communicated by labels and icons; every token resolves
/// to the active foreground colour rather than a semantic hue.
@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color primaryBlue;
  final Color errorRed;

  const SemanticColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.primaryBlue,
    required this.errorRed,
  });

  @override
  SemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? primaryBlue,
    Color? errorRed,
  }) => SemanticColors(
    success: success ?? this.success,
    warning: warning ?? this.warning,
    error: error ?? this.error,
    info: info ?? this.info,
    primaryBlue: primaryBlue ?? this.primaryBlue,
    errorRed: errorRed ?? this.errorRed,
  );

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) =>
      other is SemanticColors ? (t < .5 ? this : other) : this;

  static const light = SemanticColors(
    success: Color(0xFF000000),
    warning: Color(0xFF000000),
    error: Color(0xFF000000),
    info: Color(0xFF000000),
    primaryBlue: Color(0xFF000000),
    errorRed: Color(0xFF000000),
  );
  static const dark = SemanticColors(
    success: Color(0xFFFFFFFF),
    warning: Color(0xFFFFFFFF),
    error: Color(0xFFFFFFFF),
    info: Color(0xFFFFFFFF),
    primaryBlue: Color(0xFFFFFFFF),
    errorRed: Color(0xFFFFFFFF),
  );
}

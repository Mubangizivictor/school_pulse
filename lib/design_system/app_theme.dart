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

/// Real semantic status colors on top of the app's black-and-white base
/// theme. Black/white/grey remain the primary identity for chrome,
/// surfaces, and typography (see monochrome.AppTheme) - these tokens are
/// used only for status meaning (active/success, warning, danger/revoked,
/// informational), the way a green/red indicator reads faster than a label
/// alone. Calibrated for AA contrast against both bgLight and bgDark.
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
    success: Color(0xFF1E8E3E),
    warning: Color(0xFFB25E00),
    error: Color(0xFFD03434),
    info: Color(0xFF3A6EA5),
    primaryBlue: Color(0xFF3A6EA5),
    errorRed: Color(0xFFD03434),
  );
  static const dark = SemanticColors(
    success: Color(0xFF4CAF6D),
    warning: Color(0xFFE0A64B),
    error: Color(0xFFE5605F),
    info: Color(0xFF7CA7D8),
    primaryBlue: Color(0xFF7CA7D8),
    errorRed: Color(0xFFE5605F),
  );
}

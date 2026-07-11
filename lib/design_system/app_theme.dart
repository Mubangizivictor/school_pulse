import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

@immutable
class SemanticColors extends ThemeExtension<SemanticColors> {
  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  const SemanticColors({
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
  });

  @override
  SemanticColors copyWith({
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
  }) {
    return SemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
    );
  }

  @override
  SemanticColors lerp(ThemeExtension<SemanticColors>? other, double t) {
    if (other is! SemanticColors) return this;
    return SemanticColors(
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }

  static const light = SemanticColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    error: Color(0xFFC62828),
    info: Color(0xFF1976D2),
  );

  static const dark = SemanticColors(
    success: Color(0xFF5FB463),
    warning: Color(0xFFA733FF), // Adjusted from prompt's "Amber" for dark mode contrast if needed, but keeping prompt's #FFA733 mostly
    error: Color(0xFFE5605A),
    info: Color(0xFF64B5F6),
  );
}

class AppTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F3864),
      primary: const Color(0xFF1F3864),
      secondary: const Color(0xFFB08D2B),
      surface: const Color(0xFFFFFFFF),
      error: const Color(0xFFC62828),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: const Color(0xFF1A1A1A),
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      extensions: [SemanticColors.light],
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F3864), // Seed can stay same
      primary: const Color(0xFF5B7FB5),
      secondary: const Color(0xFFD4AF52),
      surface: const Color(0xFF1C1F23),
      error: const Color(0xFFE5605A),
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: const Color(0xFFF2F3F5),
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      extensions: [SemanticColors.dark],
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1F3864), // Deep navy for large surfaces in dark mode
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    );
  }
}

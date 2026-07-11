import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  }) {
    return SemanticColors(
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      primaryBlue: primaryBlue ?? this.primaryBlue,
      errorRed: errorRed ?? this.errorRed,
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
      primaryBlue: Color.lerp(primaryBlue, other.primaryBlue, t)!,
      errorRed: Color.lerp(errorRed, other.errorRed, t)!,
    );
  }

  static const light = SemanticColors(
    success: Color(0xFF2E7D32),
    warning: Color(0xFFED6C02),
    error: Color(0xFFC62828),
    info: Color(0xFF1976D2),
    primaryBlue: Color(0xFF1F3864),
    errorRed: Color(0xFFC62828),
  );

  static const dark = SemanticColors(
    success: Color(0xFF5FB463),
    warning: Color(0xFFA733FF), 
    error: Color(0xFFE5605A),
    info: Color(0xFF64B5F6),
    primaryBlue: Color(0xFF5B7FB5),
    errorRed: Color(0xFFE5605A),
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
      scaffoldBackgroundColor: const Color(0xFFF8F9FA),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: const Color(0xFF1A1A1A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white,
        selectedColor: colorScheme.primary.withValues(alpha: 0.1),
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: const BorderSide(color: Color(0xFFF1F3F4)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: const Color(0xFF666666),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1F3864),
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
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF2C2C2C),
        selectedColor: colorScheme.primary.withValues(alpha: 0.2),
        labelStyle: const TextStyle(fontSize: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        side: BorderSide.none,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: const Color(0xFF999999),
        selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 12),
        elevation: 8,
      ),
    );
  }
}

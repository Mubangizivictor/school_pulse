import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';

class BrandingThemeEngine {
  static ThemeData createTheme(SchoolBranding? branding, Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    
    // Parse school-specific colors if they exist
    final Color? schoolPrimary = _fromHex(branding?.primaryColor);
    final Color? schoolSecondary = _fromHex(branding?.secondaryColor);

    // If no school branding, return the default AppTheme
    if (schoolPrimary == null && schoolSecondary == null) {
      return isDark ? AppTheme.dark() : AppTheme.light();
    }

    // Otherwise, generate a themed version using the global design system constraints
    return isDark 
      ? AppTheme.dark(primary: schoolPrimary, secondary: schoolSecondary)
      : AppTheme.light(primary: schoolPrimary, secondary: schoolSecondary);
  }

  static Color? _fromHex(String? hexString) {
    if (hexString == null || hexString.isEmpty) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    try {
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (e) {
      return null;
    }
  }
}

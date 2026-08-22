import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_theme.dart';
import 'package:school_pulse/features/branding/domain/entities/school_branding.dart';

class BrandingThemeEngine {
  static ThemeData createTheme(
    SchoolBranding? branding,
    Brightness brightness,
  ) {
    // Branding artwork may remain in its uploaded form, but tenant colour
    // settings are deliberately not allowed to affect application chrome.
    return brightness == Brightness.dark ? AppTheme.dark() : AppTheme.light();
  }
}

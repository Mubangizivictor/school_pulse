import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pulse/design_system/app_theme.dart' show SemanticColors;
import 'package:school_pulse/design_system/theme/app_tokens.g.dart';

/// The application theme is composed only from generated parent tokens.
class AppTheme {
  AppTheme._();

  static ThemeData light({Color? primary, Color? secondary}) =>
      _build(Brightness.light, AppColors.light);
  static ThemeData dark({Color? primary, Color? secondary}) =>
      _build(Brightness.dark, AppColors.dark);

  static ThemeData _build(Brightness brightness, AppColors colors) {
    final scheme = ColorScheme(
      brightness: brightness,
      primary: colors.primary,
      onPrimary: colors.onPrimary,
      primaryContainer: colors.primarySoft,
      onPrimaryContainer: colors.onPrimarySoft,
      secondary: colors.secondary,
      onSecondary: colors.onSecondary,
      tertiary: colors.accent,
      onTertiary: colors.onAccent,
      error: colors.error,
      onError: colors.onError,
      surface: colors.surface,
      onSurface: colors.text,
      outline: colors.border,
      outlineVariant: colors.borderStrong,
      shadow: colors.shadow,
      scrim: colors.shadow.withValues(alpha: 0.5),
      inverseSurface: colors.text,
      onInverseSurface: colors.background,
      inversePrimary: brightness == Brightness.light
          ? AppColors.dark.primary
          : AppColors.light.primary,
    );
    final textTheme = TextTheme(
      displayLarge: AppText.display,
      displayMedium: AppText.h1,
      displaySmall: AppText.h2,
      headlineLarge: AppText.h1,
      headlineMedium: AppText.h2,
      headlineSmall: AppText.h3,
      titleLarge: AppText.title,
      titleMedium: AppText.title,
      titleSmall: AppText.label,
      bodyLarge: AppText.body,
      bodyMedium: AppText.body,
      bodySmall: AppText.bodySmall,
      labelLarge: AppText.label,
      labelMedium: AppText.label,
      labelSmall: AppText.label,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppRadius.md),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppText.body.fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: colors.background,
      canvasColor: colors.background,
      disabledColor: colors.textSubtle,
      textTheme: textTheme,
      extensions: [colors, SemanticColors.fromTokens(colors)],
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        foregroundColor: colors.text,
        surfaceTintColor: AppColorValues.transparent,
        titleTextStyle: AppText.title.copyWith(color: colors.text),
        systemOverlayStyle: brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: colors.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.border),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        labelStyle: AppText.bodySmall.copyWith(color: colors.textMuted),
        hintStyle: AppText.bodySmall.copyWith(color: colors.textSubtle),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: colors.focusRing, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          shape: shape,
          textStyle: AppText.label,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          side: BorderSide(color: colors.border),
          shape: shape,
          textStyle: AppText.label,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colors.surfaceAlt,
        selectedColor: colors.primarySoft,
        labelStyle: AppText.label.copyWith(color: colors.text),
        side: BorderSide(color: colors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }
}

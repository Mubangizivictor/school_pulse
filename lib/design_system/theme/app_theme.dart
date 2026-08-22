import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';
import 'package:school_pulse/design_system/app_theme.dart' show SemanticColors;

/// Authoritative black-and-white Material theme for every School Pulse role.
class AppTheme {
  AppTheme._();

  static ThemeData light({Color? primary, Color? secondary}) =>
      _build(Brightness.light);
  static ThemeData dark({Color? primary, Color? secondary}) =>
      _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final background = dark ? AppColors.black : AppColors.white;
    final foreground = dark ? AppColors.white : AppColors.black;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: foreground,
      onPrimary: background,
      secondary: foreground,
      onSecondary: background,
      error: foreground,
      onError: background,
      surface: background,
      onSurface: foreground,
      surfaceContainerHighest: background,
      onSurfaceVariant: foreground,
      outline: foreground,
      outlineVariant: foreground,
      shadow: Colors.transparent,
      scrim: Colors.transparent,
      inverseSurface: foreground,
      onInverseSurface: background,
      inversePrimary: background,
      primaryContainer: foreground,
      onPrimaryContainer: background,
      secondaryContainer: foreground,
      onSecondaryContainer: background,
      tertiary: foreground,
      onTertiary: background,
      tertiaryContainer: foreground,
      onTertiaryContainer: background,
    );
    final text = _textTheme(foreground);
    final outline = BorderSide(color: foreground);
    final shape = RoundedRectangleBorder(borderRadius: AppRadius.medium);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      disabledColor: foreground,
      shadowColor: Colors.transparent,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      focusColor: Colors.transparent,
      textTheme: text,
      extensions: [dark ? SemanticColors.dark : SemanticColors.light],
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: foreground,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: text.titleLarge,
        iconTheme: IconThemeData(color: foreground),
      ),
      cardTheme: CardThemeData(
        color: background,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.large,
          side: outline,
        ),
      ),
      dividerTheme: DividerThemeData(color: foreground, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: foreground),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: background,
        labelStyle: TextStyle(color: foreground),
        hintStyle: TextStyle(color: foreground),
        prefixIconColor: foreground,
        suffixIconColor: foreground,
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: outline,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: outline,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: foreground, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: foreground, width: 2),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: foreground,
          foregroundColor: background,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: shape,
          minimumSize: const Size(0, 48),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: foreground,
          side: outline,
          shape: shape,
          minimumSize: const Size(0, 48),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: foreground, shape: shape),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: foreground,
        foregroundColor: background,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: shape,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: background,
        disabledColor: background,
        selectedColor: foreground,
        secondarySelectedColor: foreground,
        labelStyle: TextStyle(color: foreground),
        secondaryLabelStyle: TextStyle(color: background),
        side: outline,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStatePropertyAll(background),
        trackColor: WidgetStatePropertyAll(foreground),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStatePropertyAll(foreground),
        checkColor: WidgetStatePropertyAll(background),
        side: outline,
      ),
      radioTheme: RadioThemeData(fillColor: WidgetStatePropertyAll(foreground)),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: background,
        selectedItemColor: foreground,
        unselectedItemColor: foreground,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: background,
        selectedIconTheme: IconThemeData(color: background),
        selectedLabelTextStyle: TextStyle(color: background),
        unselectedIconTheme: IconThemeData(color: foreground),
        unselectedLabelTextStyle: TextStyle(color: foreground),
        indicatorColor: foreground,
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: background,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.large,
          side: outline,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: background,
        elevation: 0,
        modalElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.large,
          side: outline,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: foreground,
        actionTextColor: background,
        contentTextStyle: TextStyle(color: background),
        behavior: SnackBarBehavior.floating,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(side: outline),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: foreground,
          border: Border.all(color: foreground),
        ),
        textStyle: TextStyle(color: background),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: foreground,
        linearTrackColor: background,
        circularTrackColor: background,
      ),
    );
  }

  static TextTheme _textTheme(Color foreground) => TextTheme(
    displayLarge: AppTypography.displayLarge.copyWith(color: foreground),
    displayMedium: AppTypography.displayMedium.copyWith(color: foreground),
    displaySmall: AppTypography.displaySmall.copyWith(color: foreground),
    headlineLarge: AppTypography.headlineLarge.copyWith(color: foreground),
    headlineMedium: AppTypography.headlineMedium.copyWith(color: foreground),
    headlineSmall: AppTypography.headlineSmall.copyWith(color: foreground),
    titleLarge: AppTypography.titleLarge.copyWith(color: foreground),
    titleMedium: AppTypography.titleMedium.copyWith(color: foreground),
    titleSmall: AppTypography.titleSmall.copyWith(color: foreground),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: foreground),
    bodyMedium: AppTypography.bodyMedium.copyWith(color: foreground),
    bodySmall: AppTypography.bodySmall.copyWith(color: foreground),
    labelLarge: AppTypography.labelLarge.copyWith(color: foreground),
    labelMedium: AppTypography.labelMedium.copyWith(color: foreground),
    labelSmall: AppTypography.labelSmall.copyWith(color: foreground),
  );
}

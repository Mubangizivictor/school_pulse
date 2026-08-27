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
    final background = dark ? AppColors.bgDark : AppColors.bgLight;
    final surface = dark ? AppColors.surfaceDark : AppColors.surfaceLight;
    final surfaceMuted = dark
        ? AppColors.elevatedSurfaceDark
        : AppColors.grey50;
    final foreground = dark ? AppColors.textPrimaryDark : AppColors.black;
    final secondaryText = dark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;
    final mutedText = dark ? AppColors.textMutedDark : AppColors.textMutedLight;
    final outlineColor = dark ? AppColors.borderDark : AppColors.borderLight;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: foreground,
      onPrimary: background,
      secondary: foreground,
      onSecondary: background,
      // Errors are semantic, not part of the monochrome brand palette.  This
      // keeps required-field feedback recognisable in both appearances.
      error: dark
          ? SemanticColors.dark.errorRed
          : SemanticColors.light.errorRed,
      onError: dark ? AppColors.black : AppColors.white,
      surface: surface,
      onSurface: foreground,
      surfaceContainerHighest: surfaceMuted,
      onSurfaceVariant: secondaryText,
      outline: outlineColor,
      outlineVariant: outlineColor,
      shadow: Colors.transparent,
      scrim: Colors.transparent,
      inverseSurface: foreground,
      onInverseSurface: background,
      inversePrimary: background,
      primaryContainer: surfaceMuted,
      onPrimaryContainer: foreground,
      secondaryContainer: surfaceMuted,
      onSecondaryContainer: foreground,
      tertiary: foreground,
      onTertiary: background,
      tertiaryContainer: foreground,
      onTertiaryContainer: background,
    );
    final text = _textTheme(foreground);
    final outline = BorderSide(color: outlineColor);
    final shape = RoundedRectangleBorder(borderRadius: AppRadius.medium);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      disabledColor: dark ? AppColors.disabledDark : AppColors.disabledLight,
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
        color: surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.large,
          side: outline,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: outlineColor,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: foreground),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        labelStyle: TextStyle(color: secondaryText),
        hintStyle: TextStyle(color: mutedText),
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
          borderSide: BorderSide(color: foreground, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(
            color: dark
                ? SemanticColors.dark.errorRed
                : SemanticColors.light.errorRed,
            width: 1.5,
          ),
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
        backgroundColor: surface,
        disabledColor: surfaceMuted,
        selectedColor: foreground,
        secondarySelectedColor: foreground,
        labelStyle: TextStyle(color: foreground),
        secondaryLabelStyle: TextStyle(color: background),
        side: outline,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: foreground,
        textColor: background,
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
        backgroundColor: surface,
        selectedItemColor: foreground,
        unselectedItemColor: foreground,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: surface,
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
        backgroundColor: surface,
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
        color: surface,
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
        linearTrackColor: surfaceMuted,
        circularTrackColor: surfaceMuted,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: foreground,
        textColor: foreground,
        tileColor: surface,
        selectedColor: background,
        selectedTileColor: foreground,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: foreground,
        unselectedLabelColor: secondaryText,
        indicatorColor: foreground,
        dividerColor: outlineColor,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: foreground,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? background
                : foreground,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? background
                : foreground,
          ),
        ),
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: foreground,
        headerForegroundColor: background,
        dayForegroundColor: WidgetStatePropertyAll(foreground),
        todayForegroundColor: WidgetStatePropertyAll(foreground),
        todayBorder: BorderSide(color: foreground),
        yearForegroundColor: WidgetStatePropertyAll(foreground),
      ),
      timePickerTheme: TimePickerThemeData(
        backgroundColor: background,
        dialBackgroundColor: surfaceMuted,
        dialHandColor: foreground,
        dialTextColor: foreground,
        hourMinuteColor: background,
        hourMinuteTextColor: foreground,
        entryModeIconColor: foreground,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: foreground,
        selectionColor: foreground,
        selectionHandleColor: foreground,
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

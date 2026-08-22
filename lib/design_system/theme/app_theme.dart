import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';
import 'app_radius.dart';
import 'package:school_pulse/design_system/app_theme.dart' show SemanticColors;

class AppTheme {
  AppTheme._();

  static ThemeData light({Color? primary, Color? secondary}) {
    final effectivePrimary = primary ?? AppColors.royalBlue;
    final effectiveSecondary = secondary ?? AppColors.brightOrange;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: effectivePrimary,
      primary: effectivePrimary,
      onPrimary: _bestForeground(effectivePrimary),
      secondary: effectiveSecondary,
      onSecondary: _bestForeground(effectiveSecondary),
      surface: AppColors.surfaceLight,
      onSurface: AppColors.textPrimaryLight,
      surfaceContainerHighest: AppColors.borderLight,
      onSurfaceVariant: AppColors.textSecondaryLight,
      error: AppColors.deepOrange,
      onError: AppColors.pureWhite,
      outline: AppColors.borderLight,
      brightness: Brightness.light,
    );

    return _buildTheme(colorScheme, effectivePrimary);
  }

  static ThemeData dark({Color? primary, Color? secondary}) {
    final effectivePrimary = primary ?? AppColors.electricBlue;
    final effectiveSecondary = secondary ?? AppColors.goldenYellow;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: effectivePrimary,
      primary: effectivePrimary,
      onPrimary: _bestForeground(effectivePrimary),
      secondary: effectiveSecondary,
      onSecondary: _bestForeground(effectiveSecondary),
      surface: AppColors.surfaceDark,
      surfaceDim: AppColors.bgDark,
      surfaceBright: AppColors.elevatedSurfaceDark,
      surfaceContainerLowest: AppColors.bgDark,
      surfaceContainerLow: AppColors.surfaceDark,
      surfaceContainer: AppColors.elevatedSurfaceDark,
      surfaceContainerHigh: const Color(0xFF123469),
      onSurface: AppColors.textPrimaryDark,
      surfaceContainerHighest: AppColors.borderDark,
      onSurfaceVariant: AppColors.textSecondaryDark,
      error: AppColors.deepOrange,
      onError: AppColors.pureWhite,
      outline: AppColors.borderDark,
      brightness: Brightness.dark,
    );

    return _buildTheme(colorScheme, effectivePrimary);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Color primaryColor) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      textTheme: _buildTextTheme(colorScheme),
      // Legacy screens built against the older design system (pre-dating
      // this AppTheme) still read semantic status colors via
      // Theme.of(context).extension<SemanticColors>()! - keep providing it
      // so those screens don't null-check-crash under the new theme.
      extensions: [isDark ? SemanticColors.dark : SemanticColors.light],

      appBarTheme: AppBarTheme(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        foregroundColor: isDark
            ? AppColors.textPrimaryDark
            : AppColors.textPrimaryLight,
        elevation: 0,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
        ),
        iconTheme: IconThemeData(
          color: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          size: 24,
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? AppColors.elevatedSurfaceDark : AppColors.surfaceLight,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.large,
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
        ),
        margin: EdgeInsets.zero,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x3l),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
          textStyle: AppTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.pureWhite,
        contentPadding: const EdgeInsets.all(AppSpacing.xl),
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: const BorderSide(color: AppColors.deepOrange),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(
          color: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
        prefixIconColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
        suffixIconColor: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),

      dividerTheme: DividerThemeData(
        thickness: 1,
        space: 1,
        color: isDark ? AppColors.borderDark : AppColors.borderLight,
      ),

      // Keep every module toggle on the same visual language: a clean blue
      // active track with a white thumb, and a solid navy/slate inactive
      // track. Material's default outline makes these look too busy against
      // the bordered settings cards used throughout the app.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.pureWhite
              : (isDark ? AppColors.textSecondaryDark : AppColors.pureWhite),
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? primaryColor
              : (isDark ? const Color(0xFF1D3D73) : AppColors.disabledLight),
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        selectedItemColor: primaryColor,
        unselectedItemColor: isDark
            ? AppColors.textMutedDark
            : AppColors.textMutedLight,
        selectedLabelStyle: AppTypography.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTypography.labelSmall,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        selectedIconTheme: IconThemeData(color: primaryColor),
        unselectedIconTheme: IconThemeData(
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
        selectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: primaryColor,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelTextStyle: AppTypography.labelSmall.copyWith(
          color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
        ),
      ),

      drawerTheme: DrawerThemeData(
        backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.brightOrange,
        foregroundColor: AppColors.pureWhite,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
        elevation: 4,
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? AppColors.elevatedSurfaceDark
            : AppColors.deepNavy,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: AppColors.pureWhite,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: isDark
            ? AppColors.elevatedSurfaceDark
            : AppColors.bgLight,
        disabledColor: isDark
            ? AppColors.disabledDark
            : AppColors.disabledLight,
        selectedColor: primaryColor,
        secondarySelectedColor: primaryColor,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.m,
          vertical: AppSpacing.s,
        ),
        labelStyle: AppTypography.labelMedium,
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(
          color: AppColors.pureWhite,
        ),
        brightness: isDark ? Brightness.dark : Brightness.light,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
        side: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.extraLarge),
        titleTextStyle: AppTypography.titleLarge,
        contentTextStyle: AppTypography.bodyMedium,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark
            ? AppColors.surfaceDark
            : AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
        elevation: 0,
      ),
    );
  }

  /// Maintains readable labels when a school provides a light or dark custom
  /// brand color. Comparing both candidates is more reliable than assuming
  /// all school primary colors are dark enough for white text.
  static Color _bestForeground(Color background) {
    final whiteContrast = _contrastRatio(background, AppColors.pureWhite);
    final navyContrast = _contrastRatio(background, AppColors.midnightNavy);
    return whiteContrast >= navyContrast
        ? AppColors.pureWhite
        : AppColors.midnightNavy;
  }

  static double _contrastRatio(Color first, Color second) {
    final firstLuminance = first.computeLuminance();
    final secondLuminance = second.computeLuminance();
    final lighter = firstLuminance > secondLuminance
        ? firstLuminance
        : secondLuminance;
    final darker = firstLuminance > secondLuminance
        ? secondLuminance
        : firstLuminance;
    return (lighter + 0.05) / (darker + 0.05);
  }

  static TextTheme _buildTextTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: primaryColor),
      displayMedium: AppTypography.displayMedium.copyWith(color: primaryColor),
      displaySmall: AppTypography.displaySmall.copyWith(color: primaryColor),
      headlineLarge: AppTypography.headlineLarge.copyWith(color: primaryColor),
      headlineMedium: AppTypography.headlineMedium.copyWith(
        color: primaryColor,
      ),
      headlineSmall: AppTypography.headlineSmall.copyWith(color: primaryColor),
      titleLarge: AppTypography.titleLarge.copyWith(color: primaryColor),
      titleMedium: AppTypography.titleMedium.copyWith(color: primaryColor),
      titleSmall: AppTypography.titleSmall.copyWith(color: primaryColor),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: secondaryColor),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: secondaryColor),
      bodySmall: AppTypography.bodySmall.copyWith(color: secondaryColor),
      labelLarge: AppTypography.labelLarge.copyWith(color: secondaryColor),
      labelMedium: AppTypography.labelMedium.copyWith(color: secondaryColor),
      labelSmall: AppTypography.labelSmall.copyWith(color: secondaryColor),
    );
  }
}

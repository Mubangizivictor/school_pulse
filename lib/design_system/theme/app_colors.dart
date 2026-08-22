import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors (Extracted from Logo)
  static const Color deepNavy = Color(0xFF06164A);
  static const Color midnightNavy = Color(0xFF020B2D);
  static const Color royalBlue = Color(0xFF103ECF);
  static const Color electricBlue = Color(0xFF176BFF);
  static const Color brightCyan = Color(0xFF00C8FF);
  static const Color iceBlue = Color(0xFFDDF8FF);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color white = pureWhite;

  // Accent Colors
  static const Color goldenYellow = Color(0xFFFFB400);
  static const Color brightOrange = Color(0xFFFF6A00);
  static const Color deepOrange = Color(0xFFF04400);
  static const Color successGreen = Color(0xFF11A85B);
  static const Color emeraldGreen = Color(0xFF00B96B);

  // Neutral Colors
  static const Color bgLight = Color(0xFFF4F7FC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderLight = Color(0xFFDCE5F2);
  static const Color textPrimaryLight = Color(0xFF07163D);
  static const Color textSecondaryLight = Color(0xFF54627A);
  static const Color textMutedLight = Color(0xFF8792A6);
  static const Color disabledLight = Color(0xFFB7C0CF);

  // Dark Theme Colors
  // Dark mode stays unmistakably blue, rather than collapsing into neutral
  // black. The three levels keep pages, controls, and elevated content clear
  // from one another without weakening text contrast.
  static const Color bgDark = Color(0xFF061631);
  static const Color surfaceDark = Color(0xFF091C40);
  static const Color elevatedSurfaceDark = Color(0xFF0E2A5C);
  static const Color borderDark = Color(0xFF254979);
  static const Color textPrimaryDark = Color(0xFFF7FAFF);
  static const Color textSecondaryDark = Color(0xFFB9C6DC);
  static const Color textMutedDark = Color(0xFF8190AA);
  static const Color disabledDark = Color(0xFF3A475E);

  // Semantic Tokens
  /// Theme-aware semantic colors. These deliberately read [ColorScheme]
  /// instead of returning the default brand constants so school branding,
  /// light mode, and dark mode all use the same active palette.
  static Color primary(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color primaryStrong(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  static Color primarySoft(BuildContext context) =>
      Theme.of(context).colorScheme.primaryContainer;

  static Color secondary(BuildContext context) =>
      Theme.of(context).colorScheme.secondary;

  static Color background(BuildContext context) =>
      Theme.of(context).scaffoldBackgroundColor;

  static Color get backgroundDark => bgDark;

  static Color surfaceContainer(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainer;

  static Color surfaceContainerHigh(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHigh;

  static Color surfaceElevated(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color textMuted(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  static Color border(BuildContext context) =>
      Theme.of(context).colorScheme.outline;

  static Color success(BuildContext context) => successGreen;
  static Color successSurface(BuildContext context) =>
      successGreen.withValues(alpha: .12);
  static Color warning(BuildContext context) => goldenYellow;
  static Color danger(BuildContext context) => deepOrange;
  static Color error = deepOrange;
  static Color errorRed = deepOrange;
  static Color information(BuildContext context) => brightCyan;

  static Color disabled(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.38);

  static Color focus(BuildContext context) => brightCyan.withValues(alpha: 0.2);
  static Color shadow(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? deepNavy.withValues(alpha: 0.1)
      : Colors.black.withValues(alpha: 0.4);

  static Color overlay(BuildContext context) =>
      Theme.of(context).brightness == Brightness.light
      ? deepNavy.withValues(alpha: 0.4)
      : Colors.black.withValues(alpha: 0.6);
}

import 'package:flutter/material.dart';

/// Black/white/grey as the primary identity, with real semantic colors
/// (green/amber/red) layered on top purely for status meaning - active vs.
/// revoked, success vs. danger, warnings. Chrome, surfaces, and typography
/// stay monochrome; only status indicators (badges, alerts) use hue.
///
/// The legacy names remain as compatibility aliases while feature code
/// migrates to semantic accessors.
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey25 = Color(0xFFFCFCFC);
  static const Color grey50 = Color(0xFFF7F7F7);
  static const Color grey100 = Color(0xFFF0F0F0);
  static const Color grey200 = Color(0xFFE2E2E2);
  static const Color grey300 = Color(0xFFD0D0D0);
  static const Color grey500 = Color(0xFF737373);
  static const Color grey700 = Color(0xFF404040);
  static const Color grey850 = Color(0xFF1C1C1C);
  static const Color grey900 = Color(0xFF121212);
  static const Color transparent = Colors.transparent;

  // Real semantic hues - success (green), warning (amber), danger (red),
  // info (blue) - one value per brightness, calibrated for AA contrast
  // against bgLight/bgDark respectively.
  static const Color successLight = Color(0xFF1E8E3E);
  static const Color successDark = Color(0xFF4CAF6D);
  static const Color warningLight = Color(0xFFB25E00);
  static const Color warningDark = Color(0xFFE0A64B);
  static const Color dangerLight = Color(0xFFD03434);
  static const Color dangerDark = Color(0xFFE5605F);
  static const Color infoLight = Color(0xFF3A6EA5);
  static const Color infoDark = Color(0xFF7CA7D8);
  // Tinted surfaces for status banners/chips - a very light/dark wash of
  // the same hue, so a filled badge never fights the monochrome background.
  static const Color successSurfaceLight = Color(0xFFE6F4EA);
  static const Color successSurfaceDark = Color(0xFF16301F);
  static const Color warningSurfaceLight = Color(0xFFFCEEDC);
  static const Color warningSurfaceDark = Color(0xFF3A2A12);
  static const Color dangerSurfaceLight = Color(0xFFFBE7E7);
  static const Color dangerSurfaceDark = Color(0xFF3A1919);
  static const Color infoSurfaceLight = Color(0xFFE8F0F9);
  static const Color infoSurfaceDark = Color(0xFF1B2A38);

  static const Color deepNavy = black, midnightNavy = black, royalBlue = black;
  static const Color electricBlue = black, brightCyan = black, iceBlue = white;
  static const Color pureWhite = white,
      goldenYellow = black,
      brightOrange = black;
  static const Color deepOrange = black,
      successGreen = successLight,
      emeraldGreen = successLight;
  static const Color bgLight = grey25,
      surfaceLight = white,
      borderLight = grey300;
  static const Color textPrimaryLight = black,
      textSecondaryLight = grey700,
      textMutedLight = grey500,
      disabledLight = grey500;
  static const Color bgDark = grey900,
      surfaceDark = grey850,
      elevatedSurfaceDark = Color(0xFF242424);
  static const Color borderDark = Color(0xFF454545), textPrimaryDark = white;
  static const Color textSecondaryDark = Color(0xFFD1D1D1),
      textMutedDark = Color(0xFF9B9B9B),
      disabledDark = Color(0xFF777777);

  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static Color primary(BuildContext context) => _dark(context) ? white : black;
  static Color primaryStrong(BuildContext context) => primary(context);
  static Color primarySoft(BuildContext context) => primary(context);
  static Color secondary(BuildContext context) => primary(context);
  static Color background(BuildContext context) =>
      _dark(context) ? bgDark : bgLight;
  static Color get backgroundDark => bgDark;
  static Color surfaceContainer(BuildContext context) =>
      _dark(context) ? elevatedSurfaceDark : grey50;
  static Color surfaceContainerHigh(BuildContext context) =>
      _dark(context) ? elevatedSurfaceDark : grey100;
  static Color surfaceElevated(BuildContext context) =>
      _dark(context) ? surfaceDark : surfaceLight;
  static Color textPrimary(BuildContext context) =>
      _dark(context) ? white : black;
  static Color textSecondary(BuildContext context) =>
      _dark(context) ? textSecondaryDark : textSecondaryLight;
  static Color textMuted(BuildContext context) =>
      _dark(context) ? textMutedDark : textMutedLight;
  static Color border(BuildContext context) =>
      _dark(context) ? borderDark : borderLight;
  static Color success(BuildContext context) =>
      _dark(context) ? successDark : successLight;
  static Color successSurface(BuildContext context) =>
      _dark(context) ? successSurfaceDark : successSurfaceLight;
  static Color warning(BuildContext context) =>
      _dark(context) ? warningDark : warningLight;
  static Color warningSurface(BuildContext context) =>
      _dark(context) ? warningSurfaceDark : warningSurfaceLight;
  static Color danger(BuildContext context) =>
      _dark(context) ? dangerDark : dangerLight;
  static Color dangerSurface(BuildContext context) =>
      _dark(context) ? dangerSurfaceDark : dangerSurfaceLight;
  static Color error = dangerLight;
  static Color errorRed = dangerLight;
  static Color information(BuildContext context) =>
      _dark(context) ? infoDark : infoLight;
  static Color informationSurface(BuildContext context) =>
      _dark(context) ? infoSurfaceDark : infoSurfaceLight;
  static Color disabled(BuildContext context) =>
      _dark(context) ? disabledDark : disabledLight;
  static Color focus(BuildContext context) => textPrimary(context);
  static Color shadow(BuildContext context) => transparent;
  static Color overlay(BuildContext context) => transparent;
}

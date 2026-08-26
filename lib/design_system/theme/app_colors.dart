import 'package:flutter/material.dart';

/// A deliberately quiet monochrome palette.
///
/// The legacy names remain as compatibility aliases while feature code
/// migrates to semantic accessors.  Neutral greys are intentional: they keep
/// outlines, secondary text and disabled controls from competing with the
/// content while retaining the black-and-white School Pulse identity.
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

  static const Color deepNavy = black, midnightNavy = black, royalBlue = black;
  static const Color electricBlue = black, brightCyan = black, iceBlue = white;
  static const Color pureWhite = white,
      goldenYellow = black,
      brightOrange = black;
  static const Color deepOrange = black,
      successGreen = black,
      emeraldGreen = black;
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
  static Color success(BuildContext context) => textPrimary(context);
  static Color successSurface(BuildContext context) => background(context);
  static Color warning(BuildContext context) => textPrimary(context);
  static Color danger(BuildContext context) => textPrimary(context);
  static Color error = black;
  static Color errorRed = black;
  static Color information(BuildContext context) => textPrimary(context);
  static Color disabled(BuildContext context) =>
      _dark(context) ? disabledDark : disabledLight;
  static Color focus(BuildContext context) => textPrimary(context);
  static Color shadow(BuildContext context) => transparent;
  static Color overlay(BuildContext context) => transparent;
}

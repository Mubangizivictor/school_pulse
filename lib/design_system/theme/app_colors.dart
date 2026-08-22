import 'package:flutter/material.dart';

/// The only palette available to School Pulse UI.
///
/// The legacy names are compatibility aliases while feature code migrates to
/// semantic accessors. None of them introduces a third colour.
class AppColors {
  AppColors._();

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Colors.transparent;

  static const Color deepNavy = black, midnightNavy = black, royalBlue = black;
  static const Color electricBlue = black, brightCyan = black, iceBlue = white;
  static const Color pureWhite = white,
      goldenYellow = black,
      brightOrange = black;
  static const Color deepOrange = black,
      successGreen = black,
      emeraldGreen = black;
  static const Color bgLight = white, surfaceLight = white, borderLight = black;
  static const Color textPrimaryLight = black, textSecondaryLight = black;
  static const Color textMutedLight = black, disabledLight = black;
  static const Color bgDark = black,
      surfaceDark = black,
      elevatedSurfaceDark = black;
  static const Color borderDark = white, textPrimaryDark = white;
  static const Color textSecondaryDark = white,
      textMutedDark = white,
      disabledDark = white;

  static bool _dark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;
  static Color primary(BuildContext context) => _dark(context) ? white : black;
  static Color primaryStrong(BuildContext context) => primary(context);
  static Color primarySoft(BuildContext context) => primary(context);
  static Color secondary(BuildContext context) => primary(context);
  static Color background(BuildContext context) =>
      _dark(context) ? black : white;
  static Color get backgroundDark => black;
  static Color surfaceContainer(BuildContext context) => background(context);
  static Color surfaceContainerHigh(BuildContext context) =>
      background(context);
  static Color surfaceElevated(BuildContext context) => background(context);
  static Color textPrimary(BuildContext context) =>
      _dark(context) ? white : black;
  static Color textSecondary(BuildContext context) => textPrimary(context);
  static Color textMuted(BuildContext context) => textPrimary(context);
  static Color border(BuildContext context) => textPrimary(context);
  static Color success(BuildContext context) => textPrimary(context);
  static Color successSurface(BuildContext context) => background(context);
  static Color warning(BuildContext context) => textPrimary(context);
  static Color danger(BuildContext context) => textPrimary(context);
  static Color error = black;
  static Color errorRed = black;
  static Color information(BuildContext context) => textPrimary(context);
  static Color disabled(BuildContext context) => textPrimary(context);
  static Color focus(BuildContext context) => textPrimary(context);
  static Color shadow(BuildContext context) => transparent;
  static Color overlay(BuildContext context) => transparent;
}

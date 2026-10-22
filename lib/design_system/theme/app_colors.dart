import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart' as tokens;

/// Legacy façade for feature code not yet migrated to `ThemeExtension` access.
/// Every value is sourced from generated parent tokens; new code should use
/// `Theme.of(context).extension<tokens.AppColors>()!` directly.
class AppColors {
  AppColors._();

  static const black = tokens.AppColorValues.lightText;
  static const white = tokens.AppColorValues.lightTextOnDark;
  static const transparent = tokens.AppColorValues.transparent;
  static const grey25 = tokens.AppColorValues.lightBackground;
  static const grey50 = tokens.AppColorValues.lightSurfaceAlt;
  static const grey100 = tokens.AppColorValues.lightSurfaceAlt;
  static const grey200 = tokens.AppColorValues.lightBorder;
  static const grey300 = tokens.AppColorValues.lightBorderStrong;
  static const grey500 = tokens.AppColorValues.lightTextSubtle;
  static const grey700 = tokens.AppColorValues.lightTextMuted;
  static const grey850 = tokens.AppColorValues.darkSurface;
  static const grey900 = tokens.AppColorValues.darkBackground;
  static const successLight = tokens.AppColorValues.lightSuccess;
  static const successDark = tokens.AppColorValues.darkSuccess;
  static const warningLight = tokens.AppColorValues.lightWarning;
  static const warningDark = tokens.AppColorValues.darkWarning;
  static const dangerLight = tokens.AppColorValues.lightError;
  static const dangerDark = tokens.AppColorValues.darkError;
  static const infoLight = tokens.AppColorValues.lightInfo;
  static const infoDark = tokens.AppColorValues.darkInfo;
  static const successSurfaceLight = tokens.AppColorValues.lightSuccessSoft;
  static const successSurfaceDark = tokens.AppColorValues.darkSuccessSoft;
  static const warningSurfaceLight = tokens.AppColorValues.lightWarningSoft;
  static const warningSurfaceDark = tokens.AppColorValues.darkWarningSoft;
  static const dangerSurfaceLight = tokens.AppColorValues.lightErrorSoft;
  static const dangerSurfaceDark = tokens.AppColorValues.darkErrorSoft;
  static const infoSurfaceLight = tokens.AppColorValues.lightInfoSoft;
  static const infoSurfaceDark = tokens.AppColorValues.darkInfoSoft;
  static const deepNavy = tokens.AppColorValues.lightSecondary;
  static const midnightNavy = tokens.AppColorValues.darkBackground;
  static const royalBlue = tokens.AppColorValues.lightPrimary;
  static const electricBlue = tokens.AppColorValues.lightPrimary;
  static const brightCyan = tokens.AppColorValues.lightInfo;
  static const iceBlue = tokens.AppColorValues.lightPrimarySoft;
  static const pureWhite = tokens.AppColorValues.lightTextOnDark;
  static const goldenYellow = tokens.AppColorValues.lightAccent;
  static const brightOrange = tokens.AppColorValues.lightWarning;
  static const deepOrange = tokens.AppColorValues.lightWarning;
  static const successGreen = tokens.AppColorValues.lightSuccess;
  static const emeraldGreen = tokens.AppColorValues.lightSuccess;
  static const bgLight = tokens.AppColorValues.lightBackground;
  static const surfaceLight = tokens.AppColorValues.lightSurface;
  static const borderLight = tokens.AppColorValues.lightBorder;
  static const textPrimaryLight = tokens.AppColorValues.lightText;
  static const textSecondaryLight = tokens.AppColorValues.lightTextMuted;
  static const textMutedLight = tokens.AppColorValues.lightTextSubtle;
  static const disabledLight = tokens.AppColorValues.lightTextSubtle;
  static const bgDark = tokens.AppColorValues.darkBackground;
  static const surfaceDark = tokens.AppColorValues.darkSurface;
  static const elevatedSurfaceDark = tokens.AppColorValues.darkSurfaceAlt;
  static const borderDark = tokens.AppColorValues.darkBorder;
  static const textPrimaryDark = tokens.AppColorValues.darkText;
  static const textSecondaryDark = tokens.AppColorValues.darkTextMuted;
  static const textMutedDark = tokens.AppColorValues.darkTextSubtle;
  static const disabledDark = tokens.AppColorValues.darkTextSubtle;

  static tokens.AppColors _tokens(BuildContext context) =>
      Theme.of(context).extension<tokens.AppColors>()!;
  static Color primary(BuildContext context) => _tokens(context).primary;
  static Color primaryStrong(BuildContext context) =>
      _tokens(context).primaryHover;
  static Color primarySoft(BuildContext context) =>
      _tokens(context).primarySoft;
  static Color secondary(BuildContext context) => _tokens(context).secondary;
  static Color background(BuildContext context) => _tokens(context).background;
  static Color get backgroundDark => bgDark;
  static Color surfaceContainer(BuildContext context) =>
      _tokens(context).surfaceAlt;
  static Color surfaceContainerHigh(BuildContext context) =>
      _tokens(context).surfaceAlt;
  static Color surfaceElevated(BuildContext context) =>
      _tokens(context).surface;
  static Color textPrimary(BuildContext context) => _tokens(context).text;
  static Color textSecondary(BuildContext context) =>
      _tokens(context).textMuted;
  static Color textMuted(BuildContext context) => _tokens(context).textSubtle;
  static Color border(BuildContext context) => _tokens(context).border;
  static Color success(BuildContext context) => _tokens(context).success;
  static Color successSurface(BuildContext context) =>
      _tokens(context).successSoft;
  static Color warning(BuildContext context) => _tokens(context).warning;
  static Color warningSurface(BuildContext context) =>
      _tokens(context).warningSoft;
  static Color danger(BuildContext context) => _tokens(context).error;
  static Color dangerSurface(BuildContext context) =>
      _tokens(context).errorSoft;
  static Color error = dangerLight;
  static Color errorRed = dangerLight;
  static Color information(BuildContext context) => _tokens(context).info;
  static Color informationSurface(BuildContext context) =>
      _tokens(context).infoSoft;
  static Color disabled(BuildContext context) => _tokens(context).textSubtle;
  static Color focus(BuildContext context) => _tokens(context).focusRing;
  static Color shadow(BuildContext context) => _tokens(context).shadow;
  static Color overlay(BuildContext context) => transparent;
}

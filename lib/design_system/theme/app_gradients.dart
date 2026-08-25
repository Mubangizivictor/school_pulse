import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient primary = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.deepNavy,
      AppColors.royalBlue,
      AppColors.electricBlue,
      AppColors.brightCyan,
    ],
    stops: [0.0, 0.4, 0.7, 1.0],
  );

  static const LinearGradient orange = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.goldenYellow, AppColors.brightOrange, AppColors.black],
  );

  static const LinearGradient success = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.brightCyan, AppColors.emeraldGreen],
  );

  static const LinearGradient premiumDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.midnightNavy, AppColors.deepNavy, AppColors.royalBlue],
  );

  static const LinearGradient surfaceDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.surfaceDark, AppColors.elevatedSurfaceDark],
  );
}

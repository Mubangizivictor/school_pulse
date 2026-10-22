import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get subtle => [
    BoxShadow(
      color: AppColors.deepNavy.withValues(alpha: .08),
      blurRadius: 6,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get card => [
    BoxShadow(
      color: AppColors.deepNavy.withValues(alpha: .12),
      blurRadius: 10,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get elevated => [
    BoxShadow(
      color: AppColors.deepNavy.withValues(alpha: .16),
      blurRadius: 18,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get modal => [
    BoxShadow(
      color: AppColors.midnightNavy.withValues(alpha: .24),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
  ];

  static List<BoxShadow> get glowBlue => [
    BoxShadow(
      color: AppColors.electricBlue.withValues(alpha: .18),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
}

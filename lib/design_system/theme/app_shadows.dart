import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppShadows {
  AppShadows._();

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: AppColors.deepNavy.withValues(alpha: 0.05),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get card => [
        BoxShadow(
          color: AppColors.deepNavy.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get elevated => [
        BoxShadow(
          color: AppColors.deepNavy.withValues(alpha: 0.12),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get modal => [
        BoxShadow(
          color: AppColors.midnightNavy.withValues(alpha: 0.2),
          blurRadius: 40,
          offset: const Offset(0, 16),
        ),
      ];

  static List<BoxShadow> get glowBlue => [
        BoxShadow(
          color: AppColors.electricBlue.withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}

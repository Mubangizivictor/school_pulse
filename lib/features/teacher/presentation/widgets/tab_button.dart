import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;

  const TabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.bgDark : Colors.white)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.s),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? AppColors.royalBlue
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

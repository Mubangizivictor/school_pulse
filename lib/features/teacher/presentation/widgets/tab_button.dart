import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;

  /// Kept for source compatibility with approved screens. The active theme,
  /// rather than this value, owns the colours.
  final bool isDark;

  const TabButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? scheme.surface : Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.s),
      ),
      child: Center(
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? scheme.primary : scheme.onSurfaceVariant,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_shadows.dart';
import '../theme/app_motion.dart';

enum PulseCardVariant { standard, elevated, outlined, glass }

class PulseCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final PulseCardVariant variant;
  final double? borderRadius;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final bool hasBorder;

  const PulseCard({
    super.key,
    required this.child,
    this.padding,
    this.variant = PulseCardVariant.standard,
    this.borderRadius,
    this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final effectiveBorderRadius = BorderRadius.circular(
      borderRadius ?? AppRadius.l,
    );
    final effectivePadding = padding ?? const EdgeInsets.all(AppSpacing.xl);

    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: _buildDecoration(context, isDark, effectiveBorderRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: effectiveBorderRadius,
          child: Padding(padding: effectivePadding, child: child),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(
    BuildContext context,
    bool isDark,
    BorderRadius borderRadius,
  ) {
    switch (variant) {
      case PulseCardVariant.standard:
        return BoxDecoration(
          color:
              backgroundColor ??
              (isDark ? AppColors.surfaceDark : AppColors.surfaceLight),
          borderRadius: borderRadius,
          border: hasBorder
              ? Border.all(
                  color:
                      borderColor ??
                      (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1,
                )
              : null,
          boxShadow: isDark ? null : AppShadows.subtle,
        );
      case PulseCardVariant.elevated:
        return BoxDecoration(
          color:
              backgroundColor ??
              (isDark ? AppColors.elevatedSurfaceDark : AppColors.surfaceLight),
          borderRadius: borderRadius,
          boxShadow: isDark
              ? AppShadows.card
                    .map(
                      (s) => s.copyWith(
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    )
                    .toList()
              : AppShadows.card,
          border: isDark
              ? Border.all(color: AppColors.borderDark, width: 1)
              : null,
        );
      case PulseCardVariant.outlined:
        return BoxDecoration(
          color: backgroundColor ?? Colors.transparent,
          borderRadius: borderRadius,
          border: Border.all(
            color:
                borderColor ??
                (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: 1.5,
          ),
        );
      case PulseCardVariant.glass:
        return BoxDecoration(
          color:
              backgroundColor ??
              (isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.7)),
          borderRadius: borderRadius,
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        );
    }
  }
}

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_motion.dart';
import 'package:school_pulse/design_system/theme/app_tokens.g.dart';

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
    final colors = Theme.of(context).extension<AppColors>()!;
    final radius = BorderRadius.circular(borderRadius ?? AppRadius.lg);
    final background =
        backgroundColor ??
        switch (variant) {
          PulseCardVariant.standard => colors.surface,
          PulseCardVariant.elevated => colors.surface,
          PulseCardVariant.outlined => colors.background,
          PulseCardVariant.glass => colors.surfaceAlt,
        };
    return AnimatedContainer(
      duration: AppMotion.fast,
      decoration: BoxDecoration(
        color: background,
        borderRadius: radius,
        border: hasBorder
            ? Border.all(color: borderColor ?? colors.border)
            : null,
        boxShadow: variant == PulseCardVariant.elevated
            ? [BoxShadow(color: colors.background, blurRadius: AppSpacing.md)]
            : null,
      ),
      child: Material(
        color: background,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';
import '../theme/app_gradients.dart';
import '../theme/app_motion.dart';

enum PulseButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  danger,
  success,
  warning,
  info,
}

enum PulseButtonSize { small, medium, large }

class PulseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PulseButtonVariant variant;
  final PulseButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool isFullWidth;

  const PulseButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = PulseButtonVariant.primary,
    this.size = PulseButtonSize.medium,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: AppMotion.fast,
      width: isFullWidth ? double.infinity : null,
      height: _getHeight(),
      child: _buildButton(context, isDark),
    );
  }

  double _getHeight() {
    switch (size) {
      case PulseButtonSize.small:
        return 36.0;
      case PulseButtonSize.medium:
        return 48.0;
      case PulseButtonSize.large:
        return 56.0;
    }
  }

  Widget _buildButton(BuildContext context, bool isDark) {
    final content = _buildContent(context, isDark);

    if (variant == PulseButtonVariant.primary &&
        onPressed != null &&
        !isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: AppRadius.medium,
          boxShadow: [
            BoxShadow(
              color: AppColors.royalBlue,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: AppRadius.medium,
            child: Center(child: content),
          ),
        ),
      );
    }

    return ElevatedButton(
      onPressed: (onPressed == null || isLoading) ? null : onPressed,
      style: _getButtonStyle(context, isDark),
      child: content,
    );
  }

  ButtonStyle _getButtonStyle(BuildContext context, bool isDark) {
    final baseStyle = ElevatedButton.styleFrom(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
      padding: EdgeInsets.symmetric(
        horizontal: size == PulseButtonSize.small
            ? AppSpacing.l
            : AppSpacing.x3l,
      ),
    );

    switch (variant) {
      case PulseButtonVariant.primary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) {
              return isDark ? AppColors.disabledDark : AppColors.disabledLight;
            }
            return AppColors.primary(context);
          }),
          foregroundColor: WidgetStateProperty.all(AppColors.pureWhite),
        );
      case PulseButtonVariant.secondary:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(
            isDark ? AppColors.elevatedSurfaceDark : AppColors.iceBlue,
          ),
          foregroundColor: WidgetStateProperty.all(
            isDark ? AppColors.electricBlue : AppColors.royalBlue,
          ),
        );
      case PulseButtonVariant.outline:
        return OutlinedButton.styleFrom(
          side: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1.5,
          ),
          foregroundColor: isDark
              ? AppColors.textPrimaryDark
              : AppColors.textPrimaryLight,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ).merge(baseStyle);
      case PulseButtonVariant.ghost:
        return TextButton.styleFrom(
          foregroundColor: isDark
              ? AppColors.textSecondaryDark
              : AppColors.textSecondaryLight,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ).merge(baseStyle);
      case PulseButtonVariant.danger:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(AppColors.black),
          foregroundColor: WidgetStateProperty.all(AppColors.pureWhite),
        );
      case PulseButtonVariant.success:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(AppColors.successGreen),
          foregroundColor: WidgetStateProperty.all(AppColors.pureWhite),
        );
      case PulseButtonVariant.warning:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(AppColors.goldenYellow),
          foregroundColor: WidgetStateProperty.all(AppColors.textPrimaryLight),
        );
      case PulseButtonVariant.info:
        return baseStyle.copyWith(
          backgroundColor: WidgetStateProperty.all(AppColors.brightCyan),
          foregroundColor: WidgetStateProperty.all(AppColors.pureWhite),
        );
    }
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            (variant == PulseButtonVariant.primary ||
                    variant == PulseButtonVariant.danger ||
                    variant == PulseButtonVariant.success)
                ? AppColors.pureWhite
                : AppColors.primary(context),
          ),
        ),
      );
    }

    final textStyle = _getTextStyle();
    final color = _getTextColor(context, isDark);

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: _getIconSize(), color: color),
          const SizedBox(width: AppSpacing.m),
        ],
        Text(label, style: textStyle.copyWith(color: color)),
        if (trailingIcon != null) ...[
          const SizedBox(width: AppSpacing.m),
          Icon(trailingIcon, size: _getIconSize(), color: color),
        ],
      ],
    );
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case PulseButtonSize.small:
        return AppTypography.labelLarge;
      case PulseButtonSize.medium:
        return AppTypography.titleSmall;
      case PulseButtonSize.large:
        return AppTypography.titleMedium;
    }
  }

  Color _getTextColor(BuildContext context, bool isDark) {
    if (onPressed == null) {
      return isDark ? AppColors.textMutedDark : AppColors.textMutedLight;
    }
    switch (variant) {
      case PulseButtonVariant.primary:
      case PulseButtonVariant.danger:
      case PulseButtonVariant.success:
      case PulseButtonVariant.info:
        return AppColors.pureWhite;
      case PulseButtonVariant.warning:
        return AppColors.textPrimaryLight;
      case PulseButtonVariant.secondary:
        return isDark ? AppColors.electricBlue : AppColors.royalBlue;
      case PulseButtonVariant.outline:
      case PulseButtonVariant.ghost:
        return isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    }
  }

  double _getIconSize() {
    switch (size) {
      case PulseButtonSize.small:
        return 16.0;
      case PulseButtonSize.medium:
        return 20.0;
      case PulseButtonSize.large:
        return 24.0;
    }
  }
}

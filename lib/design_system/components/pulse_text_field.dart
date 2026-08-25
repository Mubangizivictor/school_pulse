import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

class PulseTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final bool isRequired;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;

  const PulseTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.onChanged,
    this.onTap,
    this.isRequired = false,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
  });

  @override
  State<PulseTextField> createState() => _PulseTextFieldState();
}

class _PulseTextFieldState extends State<PulseTextField> {
  bool _obscureText = true;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Row(
            children: [
              Text(
                widget.label!,
                style: AppTypography.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (widget.isRequired) ...[
                const SizedBox(width: 4),
                Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.m),
        ],
        Focus(
          onFocusChange: (hasFocus) => setState(() => _isFocused = hasFocus),
          child: TextFormField(
            controller: widget.controller,
            obscureText: widget.isPassword && _obscureText,
            keyboardType: widget.keyboardType,
            validator: widget.validator,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            maxLines: widget.maxLines,
            onChanged: widget.onChanged,
            onTap: widget.onTap,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            style: AppTypography.bodyLarge.copyWith(
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              helperText: widget.helperText,
              errorText: widget.errorText,
              filled: true,
              fillColor: isDark
                  ? (_isFocused
                        ? AppColors.elevatedSurfaceDark
                        : AppColors.surfaceDark)
                  : (_isFocused ? AppColors.pureWhite : AppColors.bgLight),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.xl,
              ),
              prefixIcon: widget.prefixIcon != null
                  ? Icon(
                      widget.prefixIcon,
                      color: _isFocused
                          ? AppColors.electricBlue
                          : (isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight),
                      size: 22,
                    )
                  : null,
              suffixIcon: widget.isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscureText
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                        size: 22,
                      ),
                      onPressed: () =>
                          setState(() => _obscureText = !_obscureText),
                    )
                  : widget.suffixIcon,
              border: _buildBorder(isDark),
              enabledBorder: _buildBorder(isDark),
              focusedBorder: _buildBorder(isDark, isFocused: true),
              errorBorder: _buildBorder(isDark, isError: true),
              focusedErrorBorder: _buildBorder(
                isDark,
                isError: true,
                isFocused: true,
              ),
              disabledBorder: _buildBorder(isDark, isDisabled: true),
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(
    bool isDark, {
    bool isFocused = false,
    bool isError = false,
    bool isDisabled = false,
  }) {
    Color borderColor;
    if (isError) {
      borderColor = AppColors.black;
    } else if (isFocused) {
      borderColor = AppColors.electricBlue;
    } else if (isDisabled) {
      borderColor = isDark ? AppColors.disabledDark : AppColors.disabledLight;
    } else {
      borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    }

    return OutlineInputBorder(
      borderRadius: AppRadius.medium,
      borderSide: BorderSide(color: borderColor, width: isFocused ? 2.0 : 1.0),
    );
  }
}

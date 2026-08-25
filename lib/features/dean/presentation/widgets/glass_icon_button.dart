import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';

/// A translucent "glass" icon button used across Dean of Studies app bars —
/// a frosted rounded container behind the icon rather than a bare
/// [IconButton], matching the module's requested visual treatment.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    final button = Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.large),
      child: InkWell(
        borderRadius: AppRadius.large,
        onTap: onPressed,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: AppRadius.large,
            border: Border.all(color: primary, width: 1),
          ),
          child: Icon(icon, size: 20, color: primary),
        ),
      ),
    );
    return tooltip == null ? button : Tooltip(message: tooltip!, child: button);
  }
}

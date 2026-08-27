import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.background(context),
              border: Border.all(
                color: AppColors.border(context),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: AppColors.textPrimary(context),
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

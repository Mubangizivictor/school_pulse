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
              color: AppColors.electricBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.electricBlue),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.electricBlue),
          ),
        ],
      ),
    );
  }
}

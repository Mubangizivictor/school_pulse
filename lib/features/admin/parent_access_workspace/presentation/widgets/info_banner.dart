import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Pale-blue informational banner: "A learner can have up to 2 parents."
/// Dismissible per-session only (not persisted) - re-shown on next app
/// launch, matching the reference screenshots' lightweight, non-modal tone.
class ParentAccessInfoBanner extends StatelessWidget {
  final VoidCallback? onDismiss;

  const ParentAccessInfoBanner({super.key, this.onDismiss});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.informationSurface(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.information(context),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'A learner can have up to 2 parents',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.information(context),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onDismiss != null)
            Semantics(
              label: 'Dismiss information banner',
              button: true,
              child: InkWell(
                onTap: onDismiss,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: AppColors.information(context),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

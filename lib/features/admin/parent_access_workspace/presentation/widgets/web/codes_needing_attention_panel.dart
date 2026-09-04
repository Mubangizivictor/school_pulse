import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

/// Right-side panel on web: "Codes needing attention", fed by real counts
/// derived from cubit state (expiringSoonCount, revoked/failed count) - no
/// hardcoded numbers.
class CodesNeedingAttentionPanel extends StatelessWidget {
  final int expiringSoonCount;
  final int revokedCount;
  final VoidCallback? onViewAccessCodes;

  const CodesNeedingAttentionPanel({
    super.key,
    required this.expiringSoonCount,
    required this.revokedCount,
    this.onViewAccessCodes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Codes needing attention',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          _AttentionRow(
            icon: Icons.error_outline,
            color: AppColors.warning(context),
            count: expiringSoonCount,
            label: 'Expiring soon',
            sublabel: 'Within 48 hours',
          ),
          const SizedBox(height: 10),
          _AttentionRow(
            icon: Icons.cancel_outlined,
            color: AppColors.danger(context),
            count: revokedCount,
            label: 'Revoked',
            sublabel: 'No longer valid',
          ),
          const SizedBox(height: 16),
          if (onViewAccessCodes != null)
            TextButton(
              onPressed: onViewAccessCodes,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                foregroundColor: AppColors.information(context),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Flexible(
                    child: Text(
                      'View access codes',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AttentionRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final int count;
  final String label;
  final String sublabel;

  const _AttentionRow({
    required this.icon,
    required this.color,
    required this.count,
    required this.label,
    required this.sublabel,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$count', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary(context))),
              Text(label, style: TextStyle(fontSize: 12, color: AppColors.textPrimary(context))),
              Text(sublabel, style: TextStyle(fontSize: 11, color: AppColors.textMuted(context))),
            ],
          ),
        ),
      ],
    );
  }
}

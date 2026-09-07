import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

class SummaryCountData {
  final int linkedParents;
  final int codesPending;
  final int expiringSoon;

  const SummaryCountData({
    required this.linkedParents,
    required this.codesPending,
    required this.expiringSoon,
  });
}

/// Live count cards - linked parents / codes pending / expiring soon. Always
/// fed by [SummaryCountData] computed from real cubit state, never a
/// hardcoded literal.
class SummaryCountCards extends StatelessWidget {
  final SummaryCountData data;

  const SummaryCountCards({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.people_outline,
            iconColor: AppColors.success(context),
            iconSurface: AppColors.successSurface(context),
            value: data.linkedParents,
            label: 'linked parents',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.schedule,
            iconColor: AppColors.warning(context),
            iconSurface: AppColors.warningSurface(context),
            value: data.codesPending,
            label: 'invitations pending',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryCard(
            icon: Icons.error_outline,
            iconColor: AppColors.warning(context),
            iconSurface: AppColors.warningSurface(context),
            value: data.expiringSoon,
            label: 'expiring soon',
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconSurface;
  final int value;
  final String label;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.iconSurface,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconSurface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
          ),
        ],
      ),
    );
  }
}

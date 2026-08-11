import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class ApiManagementScreen extends StatelessWidget {
  const ApiManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('API Management')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2l,
              AppSpacing.xl,
              AppSpacing.x2l,
              0,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _ApiStatTile(
                    label: 'Total API Keys',
                    value: '12',
                    icon: Icons.vpn_key_rounded,
                    color: AppColors.primary(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _ApiStatTile(
                    label: 'Active Keys',
                    value: '9',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _ApiStatTile(
                    label: 'Expired',
                    value: '3',
                    icon: Icons.cancel_rounded,
                    color: AppColors.danger(context),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2l,
              AppSpacing.x2l,
              AppSpacing.x2l,
              AppSpacing.s,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create API Key'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2l,
              AppSpacing.xl,
              AppSpacing.x2l,
              AppSpacing.m,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.key_rounded,
                    color: AppColors.primary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Text(
                  'API Keys',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x2l,
                0,
                AppSpacing.x2l,
                AppSpacing.x3l,
              ),
              children: const [
                _ApiKeyTile(
                  name: 'Mobile App',
                  keyLabel: 'sp_live_***************e373',
                  created: 'May 15, 2024',
                  expires: 'Never',
                  status: 'Active',
                ),
                _ApiKeyTile(
                  name: 'School Integrations',
                  keyLabel: 'sp_live_***************b5e4',
                  created: 'April 28, 2024',
                  expires: 'Never',
                  status: 'Active',
                ),
                _ApiKeyTile(
                  name: 'Reporting Service',
                  keyLabel: 'sp_live_***************c9a1',
                  created: 'April 10, 2024',
                  expires: 'Dec 22, 2024',
                  status: 'Active',
                ),
                _ApiKeyTile(
                  name: 'Webhook Service',
                  keyLabel: 'sp_live_***************d2a8',
                  created: 'Mar 5, 2024',
                  expires: 'May 5, 2024',
                  status: 'Expired',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiStatTile extends StatelessWidget {
  const _ApiStatTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              maxLines: 1,
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ApiKeyTile extends StatelessWidget {
  const _ApiKeyTile({
    required this.name,
    required this.keyLabel,
    required this.created,
    required this.expires,
    required this.status,
  });

  final String name;
  final String keyLabel;
  final String created;
  final String expires;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isActive = status == 'Active';
    final statusColor = isActive
        ? AppColors.success(context)
        : AppColors.danger(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              StatusBadge(label: status, color: statusColor),
              const SizedBox(width: AppSpacing.s),
              Icon(Icons.more_horiz, color: AppColors.textSecondary(context)),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            keyLabel,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
              fontFamily: 'Monospace',
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Created: $created',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                'Expires: $expires',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

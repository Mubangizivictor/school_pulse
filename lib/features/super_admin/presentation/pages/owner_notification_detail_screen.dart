import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';

/// Full content of a single owner notification, plus real per-channel
/// delivery status pulled straight from [OwnerNotification.pushStatus] /
/// [OwnerNotification.emailStatus] - no fabricated diagnostics. In-app
/// delivery status isn't tracked as a distinct field in the entity (the
/// in-app feed *is* the notification document, so its delivery is implicit
/// in the document existing), so that row shows "Delivered" unconditionally
/// rather than inventing a status the backend doesn't return.
class OwnerNotificationDetailScreen extends StatelessWidget {
  const OwnerNotificationDetailScreen({super.key, required this.notification});

  final OwnerNotification notification;

  static const _dateFormat = 'MMM d, yyyy • h:mm a';

  @override
  Widget build(BuildContext context) {
    final money = NumberFormat.currency(symbol: 'UGX ', decimalDigits: 0);
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Details')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: AppTypography.titleMedium.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    StatusBadge(
                      label: notification.isUnread ? 'New' : 'Resolved',
                      color: notification.isUnread
                          ? AppColors.warning(context)
                          : AppColors.textSecondary(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  DateFormat(_dateFormat).format(notification.createdAt),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                if (notification.body.isNotEmpty)
                  Text(
                    notification.body,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                const SizedBox(height: AppSpacing.l),
                _infoRow(context, 'School', notification.schoolName),
                if (notification.amountUgx > 0)
                  _infoRow(
                    context,
                    'Amount',
                    money.format(notification.amountUgx),
                  ),
                if (notification.method.isNotEmpty)
                  _infoRow(context, 'Method', notification.method),
                if (notification.resolvedAt != null)
                  _infoRow(
                    context,
                    'Resolved',
                    DateFormat(_dateFormat).format(notification.resolvedAt!),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x2l),
          Text(
            'Delivery Status',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          _DeliveryRow(
            icon: Icons.smartphone_outlined,
            label: 'In-App',
            status: 'Delivered',
            ok: true,
          ),
          _DeliveryRow(
            icon: Icons.notifications_active_outlined,
            label: 'Push',
            status: _statusLabel(notification.pushStatus),
            ok:
                notification.pushStatus == 'sent' ||
                notification.pushStatus == 'delivered',
          ),
          _DeliveryRow(
            icon: Icons.email_outlined,
            label: 'Email',
            status: _statusLabel(notification.emailStatus),
            ok:
                notification.emailStatus == 'sent' ||
                notification.emailStatus == 'delivered',
          ),
        ],
      ),
    );
  }

  String _statusLabel(String? status) {
    if (status == null) return 'Not attempted';
    switch (status) {
      case 'sent':
      case 'delivered':
        return 'Sent';
      case 'failed':
        return 'Failed';
      case 'partial':
        return 'Partial';
      default:
        return status;
    }
  }

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary(context),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeliveryRow extends StatelessWidget {
  const _DeliveryRow({
    required this.icon,
    required this.label,
    required this.status,
    required this.ok,
  });

  final IconData icon;
  final String label;
  final String status;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    final color = status == 'Not attempted'
        ? AppColors.textSecondary(context)
        : ok
        ? AppColors.success(context)
        : AppColors.danger(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary(context)),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          StatusBadge(label: status, color: color),
        ],
      ),
    );
  }
}

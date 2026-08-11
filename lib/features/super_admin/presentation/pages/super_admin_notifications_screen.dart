import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_preferences.dart';

import 'payment_review_screen.dart';
import 'school_management_screen.dart';

/// SaaS Owner "Notifications" overview: category on/off switches, a Quiet
/// Hours shortcut, and the most recent alerts from the realtime feed with a
/// link into the full history.
///
/// New school applications and payment proofs are written by the Cloud
/// notification engine to `super_admin_notifications`. Push/email delivery is
/// secondary: this feed remains the durable source of truth even if an
/// external channel is unavailable.
class SuperAdminNotificationsScreen extends StatefulWidget {
  const SuperAdminNotificationsScreen({super.key});

  @override
  State<SuperAdminNotificationsScreen> createState() =>
      _SuperAdminNotificationsScreenState();
}

class _SuperAdminNotificationsScreenState
    extends State<SuperAdminNotificationsScreen> {
  final OwnerNotificationService _notifications = OwnerNotificationService();
  final ManualPaymentService _payments = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  String? _openingNotificationId;
  bool _savingPreferences = false;

  String? get _ownerId => _notifications.currentOwnerId;

  Future<void> _openNotification(OwnerNotification notification) async {
    if (notification.isApplication) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const SchoolManagementScreen()));
      return;
    }

    if (!notification.isPayment || notification.paymentId.isEmpty) return;
    setState(() => _openingNotificationId = notification.id);
    try {
      final payments = await _payments.getPayments();
      final match = payments
          .where((payment) => payment.id == notification.paymentId)
          .toList();
      if (!mounted) return;
      if (match.isEmpty) {
        _showSnack(
          'This payment could no longer be found. It may already have been resolved.',
          isError: true,
        );
        return;
      }
      await PaymentReviewScreen.open(context, match.first);
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _openingNotificationId = null);
    }
  }

  Future<void> _togglePreference(
    OwnerNotificationPreferences current,
    OwnerNotificationPreferences updated,
  ) async {
    if (_savingPreferences) return;
    setState(() => _savingPreferences = true);
    try {
      await _notifications.savePreferences(updated);
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _savingPreferences = false);
    }
  }

  Future<void> _pickQuietHours(OwnerNotificationPreferences prefs) async {
    final start = await showTimePicker(
      context: context,
      initialTime:
          prefs.quietHoursStart ?? const TimeOfDay(hour: 21, minute: 0),
      helpText: 'Quiet hours start',
    );
    if (start == null || !mounted) return;

    final end = await showTimePicker(
      context: context,
      initialTime: prefs.quietHoursEnd ?? const TimeOfDay(hour: 6, minute: 0),
      helpText: 'Quiet hours end',
    );
    if (end == null || !mounted) return;

    await _togglePreference(
      prefs,
      prefs.copyWith(quietHoursStart: start, quietHoursEnd: end),
    );
  }

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  String _friendlyError(Object error) {
    final value = error.toString();
    if (value.contains('permission-denied')) {
      return 'Only the seeded School Pulse SaaS Owner can perform this action.';
    }
    if (value.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    if (value.contains('not-found')) {
      return 'The notification backend has not been deployed yet.';
    }
    return value.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = _ownerId;
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ownerId == null
          ? const Center(child: Text('Sign in to manage notifications'))
          : StreamBuilder<OwnerNotificationPreferences>(
              stream: _notifications.watchPreferences(ownerId),
              builder: (context, prefsSnapshot) {
                final prefs =
                    prefsSnapshot.data ??
                    OwnerNotificationPreferences.defaults(ownerId);
                return StreamBuilder<List<OwnerNotification>>(
                  stream: _notifications.watchNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: SchoolPulseLoader());
                    }
                    if (snapshot.hasError) {
                      return _ErrorState(
                        message: _friendlyError(snapshot.error!),
                        onRetry: () => setState(() {}),
                      );
                    }

                    final items = snapshot.data ?? const <OwnerNotification>[];
                    final recent = items.take(5).toList();

                    return ListView(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.xl,
                        AppSpacing.x3l,
                      ),
                      children: [
                        _header(context, items),
                        const SizedBox(height: AppSpacing.xl),
                        _categoriesSection(context, prefs),
                        const SizedBox(height: AppSpacing.x3l),
                        _recentSection(context, recent),
                      ],
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _header(BuildContext context, List<OwnerNotification> items) {
    final unread = items.where((item) => item.isUnread).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Owner alerts',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (unread > 0)
              StatusBadge(
                label: '$unread new',
                color: AppColors.warning(context),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Applications, payments and critical School Pulse platform activity.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }

  Widget _categoriesSection(
    BuildContext context,
    OwnerNotificationPreferences prefs,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Categories',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () => context.push(
                '/super-admin/settings/notifications/preferences',
              ),
              child: const Text('More settings'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        _CategoryToggleRow(
          icon: Icons.notifications_active_outlined,
          title: 'Push Notifications',
          subtitle: 'Deliver alerts to this device',
          value: prefs.pushEnabled,
          enabled: !_savingPreferences,
          onChanged: (value) =>
              _togglePreference(prefs, prefs.copyWith(pushEnabled: value)),
        ),
        _CategoryToggleRow(
          icon: Icons.email_outlined,
          title: 'Email Alerts',
          subtitle: 'Send a copy to the owner email',
          value: prefs.emailEnabled,
          enabled: !_savingPreferences,
          onChanged: (value) =>
              _togglePreference(prefs, prefs.copyWith(emailEnabled: value)),
        ),
        _CategoryToggleRow(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Billing Alerts',
          subtitle: 'Subscription and invoice changes',
          value: prefs.billingAlerts,
          enabled: !_savingPreferences,
          onChanged: (value) =>
              _togglePreference(prefs, prefs.copyWith(billingAlerts: value)),
        ),
        _CategoryToggleRow(
          icon: Icons.school_outlined,
          title: 'School Application Alerts',
          subtitle: 'New schools requesting onboarding',
          value: prefs.schoolApplicationAlerts,
          enabled: !_savingPreferences,
          onChanged: (value) => _togglePreference(
            prefs,
            prefs.copyWith(schoolApplicationAlerts: value),
          ),
        ),
        _CategoryToggleRow(
          icon: Icons.payments_outlined,
          title: 'Payment Alerts',
          subtitle: 'Manual payment proofs to review',
          value: prefs.paymentAlerts,
          enabled: !_savingPreferences,
          onChanged: (value) =>
              _togglePreference(prefs, prefs.copyWith(paymentAlerts: value)),
        ),
        _CategoryToggleRow(
          icon: Icons.insights_outlined,
          title: 'Platform Activity',
          subtitle: 'General platform and audit events',
          value: prefs.platformActivityAlerts,
          enabled: !_savingPreferences,
          onChanged: (value) => _togglePreference(
            prefs,
            prefs.copyWith(platformActivityAlerts: value),
          ),
        ),
        AppCard(
          margin: const EdgeInsets.only(top: 2),
          onTap: () => _pickQuietHours(prefs),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft(context),
                  borderRadius: BorderRadius.circular(AppRadius.m),
                ),
                child: Icon(
                  Icons.bedtime_outlined,
                  color: AppColors.primary(context),
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quiet Hours',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      prefs.quietHoursConfigured
                          ? '${_formatTime(prefs.quietHoursStart!)} – ${_formatTime(prefs.quietHoursEnd!)}'
                          : 'Off',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ],
    );
  }

  Widget _recentSection(BuildContext context, List<OwnerNotification> recent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Recent Notifications',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary(context),
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.push('/super-admin/settings/notifications/history'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.m),
        if (recent.isEmpty)
          const EmptyState(
            icon: Icons.notifications_none_rounded,
            title: 'No notifications yet',
            message:
                'New school applications and payment proofs that need your attention will appear here in real time.',
          )
        else
          ...recent.map(
            (notification) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _NotificationCard(
                notification: notification,
                amount: notification.amountUgx > 0
                    ? _money.format(notification.amountUgx)
                    : null,
                createdAt: _dateTime.format(notification.createdAt),
                isOpening: _openingNotificationId == notification.id,
                onTap: () => _openNotification(notification),
              ),
            ),
          ),
      ],
    );
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}

class _CategoryToggleRow extends StatelessWidget {
  const _CategoryToggleRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(AppRadius.m),
            ),
            child: Icon(icon, color: AppColors.primary(context), size: 20),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: enabled ? onChanged : null),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notification,
    required this.amount,
    required this.createdAt,
    required this.isOpening,
    required this.onTap,
  });

  final OwnerNotification notification;
  final String? amount;
  final String createdAt;
  final bool isOpening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final icon = notification.isApplication
        ? Icons.school_outlined
        : notification.method == 'bank'
        ? Icons.account_balance_rounded
        : Icons.payments_outlined;

    return AppCard(
      onTap: isOpening ? null : onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: theme.colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      label: notification.isUnread ? 'New' : 'Resolved',
                      color: notification.isUnread
                          ? AppColors.warning(context)
                          : AppColors.textSecondary(context),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  notification.schoolName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (notification.body.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: [
                    if (amount != null)
                      Text(
                        amount!,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    Text(createdAt, style: theme.textTheme.bodySmall),
                    if (notification.pushStatus != null)
                      _DeliveryChip(
                        icon: Icons.notifications_active_outlined,
                        label: 'Push ${notification.pushStatus}',
                      ),
                    if (notification.emailStatus != null)
                      _DeliveryChip(
                        icon: Icons.email_outlined,
                        label: 'Email ${notification.emailStatus}',
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          isOpening
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

class _DeliveryChip extends StatelessWidget {
  const _DeliveryChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary(context)),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

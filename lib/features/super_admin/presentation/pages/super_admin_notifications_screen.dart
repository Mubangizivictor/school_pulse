import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';

import 'payment_review_screen.dart';
import 'school_management_screen.dart';

/// Realtime SaaS Owner notification center.
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
  bool _diagnosing = false;

  Future<void> _openNotification(OwnerNotification notification) async {
    if (notification.isApplication) {
      await Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const SchoolManagementScreen()),
      );
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

  Future<void> _showDiagnostics() async {
    if (_diagnosing) return;
    setState(() => _diagnosing = true);
    try {
      final health = await _notifications.getHealth();
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => _NotificationHealthSheet(
          health: health,
          onSendTest: () async {
            Navigator.of(sheetContext).pop();
            await _sendTest();
          },
        ),
      );
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _diagnosing = false);
    }
  }

  Future<void> _sendTest() async {
    _showSnack('Sending test through in-app, push and email…');
    try {
      final result = await _notifications.sendTest();
      if (!mounted) return;
      final push = result['push'] is Map
          ? Map<String, dynamic>.from(result['push'] as Map)
          : const <String, dynamic>{};
      final email = result['email'] is Map
          ? Map<String, dynamic>.from(result['email'] as Map)
          : const <String, dynamic>{};
      final inApp = result['inApp'] is Map
          ? Map<String, dynamic>.from(result['inApp'] as Map)
          : const <String, dynamic>{};
      _showSnack(
        'In-app: ${inApp['status'] ?? 'unknown'} • Push: ${push['status'] ?? 'unknown'} • Email: ${email['status'] ?? 'unknown'}',
        isError: push['status'] == 'failed' || email['status'] == 'failed',
      );
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Notification health',
            onPressed: _diagnosing ? null : _showDiagnostics,
            icon: _diagnosing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.monitor_heart_outlined),
          ),
        ],
      ),
      body: StreamBuilder<List<OwnerNotification>>(
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
          return CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                  AppSpacing.s,
                ),
                sliver: SliverToBoxAdapter(child: _header(context, items)),
              ),
              if (items.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyState(
                    icon: Icons.notifications_none_rounded,
                    title: 'No notifications yet',
                    message:
                        'New school applications and payment proofs that need your attention will appear here in real time.',
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.s,
                    AppSpacing.xl,
                    AppSpacing.x3l,
                  ),
                  sliver: SliverList.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final notification = items[index];
                      return _NotificationCard(
                        notification: notification,
                        amount: notification.amountUgx > 0
                            ? _money.format(notification.amountUgx)
                            : null,
                        createdAt: _dateTime.format(notification.createdAt),
                        isOpening:
                            _openingNotificationId == notification.id,
                        onTap: () => _openNotification(notification),
                      );
                    },
                  ),
                ),
            ],
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
          'Applications, payments and critical School Pulse platform activity. Use the health button to test push and email delivery.',
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
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

class _NotificationHealthSheet extends StatelessWidget {
  const _NotificationHealthSheet({
    required this.health,
    required this.onSendTest,
  });

  final Map<String, dynamic> health;
  final Future<void> Function() onSendTest;

  @override
  Widget build(BuildContext context) {
    final ownerCount = health['ownerCount'] ?? 0;
    final tokenCount = health['pushTokenCount'] ?? 0;
    final smtpReady = health['smtpConfigured'] == true;
    final recipients = health['emailRecipients'] is List
        ? (health['emailRecipients'] as List).join(', ')
        : 'None';

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 4, 22, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification health',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Live backend checks for the SaaS Owner notification pipeline.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(height: 20),
            _HealthRow(
              label: 'Owner account',
              value: '$ownerCount found',
              ok: ownerCount is num && ownerCount > 0,
            ),
            _HealthRow(
              label: 'Push devices',
              value: '$tokenCount registered',
              ok: tokenCount is num && tokenCount > 0,
            ),
            _HealthRow(
              label: 'Email transport',
              value: smtpReady ? 'SMTP configured' : 'SMTP not configured',
              ok: smtpReady,
            ),
            _HealthRow(
              label: 'Email recipient',
              value: recipients,
              ok: recipients != 'None' && recipients.isNotEmpty,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onSendTest,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send test notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HealthRow extends StatelessWidget {
  const _HealthRow({required this.label, required this.value, required this.ok});
  final String label;
  final String value;
  final bool ok;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            ok ? Icons.check_circle_rounded : Icons.error_outline_rounded,
            size: 20,
            color: ok ? Colors.green : Theme.of(context).colorScheme.error,
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
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
            FilledButton.tonal(onPressed: onRetry, child: const Text('Try Again')),
          ],
        ),
      ),
    );
  }
}

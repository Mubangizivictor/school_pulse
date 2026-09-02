import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/super_admin/data/services/manual_payment_service.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';

import '../responsive.dart';
import 'payment_review_screen.dart';
import 'school_management_screen.dart';

/// SaaS Owner "Notifications" overview.
///
/// The feed streams from `super_admin_notifications` (owner-scoped by an
/// `ownerId` field the Firestore rule enforces). Every mutation - mark one
/// read, mark all read, delete one, clear all - goes through the owner-only
/// callables in [OwnerNotificationService], never a direct Firestore write.
/// The unread count in the header and the top-bar bell both derive from the
/// same live stream, so they update the instant a callable resolves.
class SuperAdminNotificationsScreen extends StatefulWidget {
  const SuperAdminNotificationsScreen({super.key, this.service});

  /// Injectable for tests; production uses the default [OwnerNotificationService].
  final OwnerNotificationService? service;

  @override
  State<SuperAdminNotificationsScreen> createState() =>
      _SuperAdminNotificationsScreenState();
}

class _SuperAdminNotificationsScreenState
    extends State<SuperAdminNotificationsScreen> {
  late final OwnerNotificationService _notifications =
      widget.service ?? OwnerNotificationService();
  final ManualPaymentService _payments = ManualPaymentService();
  final NumberFormat _money = NumberFormat.currency(
    symbol: 'UGX ',
    decimalDigits: 0,
  );
  final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  String? _openingNotificationId;
  bool _busy = false;
  int _pendingOffline = 0;

  String? get _ownerId => _notifications.currentOwnerId;

  @override
  void initState() {
    super.initState();
    _refreshPending();
    // Best-effort: replay any actions queued from a previous offline session.
    _notifications.syncPending().then((_) => _refreshPending());
  }

  Future<void> _refreshPending() async {
    final count = await _notifications.pendingActionCount();
    if (mounted && count != _pendingOffline) {
      setState(() => _pendingOffline = count);
    }
  }

  Future<void> _refresh() async {
    if (_busy) return;
    // The feed is already a live, owner-scoped stream. Replaying approved
    // offline actions and rebuilding the subscription is its real refresh;
    // no duplicate direct Firestore read is introduced here.
    setState(() => _busy = true);
    try {
      await _notifications.syncPending();
      await _refreshPending();
      if (mounted) setState(() {});
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openNotification(OwnerNotification notification) async {
    // Opening a notification also clears its unread state - matches the
    // behaviour of every other notification surface in the app.
    if (notification.isUnread) {
      unawaited(_notifications.markRead(notification.id));
    }

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

  Future<void> _markRead(OwnerNotification notification) async {
    await _run(() => _notifications.markRead(notification.id));
  }

  Future<void> _markAllRead() async {
    await _run(() async {
      final n = await _notifications.markAllRead();
      if (mounted) {
        _showSnack(n == 0 ? 'Nothing to mark' : 'Marked $n as read');
      }
    });
  }

  Future<void> _delete(OwnerNotification notification) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Delete this notification?',
      message:
          'It is removed from your feed only. The underlying school '
          'application or payment record is untouched.',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed != true) return;
    await _run(() => _notifications.deleteNotification(notification.id));
  }

  Future<void> _clearAll() async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Clear all notifications?',
      message:
          'Every notification in your feed is permanently removed. This '
          'cannot be undone. Underlying records are untouched.',
      confirmLabel: 'Clear all',
      isDestructive: true,
    );
    if (confirmed != true) return;
    await _run(() async {
      final n = await _notifications.clearAll();
      if (mounted) _showSnack('Cleared $n notification${n == 1 ? '' : 's'}');
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) _showSnack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
      await _refreshPending();
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
    if (value.contains('unavailable') || value.contains('network')) {
      return 'You appear to be offline. This action will not apply until '
          'you reconnect.';
    }
    return value.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  void _openSettings() {
    context.push('/super-admin/settings/notifications/preferences');
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = _ownerId;
    final wide = isSuperAdminWide(context);
    final showAppBar = !wide || Navigator.canPop(context);
    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: const Text('Notifications'),
              actions: [
                IconButton(
                  tooltip: 'Notification settings',
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: _openSettings,
                ),
              ],
            )
          : null,
      body: ownerId == null
          ? const Center(child: Text('Sign in to manage notifications'))
          : StreamBuilder<List<OwnerNotification>>(
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

                final list = RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      wide ? AppSpacing.x2l : AppSpacing.xl,
                      AppSpacing.xl,
                      wide ? AppSpacing.x2l : AppSpacing.xl,
                      AppSpacing.x3l,
                    ),
                    children: [
                      _header(context, items, showSettingsButton: !showAppBar),
                      const SizedBox(height: AppSpacing.xl),
                      _recentSection(context, items),
                    ],
                  ),
                );
                if (!wide) return list;
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: list,
                  ),
                );
              },
            ),
    );
  }

  Widget _header(
    BuildContext context,
    List<OwnerNotification> items, {
    required bool showSettingsButton,
  }) {
    final unread = items.where((item) => item.isUnread).length;
    return Row(
      children: [
        Expanded(
          child: Text(
            'Recent Notifications',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        if (unread > 0) ...[
          StatusBadge(label: '$unread new', color: AppColors.warning(context)),
          const SizedBox(width: AppSpacing.s),
        ],
        if (items.isNotEmpty)
          PopupMenuButton<String>(
            enabled: !_busy,
            tooltip: 'Notification actions',
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.more_horiz_rounded),
            onSelected: (value) {
              switch (value) {
                case 'mark_all':
                  _markAllRead();
                case 'clear_all':
                  _clearAll();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'mark_all',
                enabled: unread > 0,
                child: const Text('Mark all as read'),
              ),
              const PopupMenuItem(value: 'clear_all', child: Text('Clear all')),
            ],
          ),
        if (showSettingsButton)
          IconButton(
            tooltip: 'Notification settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
      ],
    );
  }

  Widget _recentSection(BuildContext context, List<OwnerNotification> recent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                busy: _busy,
                onTap: () => _openNotification(notification),
                onMarkRead: notification.isUnread
                    ? () => _markRead(notification)
                    : null,
                onDelete: () => _delete(notification),
              ),
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
    required this.busy,
    required this.onTap,
    required this.onMarkRead,
    required this.onDelete,
  });

  final OwnerNotification notification;
  final String? amount;
  final String createdAt;
  final bool isOpening;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback onDelete;

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
                      label: notification.displayStatus == 'NEW'
                          ? 'New'
                          : notification.displayStatus == 'RESOLVED'
                          ? 'Resolved'
                          : 'Read',
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
          const SizedBox(width: 4),
          if (isOpening)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          else
            PopupMenuButton<String>(
              enabled: !busy,
              tooltip: 'Actions',
              icon: const Icon(Icons.more_vert_rounded),
              onSelected: (value) {
                if (value == 'read') onMarkRead?.call();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (context) => [
                if (onMarkRead != null)
                  const PopupMenuItem(
                    value: 'read',
                    child: Text('Mark as read'),
                  ),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
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

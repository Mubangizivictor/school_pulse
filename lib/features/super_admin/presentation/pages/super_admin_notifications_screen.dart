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

import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';
import 'payment_review_screen.dart';

/// Real notifications feed for the SaaS owner console. Currently shows
/// manual-payment-submission events written server-side to
/// `super_admin_notifications`; tapping one loads the full payment and opens
/// [PaymentReviewScreen].
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

  List<OwnerNotification> _items = const [];
  bool _loading = true;
  String? _error;
  String? _openingNotificationId;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await _notifications.getNotifications();
      if (!mounted) return;
      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _friendlyError(error);
      });
    }
  }

  Future<void> _openNotification(OwnerNotification notification) async {
    setState(() => _openingNotificationId = notification.id);
    try {
      final payments = await _payments.getPayments();
      final match = payments
          .where((payment) => payment.id == notification.paymentId)
          .toList();
      if (!mounted) return;
      if (match.isEmpty) {
        _showSnack(
          'This payment could no longer be found. It may have been removed.',
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

  void _showSnack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : null,
      ),
    );
  }

  String _friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('permission-denied')) {
      return 'Only the seeded School Pulse SaaS Owner can perform this action.';
    }
    if (text.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    return text.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Refresh notifications',
            onPressed: _loading ? null : _reload,
            icon: const Icon(Icons.refresh_rounded),
          ),
          if (!wide) const SuperAdminLogoutButton(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.s,
              ),
              sliver: SliverToBoxAdapter(child: _header(context)),
            ),
            if (_loading)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: SchoolPulseLoader()),
              )
            else if (_error != null)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _ErrorState(message: _error!, onRetry: _reload),
              )
            else if (_items.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  icon: Icons.notifications_none_rounded,
                  title: 'No notifications yet',
                  message:
                      'Payment submissions and platform activity that need your attention will appear here.',
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
                  itemCount: _items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final notification = _items[index];
                    return _NotificationCard(
                      notification: notification,
                      amount: _money.format(notification.amountUgx),
                      createdAt: _dateTime.format(notification.createdAt),
                      isOpening: _openingNotificationId == notification.id,
                      onTap: () => _openNotification(notification),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notifications',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          'Payment submissions and platform activity that need your attention.',
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
  final String amount;
  final String createdAt;
  final bool isOpening;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: isOpening ? null : onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              notification.method == 'bank'
                  ? Icons.account_balance_rounded
                  : Icons.phone_android_rounded,
              color: theme.colorScheme.onPrimaryContainer,
            ),
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
                        notification.schoolName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
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
                const SizedBox(height: 4),
                Text(
                  'Submitted a manual subscription payment',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 7),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      notification.method == 'bank'
                          ? 'Centenary Bank'
                          : 'MTN MoMo',
                      style: theme.textTheme.bodySmall,
                    ),
                    Text(
                      createdAt,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
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

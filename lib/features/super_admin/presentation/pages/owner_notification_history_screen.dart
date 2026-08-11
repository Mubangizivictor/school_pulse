import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';

import 'owner_notification_detail_screen.dart';

enum _ChannelFilter { all, push, email }

/// Full history of SaaS Owner notifications, grouped by date, with a channel
/// filter. Sourced entirely from [OwnerNotificationService.watchNotifications]
/// - the same realtime `super_admin_notifications` feed as the Overview
/// screen's "Recent Notifications" section, just unbounded and grouped.
class OwnerNotificationHistoryScreen extends StatefulWidget {
  const OwnerNotificationHistoryScreen({super.key});

  @override
  State<OwnerNotificationHistoryScreen> createState() =>
      _OwnerNotificationHistoryScreenState();
}

class _OwnerNotificationHistoryScreenState
    extends State<OwnerNotificationHistoryScreen> {
  final OwnerNotificationService _service = OwnerNotificationService();
  final DateFormat _time = DateFormat('h:mm a');
  _ChannelFilter _filter = _ChannelFilter.all;

  String _filterLabel(_ChannelFilter filter) {
    switch (filter) {
      case _ChannelFilter.all:
        return 'All Channels';
      case _ChannelFilter.push:
        return 'Push';
      case _ChannelFilter.email:
        return 'Email';
    }
  }

  bool _matchesFilter(OwnerNotification notification) {
    switch (_filter) {
      case _ChannelFilter.all:
        return true;
      case _ChannelFilter.push:
        return notification.pushStatus != null;
      case _ChannelFilter.email:
        return notification.emailStatus != null;
    }
  }

  String _sectionFor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff < 7) return DateFormat('EEEE').format(date);
    return DateFormat('MMMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification History')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.l,
              AppSpacing.xl,
              AppSpacing.s,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: _FilterDropdown(
                label: _filterLabel(_filter),
                onSelected: (filter) => setState(() => _filter = filter),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<OwnerNotification>>(
              stream: _service.watchNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: SchoolPulseLoader());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Could not load notification history.'),
                  );
                }

                final items = (snapshot.data ?? const <OwnerNotification>[])
                    .where(_matchesFilter)
                    .toList();

                if (items.isEmpty) {
                  return const EmptyState(
                    icon: Icons.history_outlined,
                    title: 'No notifications',
                    message: 'No notifications match this filter yet.',
                  );
                }

                final grouped = <String, List<OwnerNotification>>{};
                for (final item in items) {
                  grouped
                      .putIfAbsent(_sectionFor(item.createdAt), () => [])
                      .add(item);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.s,
                    AppSpacing.xl,
                    AppSpacing.x3l,
                  ),
                  children: [
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(
                          top: AppSpacing.l,
                          bottom: AppSpacing.s,
                        ),
                        child: Text(
                          entry.key,
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                      ...entry.value.map(
                        (notification) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _HistoryTile(
                            notification: notification,
                            time: _time.format(notification.createdAt),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OwnerNotificationDetailScreen(
                                  notification: notification,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({required this.label, required this.onSelected});

  final String label;
  final ValueChanged<_ChannelFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_ChannelFilter>(
      onSelected: onSelected,
      itemBuilder: (context) => const [
        PopupMenuItem(value: _ChannelFilter.all, child: Text('All Channels')),
        PopupMenuItem(value: _ChannelFilter.push, child: Text('Push')),
        PopupMenuItem(value: _ChannelFilter.email, child: Text('Email')),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({
    required this.notification,
    required this.time,
    required this.onTap,
  });

  final OwnerNotification notification;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = notification.isApplication
        ? Icons.school_outlined
        : notification.method == 'bank'
        ? Icons.account_balance_rounded
        : Icons.payments_outlined;

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 18,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  notification.schoolName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            time,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

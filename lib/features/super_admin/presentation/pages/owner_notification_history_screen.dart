import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_taxonomy.dart';

import '../widgets/owner_notification_visuals.dart';
import 'owner_notification_detail_screen.dart';
import 'super_admin_notifications_screen.dart';

/// Full, date-grouped history of owner notifications. Same realtime
/// `super_admin_notifications` feed as the main screen, unbounded and
/// grouped, with the same six owner filter chips.
class OwnerNotificationHistoryScreen extends StatefulWidget {
  const OwnerNotificationHistoryScreen({super.key, this.service});

  final OwnerNotificationService? service;

  @override
  State<OwnerNotificationHistoryScreen> createState() =>
      _OwnerNotificationHistoryScreenState();
}

class _OwnerNotificationHistoryScreenState
    extends State<OwnerNotificationHistoryScreen> {
  late final OwnerNotificationService _service =
      widget.service ?? OwnerNotificationService();
  final DateFormat _time = DateFormat('h:mm a');
  OwnerNotificationFilter _filter = OwnerNotificationFilter.all;

  bool _matches(OwnerNotification n) {
    switch (_filter) {
      case OwnerNotificationFilter.all:
        return true;
      case OwnerNotificationFilter.critical:
        return n.severity == OwnerNotificationSeverity.critical ||
            n.severity == OwnerNotificationSeverity.requiresReview;
      case OwnerNotificationFilter.billing:
        return n.category == OwnerNotificationCategory.billing;
      case OwnerNotificationFilter.platform:
        return n.category == OwnerNotificationCategory.platform;
      case OwnerNotificationFilter.schools:
        return n.category == OwnerNotificationCategory.schools;
      case OwnerNotificationFilter.security:
        return n.category == OwnerNotificationCategory.security;
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
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        title: const Text('Notification history'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: OwnerFilterChips(
              selected: _filter,
              onSelected: (f) => setState(() => _filter = f),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<OwnerNotification>>(
              stream: _service.watchNotifications(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load notification history.'),
                  );
                }

                final items = (snapshot.data ?? const <OwnerNotification>[])
                    .where(_matches)
                    .toList();

                if (items.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Nothing in ${_filter.label} yet.',
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    ),
                  );
                }

                final grouped = <String, List<OwnerNotification>>{};
                for (final item in items) {
                  grouped
                      .putIfAbsent(_sectionFor(item.createdAt), () => [])
                      .add(item);
                }

                return ListView(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
                  children: [
                    for (final entry in grouped.entries) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                        child: Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                      ),
                      ...entry.value.map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OwnerNotificationTile(
                            notification: n,
                            timestamp: _time.format(n.createdAt),
                            busy: false,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => OwnerNotificationDetailScreen(
                                  notification: n,
                                  service: _service,
                                ),
                              ),
                            ),
                            onMarkRead: n.isUnread
                                ? () => _service.markRead(n.id)
                                : null,
                            onMarkUnread: null,
                            onArchive: () =>
                                _service.archiveNotification(n.id),
                            onDelete: () =>
                                _service.deleteNotification(n.id),
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

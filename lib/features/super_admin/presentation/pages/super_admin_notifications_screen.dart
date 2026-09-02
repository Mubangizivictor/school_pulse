import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/super_admin/data/services/owner_notification_service.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification.dart';
import 'package:school_pulse/features/super_admin/domain/entities/owner_notification_taxonomy.dart';

import '../responsive.dart';
import '../widgets/owner_notification_visuals.dart';
import 'owner_notification_detail_screen.dart';

/// SaaS Owner "Notifications" screen — an owner-only nested route under
/// Settings. The persistent owner bottom navigation stays visible (Settings
/// selected) because the route is wrapped in `SuperAdminMobileNavShell`.
///
/// Dark-premium: near-black page, charcoal tiles with a 1px grey border,
/// royal-blue selected/filter accent, compact 8px rhythm. Light theme uses
/// the identical layout on an off-white ground with white tiles.
///
/// Shares nothing with any school-role notification screen: its own screen,
/// its own [OwnerNotificationService], its own tile, its own filters.
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
  final DateFormat _dateTime = DateFormat('MMM d, yyyy • h:mm a');

  OwnerNotificationFilter _filter = OwnerNotificationFilter.all;
  bool _busy = false;
  int _pendingOffline = 0;
  List<OwnerNotification>? _cachedFallback;

  String? get _ownerId => _notifications.currentOwnerId;

  @override
  void initState() {
    super.initState();
    _refreshPending();
    _notifications.cachedNotifications().then((cached) {
      if (mounted && cached.isNotEmpty) {
        setState(() => _cachedFallback = cached);
      }
    });
    _notifications.syncPending().then((_) => _refreshPending());
  }

  Future<void> _refreshPending() async {
    final count = await _notifications.pendingActionCount();
    if (mounted && count != _pendingOffline) {
      setState(() => _pendingOffline = count);
    }
  }

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

  void _openSettings() =>
      context.go('/super-admin/settings/notifications/preferences');

  Future<void> _openDetail(OwnerNotification n) async {
    if (n.isUnread) unawaited(_run(() => _notifications.markRead(n.id)));
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OwnerNotificationDetailScreen(
          notification: n,
          service: _notifications,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _markAllRead() => _run(() async {
        final n = await _notifications.markAllRead();
        if (mounted) {
          _snack(n == 0 ? 'Nothing to mark' : 'Marked $n as read');
        }
      });

  Future<void> _markRead(OwnerNotification n) =>
      _run(() => _notifications.markRead(n.id));

  Future<void> _markUnread(OwnerNotification n) =>
      // No "mark unread" callable exists; surface honestly rather than fake it.
      _run(() async {
        if (mounted) _snack('Marking unread is not available for owner alerts.');
      });

  Future<void> _archive(OwnerNotification n) =>
      _run(() => _notifications.archiveNotification(n.id));

  Future<void> _delete(OwnerNotification n) async {
    final ok = await _confirm(
      title: 'Delete this notification?',
      message: 'It is removed from your owner feed only. The underlying '
          'record is untouched.',
      confirmLabel: 'Delete',
    );
    if (ok != true) return;
    await _run(() => _notifications.deleteNotification(n.id));
  }

  Future<void> _clearAll() async {
    final ok = await _confirm(
      title: 'Clear all notifications?',
      message: 'Every notification in your owner feed is permanently removed. '
          'This cannot be undone. Underlying records are untouched.',
      confirmLabel: 'Clear all',
    );
    if (ok != true) return;
    await _run(() async {
      final n = await _notifications.clearAll();
      if (mounted) _snack('Cleared $n notification${n == 1 ? '' : 's'}');
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } catch (error) {
      if (mounted) _snack(_friendlyError(error), isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
      await _refreshPending();
    }
  }

  Future<bool?> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger(ctx),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _snack(String text, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: isError ? AppColors.danger(context) : null,
      ),
    );
  }

  String _friendlyError(Object error) {
    final v = error.toString();
    if (v.contains('permission-denied')) {
      return 'Only the School Pulse SaaS Owner can perform this action.';
    }
    if (v.contains('unauthenticated')) {
      return 'Your owner session expired. Sign in again.';
    }
    if (v.contains('not-found')) {
      return 'The owner notification backend is not deployed yet.';
    }
    if (v.contains('unavailable') || v.contains('network')) {
      return 'You appear to be offline. This applies when you reconnect.';
    }
    return v.replaceFirst(RegExp(r'^Exception:\s*'), '');
  }

  @override
  Widget build(BuildContext context) {
    final wide = isSuperAdminWide(context);
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: AppColors.background(context),
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Notification settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _ownerId == null
          ? const Center(child: Text('Sign in to manage notifications'))
          : StreamBuilder<List<OwnerNotification>>(
              stream: _notifications.watchNotifications(),
              builder: (context, snapshot) {
                final live = snapshot.data;
                final items = live ?? _cachedFallback ?? const [];
                final offline = live == null && _cachedFallback != null;

                if (live == null &&
                    _cachedFallback == null &&
                    snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError && _cachedFallback == null) {
                  return _ErrorState(
                    message: _friendlyError(snapshot.error!),
                    onRetry: () => setState(() {}),
                  );
                }

                final filtered =
                    items.where(_matches).toList(growable: false);
                final unread = items.where((n) => n.isUnread).length;

                final body = ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  children: [
                    _TopControls(
                      unread: unread,
                      busy: _busy,
                      hasItems: items.isNotEmpty,
                      onMarkAll: unread > 0 ? _markAllRead : null,
                      onClearAll: items.isNotEmpty ? _clearAll : null,
                    ),
                    const SizedBox(height: 12),
                    OwnerFilterChips(
                      selected: _filter,
                      onSelected: (f) => setState(() => _filter = f),
                    ),
                    if (offline) ...[
                      const SizedBox(height: 12),
                      _OfflineBanner(pending: _pendingOffline),
                    ],
                    const SizedBox(height: 12),
                    if (filtered.isEmpty)
                      _EmptyState(filter: _filter)
                    else
                      ...filtered.map(
                        (n) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: OwnerNotificationTile(
                            notification: n,
                            timestamp: _dateTime.format(n.createdAt),
                            busy: _busy,
                            onTap: () => _openDetail(n),
                            onMarkRead:
                                n.isUnread ? () => _markRead(n) : null,
                            onMarkUnread:
                                n.isUnread ? null : () => _markUnread(n),
                            onArchive: () => _archive(n),
                            onDelete: () => _delete(n),
                          ),
                        ),
                      ),
                  ],
                );

                if (!wide) return body;
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 760),
                    child: body,
                  ),
                );
              },
            ),
    );
  }
}

class _TopControls extends StatelessWidget {
  const _TopControls({
    required this.unread,
    required this.busy,
    required this.hasItems,
    required this.onMarkAll,
    required this.onClearAll,
  });

  final int unread;
  final bool busy;
  final bool hasItems;
  final VoidCallback? onMarkAll;
  final VoidCallback? onClearAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(
            'Recent',
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
          ),
        ),
        if (unread > 0) ...[
          const SizedBox(width: 10),
          OwnerUnreadChip(count: unread),
        ],
        const Spacer(),
        if (onMarkAll != null)
          TextButton(
            onPressed: busy ? null : onMarkAll,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.information(context),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            child: const Text(
              'Mark all read',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ),
        if (hasItems)
          PopupMenuButton<String>(
            enabled: !busy,
            tooltip: 'More',
            icon: Icon(
              Icons.more_horiz_rounded,
              color: AppColors.textSecondary(context),
            ),
            onSelected: (v) {
              if (v == 'clear') onClearAll?.call();
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'clear', child: Text('Clear all')),
            ],
          ),
      ],
    );
  }
}

/// Compact 88px owner notification tile.
class OwnerNotificationTile extends StatelessWidget {
  const OwnerNotificationTile({
    super.key,
    required this.notification,
    required this.timestamp,
    required this.busy,
    required this.onTap,
    required this.onMarkRead,
    required this.onMarkUnread,
    required this.onArchive,
    required this.onDelete,
  });

  final OwnerNotification notification;
  final String timestamp;
  final bool busy;
  final VoidCallback onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onMarkUnread;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final visuals =
        OwnerNotificationVisuals.forNotification(context, notification);
    return Material(
      color: AppColors.surfaceElevated(context),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        onLongPress: busy ? null : () => _showActions(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          constraints: const BoxConstraints(minHeight: 84),
          padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border(context)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OwnerIconSquare(icon: visuals.icon, accent: visuals.accent),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.25,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                        if (notification.isUnread) ...[
                          const SizedBox(width: 8),
                          Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppColors.information(context),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _summary(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Text(
                          timestamp,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textMuted(context),
                          ),
                        ),
                        if (notification.severity.showsOnTile)
                          OwnerSeverityChip(severity: notification.severity),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _summary() {
    if (notification.body.isNotEmpty) return notification.body;
    if (notification.schoolName.isNotEmpty &&
        notification.schoolName != 'School Pulse') {
      return notification.schoolName;
    }
    return notification.category.wire;
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onMarkRead != null)
              ListTile(
                leading: const Icon(Icons.mark_email_read_outlined),
                title: const Text('Mark read'),
                onTap: () {
                  Navigator.pop(ctx);
                  onMarkRead!();
                },
              ),
            if (onMarkUnread != null)
              ListTile(
                leading: const Icon(Icons.mark_email_unread_outlined),
                title: const Text('Mark unread'),
                onTap: () {
                  Navigator.pop(ctx);
                  onMarkUnread!();
                },
              ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archive notification'),
              onTap: () {
                Navigator.pop(ctx);
                onArchive();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger(ctx),
              ),
              title: Text(
                'Delete notification',
                style: TextStyle(color: AppColors.danger(ctx)),
              ),
              onTap: () {
                Navigator.pop(ctx);
                onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.pending});
  final int pending;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.textMuted(context).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            size: 16,
            color: AppColors.textSecondary(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              pending > 0
                  ? 'Offline — showing your last synced feed. $pending change'
                      "${pending == 1 ? '' : 's'} will apply when you reconnect."
                  : 'Offline — showing your last synced feed.',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.filter});
  final OwnerNotificationFilter filter;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(
            Icons.notifications_none_rounded,
            size: 40,
            color: AppColors.textMuted(context),
          ),
          const SizedBox(height: 12),
          Text(
            filter == OwnerNotificationFilter.all
                ? 'No notifications yet'
                : 'Nothing in ${filter.label}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Owner-level events — payment reviews, platform health, school '
            'requests and security — appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary(context),
            ),
          ),
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
              color: AppColors.danger(context),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

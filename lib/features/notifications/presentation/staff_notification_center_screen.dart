import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/data/models/staff_alert.dart';
import 'package:school_pulse/features/notifications/data/repositories/staff_alerts_repository.dart';

class StaffNotificationCenterScreen extends StatefulWidget {
  const StaffNotificationCenterScreen({super.key});

  @override
  State<StaffNotificationCenterScreen> createState() =>
      _StaffNotificationCenterScreenState();
}

class _StaffNotificationCenterScreenState
    extends State<StaffNotificationCenterScreen> {
  final _repository = StaffAlertsRepository();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    final uid = authState.user.id;
    final groups = NotificationGroups.forRole(authState.user.role);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(title: const Text('Notifications')),
      body: StreamBuilder<List<StaffAlert>>(
        stream: _repository.watchAllForUser(uid: uid, groups: groups),
        initialData: const [],
        builder: (context, snapshot) {
          // Only show skeletons if we are truly waiting and have no data at all
          if (snapshot.connectionState == ConnectionState.waiting &&
              snapshot.data == null) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 6,
              itemBuilder: (context, index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Skeleton(height: 76),
              ),
            );
          }
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Couldn\'t load notifications',
              message:
                  'Something went wrong on our end. Pull to refresh or check back shortly.',
            );
          }
          final alerts = snapshot.data ?? const [];
          if (alerts.isEmpty) {
            return const EmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
              message:
                  'Broadcasts and direct alerts sent to you will show up here.',
            );
          }

          final unread = alerts.where((a) => !a.isReadBy(uid)).toList();

          return Column(
            children: [
              if (unread.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${unread.length} unread',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _repository.markAllRead(alerts, uid),
                        child: const Text('Mark all read'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: alerts.length,
                  itemBuilder: (context, index) {
                    final alert = alerts[index];
                    final isUnread = !alert.isReadBy(uid);
                    return Dismissible(
                      key: Key(alert.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.delete_outline,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        _repository.deleteAlert(alert.id);
                      },
                      child: FadeInSlide(
                        delay: Duration(milliseconds: index * 40),
                        child: _AlertTile(
                          alert: alert,
                          isUnread: isUnread,
                          onTap: () {
                            if (isUnread) _repository.markRead(alert.id, uid);
                          },
                        ),
                      ),
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
}

class _AlertTile extends StatelessWidget {
  final StaffAlert alert;
  final bool isUnread;
  final VoidCallback onTap;

  const _AlertTile({
    required this.alert,
    required this.isUnread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final color = alert.type == 'SMS' ? semantic.warning : semantic.info;
    final icon = alert.userId != null
        ? Icons.person_pin_circle_outlined
        : (alert.type == 'SMS' ? Icons.sms_outlined : Icons.campaign_outlined);

    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        alert.title,
                        style: TextStyle(
                          fontWeight: isUnread
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _relative(alert.timestamp),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  alert.body,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }

  String _relative(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${timestamp.day}/${timestamp.month}';
  }
}

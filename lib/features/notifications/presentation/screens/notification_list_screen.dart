import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_category_config.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_bloc.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_event.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // The signed-in user supplies the tenant and recipient the centre is
    // scoped to; without one there is nothing to show.
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    if (user == null) {
      return const _NotificationScaffold(
        body: Center(
          child: Text(
            'Sign in to see your notifications',
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => di.sl<NotificationCenterBloc>()
        ..add(
          NotificationCenterStarted(schoolId: user.schoolId, userId: user.id),
        ),
      child: const _NotificationListView(),
    );
  }
}

/// Tells the user these rows came from the on-device cache, so stale content
/// is never mistaken for live content.
class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E293B),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: Colors.white60, size: 16),
          SizedBox(width: 8),
          Text(
            'Showing saved notifications',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

/// Shared chrome so the signed-out and loaded states look identical.
class _NotificationScaffold extends StatelessWidget {
  final Widget body;

  const _NotificationScaffold({required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view, color: Colors.white),
            onPressed: () => context.push('/staff/notifications/center'),
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () => context.push('/staff/notifications/search'),
          ),
          IconButton(
            icon: const Icon(Icons.tune, color: Colors.white),
            onPressed: () => context.push('/staff/notifications/filter'),
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/staff/notifications/add'),
        backgroundColor: const Color(0xFF6366F1),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _NotificationListView extends StatefulWidget {
  const _NotificationListView();

  @override
  State<_NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<_NotificationListView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCenterBloc, NotificationCenterState>(
      builder: (context, state) {
        return _NotificationScaffold(
          body: Column(
            children: [
              _buildTabs(state),
              if (state.isOffline) const _OfflineBanner(),
              Expanded(
                child: state.status == NotificationCenterStatus.loading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6366F1),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildNotificationList(state.items),
                          _buildNotificationList(state.unread),
                          _buildNotificationList(state.pinned),
                          _buildNotificationList(state.mentions),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs(NotificationCenterState state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          dividerColor: Colors.transparent,
          indicatorColor: Colors.transparent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
          tabs: [
            // Counts come from the live cache aggregate rather than the loaded
            // page, so they reflect the full history, not just what is on
            // screen.
            _buildTab('All', state.totalCount),
            _buildTab('Unread', state.unreadCount),
            _buildTab('Pinned', state.pinnedCount),
            _buildTab('Mentions', state.mentions.length),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int count) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label),
            if (count > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  count.toString(),
                  style: const TextStyle(fontSize: 10, color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<NotificationItem> notifications) {
    final bloc = context.read<NotificationCenterBloc>();

    if (notifications.isEmpty) {
      // Still wrapped in a refresh indicator: an empty list is exactly when a
      // user is most likely to pull down expecting something to appear.
      return RefreshIndicator(
        onRefresh: () async => bloc.add(const NotificationCenterRefreshed()),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 160),
            Center(
              child: Text(
                'No notifications found',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      );
    }

    final state = bloc.state;

    return RefreshIndicator(
      onRefresh: () async => bloc.add(const NotificationCenterRefreshed()),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          // Request the next page slightly before the bottom so the list keeps
          // moving rather than stalling at the end.
          final atEnd =
              scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 300;
          if (atEnd && state.hasMore && !state.isLoadingMore) {
            bloc.add(const NotificationCenterLoadedMore());
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: notifications.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= notifications.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                ),
              );
            }
            return _NotificationTile(notification: notifications[index]);
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationItem notification;

  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // Opening records openedAt and readAt as distinct timestamps, then
        // navigates. The notification travels as `extra` so the details screen
        // renders immediately instead of re-fetching by id.
        context.read<NotificationCenterBloc>().add(
          NotificationOpened(notification.id),
        );
        context.push(
          '/staff/notifications/${notification.id}',
          extra: notification,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(notification.timestamp),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.description,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        notification.senderName,
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      if (notification.priority == NotificationPriority.high)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE11D48).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'High',
                            style: TextStyle(
                              color: Color(0xFFE11D48),
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (notification.status == NotificationStatus.unread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: 8, top: 4),
                decoration: const BoxDecoration(
                  color: Color(0xFF6366F1),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    // Category treatment comes from the shared catalog, so a newly-added
    // category gets its own icon and colour rather than falling back to a
    // generic grey bell.
    final config = NotificationCategoryCatalog.of(notification.category);
    final iconColor = config.color;
    final photoUrl = notification.senderIdentity.photoUrl;

    // A human sender's photo identifies them faster than a category icon
    // does; automated notifications keep the module icon.
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundColor: iconColor.withValues(alpha: 0.2),
        foregroundImage: NetworkImage(photoUrl),
        // Shown while loading and if the image fails or was deleted.
        child: Icon(config.icon, color: iconColor, size: 20),
      );
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(config.icon, color: iconColor, size: 20),
    );
  }
}

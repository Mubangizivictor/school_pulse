import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_category_config.dart';
import 'package:school_pulse/features/notifications/domain/entities/notification_model.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_bloc.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_event.dart';
import 'package:school_pulse/features/notifications/presentation/bloc/notification_center_state.dart';
import 'package:school_pulse/features/notifications/routing/deep_link_router/notification_deep_link_router.dart';
import 'package:school_pulse/features/notifications/routing/notification_shell_route.dart';
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
      return _NotificationScaffold(
        unreadCount: 0,
        onMarkAllRead: null,
        body: Center(
          child: Text(
            'Sign in to see your notifications',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => di.sl<NotificationCenterBloc>()
        ..add(
          NotificationCenterStarted(schoolId: user.schoolId, userId: user.id),
        ),
      child: _NotificationListView(
        basePath: notificationShellBasePath(user.role),
        canCompose: user.role == UserRole.schoolAdmin,
      ),
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
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.m,
      ),
      color: AppColors.surfaceContainer(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off, color: AppColors.textMuted(context), size: 16),
          const SizedBox(width: AppSpacing.m),
          Text(
            'Showing saved notifications',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Shared chrome so every state (signed-out, loading, loaded) looks
/// identical to the reference: back arrow, title, unread badge, overflow
/// menu, search field, and quick-filter chip row.
class _NotificationScaffold extends StatelessWidget {
  final Widget body;
  final int unreadCount;
  final VoidCallback? onMarkAllRead;
  final String basePath;
  final bool canCompose;

  const _NotificationScaffold({
    required this.body,
    required this.unreadCount,
    required this.onMarkAllRead,
    this.basePath = '/staff/notifications',
    this.canCompose = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        title: Row(
          children: [
            Text('Notifications', style: AppTypography.headlineSmall),
            if (unreadCount > 0) ...[
              const SizedBox(width: AppSpacing.m),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  borderRadius: AppRadius.full,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: AppTypography.labelMedium.copyWith(
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => context.push('$basePath/center'),
          ),
        ],
      ),
      body: body,
      floatingActionButton: canCompose
          ? FloatingActionButton(
              onPressed: () => context.push('$basePath/add'),
              backgroundColor: AppColors.primary(context),
              child: const Icon(Icons.add, color: AppColors.pureWhite),
            )
          : null,
    );
  }
}

class _NotificationListView extends StatefulWidget {
  final String basePath;
  final bool canCompose;

  const _NotificationListView({
    required this.basePath,
    required this.canCompose,
  });

  @override
  State<_NotificationListView> createState() => _NotificationListViewState();
}

class _NotificationListViewState extends State<_NotificationListView> {
  final _searchController = TextEditingController();

  String get _basePath => widget.basePath;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCenterBloc, NotificationCenterState>(
      builder: (context, state) {
        final bloc = context.read<NotificationCenterBloc>();
        return _NotificationScaffold(
          unreadCount: state.unreadCount,
          basePath: _basePath,
          canCompose: widget.canCompose,
          onMarkAllRead: state.unreadCount > 0
              ? () => bloc.add(const NotificationAllMarkedRead())
              : null,
          body: Column(
            children: [
              _buildSearchBar(context),
              if (state.isOffline) const _OfflineBanner(),
              Expanded(
                child: state.status == NotificationCenterStatus.loading
                    ? const Center(child: SchoolPulseLoader())
                    : state.status == NotificationCenterStatus.failure
                    ? _buildError(context, bloc)
                    : _buildSectionedList(context, state, bloc),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.l,
        AppSpacing.xl,
        AppSpacing.m,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) => context.read<NotificationCenterBloc>().add(
          NotificationCenterSearched(value),
        ),
        decoration: InputDecoration(
          hintText: 'Search notifications',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: AppColors.surfaceContainer(context),
          contentPadding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
          border: OutlineInputBorder(
            borderRadius: AppRadius.large,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.large,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.large,
            borderSide: BorderSide(color: AppColors.primary(context)),
          ),
        ),
      ),
    );
  }

  Widget _buildError(BuildContext context, NotificationCenterBloc bloc) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.x3l),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: AppSpacing.l),
            Text(
              'Could not load notifications',
              style: AppTypography.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.m),
            OutlinedButton(
              onPressed: () => bloc.add(const NotificationCenterRefreshed()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionedList(
    BuildContext context,
    NotificationCenterState state,
    NotificationCenterBloc bloc,
  ) {
    if (state.items.isEmpty) {
      // Still wrapped in a refresh indicator: an empty list is exactly when a
      // user is most likely to pull down expecting something to appear.
      return RefreshIndicator(
        onRefresh: () async => bloc.add(const NotificationCenterRefreshed()),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 120),
            Icon(
              Icons.notifications_none,
              size: 48,
              color: AppColors.textMuted(context),
            ),
            const SizedBox(height: AppSpacing.l),
            Center(
              child: Text(
                'No notifications found',
                style: AppTypography.bodyLarge.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ),
          ],
        ),
      );
    }

    final sections = _sectionize(state.items);

    return RefreshIndicator(
      onRefresh: () async => bloc.add(const NotificationCenterRefreshed()),
      child: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          // Request the next page slightly before the bottom so the list
          // keeps moving rather than stalling at the end.
          final atEnd =
              scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 300;
          if (atEnd && state.hasMore && !state.isLoadingMore) {
            bloc.add(const NotificationCenterLoadedMore());
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: sections.length + (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index >= sections.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.l),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }

            final entry = sections[index];
            if (entry is _SectionHeader) {
              return Padding(
                padding: EdgeInsets.only(
                  top: index == 0 ? AppSpacing.m : AppSpacing.xl,
                  bottom: AppSpacing.m,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(entry.label, style: AppTypography.titleMedium),
                    if (entry.showMarkAllRead && state.unreadCount > 0)
                      TextButton(
                        onPressed: () =>
                            bloc.add(const NotificationAllMarkedRead()),
                        child: const Text('Mark all as read'),
                      ),
                  ],
                ),
              );
            }

            return _NotificationTile(
              notification: (entry as _SectionItem).notification,
              basePath: _basePath,
            );
          },
        ),
      ),
    );
  }

  /// Groups items into "Today" / "Earlier" sections, matching the reference
  /// layout. Real section boundaries beyond that (e.g. "Yesterday", weekday
  /// names) aren't in the reference, so everything before today collapses
  /// into one "Earlier" bucket.
  List<_SectionEntry> _sectionize(List<NotificationItem> items) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final todayItems = <NotificationItem>[];
    final earlierItems = <NotificationItem>[];
    for (final item in items) {
      final day = DateTime(
        item.timestamp.year,
        item.timestamp.month,
        item.timestamp.day,
      );
      if (day == today) {
        todayItems.add(item);
      } else {
        earlierItems.add(item);
      }
    }

    return [
      if (todayItems.isNotEmpty) ...[
        const _SectionHeader('Today', showMarkAllRead: true),
        ...todayItems.map(_SectionItem.new),
      ],
      if (earlierItems.isNotEmpty) ...[
        _SectionHeader('Earlier', showMarkAllRead: todayItems.isEmpty),
        ...earlierItems.map(_SectionItem.new),
      ],
    ];
  }
}

sealed class _SectionEntry {
  const _SectionEntry();
}

class _SectionHeader extends _SectionEntry {
  final String label;
  final bool showMarkAllRead;
  const _SectionHeader(this.label, {this.showMarkAllRead = false});
}

class _SectionItem extends _SectionEntry {
  final NotificationItem notification;
  const _SectionItem(this.notification);
}

class _NotificationTile extends StatefulWidget {
  final NotificationItem notification;
  final String basePath;

  const _NotificationTile({required this.notification, required this.basePath});

  @override
  State<_NotificationTile> createState() => _NotificationTileState();
}

class _NotificationTileState extends State<_NotificationTile> {
  NotificationItem get notification => widget.notification;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.status == NotificationStatus.unread;

    return InkWell(
      borderRadius: AppRadius.large,
      onTap: () {
        // Opening records openedAt and readAt as distinct timestamps, then
        // navigates. The notification travels as `extra` so the details
        // screen renders immediately instead of re-fetching by id.
        context.read<NotificationCenterBloc>().add(
          NotificationOpened(notification.id),
        );
        context.push(
          '${widget.basePath}/${notification.id}',
          extra: notification,
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.m),
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: AppRadius.large,
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(context),
            const SizedBox(width: AppSpacing.l),
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
                          style: AppTypography.titleMedium,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Text(
                        _relativeTime(notification.timestamp),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Text(
                    notification.description,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary(context),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (notification.hasAction) ...[
                    const SizedBox(height: AppSpacing.m),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton(
                        onPressed: () => _handleAction(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 36),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.l,
                          ),
                        ),
                        child: Text(notification.actions.first.label),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(left: AppSpacing.m, top: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary(context),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Resolved through the same authorized deep-link router the details
  /// screen uses, rather than pushed directly - tenancy, permission and
  /// existence are re-checked at the moment of navigation since the
  /// underlying record may have changed since the notification was sent.
  Future<void> _handleAction(BuildContext context) async {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    if (user == null) return;

    final bloc = context.read<NotificationCenterBloc>();
    bloc.add(NotificationOpened(notification.id));

    final resolution = await const NotificationDeepLinkRouter().resolve(
      notification: notification,
      user: user,
    );

    if (!context.mounted) return;

    final destination = resolution.destination;
    if (destination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resolution.message ?? 'This item is no longer available.',
          ),
        ),
      );
      return;
    }

    context.push(destination.route, extra: destination.extra);
  }

  /// Matches the reference's "10 min ago" / "1 hr ago" style for the same
  /// day, falling back to a clock time for anything older.
  String _relativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24 &&
        timestamp.day == now.day &&
        timestamp.month == now.month) {
      return '${diff.inHours} hr${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return DateFormat('EEE').format(timestamp);
    return DateFormat('MMM d').format(timestamp);
  }

  Widget _buildIcon(BuildContext context) {
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
        radius: 20,
        backgroundColor: iconColor.withValues(alpha: 0.15),
        foregroundImage: NetworkImage(photoUrl),
        // Shown while loading and if the image fails or was deleted.
        child: Icon(config.icon, color: iconColor, size: 20),
      );
    }

    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.15),
        borderRadius: AppRadius.medium,
      ),
      child: Icon(config.icon, color: iconColor, size: 20),
    );
  }
}

extension on NotificationItem {
  bool get hasAction => actions.isNotEmpty;
}

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
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

class NotificationCenterGroupedScreen extends StatelessWidget {
  const NotificationCenterGroupedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Sign in to see your notifications',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return BlocProvider(
      create: (_) => di.sl<NotificationCenterBloc>()
        ..add(
          NotificationCenterStarted(schoolId: user.schoolId, userId: user.id),
        ),
      child: const _GroupedCenterView(),
    );
  }
}

class _GroupedCenterView extends StatefulWidget {
  const _GroupedCenterView();

  @override
  State<_GroupedCenterView> createState() => _GroupedCenterViewState();
}

class _GroupedCenterViewState extends State<_GroupedCenterView> {
  final Map<NotificationCategory, bool> _expandedSections = {
    NotificationCategory.announcements: true,
    NotificationCategory.attendance: true,
    NotificationCategory.finance: true,
  };

  NotificationCategory? _selectedCategory;

  /// Sections rendered, in order. Colours and icons match what this screen
  /// drew inline before; they now come from the shared catalog so a newly
  /// added category cannot end up untreated.
  static const _sections = [
    NotificationCategory.announcements,
    NotificationCategory.attendance,
    NotificationCategory.finance,
    NotificationCategory.transport,
    NotificationCategory.messages,
    NotificationCategory.homework,
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCenterBloc, NotificationCenterState>(
      builder: (context, state) {
        final grouped = state.groupedByCategory;

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.pop(),
            ),
            title: const Text(
              'Notification Center',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: () => context.push('/staff/notifications/search'),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: () async => context.read<NotificationCenterBloc>().add(
              const NotificationCenterRefreshed(),
            ),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCategoryGrid(state),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: state.unreadCount == 0
                            ? null
                            : () => _markAllRead(context),
                        child: Text(
                          'Mark all as read',
                          style: TextStyle(
                            color: state.unreadCount == 0
                                ? Colors.white
                                : Colors.black,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (state.status == NotificationCenterStatus.loading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: SchoolPulseLoader()),
                    )
                  else if (grouped.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(
                        child: Text(
                          'No notifications yet',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                  else
                    // Only sections that actually have notifications are drawn,
                    // so the screen does not show a wall of empty headers.
                    ..._sections
                        .where(
                          (category) =>
                              (_selectedCategory == null ||
                                  _selectedCategory == category) &&
                              (grouped[category]?.isNotEmpty ?? false),
                        )
                        .expand((category) {
                          final config = NotificationCategoryCatalog.of(
                            category,
                          );
                          final items = grouped[category]!;
                          final unread = items
                              .where(
                                (n) => n.status == NotificationStatus.unread,
                              )
                              .length;
                          return [
                            _buildGroupedSection(
                              context,
                              category,
                              config.displayName,
                              config.color,
                              config.icon,
                              unread,
                              items,
                            ),
                            const SizedBox(height: 12),
                          ];
                        }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _markAllRead(BuildContext context) {
    context.read<NotificationCenterBloc>().add(
      NotificationAllMarkedRead(
        // Respects the active filter: "mark all read" inside a category
        // view should not silently clear the rest of the centre.
        categories: _selectedCategory == null ? const {} : {_selectedCategory!},
      ),
    );
  }

  Widget _buildCategoryGrid(NotificationCenterState state) {
    // Same eight tiles as before; the badge numbers are now real unread counts
    // from the live cache rather than hardcoded values.
    const tiles = <NotificationCategory?>[
      null, // "All"
      NotificationCategory.announcements,
      NotificationCategory.attendance,
      NotificationCategory.finance,
      NotificationCategory.transport,
      NotificationCategory.messages,
      NotificationCategory.homework,
      NotificationCategory.others,
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, index) {
        final category = tiles[index];
        final isSelected = _selectedCategory == category;

        if (category == null) {
          return _buildCategoryItem(
            'All',
            Icons.apps,
            Colors.black,
            isSelected: isSelected,
            count: state.unreadCount == 0 ? null : state.unreadCount,
            onTap: () => setState(() => _selectedCategory = null),
          );
        }

        final config = NotificationCategoryCatalog.of(category);
        final unread = state.items
            .where(
              (n) =>
                  n.category == category &&
                  n.status == NotificationStatus.unread,
            )
            .length;

        return _buildCategoryItem(
          config.displayName,
          config.icon,
          config.color,
          isSelected: isSelected,
          // A zero badge is noise; omit it rather than drawing "0".
          count: unread == 0 ? null : unread,
          onTap: () =>
              setState(() => _selectedCategory = isSelected ? null : category),
        );
      },
    );
  }

  Widget _buildCategoryItem(
    String label,
    IconData icon,
    Color color, {
    bool isSelected = false,
    int? count,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected ? color : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isSelected
                      ? Border.all(color: color, width: 2)
                      : null,
                ),
                child: Icon(
                  icon,
                  color: isSelected ? color : Colors.white,
                  size: 24,
                ),
              ),
              if (count != null)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isSelected ? color : Colors.black,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildGroupedSection(
    BuildContext context,
    NotificationCategory category,
    String title,
    Color color,
    IconData icon,
    int count,
    List<NotificationItem> items,
  ) {
    final isExpanded = _expandedSections[category] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _expandedSections[category] = !isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const Divider(height: 1, color: Colors.white),
            ...items.map((item) => _buildSimpleTile(context, item, color)),
          ],
        ],
      ),
    );
  }

  Widget _buildSimpleTile(
    BuildContext context,
    NotificationItem item,
    Color iconColor,
  ) {
    return InkWell(
      onTap: () {
        // Pass the notification so the details screen paints immediately;
        // marking read happens there.
        context.push('/staff/notifications/${item.id}', extra: item);
      },
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
              ),
            ),
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
                          item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('h:mm a').format(item.timestamp),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (item.priority == NotificationPriority.high) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'High',
                        style: TextStyle(color: Colors.black, fontSize: 10),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

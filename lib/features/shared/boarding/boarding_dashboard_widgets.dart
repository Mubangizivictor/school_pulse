import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

/// Shared building blocks for the Matron (girls) and Patron (boys) boarding
/// dashboards. Both wings run the identical workflow and differ only in the
/// gender they are scoped to, so the chrome lives here once - keeping the two
/// dashboards uniform by construction rather than by copy-paste.

/// Greeting header: avatar, time-of-day greeting, name, role and school.
class BoardingDashboardHeader extends StatelessWidget {
  final String userName;
  final String roleLabel;
  final String? schoolName;
  final String? photoUrl;
  final Widget? trailing;

  const BoardingDashboardHeader({
    super.key,
    required this.userName,
    required this.roleLabel,
    this.schoolName,
    this.photoUrl,
    this.trailing,
  });

  static String greetingForNow([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour < 12) return 'Good Morning,';
    if (hour < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  String get _initials {
    final parts = userName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return (parts.first.characters.first + parts.last.characters.first)
        .toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    // IntrinsicHeight lets the avatar match the height of the greeting/name/
    // role column beside it. The avatar keeps a fixed width and stretches only
    // vertically - stretching both axes deadlocks the layout.
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 62,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.15,
                    ),
                    backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
                    child: hasPhoto
                        ? null
                        : Text(
                            _initials,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: semanticColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.scaffoldBackgroundColor,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greetingForNow(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  roleLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12.5,
                    color: theme.colorScheme.outline,
                  ),
                ),
                if (schoolName != null && schoolName!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.m),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: 16,
                        color: theme.colorScheme.outline,
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Flexible(
                        child: Text(
                          schoolName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) Center(child: trailing!),
        ],
      ),
    );
  }
}

/// A single metric in the boarding overview strip.
class BoardingMetric {
  final String label;
  final IconData icon;
  final Color color;
  final int value;

  /// Small caption under the number - "Total" on the headline tile, a share
  /// of the roll ("97.8%") on the rest.
  final String? caption;

  /// Whether the caption should carry the metric's own colour.
  final bool captionUsesColor;
  final VoidCallback? onTap;

  const BoardingMetric({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    this.caption,
    this.captionUsesColor = true,
    this.onTap,
  });
}

/// The boarding overview card - a horizontally scrollable strip of metric
/// tiles above a proportional bar showing how the roll splits.
class BoardingOverviewCard extends StatelessWidget {
  final List<BoardingMetric> metrics;
  final bool isLoading;

  const BoardingOverviewCard({
    super.key,
    required this.metrics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isLoading)
            const Skeleton(height: 64, borderRadius: 12)
          else ...[
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < metrics.length; i++) ...[
                    if (i > 0)
                      VerticalDivider(
                        width: 1,
                        thickness: 1,
                        color: theme.colorScheme.outlineVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                    Expanded(child: _MetricTile(metric: metrics[i])),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            _MetricBar(metrics: metrics),
          ],
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final BoardingMetric metric;

  const _MetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: metric.onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xs,
          vertical: AppSpacing.m,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(metric.icon, color: metric.color, size: 24),
            const SizedBox(height: AppSpacing.m),
            Text(
              metric.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                fontSize: 11.5,
                height: 1.15,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              '${metric.value}',
              style: theme.textTheme.titleLarge?.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            ),
            if (metric.caption != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                metric.caption!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  color: metric.captionUsesColor
                      ? metric.color
                      : theme.colorScheme.outline,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Proportional bar under the metric strip, one segment per non-zero metric.
class _MetricBar extends StatelessWidget {
  final List<BoardingMetric> metrics;

  const _MetricBar({required this.metrics});

  @override
  Widget build(BuildContext context) {
    // The first tile is the roll total, so the bar is built from the states
    // that make it up rather than from every tile.
    final parts = metrics.skip(1).where((m) => m.value > 0).toList();
    if (parts.isEmpty) return const SizedBox.shrink();

    // A raw count flex makes small states (1 of 418) round away to nothing,
    // so each present state is floored at a visible share of the bar.
    final total = parts.fold<int>(0, (sum, m) => sum + m.value);
    int weight(BoardingMetric m) {
      final share = total == 0 ? 0.0 : m.value / total;
      return (share < 0.03 ? 0.03 : share) * 1000 ~/ 1;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: SizedBox(
        height: 4,
        child: Row(
          children: [
            for (var i = 0; i < parts.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              Expanded(
                flex: weight(parts[i]),
                child: ColoredBox(color: parts[i].color),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A three-across quick action tile, sized so two-word labels wrap cleanly
/// rather than being truncated the way the four-across grid does.
class BoardingQuickAction {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const BoardingQuickAction({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class BoardingQuickActionGrid extends StatelessWidget {
  final List<BoardingQuickAction> actions;
  final bool useGlassIconContainers;

  const BoardingQuickActionGrid({
    super.key,
    required this.actions,
    this.useGlassIconContainers = false,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: AppSpacing.l,
        crossAxisSpacing: AppSpacing.l,
        childAspectRatio: 1.35,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        return AppCard(
          onTap: action.onTap,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.m,
            vertical: AppSpacing.l,
          ),
          showShadow: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _QuickActionIcon(
                icon: action.icon,
                color: action.color,
                useGlassContainer: useGlassIconContainers,
              ),
              const SizedBox(height: AppSpacing.m),
              Flexible(
                child: Text(
                  action.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.2,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _QuickActionIcon extends StatelessWidget {
  const _QuickActionIcon({
    required this.icon,
    required this.color,
    required this.useGlassContainer,
  });

  final IconData icon;
  final Color color;
  final bool useGlassContainer;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(icon, color: color, size: 26);
    if (!useGlassContainer) return iconWidget;

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
        ),
      ),
      child: iconWidget,
    );
  }
}

/// A single tile in the secondary metrics row - Dormitories assigned,
/// Occupancy %, Open Discipline Cases, Welfare Concerns.
class BoardingSecondaryMetric {
  final String label;
  final IconData icon;
  final Color color;
  final String value;
  final VoidCallback? onTap;

  const BoardingSecondaryMetric({
    required this.label,
    required this.icon,
    required this.color,
    required this.value,
    this.onTap,
  });
}

/// 2x2 grid of secondary boarding metrics - distinct from
/// [BoardingOverviewCard]'s roll-total strip, this surfaces the
/// dormitory/occupancy/discipline/welfare snapshot.
class BoardingSecondaryMetricsRow extends StatelessWidget {
  final List<BoardingSecondaryMetric> metrics;
  final bool isLoading;

  const BoardingSecondaryMetricsRow({
    super.key,
    required this.metrics,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Skeleton(height: 140, borderRadius: 16);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.l,
        crossAxisSpacing: AppSpacing.l,
        childAspectRatio: 1.9,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        final theme = Theme.of(context);
        return AppCard(
          onTap: metric.onTap,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: metric.color.withValues(alpha: 0.15),
                ),
                child: Icon(metric.icon, size: 18, color: metric.color),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      metric.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      metric.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One row in the "Today's Schedule" card - Morning/Evening Roll Call only,
/// with a time label and, when known, a real completion status derived from
/// attendance data. [statusLabel]/[statusColor] are left null when
/// completion can't be determined from the data available, in which case
/// only the time label renders - never a fabricated "Completed" state.
class BoardingScheduleItem {
  final String title;
  final String timeLabel;
  final IconData icon;
  final Color color;
  final String? statusLabel;
  final Color? statusColor;
  final VoidCallback? onTap;

  const BoardingScheduleItem({
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.color,
    this.statusLabel,
    this.statusColor,
    this.onTap,
  });
}

class BoardingScheduleCard extends StatelessWidget {
  final List<BoardingScheduleItem> items;

  const BoardingScheduleCard({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _CardHeading(title: "Today's Schedule"),
        const SizedBox(height: AppSpacing.l),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.s,
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Divider(
                    height: 1,
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.5,
                    ),
                  ),
                _ScheduleRow(item: items[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final BoardingScheduleItem item;

  const _ScheduleRow({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: item.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        child: Row(
          children: [
            Icon(item.icon, color: item.color, size: 20),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    item.timeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            if (item.statusLabel != null && item.statusColor != null) ...[
              const SizedBox(width: AppSpacing.m),
              StatusBadge(label: item.statusLabel!, color: item.statusColor!),
            ],
          ],
        ),
      ),
    );
  }
}

/// One row in the "Today's Tasks" card.
class BoardingTask {
  final String title;
  final String timeLabel;
  final IconData icon;
  final Color color;
  final bool isDone;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onToggle;

  const BoardingTask({
    required this.title,
    required this.timeLabel,
    required this.icon,
    required this.color,
    this.isDone = false,
    this.onTap,
    this.onToggle,
  });
}

class BoardingTasksCard extends StatelessWidget {
  final List<BoardingTask> tasks;
  final VoidCallback? onViewAll;

  const BoardingTasksCard({super.key, required this.tasks, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  "Today's Tasks",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (onViewAll != null)
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    'View All',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.5,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'Nothing outstanding right now.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ),
            )
          else
            for (var i = 0; i < tasks.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: theme.colorScheme.outlineVariant.withValues(
                    alpha: 0.5,
                  ),
                ),
              _TaskRow(task: tasks[i]),
            ],
        ],
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  final BoardingTask task;

  const _TaskRow({required this.task});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;

    return InkWell(
      onTap: task.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        child: Row(
          children: [
            Icon(task.icon, color: task.color, size: 20),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: task.isDone
                          ? TextDecoration.lineThrough
                          : null,
                      color: task.isDone ? theme.colorScheme.outline : null,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    task.timeLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11.5,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            StatusBadge(
              label: task.isDone ? 'Done' : 'Pending',
              color: task.isDone
                  ? semanticColors.success
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: AppSpacing.m),
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: task.isDone,
                onChanged: task.onToggle == null
                    ? null
                    : (v) => task.onToggle!(v ?? false),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One entry in the Urgent Alerts carousel.
class BoardingAlert {
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const BoardingAlert({
    required this.title,
    required this.detail,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

/// Urgent Alerts: a paged strip of three alerts at a time with page dots,
/// so a long queue stays glanceable without growing the dashboard.
class BoardingAlertsCard extends StatefulWidget {
  final List<BoardingAlert> alerts;
  final VoidCallback? onViewAll;

  const BoardingAlertsCard({super.key, required this.alerts, this.onViewAll});

  @override
  State<BoardingAlertsCard> createState() => _BoardingAlertsCardState();
}

class _BoardingAlertsCardState extends State<BoardingAlertsCard> {
  static const _perPage = 3;

  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pages = <List<BoardingAlert>>[
      for (var i = 0; i < widget.alerts.length; i += _perPage)
        widget.alerts.skip(i).take(_perPage).toList(),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CardHeading(title: 'Urgent Alerts', onViewAll: widget.onViewAll),
        const SizedBox(height: AppSpacing.l),
        AppCard(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.l,
          ),
          child: Column(
            children: [
              SizedBox(
                height: 68,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final group = pages[index];
                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < group.length; i++) ...[
                            if (i > 0)
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: theme.colorScheme.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            Expanded(child: _AlertTile(alert: group[i])),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (pages.length > 1) ...[
                const SizedBox(height: AppSpacing.l),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var i = 0; i < pages.length; i++) ...[
                      if (i > 0) const SizedBox(width: 6),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i == _page
                              ? theme.colorScheme.primary
                              : theme.colorScheme.outlineVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AlertTile extends StatelessWidget {
  final BoardingAlert alert;

  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: alert.onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: alert.color.withValues(alpha: 0.18),
              ),
              child: Icon(alert.icon, size: 18, color: alert.color),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    alert.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    alert.detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      height: 1.3,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: alert.color),
          ],
        ),
      ),
    );
  }
}

/// Card-level heading with an optional "View All" action, sized to sit with
/// the dashboard cards rather than the larger page-level SectionHeader.
class _CardHeading extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const _CardHeading({required this.title, this.onViewAll});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: Text(
              'View All',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.5,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}

/// Page-level heading used above the quick-action grid.
class BoardingSectionHeading extends StatelessWidget {
  final String title;
  final VoidCallback? onViewAll;

  const BoardingSectionHeading({
    super.key,
    required this.title,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) =>
      _CardHeading(title: title, onViewAll: onViewAll);
}

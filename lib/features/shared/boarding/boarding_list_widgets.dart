import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

/// Shared list/detail building blocks for the Matron (girls) and Patron
/// (boys) boarding modules. Both wings run the identical workflow and differ
/// only in the gender they are scoped to, so this chrome lives here once.

/// Present/Absent/Late legend row used under [RollCallGaugeCard]'s gauge.
class RollCallGaugeCard extends StatelessWidget {
  final double presentPercent; // 0.0 - 1.0
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final int totalCount;

  const RollCallGaugeCard({
    super.key,
    required this.presentPercent,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    required this.totalCount,
  });

  String _pct(int value) {
    if (totalCount == 0) return '0%';
    return '${(value / totalCount * 100).round()}%';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        children: [
          CircularPercentGauge(
            percent: presentPercent,
            centerLabel: '${(presentPercent * 100).round()}%',
            subLabel: 'Present',
            color: semanticColors.success,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: _LegendItem(
                  label: 'Present',
                  count: presentCount,
                  percentLabel: _pct(presentCount),
                  color: semanticColors.success,
                ),
              ),
              Expanded(
                child: _LegendItem(
                  label: 'Absent',
                  count: absentCount,
                  percentLabel: _pct(absentCount),
                  color: semanticColors.error,
                ),
              ),
              Expanded(
                child: _LegendItem(
                  label: 'Late',
                  count: lateCount,
                  percentLabel: _pct(lateCount),
                  color: semanticColors.warning,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final String label;
  final int count;
  final String percentLabel;
  final Color color;

  const _LegendItem({
    required this.label,
    required this.count,
    required this.percentLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(shape: BoxShape.circle, color: color),
            ),
            const SizedBox(width: AppSpacing.s),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12,
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          '$count',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        Text(
          percentLabel,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 11,
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

/// One dorm's mini present/absent/late breakdown row, used in the roll-call
/// "Dormitory Breakdown" list.
class RollCallDormBreakdownRow extends StatelessWidget {
  final String dormName;
  final int presentCount;
  final int absentCount;
  final int lateCount;
  final VoidCallback? onTap;

  const RollCallDormBreakdownRow({
    super.key,
    required this.dormName,
    required this.presentCount,
    required this.absentCount,
    required this.lateCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Row(
          children: [
            Expanded(
              child: Text(
                dormName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _MiniStat(count: presentCount, color: semanticColors.success),
            const SizedBox(width: AppSpacing.m),
            _MiniStat(count: absentCount, color: semanticColors.error),
            const SizedBox(width: AppSpacing.m),
            _MiniStat(count: lateCount, color: semanticColors.warning),
            if (onTap != null) ...[
              const SizedBox(width: AppSpacing.s),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: theme.colorScheme.outline,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final int count;
  final Color color;

  const _MiniStat({required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

/// The four attendance states a boarder can be quick-marked with on the
/// roll-call checklist. Extends the old 3-state (`present`/`late`/`absent`)
/// `_StatusButton` pattern from `boarding_attendance_screen.dart` with
/// `leave`.
enum AttendanceQuickStatus { present, late, absent, leave }

/// Compact 4-state present/absent/late/leave quick-mark control group, used
/// as a [StudentListRow] trailing widget on roll-call checklists.
class AttendanceStatusToggle extends StatelessWidget {
  final AttendanceQuickStatus? selected;
  final ValueChanged<AttendanceQuickStatus> onChanged;

  const AttendanceStatusToggle({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ToggleButton(
          icon: Icons.check,
          color: semanticColors.success,
          isSelected: selected == AttendanceQuickStatus.present,
          onTap: () => onChanged(AttendanceQuickStatus.present),
        ),
        const SizedBox(width: 4),
        _ToggleButton(
          icon: Icons.access_time,
          color: semanticColors.warning,
          isSelected: selected == AttendanceQuickStatus.late,
          onTap: () => onChanged(AttendanceQuickStatus.late),
        ),
        const SizedBox(width: 4),
        _ToggleButton(
          icon: Icons.close,
          color: semanticColors.error,
          isSelected: selected == AttendanceQuickStatus.absent,
          onTap: () => onChanged(AttendanceQuickStatus.absent),
        ),
        const SizedBox(width: 4),
        _ToggleButton(
          icon: Icons.exit_to_app,
          color: Colors.black,
          isSelected: selected == AttendanceQuickStatus.leave,
          onTap: () => onChanged(AttendanceQuickStatus.leave),
        ),
      ],
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: isSelected ? color : color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: isSelected ? Colors.white : color),
      ),
    );
  }
}

/// One row in a student list - avatar/photo, name, bed, class, and a
/// trailing slot for either a chevron (profile navigation) or an
/// [AttendanceStatusToggle] quick-mark group.
class StudentListRow extends StatelessWidget {
  final String name;
  final String? photoUrl;
  final String? bedLabel;
  final String? classLabel;
  final VoidCallback? onTap;

  /// Trailing content - pass a chevron icon, an [AttendanceStatusToggle], or
  /// leave null for no trailing content.
  final Widget? trailing;

  const StudentListRow({
    super.key,
    required this.name,
    this.photoUrl,
    this.bedLabel,
    this.classLabel,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitleParts = [
      if (bedLabel != null && bedLabel!.isNotEmpty) bedLabel!,
      if (classLabel != null && classLabel!.isNotEmpty) classLabel!,
    ];

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.m),
        child: Row(
          children: [
            if (photoUrl != null && photoUrl!.isNotEmpty)
              CircleAvatar(radius: 20, backgroundImage: NetworkImage(photoUrl!))
            else
              AvatarInitials(name: name, size: 40),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitleParts.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitleParts.join(' · '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// Thin wrapper over [StatusBadge] mapping the real severity/status strings
/// used by `WelfareRecord`/`DisciplineIncident` (`patron_entities.dart`) -
/// severity: 'Low' | 'Medium' | 'High'; status: 'Pending' | 'Resolved' |
/// 'Follow-up' (welfare) or similar case-status strings - to semantic colors.
class SeverityBadge extends StatelessWidget {
  final String severity;

  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    final color = switch (severity.toLowerCase()) {
      'high' => semanticColors.error,
      'medium' => semanticColors.warning,
      'low' => semanticColors.success,
      _ => Theme.of(context).colorScheme.outline,
    };
    return StatusBadge(label: severity, color: color);
  }
}

/// Generic tabbed scaffold: a [SegmentedTabControl] strip over a filtered
/// list of cards, falling back to [EmptyState] when a tab has nothing to
/// show. Backs Welfare/Discipline/Leave/Announcements-style screens so they
/// become thin instantiations rather than near-duplicate scaffolds.
class TabbedListScaffold<T> extends StatefulWidget {
  final List<String> tabLabels;
  final List<T> items;

  /// Given the selected tab index and an item, returns whether the item
  /// belongs on that tab.
  final bool Function(int tabIndex, T item) filter;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;
  final EdgeInsetsGeometry padding;
  final Widget? header;

  const TabbedListScaffold({
    super.key,
    required this.tabLabels,
    required this.items,
    required this.filter,
    required this.itemBuilder,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here',
    this.emptyMessage = 'Nothing to show for this tab yet.',
    this.padding = const EdgeInsets.all(AppSpacing.l),
    this.header,
  });

  @override
  State<TabbedListScaffold<T>> createState() => _TabbedListScaffoldState<T>();
}

class _TabbedListScaffoldState<T> extends State<TabbedListScaffold<T>> {
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final filtered = widget.items
        .where((item) => widget.filter(_tabIndex, item))
        .toList();

    return ListView(
      padding: widget.padding,
      children: [
        if (widget.header != null) ...[
          widget.header!,
          const SizedBox(height: AppSpacing.l),
        ],
        if (widget.tabLabels.isNotEmpty) ...[
          SegmentedTabControl(
            labels: widget.tabLabels,
            selectedIndex: _tabIndex,
            onChanged: (i) => setState(() => _tabIndex = i),
          ),
          const SizedBox(height: AppSpacing.l),
        ],
        if (filtered.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.x4l),
            child: EmptyState(
              icon: widget.emptyIcon,
              title: widget.emptyTitle,
              message: widget.emptyMessage,
            ),
          )
        else
          for (final item in filtered) widget.itemBuilder(context, item),
      ],
    );
  }
}

/// A grouped, titled section of tappable rows for the More menu.
class MoreMenuSection extends StatelessWidget {
  final String? title;
  final List<Widget> rows;

  const MoreMenuSection({super.key, this.title, required this.rows});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.only(
              left: AppSpacing.s,
              bottom: AppSpacing.m,
            ),
            child: Text(
              title!,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.outline,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ],
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, color: theme.colorScheme.outlineVariant),
                rows[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// One tappable row inside a [MoreMenuSection]: leading icon, label, and a
/// trailing chevron (or custom trailing widget).
class MoreMenuRow extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const MoreMenuRow({
    super.key,
    required this.icon,
    this.iconColor,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.l,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? theme.colorScheme.primary),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: theme.colorScheme.outline,
                ),
          ],
        ),
      ),
    );
  }
}

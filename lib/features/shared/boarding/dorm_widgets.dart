import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

/// Shared building blocks for the dormitory section, used by both the Matron
/// (girls) and Patron (boys) wings so the two stay identical by construction.

/// Compact stat tile used in the 2x2 summary grid at the top of the
/// dormitory list, and in the row above the bed list.
class DormStatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const DormStatTile({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.l,
      ),
      showShadow: false,
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    color: theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Search field with a trailing filter button, as at the top of the
/// dormitory list.
class DormSearchBar extends StatelessWidget {
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterPressed;

  const DormSearchBar({
    super.key,
    this.hintText = 'Search dormitory...',
    this.controller,
    this.onChanged,
    this.onFilterPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
      ),
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            style: theme.textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              isDense: true,
              prefixIcon: Icon(
                Icons.search,
                size: 20,
                color: theme.colorScheme.outline,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppSpacing.l,
                horizontal: AppSpacing.l,
              ),
              border: border,
              enabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: BorderSide(color: theme.colorScheme.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.m),
        InkWell(
          onTap: onFilterPressed,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
              ),
            ),
            child: Icon(
              Icons.tune,
              size: 20,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// One dormitory in the list: name, occupancy badge and bar, leadership rows
/// and the Beds / Students / Leadership action strip.
class DormitoryCard extends StatelessWidget {
  final String name;
  final int occupantCount;
  final int capacity;
  final String? roomLeaderName;
  final String? dormPrefectName;
  final Color accent;
  final VoidCallback? onBeds;
  final VoidCallback? onStudents;
  final VoidCallback? onLeadership;
  final VoidCallback? onMore;

  /// Compact list-display mode: drops the Room Leader/Dorm Prefect rows and
  /// the Beds/Students/Leadership/More action-row footer, in favour of a
  /// whole-card [onTap] for list navigation. Defaults to false so existing
  /// call sites (`dormitory_management_screen.dart`) keep today's full
  /// behaviour unchanged.
  final bool compact;

  /// Plain "Boys Dormitory" / "Girls Dormitory" subtitle shown under the
  /// name in compact mode. Ignored in full mode.
  final String? subtitle;

  /// Whole-card tap target, used in compact mode for list navigation.
  final VoidCallback? onTap;

  const DormitoryCard({
    super.key,
    required this.name,
    required this.occupantCount,
    required this.capacity,
    this.roomLeaderName,
    this.dormPrefectName,
    required this.accent,
    this.onBeds,
    this.onStudents,
    this.onLeadership,
    this.onMore,
    this.compact = false,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;
    final ratio = capacity == 0 ? 0.0 : occupantCount / capacity;
    final percent = (ratio * 100).round();
    final available = (capacity - occupantCount).clamp(0, capacity);

    // Green while there is room, amber as it fills, red once full.
    final barColor = ratio >= 1.0
        ? semanticColors.error
        : ratio >= 0.85
        ? Colors.orange
        : semanticColors.success;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.l),
      onTap: compact ? onTap : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.home_outlined, color: accent, size: 22),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (compact && subtitle != null && subtitle!.isNotEmpty)
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
                ),
              ),
              StatusBadge(label: '$occupantCount/$capacity', color: barColor),
              if (compact && onMore != null) ...[
                const SizedBox(width: AppSpacing.s),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: _CardAction(icon: Icons.more_horiz, onTap: onMore),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.l),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 6,
              backgroundColor: theme.colorScheme.outlineVariant.withValues(
                alpha: 0.4,
              ),
              valueColor: AlwaysStoppedAnimation(barColor),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$percent% Occupied',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                '$available Beds Available',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11.5,
                  color: theme.colorScheme.outline,
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.l),
            _LeadershipRow(
              icon: Icons.emoji_events_outlined,
              label: 'Room Leader',
              value: roomLeaderName,
            ),
            const SizedBox(height: AppSpacing.m),
            _LeadershipRow(
              icon: Icons.shield_outlined,
              label: 'Dorm Prefect',
              value: dormPrefectName,
            ),
            const SizedBox(height: AppSpacing.m),
            Divider(
              height: 1,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
            Row(
              children: [
                Expanded(
                  child: _CardAction(
                    icon: Icons.bed_outlined,
                    label: 'Beds',
                    onTap: onBeds,
                  ),
                ),
                Expanded(
                  child: _CardAction(
                    icon: Icons.groups_outlined,
                    label: 'Students',
                    onTap: onStudents,
                  ),
                ),
                Expanded(
                  child: _CardAction(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Leadership',
                    onTap: onLeadership,
                  ),
                ),
                SizedBox(
                  width: 44,
                  child: _CardAction(icon: Icons.more_horiz, onTap: onMore),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LeadershipRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;

  const _LeadershipRow({required this.icon, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final assigned = value != null && value!.isNotEmpty;

    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.outline),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        Text(
          assigned ? value! : 'Not Assigned',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 12,
            fontWeight: assigned ? FontWeight.w600 : FontWeight.w400,
            color: assigned
                ? theme.colorScheme.onSurface
                : theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }
}

class _CardAction extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback? onTap;

  const _CardAction({required this.icon, this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: theme.colorScheme.onSurfaceVariant),
            if (label != null) ...[
              const SizedBox(width: AppSpacing.s),
              Flexible(
                child: Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Labelled form field used across the Add Dormitory form.
class DormFormField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;

  const DormFormField({
    super.key,
    required this.label,
    required this.hint,
    required this.icon,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            fontSize: 11.5,
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.s),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Padding(
              padding: EdgeInsets.only(
                bottom: maxLines > 1 ? (maxLines - 1) * 22.0 : 0,
              ),
              child: Icon(icon, size: 20, color: theme.colorScheme.primary),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: AppSpacing.l,
              horizontal: AppSpacing.l,
            ),
            border: border,
            enabledBorder: border,
            focusedBorder: border.copyWith(
              borderSide: BorderSide(color: theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }
}

/// Full-width primary button used at the foot of the dorm forms.
class DormPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const DormPrimaryButton({super.key, required this.label, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 52,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.titleSmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// A person picker row: avatar, name, sub-label and a trailing chevron.
class DormPersonPicker extends StatelessWidget {
  final String? name;
  final String? subtitle;
  final String placeholder;
  final VoidCallback? onTap;

  const DormPersonPicker({
    super.key,
    this.name,
    this.subtitle,
    this.placeholder = 'Select a student',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chosen = name != null && name!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.m,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.colorScheme.primary.withValues(
                alpha: 0.15,
              ),
              child: Icon(
                Icons.person_outline,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chosen ? name! : placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: chosen
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.outline,
                    ),
                  ),
                  if (chosen && subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: theme.colorScheme.outline,
            ),
          ],
        ),
      ),
    );
  }
}

/// One bed in the bed list: icon, number, location and an availability chip.
class BedListTile extends StatelessWidget {
  final String bedNumber;
  final String? location;
  final bool occupied;
  final String? studentName;
  final VoidCallback? onTap;

  const BedListTile({
    super.key,
    required this.bedNumber,
    this.location,
    required this.occupied,
    this.studentName,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semanticColors = theme.extension<SemanticColors>()!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.l,
        vertical: AppSpacing.m,
      ),
      showShadow: false,
      onTap: onTap,
      child: Row(
        children: [
          Icon(
            Icons.bed_outlined,
            size: 22,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  bedNumber,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (occupied && studentName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    studentName!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ] else if (location != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    location!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          StatusBadge(
            label: occupied ? 'Occupied' : 'Available',
            color: occupied ? Colors.orange : semanticColors.success,
          ),
        ],
      ),
    );
  }
}

/// One row in the transfer history: avatar, student, from/to, type chip
/// and a timestamp.
class TransferHistoryTile extends StatelessWidget {
  final String studentName;
  final String fromLabel;
  final String toLabel;
  final String typeLabel;
  final Color typeColor;
  final String dateLabel;
  final String timeLabel;

  const TransferHistoryTile({
    super.key,
    required this.studentName,
    required this.fromLabel,
    required this.toLabel,
    required this.typeLabel,
    required this.typeColor,
    required this.dateLabel,
    required this.timeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: const EdgeInsets.all(AppSpacing.l),
      showShadow: false,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: typeColor.withValues(alpha: 0.18),
            child: Icon(Icons.person_outline, size: 18, color: typeColor),
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
                        studentName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.m),
                    StatusBadge(label: typeLabel, color: typeColor),
                  ],
                ),
                const SizedBox(height: AppSpacing.s),
                _FromToRow(label: 'From:', value: fromLabel),
                const SizedBox(height: 2),
                _FromToRow(label: 'To:', value: toLabel),
                const SizedBox(height: AppSpacing.s),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '$dateLabel   $timeLabel',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontSize: 10.5,
                        color: theme.colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FromToRow extends StatelessWidget {
  final String label;
  final String value;

  const _FromToRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 38,
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: theme.colorScheme.outline,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 11,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Occupancy buckets the dormitory list can be filtered down to.
enum DormFilter { all, available, nearlyFull, full, unassignedLeadership }

extension DormFilterLabel on DormFilter {
  String get label => switch (this) {
    DormFilter.all => 'All dormitories',
    DormFilter.available => 'Has free beds',
    DormFilter.nearlyFull => 'Nearly full (85%+)',
    DormFilter.full => 'Full',
    DormFilter.unassignedLeadership => 'Leadership not assigned',
  };

  IconData get icon => switch (this) {
    DormFilter.all => Icons.apps_outlined,
    DormFilter.available => Icons.event_available_outlined,
    DormFilter.nearlyFull => Icons.trending_up,
    DormFilter.full => Icons.block_outlined,
    DormFilter.unassignedLeadership => Icons.person_off_outlined,
  };
}

/// Bottom sheet for choosing which dormitories the list shows.
class DormFilterSheet extends StatelessWidget {
  final DormFilter selected;

  const DormFilterSheet({super.key, required this.selected});

  static Future<DormFilter?> show(BuildContext context, DormFilter selected) {
    return showModalBottomSheet<DormFilter>(
      context: context,
      builder: (_) => DormFilterSheet(selected: selected),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.xl,
              AppSpacing.m,
            ),
            child: Text(
              'Filter Dormitories',
              style: theme.textTheme.titleMedium?.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          for (final filter in DormFilter.values)
            ListTile(
              leading: Icon(
                filter.icon,
                color: filter == selected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              title: Text(
                filter.label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: filter == selected
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: filter == selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                ),
              ),
              trailing: filter == selected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () => Navigator.pop(context, filter),
            ),
          const SizedBox(height: AppSpacing.m),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';

/// A single navigation row on the Academics landing screen - leading
/// colored icon tile, title/subtitle, trailing chevron. Matches the
/// reference UI's Levels/Years & Terms/... card list.
class AcademicsNavCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const AcademicsNavCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: Colors.grey[500]),
        ],
      ),
    );
  }
}

/// A record row for Academics list screens (Levels, Subjects, Departments,
/// ...) - leading icon tile, title, subtitle, an optional trailing count
/// pill, and a chevron to drill in. Distinct from [StructureListRow] (which
/// exposes inline edit/delete icon buttons) - list screens navigate to a
/// dedicated tap target instead per the reference UI.
class AcademicsListCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String? trailingLabel;
  final bool isActive;
  final VoidCallback onTap;

  const AcademicsListCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    this.trailingLabel,
    this.isActive = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    decoration: isActive ? null : TextDecoration.lineThrough,
                    color: isActive ? null : Colors.grey,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          if (trailingLabel != null) ...[
            Text(
              trailingLabel!,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            const SizedBox(width: 6),
          ],
          Icon(Icons.chevron_right, color: Colors.grey[500]),
        ],
      ),
    );
  }
}

/// Two-way segmented control used by Years & Terms and Classes & Streams
/// ("Years | Terms/Semesters", "Classes | Streams").
class AcademicsSegmentedTabs extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const AcademicsSegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(labels.length, (index) {
          final selected = index == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: selected ? scheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  labels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: selected ? scheme.onPrimary : scheme.onSurface,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

/// A rounded "Current"/"Completed"-style status chip for years/terms.
class AcademicsStatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const AcademicsStatusChip({
    super.key,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// One stat tile in the "Overview" grid at the top of a list screen (Total
/// Classes / Active Classes / Total Students / Avg Class Size, and their
/// Streams equivalents). Purely a display widget - the caller computes the
/// value from real state, never a placeholder number.
class AcademicsStatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const AcademicsStatTile({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: valueColor ?? scheme.onSurface,
          ),
        ),
      ],
    );
  }
}

/// The "Overview" card - a titled container with a 2x2 grid of
/// [AcademicsStatTile]s, matching the reference UI's summary section on the
/// Classes and Streams tabs.
class AcademicsOverviewCard extends StatelessWidget {
  final List<AcademicsStatTile> tiles;

  const AcademicsOverviewCard({super.key, required this.tiles});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      showShadow: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Overview',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: tiles[0]),
              Expanded(child: tiles[1]),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: tiles[2]),
              Expanded(child: tiles[3]),
            ],
          ),
        ],
      ),
    );
  }
}

/// A two-segment Active/Inactive status selector for Add/Edit forms -
/// visually distinct from [AcademicsSegmentedTabs] (which switches list
/// content) even though the shape is similar, since this one holds form
/// state rather than navigation state.
class AcademicsStatusToggle extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onChanged;

  const AcademicsStatusToggle({
    super.key,
    required this.isActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget segment(String label, bool active, VoidCallback onTap) {
      final selected = isActive == active;
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primaryContainer
                  : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? scheme.primary : Colors.transparent,
              ),
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: selected ? scheme.primary : scheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        segment('Active', true, () => onChanged(true)),
        const SizedBox(width: 10),
        segment('Inactive', false, () => onChanged(false)),
      ],
    );
  }
}

/// Standard screen scaffold for every Academics subsection: AppBar with
/// back chevron, breadcrumb-style subtitle, search field, scrollable list
/// body (with an empty-state slot) and an FAB.
class AcademicsListScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final Widget body;
  final String fabLabel;
  final VoidCallback onFabPressed;
  final List<Widget>? headerExtra;

  const AcademicsListScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.searchHint,
    this.onSearchChanged,
    required this.body,
    required this.fabLabel,
    required this.onFabPressed,
    this.headerExtra,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(title: title),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                ],
                AppSearchField(
                  hintText: searchHint,
                  onChanged: onSearchChanged,
                ),
                if (headerExtra != null) ...[
                  const SizedBox(height: 12),
                  ...headerExtra!,
                ],
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onFabPressed,
        icon: const Icon(Icons.add),
        label: Text(fabLabel),
      ),
    );
  }
}

/// Standard full-screen form scaffold ("Add Educational Level" style):
/// AppBar with back chevron, scrollable field column, full-width primary
/// save button pinned at the bottom.
class AcademicsFormScaffold extends StatelessWidget {
  final String title;
  final String? subtitle;
  final List<Widget> fields;
  final String saveLabel;
  final VoidCallback onSave;
  final bool isSaving;

  const AcademicsFormScaffold({
    super.key,
    required this.title,
    this.subtitle,
    required this.fields,
    required this.saveLabel,
    required this.onSave,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AdminAppBar(title: title),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                children: [
                  if (subtitle != null) ...[
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 20),
                  ],
                  for (final field in fields) ...[
                    field,
                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: isSaving ? null : onSave,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          saveLabel,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

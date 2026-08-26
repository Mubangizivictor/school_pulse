import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

/// A compact icon-tile used on the Structure hub - mirrors Admin
/// dashboard's `_AdminShortcut` tile so the module fits the app's existing
/// visual language instead of introducing its own.
class StructureHubTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const StructureHubTile({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      showShadow: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outlineVariant),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: scheme.onSurface, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A single record row used throughout Structure's list tabs - a leading
/// colored icon, title/subtitle, and edit/delete actions, replacing plain
/// ListTiles so every entity type reads consistently.
class StructureListRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool isActive;
  final Widget? badge;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const StructureListRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.isActive = true,
    this.badge,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      showShadow: false,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              border: Border.all(color: scheme.outlineVariant),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(icon, color: scheme.onSurface, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          decoration: isActive
                              ? null
                              : TextDecoration.lineThrough,
                          color: isActive ? scheme.onSurface : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (badge != null) ...[const SizedBox(width: 8), badge!],
                  ],
                ),
                if (subtitle != null && subtitle!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      subtitle!,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(Icons.edit_outlined, size: 20, color: scheme.onSurface),
            onPressed: onEdit,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            icon: Icon(
              Icons.delete_outline,
              size: 20,
              color: scheme.onSurface,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

/// A standard status badge used in list rows (e.g., "Active", "Inactive").
class StructureStatusBadge extends StatelessWidget {
  final String label;
  final bool isActive;

  const StructureStatusBadge({
    super.key,
    required this.label,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = isActive ? scheme.onSurface : scheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: foreground),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: foreground,
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// A search bar styled for the Structure module sub-screens.
class StructureSearchBar extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;

  const StructureSearchBar({super.key, required this.hint, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outline),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          Icon(Icons.search, color: colors.onSurfaceVariant, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: colors.onSurfaceVariant,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Icon(Icons.tune, color: colors.onSurfaceVariant, size: 20),
        ],
      ),
    );
  }
}

/// Horizontal filter chips for categorizing lists (e.g. "All", "Primary", "Secondary").
class StructureFilterChips extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const StructureFilterChips({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == selectedFilter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => onSelected(filter),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// A mobile-first subsection navigator for configuration areas. It avoids the
/// cramped, decorative tab strips that made Structure screens hard to scan.
/// Each item is a real selection and the sheet keeps long option names
/// readable on small devices.
class StructureSectionPicker extends StatelessWidget {
  const StructureSectionPicker({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<String> sections;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = sections[selectedIndex];
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () async {
            final index = await showModalBottomSheet<int>(
              context: context,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (sheetContext) => SafeArea(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.8,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                    children: [
                      Text(
                        'Choose section',
                        style: Theme.of(sheetContext).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      ...List.generate(
                        sections.length,
                        (index) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(sections[index]),
                          trailing: index == selectedIndex
                              ? const Icon(Icons.check_circle)
                              : null,
                          onTap: () => Navigator.pop(sheetContext, index),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (index != null) onSelected(index);
          },
          child: Ink(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: colors.outline),
              color: Theme.of(context).cardColor,
            ),
            child: Row(
              children: [
                const Icon(Icons.tune_rounded, size: 19),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selected,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A section header above each record group within a tab (e.g. "Houses" /
/// "Add House") - thin wrapper around the app's shared `SectionHeader` so
/// Structure's grouped lists use the same title+action pattern as the rest
/// of the app, with a compact icon button instead of a bare text link.
class StructureSectionHeader extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  const StructureSectionHeader({
    super.key,
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SectionHeader(
        title: title,
        trailing: OutlinedButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.add, size: 18),
          label: Text(actionLabel),
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            foregroundColor: scheme.primary,
            side: BorderSide(color: scheme.primary),
          ),
        ),
      ),
    );
  }
}

/// The bottom-sheet shell every Structure add/edit form is presented in -
/// a drag handle, title, scrollable field area, and a sticky action bar.
/// Replaces the old centered AlertDialog so forms feel roomier on mobile.
Future<void> showStructureFormSheet(
  BuildContext context, {
  required String title,
  required Widget Function(BuildContext context, StateSetter setState)
  fieldsBuilder,
  required String submitLabel,
  required VoidCallback onSubmit,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.92,
          expand: false,
          builder: (context, scrollController) => StatefulBuilder(
            builder: (context, setState) {
              return Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          fieldsBuilder(context, setState),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        12 + MediaQuery.paddingOf(context).bottom,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(sheetContext),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: onSubmit,
                              child: Text(submitLabel),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    },
  );
}

/// A consistently-spaced field column for use inside form-sheet children,
/// so multi-field dialogs don't need repeated SizedBox spacers.
class StructureFieldGroup extends StatelessWidget {
  final List<Widget> children;
  const StructureFieldGroup({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    final spaced = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) spaced.add(const SizedBox(height: 14));
      spaced.add(children[i]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: spaced,
    );
  }
}

/// The reference-design record card: a colored icon box, title, code/count
/// subtitle, optional status badge, and a chevron leading to a details page.
/// Replaces [StructureListRow]'s inline edit/delete affordances for entity
/// types that now have a dedicated details screen.
class StructureRecordCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? subtitle;
  final bool isActive;
  final VoidCallback onTap;

  const StructureRecordCard({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    this.subtitle,
    this.isActive = true,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outline),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(icon, color: color, size: 19),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: isActive
                              ? null
                              : TextDecoration.lineThrough,
                        ),
                      ),
                      if (subtitle != null && subtitle!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isActive) ...[
                  const StructureStatusBadge(
                    label: 'Inactive',
                    isActive: false,
                  ),
                  const SizedBox(width: 6),
                ],
                Icon(Icons.chevron_right_rounded, color: colors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A searchable staff-selection field for the Structure module (Head of
/// Department, House Master/Mistress, Club Patron, Hostel Warden, ...).
/// Thin wrapper over the app's generic [showSearchablePicker] so every
/// "assign a staff member" field in Structure looks and behaves the same.
class StructureStaffPickerField extends StatelessWidget {
  final String label;
  final String? selectedStaffId;
  final List<UserEntity> staff;
  final ValueChanged<String?> onChanged;
  final bool required;

  const StructureStaffPickerField({
    super.key,
    required this.label,
    required this.selectedStaffId,
    required this.staff,
    required this.onChanged,
    this.required = false,
  });

  UserEntity? get _selected {
    if (selectedStaffId == null || selectedStaffId!.isEmpty) return null;
    for (final member in staff) {
      if (member.id == selectedStaffId) return member;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final selected = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelSmall,
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: colors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: () async {
            final picked = await showSearchablePicker<UserEntity>(
              context: context,
              title: label,
              items: staff,
              labelBuilder: (s) => s.name,
              subtitleBuilder: (s) =>
                  s.designationId?.isNotEmpty == true ? s.designationId : null,
              searchHint: 'Search staff by name...',
            );
            if (picked != null) onChanged(picked.id);
          },
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected?.name ?? 'Select staff member',
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: selected == null ? colors.onSurfaceVariant : null,
                    ),
                  ),
                ),
                if (selected != null)
                  InkWell(
                    onTap: () => onChanged(null),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  )
                else
                  const Icon(Icons.keyboard_arrow_down_rounded),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// True if [code] already belongs to a different record in [items] within
/// the same school - used by Department/Campus/House/Club/Facility forms so
/// every coded Structure entity rejects duplicate codes consistently.
bool structureDuplicateCode<T>({
  required List<T> items,
  required String Function(T item) codeOf,
  required String Function(T item) idOf,
  required String code,
  String? excludeId,
}) {
  final normalized = code.trim().toLowerCase();
  if (normalized.isEmpty) return false;
  return items.any(
    (item) =>
        idOf(item) != excludeId &&
        codeOf(item).trim().toLowerCase() == normalized,
  );
}

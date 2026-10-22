import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../../cubit/parents_access_state.dart';
import '../filter_bottom_sheet.dart';

/// Desktop toolbar: search field, "Filters" button with a count badge that
/// opens the same filter choices as a popup menu, and the black "+ Add /
/// link parent" button - matches the reference screenshot's single-row
/// toolbar rather than inline chips.
class ParentAccessToolbar extends StatelessWidget {
  final ParentsAccessFilter selectedFilter;
  final ValueChanged<ParentsAccessFilter> onFilterChanged;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onAddParent;

  const ParentAccessToolbar({
    super.key,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onSearchChanged,
    required this.onAddParent,
  });

  @override
  Widget build(BuildContext context) {
    final activeFilterCount = selectedFilter == ParentsAccessFilter.all ? 0 : 1;

    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search parents',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceContainer(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        PopupMenuButton<ParentsAccessFilter>(
          onSelected: onFilterChanged,
          itemBuilder: (context) => kParentAccessFilterLabels.entries
              .map((e) => PopupMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.filter_list, size: 18, color: AppColors.textPrimary(context)),
                const SizedBox(width: 6),
                Text('Filters', style: TextStyle(color: AppColors.textPrimary(context))),
                if (activeFilterCount > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.primary(context),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$activeFilterCount',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.background(context),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: onAddParent,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary(context),
            foregroundColor: AppColors.background(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add / link parent'),
        ),
      ],
    );
  }
}

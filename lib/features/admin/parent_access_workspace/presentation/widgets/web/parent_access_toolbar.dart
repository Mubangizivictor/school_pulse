import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../../cubit/parents_access_state.dart';
import '../filter_bottom_sheet.dart';

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
    return Row(
      children: [
        Expanded(
          flex: 2,
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
        ParentAccessFilterChips(
          selected: selectedFilter,
          onChanged: onFilterChanged,
        ),
        const Spacer(),
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

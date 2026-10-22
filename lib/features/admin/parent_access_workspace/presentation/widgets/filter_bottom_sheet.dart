import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../cubit/parents_access_state.dart';

const Map<ParentsAccessFilter, String> kParentAccessFilterLabels = {
  ParentsAccessFilter.all: 'All',
  ParentsAccessFilter.linked: 'Linked',
  ParentsAccessFilter.pending: 'Pending',
  ParentsAccessFilter.expiring: 'Expiring',
};

/// Filter chip row (used inline on tablet/web) and the phone bottom sheet
/// that wraps the same choices for a compact screen.
class ParentAccessFilterChips extends StatelessWidget {
  final ParentsAccessFilter selected;
  final ValueChanged<ParentsAccessFilter> onChanged;

  const ParentAccessFilterChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: kParentAccessFilterLabels.entries.map((entry) {
        final isSelected = entry.key == selected;
        final dotColor = _dotColorFor(context, entry.key);
        return ChoiceChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (dotColor != null) ...[
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
              ],
              Text(entry.value),
            ],
          ),
          selected: isSelected,
          onSelected: (_) => onChanged(entry.key),
          selectedColor: AppColors.primary(context),
          labelStyle: TextStyle(
            color: isSelected
                ? AppColors.background(context)
                : AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
          backgroundColor: AppColors.surfaceContainer(context),
          side: BorderSide(color: AppColors.border(context)),
        );
      }).toList(),
    );
  }

  Color? _dotColorFor(BuildContext context, ParentsAccessFilter filter) {
    switch (filter) {
      case ParentsAccessFilter.all:
        return null;
      case ParentsAccessFilter.linked:
        return AppColors.success(context);
      case ParentsAccessFilter.pending:
      case ParentsAccessFilter.expiring:
        return AppColors.warning(context);
    }
  }
}

Future<ParentsAccessFilter?> showParentAccessFilterSheet(
  BuildContext context, {
  required ParentsAccessFilter current,
}) {
  return showModalBottomSheet<ParentsAccessFilter>(
    context: context,
    backgroundColor: AppColors.background(context),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(sheetContext),
                ),
              ),
              const SizedBox(height: 16),
              ...kParentAccessFilterLabels.entries.map((entry) {
                return RadioListTile<ParentsAccessFilter>(
                  value: entry.key,
                  groupValue: current,
                  title: Text(entry.value),
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    Navigator.of(sheetContext).pop(value);
                  },
                );
              }),
            ],
          ),
        ),
      );
    },
  );
}

import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

class AppFilterOption<T> {
  final T value;
  final String label;
  final int? count;

  const AppFilterOption({required this.value, required this.label, this.count});
}

/// Single-select row of filter chips (e.g. All / Pending / Paid / Failed),
/// optionally preceded by a search field.
///
/// Chips scroll horizontally, so the bar never overflows on narrow phones.
/// Pass [onSearchChanged] to show the search field; on tablet/desktop widths
/// it sits beside the chips, on mobile above them.
class AppFilterBar<T> extends StatelessWidget {
  final List<AppFilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onSelected;
  final ValueChanged<String>? onSearchChanged;
  final String searchHint;
  final Widget? trailing;

  const AppFilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
    this.onSearchChanged,
    this.searchHint = 'Search',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final chips = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.s),
              child: ChoiceChip(
                label: Text(
                  option.count == null
                      ? option.label
                      : '${option.label} (${option.count})',
                ),
                selected: option.value == selected,
                onSelected: (_) => onSelected(option.value),
              ),
            ),
        ],
      ),
    );

    final search = onSearchChanged == null
        ? null
        : TextField(
            onChanged: onSearchChanged,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: searchHint,
              prefixIcon: const Icon(Icons.search_rounded),
              isDense: true,
            ),
          );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 720;
        if (search == null) {
          return Row(
            children: [
              Expanded(child: chips),
              ?trailing,
            ],
          );
        }
        if (wide) {
          return Row(
            children: [
              SizedBox(width: 280, child: search),
              const SizedBox(width: AppSpacing.l),
              Expanded(child: chips),
              ?trailing,
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(child: search),
                ?trailing,
              ],
            ),
            const SizedBox(height: AppSpacing.s),
            chips,
          ],
        );
      },
    );
  }
}

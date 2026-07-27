import 'package:flutter/material.dart';

/// Opens a modal bottom sheet with a search box over [items], for pickers
/// where a plain dropdown doesn't scale (a school can have thousands of
/// students/staff). Returns the selected item, or null if dismissed.
Future<T?> showSearchablePicker<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T item) labelBuilder,
  String? Function(T item)? subtitleBuilder,
  String searchHint = 'Search by name...',
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _SearchablePickerSheet<T>(
      title: title,
      items: items,
      labelBuilder: labelBuilder,
      subtitleBuilder: subtitleBuilder,
      searchHint: searchHint,
    ),
  );
}

class _SearchablePickerSheet<T> extends StatefulWidget {
  final String title;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final String? Function(T item)? subtitleBuilder;
  final String searchHint;

  const _SearchablePickerSheet({
    required this.title,
    required this.items,
    required this.labelBuilder,
    required this.subtitleBuilder,
    required this.searchHint,
  });

  @override
  State<_SearchablePickerSheet<T>> createState() => _SearchablePickerSheetState<T>();
}

class _SearchablePickerSheetState<T> extends State<_SearchablePickerSheet<T>> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _query.isEmpty
        ? widget.items
        : widget.items
            .where((item) => widget.labelBuilder(item).toLowerCase().contains(_query.toLowerCase()))
            .toList();

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: widget.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        'No matches for "$_query"',
                        style: TextStyle(color: Theme.of(context).colorScheme.outline),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final item = filtered[index];
                        final subtitle = widget.subtitleBuilder?.call(item);
                        return ListTile(
                          title: Text(widget.labelBuilder(item)),
                          subtitle: subtitle != null ? Text(subtitle) : null,
                          onTap: () => Navigator.pop(context, item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A form-field-styled tappable box that opens [showSearchablePicker] - a
/// drop-in replacement for DropdownButtonFormField when the option list can
/// grow large (students, staff).
class SearchablePickerField<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) labelBuilder;
  final String? Function(T item)? subtitleBuilder;
  final ValueChanged<T> onChanged;
  final String searchHint;

  const SearchablePickerField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
    this.subtitleBuilder,
    this.searchHint = 'Search by name...',
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(4),
      onTap: () async {
        final selected = await showSearchablePicker<T>(
          context: context,
          title: label,
          items: items,
          labelBuilder: labelBuilder,
          subtitleBuilder: subtitleBuilder,
          searchHint: searchHint,
        );
        if (selected != null) onChanged(selected);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          suffixIcon: const Icon(Icons.arrow_drop_down),
        ),
        child: Text(
          value != null ? labelBuilder(value as T) : 'Select...',
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

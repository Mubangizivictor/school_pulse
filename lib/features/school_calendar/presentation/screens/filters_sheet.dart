import 'package:flutter/material.dart';
import 'package:school_pulse/features/notifications/domain/services/notification_sender.dart';
import '../../domain/entities/calendar_event_type.dart';
import '../widgets/calendar_format.dart';

/// Filter state shared by Calendar View and List View, lifted above both so
/// it persists as the user navigates between them until explicitly reset.
class CalendarFilters {
  final String search;
  final Set<CalendarEventType> types;
  final NotificationAudienceKind? audience;
  final DateTime? from;
  final DateTime? to;
  const CalendarFilters({
    this.search = '',
    this.types = const {},
    this.audience,
    this.from,
    this.to,
  });

  bool get isEmpty =>
      search.isEmpty &&
      types.isEmpty &&
      audience == null &&
      from == null &&
      to == null;

  CalendarFilters copyWith({
    String? search,
    Set<CalendarEventType>? types,
    NotificationAudienceKind? audience,
    bool clearAudience = false,
    DateTime? from,
    bool clearFrom = false,
    DateTime? to,
    bool clearTo = false,
  }) => CalendarFilters(
    search: search ?? this.search,
    types: types ?? this.types,
    audience: clearAudience ? null : (audience ?? this.audience),
    from: clearFrom ? null : (from ?? this.from),
    to: clearTo ? null : (to ?? this.to),
  );
}

const _audienceFilterOptions = <NotificationAudienceKind, String>{
  NotificationAudienceKind.school: 'All School',
  NotificationAudienceKind.allStaff: 'Staff',
  NotificationAudienceKind.allParents: 'Parents',
  NotificationAudienceKind.studentParents: 'Students',
};

/// "Filters & Search" bottom sheet matching the reference mockup: search,
/// type checkboxes for all 9 types, audience dropdown, date range,
/// Reset/Apply.
class FilterSheet extends StatefulWidget {
  final CalendarFilters initial;
  const FilterSheet({super.key, required this.initial});
  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late String search = widget.initial.search;
  late Set<CalendarEventType> types = {...widget.initial.types};
  late NotificationAudienceKind? audience = widget.initial.audience;
  late DateTime? from = widget.initial.from;
  late DateTime? to = widget.initial.to;

  Future<void> pick(bool start) async {
    final value = await showDatePicker(
      context: context,
      initialDate: start ? from ?? DateTime.now() : to ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (value != null) {
      setState(() {
        if (start) {
          from = value;
        } else {
          to = value;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: 2),
                const Expanded(
                  child: Text(
                    'Filters & Search',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    search = '';
                    types.clear();
                    audience = null;
                    from = null;
                    to = null;
                  }),
                  child: const Text('Reset'),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: TextEditingController(text: search)
                ..selection = TextSelection.collapsed(offset: search.length),
              onChanged: (v) => search = v,
              decoration: const InputDecoration(
                labelText: 'Search Events',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 18),
            const Text('Filter By Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CalendarEventType.values
                  .map(
                    (type) => FilterChip(
                      label: Text(type.label),
                      selected: types.contains(type),
                      onSelected: (selected) => setState(
                        () => selected ? types.add(type) : types.remove(type),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<NotificationAudienceKind>(
              initialValue: audience,
              decoration: const InputDecoration(
                labelText: 'Filter By Audience',
                border: OutlineInputBorder(),
              ),
              items: _audienceFilterOptions.entries
                  .map(
                    (e) => DropdownMenuItem(value: e.key, child: Text(e.value)),
                  )
                  .toList(),
              onChanged: (v) => setState(() => audience = v),
            ),
            const SizedBox(height: 18),
            const Text('Filter By Date'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => pick(true),
                    child: Text(from == null ? 'From' : formatDate(from!)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => pick(false),
                    child: Text(to == null ? 'To' : formatDate(to!)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(
                  context,
                  CalendarFilters(
                    search: search,
                    types: types,
                    audience: audience,
                    from: from,
                    to: to,
                  ),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

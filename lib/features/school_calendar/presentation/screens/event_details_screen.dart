import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../domain/entities/calendar_event.dart';
import '../../domain/entities/calendar_event_type.dart';
import '../../domain/entities/recurrence_rule.dart';
import '../widgets/calendar_format.dart';
import '../widgets/event_type_colors.dart';

const _weekdayShort = {
  Weekday.monday: 'Mon',
  Weekday.tuesday: 'Tue',
  Weekday.wednesday: 'Wed',
  Weekday.thursday: 'Thu',
  Weekday.friday: 'Fri',
  Weekday.saturday: 'Sat',
  Weekday.sunday: 'Sun',
};

/// Event Details screen matching the reference mockup: type indicator,
/// title, date/time, location, organizer, audience, description,
/// attachments, reminder, recurrence — sections are omitted when empty so
/// nothing shows a blank value.
class EventDetailsScreen extends StatelessWidget {
  final CalendarEvent event;
  final bool canManage;
  final VoidCallback onEdit;

  /// Called with the chosen scope once the user confirms deletion. For a
  /// non-recurring event the scope is always [RecurrenceEditScope.allOccurrences].
  final ValueChanged<RecurrenceEditScope> onDelete;

  const EventDetailsScreen({
    super.key,
    required this.event,
    required this.canManage,
    required this.onEdit,
    required this.onDelete,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    RecurrenceEditScope scope = RecurrenceEditScope.allOccurrences;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Delete event?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"${event.title}" will no longer appear on the school calendar.',
              ),
              if (event.recurrence != null) ...[
                const SizedBox(height: 16),
                RadioGroup<RecurrenceEditScope>(
                  groupValue: scope,
                  onChanged: (v) => setState(() => scope = v!),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      RadioListTile<RecurrenceEditScope>(
                        value: RecurrenceEditScope.thisOccurrence,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text('This event only'),
                      ),
                      RadioListTile<RecurrenceEditScope>(
                        value: RecurrenceEditScope.thisAndFuture,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text('This and following events'),
                      ),
                      RadioListTile<RecurrenceEditScope>(
                        value: RecurrenceEditScope.allOccurrences,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                        title: Text('All events in the series'),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
    if (confirmed == true) onDelete(scope);
  }

  String _recurrenceSummary(RecurrenceRule rule) {
    final freq = switch (rule.frequency) {
      RecurrenceFrequency.daily => 'Daily',
      RecurrenceFrequency.weekly => 'Weekly',
      RecurrenceFrequency.monthly => 'Monthly',
      RecurrenceFrequency.yearly => 'Yearly',
    };
    final parts = <String>[freq];
    if (rule.repeatsOn.isNotEmpty) {
      parts.add('on ${rule.repeatsOn.map((d) => _weekdayShort[d]).join(', ')}');
    }
    switch (rule.endType) {
      case RecurrenceEndType.onDate:
        if (rule.endDate != null) {
          parts.add('until ${formatDate(rule.endDate!)}');
        }
        break;
      case RecurrenceEndType.afterOccurrences:
        if (rule.occurrences != null) {
          parts.add('for ${rule.occurrences} occurrences');
        }
        break;
      case RecurrenceEndType.never:
        break;
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (canManage)
            IconButton(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined),
            ),
          if (canManage)
            IconButton(
              onPressed: () => _confirmDelete(context),
              icon: const Icon(Icons.delete_outline),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: calendarEventTypeColor(event.type),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                event.type.label,
                style: TextStyle(
                  color: calendarEventTypeColor(event.type),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            event.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),
          _DetailRow(
            Icons.calendar_today_outlined,
            formatDate(event.startDate),
          ),
          _DetailRow(Icons.access_time, formatEventTime(event)),
          if (event.location.isNotEmpty)
            _DetailRow(Icons.location_on_outlined, event.location),
          if (event.organizer.isNotEmpty)
            _DetailRow(Icons.person_outline, event.organizer),
          _DetailRow(Icons.group_outlined, event.audience.description),
          if (event.description.isNotEmpty)
            _Section('Description', child: Text(event.description)),
          if (event.attachments.isNotEmpty)
            _Section(
              'Attachments',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: event.attachments
                    .map(
                      (a) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          onTap: a.url.isEmpty
                              ? null
                              : () => launchUrl(
                                  Uri.parse(a.url),
                                  mode: LaunchMode.externalApplication,
                                ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                size: 16,
                                color: AppColors.primary(context),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  a.name,
                                  style: TextStyle(
                                    color: AppColors.primary(context),
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          if (event.reminder != 'None')
            _Section('Reminder', child: Text(event.reminder)),
          if (event.recurrence != null)
            _Section(
              'Repeat',
              child: Text('Repeats ${_recurrenceSummary(event.recurrence!)}'),
            ),
          if (event.notes.isNotEmpty)
            _Section('Notes', child: Text(event.notes)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String value;
  const _DetailRow(this.icon, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted(context)),
        const SizedBox(width: 12),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

class _Section extends StatelessWidget {
  final String label;
  final Widget child;
  const _Section(this.label, {required this.child});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
        ),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

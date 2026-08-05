import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import '../../../domain/entities/calendar_event_type.dart';
import '../../widgets/event_type_colors.dart';

/// Matches mockup screen #4 "Event Type" - a full-height radio list of
/// icon + title + description rows, one per CalendarEventType.
class EventTypePickerScreen extends StatefulWidget {
  final CalendarEventType initial;

  const EventTypePickerScreen({super.key, required this.initial});

  @override
  State<EventTypePickerScreen> createState() => _EventTypePickerScreenState();
}

class _EventTypePickerScreenState extends State<EventTypePickerScreen> {
  late CalendarEventType _selected = widget.initial;

  static const _icons = {
    CalendarEventType.schoolDay: Icons.school,
    CalendarEventType.holiday: Icons.beach_access,
    CalendarEventType.breakDay: Icons.free_breakfast,
    CalendarEventType.examination: Icons.edit_note,
    CalendarEventType.event: Icons.event,
    CalendarEventType.staffTraining: Icons.groups,
    CalendarEventType.meeting: Icons.meeting_room,
    CalendarEventType.sports: Icons.sports_basketball,
    CalendarEventType.other: Icons.more_horiz,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Event Type'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: CalendarEventType.values.length,
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.m),
        itemBuilder: (context, index) {
          final type = CalendarEventType.values[index];
          final selected = type == _selected;
          return InkWell(
            onTap: () => setState(() => _selected = type),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.l),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated(context),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selected
                      ? AppColors.primary(context)
                      : AppColors.border(context),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(_icons[type], color: calendarEventTypeColor(type)),
                  const SizedBox(width: AppSpacing.m),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          type.label,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          type.description,
                          style: TextStyle(
                            color: AppColors.textMuted(context),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Radio<CalendarEventType>(
                    value: type,
                    groupValue: _selected,
                    onChanged: (v) => setState(() => _selected = v!),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(_selected),
            child: const Text('Next'),
          ),
        ),
      ),
    );
  }
}

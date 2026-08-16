import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/timetable_config.dart';
import 'structure_ui_kit.dart';

const List<String> kTimetableSlotTypes = [
  'period',
  'break',
  'tea_break',
  'lunch',
  'prep',
  'study',
  'assembly',
  'games',
  'club',
  'worship',
  'free',
  'custom',
];

int? timetableMinutes(String value) {
  final match = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(value.trim());
  if (match == null) return null;
  final hour = int.parse(match.group(1)!);
  final minute = int.parse(match.group(2)!);
  return hour > 23 || minute > 59 ? null : hour * 60 + minute;
}

String timetableTime(TimeOfDay value) =>
    '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';

Future<void> showTimetableSlotFormDialog(
  BuildContext context, {
  TimetableSlot? existing,
  required List<String> teachingDays,
  required List<TimetableSlot> occupiedSlots,
  required String schoolStartTime,
  required String schoolEndTime,
  required void Function(TimetableSlot) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final notesController = TextEditingController(text: existing?.notes);
  var start = existing?.startTime ?? '';
  var end = existing?.endTime ?? '';
  var type = kTimetableSlotTypes.contains(existing?.type)
      ? existing!.type
      : kTimetableSlotTypes.first;
  var selectedDays = [
    ...(existing?.days.isEmpty ?? true ? teachingDays : existing!.days),
  ];

  Future<void> pickTime(StateSetter setState, bool isStart) async {
    final minutes = timetableMinutes(isStart ? start : end) ?? 8 * 60;
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutes ~/ 60, minute: minutes % 60),
    );
    if (selected != null) {
      setState(() {
        if (isStart) {
          start = timetableTime(selected);
        } else {
          end = timetableTime(selected);
        }
      });
    }
  }

  bool overlaps(TimetableSlot other, int startMinutes, int endMinutes) {
    if (other.id == existing?.id && other.id.isNotEmpty) return false;
    final otherStart = timetableMinutes(other.startTime);
    final otherEnd = timetableMinutes(other.endTime);
    if (otherStart == null || otherEnd == null) return false;
    final sameDay = selectedDays.any(
      (day) => other.days.isEmpty || other.days.contains(day),
    );
    return sameDay && startMinutes < otherEnd && endMinutes > otherStart;
  }

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Timetable Slot' : 'Edit Timetable Slot',
    submitLabel: existing == null ? 'Add Slot' : 'Save Slot',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Slot Name *'),
            validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Type *'),
            items: kTimetableSlotTypes
                .map(
                  (value) => DropdownMenuItem(
                    value: value,
                    child: Text(value.replaceAll('_', ' ')),
                  ),
                )
                .toList(),
            onChanged: (value) => setState(() => type = value ?? type),
          ),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'Start Time *',
                  value: start,
                  onTap: () => pickTime(setState, true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(
                  label: 'End Time *',
                  value: end,
                  onTap: () => pickTime(setState, false),
                ),
              ),
            ],
          ),
          const Text('Applies on *'),
          Wrap(
            spacing: 8,
            children: teachingDays
                .map(
                  (day) => FilterChip(
                    label: Text(day),
                    selected: selectedDays.contains(day),
                    onSelected: (selected) => setState(() {
                      selected
                          ? selectedDays.add(day)
                          : selectedDays.remove(day);
                    }),
                  ),
                )
                .toList(),
          ),
          TextFormField(
            controller: notesController,
            maxLines: 2,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
          ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      final startMinutes = timetableMinutes(start);
      final endMinutes = timetableMinutes(end);
      final dayStart = timetableMinutes(schoolStartTime);
      final dayEnd = timetableMinutes(schoolEndTime);
      String? problem;
      if (selectedDays.isEmpty) {
        problem = 'Select at least one teaching day.';
      } else if (startMinutes == null || endMinutes == null) {
        problem = 'Choose valid start and end times.';
      } else if (endMinutes <= startMinutes) {
        problem = 'End time must be after start time.';
      } else if (dayStart != null &&
          dayEnd != null &&
          (startMinutes < dayStart || endMinutes > dayEnd)) {
        problem = 'This slot must be within the configured school day.';
      } else if (occupiedSlots.any(
        (slot) => overlaps(slot, startMinutes, endMinutes),
      )) {
        problem =
            'This slot overlaps an existing slot on one or more selected days.';
      }
      if (problem != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(problem)));
        return;
      }
      onSave(
        TimetableSlot(
          id: existing?.id ?? const Uuid().v4(),
          name: nameController.text.trim(),
          startTime: start,
          endTime: end,
          type: type,
          displayOrder: existing?.displayOrder ?? occupiedSlots.length,
          isActive: existing?.isActive ?? true,
          days: selectedDays,
          notes: notesController.text.trim(),
        ),
      );
      Navigator.pop(context);
    },
  );
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onTap,
  });
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.schedule_outlined),
      ),
      child: Text(value.isEmpty ? 'Select time' : value),
    ),
  );
}

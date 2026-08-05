import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import '../../domain/entities/timetable_config.dart';
import 'structure_ui_kit.dart';

const List<String> kTimetableSlotTypes = [
  'period',
  'break',
  'lunch',
  'assembly',
];

Future<void> showTimetableSlotFormDialog(
  BuildContext context, {
  TimetableSlot? existing,
  required void Function(TimetableSlot) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final startController = TextEditingController(text: existing?.startTime);
  final endController = TextEditingController(text: existing?.endTime);
  String type = kTimetableSlotTypes.contains(existing?.type)
      ? existing!.type
      : kTimetableSlotTypes.first;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Timetable Slot' : 'Edit Timetable Slot',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          PulseTextField(
            label: 'Slot Name',
            hint: 'e.g. Period 1, Morning Break, Lunch',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: kTimetableSlotTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => type = v ?? type),
          ),
          Row(
            children: [
              Expanded(
                child: PulseTextField(
                  label: 'Start Time',
                  hint: 'HH:MM',
                  controller: startController,
                  isRequired: true,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: PulseTextField(
                  label: 'End Time',
                  hint: 'HH:MM',
                  controller: endController,
                  isRequired: true,
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      onSave(
        TimetableSlot(
          name: nameController.text,
          startTime: startController.text,
          endTime: endController.text,
          type: type,
        ),
      );
      Navigator.pop(context);
    },
  );
}

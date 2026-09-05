import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import '../../domain/entities/attendance_config_entities.dart';
import 'structure_ui_kit.dart';

const List<Color> kAttendanceColorSwatches = [
  Color(0xFF43A047),
  Color(0xFFE53935),
  Color(0xFFFB8C00),
  Color(0xFF1E88E5),
  Color(0xFF8E24AA),
  Color(0xFF00897B),
  Color(0xFF757575),
];

String _colorToHex(Color c) =>
    '#${c.toARGB32().toRadixString(16).substring(2)}';

Future<void> showAttendanceTypeFormDialog(
  BuildContext context, {
  AttendanceTypeDef? existing,
  required String schoolId,
  required void Function(AttendanceTypeDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  Color selectedColor = kAttendanceColorSwatches.first;
  if (existing != null && existing.colorHex.isNotEmpty) {
    try {
      selectedColor = Color(
        int.parse(existing.colorHex.replaceFirst('#', '0xff')),
      );
    } catch (_) {}
  }
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Attendance Type' : 'Edit Attendance Type',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          PulseTextField(
            label: 'Type Name',
            hint: 'e.g. Present, Absent, Late, Excused',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: kAttendanceColorSwatches.map((c) {
              final selected = c.toARGB32() == selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => selectedColor = c),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: selected
                        ? Border.all(color: Colors.white, width: 2)
                        : null,
                  ),
                ),
              );
            }).toList(),
          ),
          if (existing != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      onSave(
        AttendanceTypeDef(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          name: nameController.text,
          colorHex: _colorToHex(selectedColor),
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

Future<void> showAttendanceSessionFormDialog(
  BuildContext context, {
  AttendanceSessionDef? existing,
  required String schoolId,
  required void Function(AttendanceSessionDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null
        ? 'Add Attendance Session'
        : 'Edit Attendance Session',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          PulseTextField(
            label: 'Session Name',
            hint: 'e.g. Morning, Afternoon, Lesson, Gate',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          if (existing != null)
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Active'),
              value: isActive,
              onChanged: (v) => setState(() => isActive = v),
            ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      onSave(
        AttendanceSessionDef(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          name: nameController.text,
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

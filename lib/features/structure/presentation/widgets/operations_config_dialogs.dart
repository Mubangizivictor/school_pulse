import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/attendance_config_entities.dart';
import '../../domain/entities/communication_config_entities.dart';
import '../../domain/entities/document_template_entities.dart';
import '../../domain/entities/custom_field_entities.dart';
import '../../domain/entities/timetable_config.dart';
import 'structure_dialogs.dart' show kSubjectColorSwatches;
import 'structure_ui_kit.dart';

String _colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2)}';

const List<String> kMessageChannels = ['sms', 'email', 'push', 'message'];
const List<String> kCustomFieldAppliesTo = ['Student', 'Staff'];
const List<String> kCustomFieldTypes = [
  'text',
  'number',
  'date',
  'dropdown',
  'boolean',
];
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
  String selectedType = kTimetableSlotTypes.contains(existing?.type)
      ? existing!.type
      : kTimetableSlotTypes.first;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Slot' : 'Edit Slot',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Slot Name (e.g. Period 1, Lunch)',
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: kTimetableSlotTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => selectedType = v ?? selectedType),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: startController,
                  decoration: const InputDecoration(
                    labelText: 'Start (e.g. 08:00)',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: endController,
                  decoration: const InputDecoration(
                    labelText: 'End (e.g. 08:40)',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      final slot = TimetableSlot(
        name: nameController.text,
        startTime: startController.text,
        endTime: endController.text,
        type: selectedType,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(slot);
    },
  );
}

Future<void> showAttendanceTypeFormDialog(
  BuildContext context, {
  AttendanceTypeDef? existing,
  required String schoolId,
  required void Function(AttendanceTypeDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  Color selectedColor = existing?.colorHex.isNotEmpty == true
      ? Color(int.parse(existing!.colorHex.replaceFirst('#', '0xff')))
      : kSubjectColorSwatches.first;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Attendance Type' : 'Edit Attendance Type',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Type Name (e.g. Present, Late, Excused)',
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          Wrap(
            spacing: 8,
            children: kSubjectColorSwatches.map((c) {
              final selected = c.toARGB32() == selectedColor.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => selectedColor = c),
                child: CircleAvatar(
                  backgroundColor: c,
                  radius: 14,
                  child: selected
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : null,
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
      final type = AttendanceTypeDef(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        colorHex: _colorToHex(selectedColor),
        isActive: isActive,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(type);
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
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Session Name (e.g. Morning, Gate, Transport)',
            ),
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
      final session = AttendanceSessionDef(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        isActive: isActive,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(session);
    },
  );
}

Future<void> showAnnouncementCategoryFormDialog(
  BuildContext context, {
  AnnouncementCategoryDef? existing,
  required String schoolId,
  required void Function(AnnouncementCategoryDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null
        ? 'Add Announcement Category'
        : 'Edit Announcement Category',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
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
      final category = AnnouncementCategoryDef(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        isActive: isActive,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(category);
    },
  );
}

Future<void> showNotificationCategoryFormDialog(
  BuildContext context, {
  NotificationCategoryDef? existing,
  required String schoolId,
  required void Function(NotificationCategoryDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null
        ? 'Add Notification Category'
        : 'Edit Notification Category',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Category Name'),
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
      final category = NotificationCategoryDef(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        isActive: isActive,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(category);
    },
  );
}

Future<void> showMessageTemplateFormDialog(
  BuildContext context, {
  MessageTemplateDef? existing,
  required String schoolId,
  required void Function(MessageTemplateDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final subjectController = TextEditingController(text: existing?.subject);
  final bodyController = TextEditingController(text: existing?.body);
  String selectedChannel = kMessageChannels.contains(existing?.channel)
      ? existing!.channel
      : kMessageChannels.first;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Message Template' : 'Edit Message Template',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Template Name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedChannel,
            decoration: const InputDecoration(labelText: 'Channel'),
            items: kMessageChannels
                .map(
                  (c) =>
                      DropdownMenuItem(value: c, child: Text(c.toUpperCase())),
                )
                .toList(),
            onChanged: (v) =>
                setState(() => selectedChannel = v ?? selectedChannel),
          ),
          if (selectedChannel == 'email')
            TextFormField(
              controller: subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject (optional)',
              ),
            ),
          TextFormField(
            controller: bodyController,
            decoration: const InputDecoration(labelText: 'Message Body'),
            maxLines: 4,
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
      final template = MessageTemplateDef(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        channel: selectedChannel,
        subject: subjectController.text,
        body: bodyController.text,
        isActive: isActive,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(template);
    },
  );
}

Future<void> showDocumentTemplateFormDialog(
  BuildContext context, {
  DocumentTemplateDef? existing,
  required String schoolId,
  required void Function(DocumentTemplateDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final typeController = TextEditingController(text: existing?.templateType);
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null
        ? 'Add Document Template'
        : 'Edit Document Template',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Template Name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: typeController,
            decoration: const InputDecoration(
              labelText: 'Document Type (e.g. Student ID Card, Gate Pass)',
            ),
          ),
          TextFormField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
            ),
            maxLines: 2,
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
      final template = DocumentTemplateDef(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: existing?.schoolId ?? schoolId,
        name: nameController.text,
        templateType: typeController.text,
        description: descController.text,
        isActive: isActive,
      );
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(context);
      onSave(template);
    },
  );
}

Future<void> showCustomFieldFormDialog(
  BuildContext context, {
  CustomFieldDef? existing,
  required String schoolId,
  required void Function(CustomFieldDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final fieldNameController = TextEditingController(text: existing?.fieldName);
  final optionsController = TextEditingController(
    text: existing?.options.join(', '),
  );
  String selectedAppliesTo = kCustomFieldAppliesTo.contains(existing?.appliesTo)
      ? existing!.appliesTo
      : kCustomFieldAppliesTo.first;
  String selectedFieldType = kCustomFieldTypes.contains(existing?.fieldType)
      ? existing!.fieldType
      : kCustomFieldTypes.first;
  bool isRequired = existing?.isRequired ?? false;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Custom Field' : 'Edit Custom Field',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedAppliesTo,
            decoration: const InputDecoration(labelText: 'Applies To'),
            items: kCustomFieldAppliesTo
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: (v) =>
                setState(() => selectedAppliesTo = v ?? selectedAppliesTo),
          ),
          TextFormField(
            controller: fieldNameController,
            decoration: const InputDecoration(
              labelText: 'Field Name (e.g. Blood Group)',
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedFieldType,
            decoration: const InputDecoration(labelText: 'Field Type'),
            items: kCustomFieldTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) =>
                setState(() => selectedFieldType = v ?? selectedFieldType),
          ),
          if (selectedFieldType == 'dropdown')
            TextFormField(
              controller: optionsController,
              decoration: const InputDecoration(
                labelText: 'Options (comma-separated)',
              ),
            ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Required'),
            value: isRequired,
            onChanged: (v) => setState(() => isRequired = v),
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
        CustomFieldDef(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          appliesTo: selectedAppliesTo,
          fieldName: fieldNameController.text,
          fieldType: selectedFieldType,
          options: optionsController.text
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList(),
          isRequired: isRequired,
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

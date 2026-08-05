import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import '../../domain/entities/communication_config_entities.dart';
import 'structure_ui_kit.dart';

const List<String> kMessageChannels = ['sms', 'email', 'push', 'message'];

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
          PulseTextField(
            label: 'Category Name',
            hint: 'e.g. Academic, Sports, Emergency',
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
        AnnouncementCategoryDef(
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
          PulseTextField(
            label: 'Category Name',
            hint: 'e.g. Fee Reminder, Homework',
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
        NotificationCategoryDef(
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
  String channel = kMessageChannels.contains(existing?.channel)
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
          PulseTextField(
            label: 'Template Name',
            hint: 'e.g. Fee Due Reminder',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: channel,
            decoration: const InputDecoration(labelText: 'Channel'),
            items: kMessageChannels
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => setState(() => channel = v ?? channel),
          ),
          if (channel == 'email' || channel == 'push')
            PulseTextField(
              label: 'Subject',
              hint: 'Optional',
              controller: subjectController,
            ),
          PulseTextField(
            label: 'Body',
            hint: 'Message content, supports placeholders like {{studentName}}',
            controller: bodyController,
            maxLines: 4,
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
        MessageTemplateDef(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          name: nameController.text,
          channel: channel,
          subject: subjectController.text,
          body: bodyController.text,
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

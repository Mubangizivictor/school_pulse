import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import '../../domain/entities/custom_field_entities.dart';
import 'structure_ui_kit.dart';

const List<String> kCustomFieldAppliesTo = [
  'Student',
  'Staff',
  'Class',
  'Parent',
  'Visitor',
];
const List<String> kCustomFieldTypes = [
  'text',
  'number',
  'date',
  'dropdown',
  'checkbox',
];

Future<void> showCustomFieldFormDialog(
  BuildContext context, {
  CustomFieldDef? existing,
  required String schoolId,
  required void Function(CustomFieldDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.fieldName);
  final optionsController = TextEditingController(
    text: existing?.options.join(', '),
  );
  String appliesTo = kCustomFieldAppliesTo.contains(existing?.appliesTo)
      ? existing!.appliesTo
      : kCustomFieldAppliesTo.first;
  String fieldType = kCustomFieldTypes.contains(existing?.fieldType)
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
            initialValue: appliesTo,
            decoration: const InputDecoration(labelText: 'Applies To'),
            items: kCustomFieldAppliesTo
                .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                .toList(),
            onChanged: (v) => setState(() => appliesTo = v ?? appliesTo),
          ),
          PulseTextField(
            label: 'Field Name',
            hint: 'e.g. Blood Group, Religion',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: fieldType,
            decoration: const InputDecoration(labelText: 'Field Type'),
            items: kCustomFieldTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => fieldType = v ?? fieldType),
          ),
          if (fieldType == 'dropdown')
            PulseTextField(
              label: 'Options',
              hint: 'Comma-separated, e.g. A+, A-, B+, B-',
              controller: optionsController,
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
          appliesTo: appliesTo,
          fieldName: nameController.text,
          fieldType: fieldType,
          options: fieldType == 'dropdown'
              ? optionsController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList()
              : const [],
          isRequired: isRequired,
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

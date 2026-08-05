import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import '../../domain/entities/document_template_entities.dart';
import 'structure_ui_kit.dart';

const List<String> kDocumentTemplateTypes = [
  'Student ID Card',
  'Staff ID Card',
  'Report Card',
  'Certificate',
  'Admission Letter',
  'Transfer Letter',
  'Statement',
  'Receipt',
  'Visitor Pass',
  'Gate Pass',
  'Leaving Certificate',
  'Other',
];

Future<void> showDocumentTemplateFormDialog(
  BuildContext context, {
  DocumentTemplateDef? existing,
  required String schoolId,
  required void Function(DocumentTemplateDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final descController = TextEditingController(text: existing?.description);
  String templateType = kDocumentTemplateTypes.contains(existing?.templateType)
      ? existing!.templateType
      : kDocumentTemplateTypes.first;
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
          PulseTextField(
            label: 'Template Name',
            hint: 'e.g. Standard Report Card',
            controller: nameController,
            isRequired: true,
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: templateType,
            decoration: const InputDecoration(labelText: 'Template Type'),
            items: kDocumentTemplateTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => templateType = v ?? templateType),
          ),
          PulseTextField(
            label: 'Description',
            hint: 'Optional',
            controller: descController,
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
      onSave(
        DocumentTemplateDef(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          name: nameController.text,
          templateType: templateType,
          description: descController.text,
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

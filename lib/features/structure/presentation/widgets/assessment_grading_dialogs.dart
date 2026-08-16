import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/fee_category_entities.dart';
import '../../domain/entities/assessment_grading_entities.dart'
    show AssessmentTypeDef;
import 'structure_ui_kit.dart';

Future<void> showFeeCategoryFormDialog(
  BuildContext context, {
  FeeCategory? existing,
  required String schoolId,
  required void Function(FeeCategory) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final descController = TextEditingController(text: existing?.description);
  bool isMandatory = existing?.isMandatory ?? true;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Fee Category' : 'Edit Fee Category',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Category Name (e.g. Tuition, Transport)',
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: codeController,
            decoration: const InputDecoration(labelText: 'Code (optional)'),
          ),
          TextFormField(
            controller: descController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
            ),
            maxLines: 2,
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Mandatory'),
            value: isMandatory,
            onChanged: (v) => setState(() => isMandatory = v),
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
        FeeCategory(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          name: nameController.text,
          code: codeController.text,
          description: descController.text,
          isMandatory: isMandatory,
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

Future<void> showAssessmentTypeFormDialog(
  BuildContext context, {
  AssessmentTypeDef? existing,
  required String schoolId,
  required void Function(AssessmentTypeDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final weightController = TextEditingController(
    text: existing?.weightPercentage.toString() ?? '0',
  );
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Assessment Type' : 'Edit Assessment Type',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Type Name (e.g. CAT, Assignment, Final Exam)',
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          TextFormField(
            controller: weightController,
            decoration: const InputDecoration(labelText: 'Weighting (%)'),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
      onSave(
        AssessmentTypeDef(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          name: nameController.text,
          weightPercentage: double.tryParse(weightController.text) ?? 0,
          description: descController.text,
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

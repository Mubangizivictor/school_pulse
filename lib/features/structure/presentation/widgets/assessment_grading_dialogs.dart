import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/fee_category_entities.dart';
import '../../domain/entities/assessment_grading_entities.dart';
import 'structure_ui_kit.dart';

const List<String> kGradingSystemTypes = [
  'Letter (A-F)',
  'Numeric (1-9)',
  'Percentage',
  'Competency Based',
  'Custom',
];

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

Future<void> showGradingSystemFormDialog(
  BuildContext context, {
  GradingSystemDef? existing,
  required String schoolId,
  required void Function(GradingSystemDef) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  String selectedType = kGradingSystemTypes.contains(existing?.type)
      ? existing!.type
      : kGradingSystemTypes.first;
  bool isDefault = existing?.isDefault ?? false;
  bool isActive = existing?.isActive ?? true;

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Grading System' : 'Edit Grading System',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          TextFormField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'System Name'),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          DropdownButtonFormField<String>(
            initialValue: selectedType,
            decoration: const InputDecoration(labelText: 'Type'),
            items: kGradingSystemTypes
                .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                .toList(),
            onChanged: (v) => setState(() => selectedType = v ?? selectedType),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Default grading system'),
            value: isDefault,
            onChanged: (v) => setState(() => isDefault = v),
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
        GradingSystemDef(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          name: nameController.text,
          type: selectedType,
          isDefault: isDefault,
          isActive: isActive,
        ),
      );
      Navigator.pop(context);
    },
  );
}

Future<void> showGradeBandFormDialog(
  BuildContext context, {
  GradeBand? existing,
  required List<GradingSystemDef> gradingSystems,
  required String schoolId,
  required void Function(GradeBand) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final gradeController = TextEditingController(text: existing?.grade);
  final minController = TextEditingController(
    text: existing?.minScore.toString() ?? '0',
  );
  final maxController = TextEditingController(
    text: existing?.maxScore.toString() ?? '0',
  );
  final remarksController = TextEditingController(text: existing?.remarks);
  final orderController = TextEditingController(
    text: existing?.order.toString() ?? '0',
  );
  String? selectedSystemId = existing?.gradingSystemId.isNotEmpty == true
      ? existing!.gradingSystemId
      : (gradingSystems.isNotEmpty ? gradingSystems.first.id : null);

  return showStructureFormSheet(
    context,
    title: existing == null ? 'Add Grade Band' : 'Edit Grade Band',
    submitLabel: existing == null ? 'Add' : 'Save',
    fieldsBuilder: (context, setState) => Form(
      key: formKey,
      child: StructureFieldGroup(
        children: [
          DropdownButtonFormField<String>(
            initialValue: selectedSystemId,
            decoration: const InputDecoration(labelText: 'Grading System'),
            items: gradingSystems
                .map((g) => DropdownMenuItem(value: g.id, child: Text(g.name)))
                .toList(),
            onChanged: (v) => setState(() => selectedSystemId = v),
            validator: (v) => v == null ? 'Select a grading system' : null,
          ),
          TextFormField(
            controller: gradeController,
            decoration: const InputDecoration(
              labelText: 'Grade (e.g. A, Distinction, 1)',
            ),
            validator: (v) => v == null || v.isEmpty ? 'Required' : null,
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: minController,
                  decoration: const InputDecoration(labelText: 'Min Score'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  controller: maxController,
                  decoration: const InputDecoration(labelText: 'Max Score'),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
          TextFormField(
            controller: remarksController,
            decoration: const InputDecoration(labelText: 'Remarks (optional)'),
          ),
          TextFormField(
            controller: orderController,
            decoration: const InputDecoration(labelText: 'Display Order'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    ),
    onSubmit: () {
      if (!formKey.currentState!.validate()) return;
      onSave(
        GradeBand(
          id: existing?.id ?? const Uuid().v4(),
          schoolId: existing?.schoolId ?? schoolId,
          gradingSystemId: selectedSystemId!,
          grade: gradeController.text,
          minScore: double.tryParse(minController.text) ?? 0,
          maxScore: double.tryParse(maxController.text) ?? 0,
          remarks: remarksController.text,
          order: int.tryParse(orderController.text) ?? 0,
        ),
      );
      Navigator.pop(context);
    },
  );
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/structure_entities.dart';

const List<Color> kSubjectColorSwatches = [
  Color(0xFF1976D2),
  Color(0xFF2E7D32),
  Color(0xFFC62828),
  Color(0xFFED6C02),
  Color(0xFF6A1B9A),
  Color(0xFF00838F),
  Color(0xFF5D4037),
  Color(0xFF455A64),
];

String _colorToHex(Color color) =>
    '#${color.toARGB32().toRadixString(16).substring(2)}';

Future<void> showLevelFormDialog(
  BuildContext context, {
  EducationalLevel? existing,
  required String schoolId,
  required void Function(EducationalLevel) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final orderController = TextEditingController(
    text: existing?.order.toString() ?? '0',
  );
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          existing == null ? 'Add Educational Level' : 'Edit Educational Level',
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Level Name (e.g. Primary)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code (optional)',
                  ),
                ),
                TextFormField(
                  controller: orderController,
                  decoration: const InputDecoration(labelText: 'Display Order'),
                  keyboardType: TextInputType.number,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                EducationalLevel(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: nameController.text,
                  code: codeController.text,
                  order: int.tryParse(orderController.text) ?? 0,
                  description: descController.text,
                  isActive: isActive,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showAcademicYearFormDialog(
  BuildContext context, {
  AcademicYear? existing,
  required String schoolId,
  required void Function(AcademicYear) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  DateTime startDate =
      existing?.startDate ?? DateTime(DateTime.now().year, 1, 1);
  DateTime endDate = existing?.endDate ?? DateTime(DateTime.now().year, 12, 31);

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          existing == null ? 'Add Academic Year' : 'Edit Academic Year',
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Year Name (e.g. 2026)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => startDate = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(endDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => endDate = picked);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                AcademicYear(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: nameController.text,
                  startDate: startDate,
                  endDate: endDate,
                  isCurrent: existing?.isCurrent ?? false,
                  isArchived: existing?.isArchived ?? false,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showAcademicTermFormDialog(
  BuildContext context, {
  AcademicTerm? existing,
  required List<AcademicYear> years,
  required String schoolId,
  required void Function(AcademicTerm) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final orderController = TextEditingController(
    text: existing?.order.toString() ?? '0',
  );
  String? selectedYearId =
      existing?.academicYearId ?? (years.isNotEmpty ? years.first.id : null);
  DateTime startDate = existing?.startDate ?? DateTime.now();
  DateTime endDate =
      existing?.endDate ?? DateTime.now().add(const Duration(days: 90));

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          existing == null ? 'Add Term / Semester' : 'Edit Term / Semester',
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedYearId,
                  decoration: const InputDecoration(labelText: 'Academic Year'),
                  items: years
                      .map(
                        (y) =>
                            DropdownMenuItem(value: y.id, child: Text(y.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedYearId = v),
                  validator: (v) => v == null ? 'Select a year' : null,
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Term Name (e.g. Term 1, Semester 1)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: orderController,
                  decoration: const InputDecoration(labelText: 'Order'),
                  keyboardType: TextInputType.number,
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Start Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(startDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: startDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => startDate = picked);
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('End Date'),
                  subtitle: Text(DateFormat('MMM dd, yyyy').format(endDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: endDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) setState(() => endDate = picked);
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                AcademicTerm(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  academicYearId: selectedYearId!,
                  name: nameController.text,
                  order: int.tryParse(orderController.text) ?? 0,
                  startDate: startDate,
                  endDate: endDate,
                  isCurrent: existing?.isCurrent ?? false,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showClassFormDialog(
  BuildContext context, {
  SchoolClass? existing,
  required List<EducationalLevel> levels,
  required String schoolId,
  required void Function(SchoolClass) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final capacityController = TextEditingController(
    text: existing?.capacity.toString() ?? '0',
  );
  final descController = TextEditingController(text: existing?.description);
  String? selectedLevelId = existing?.levelId.isNotEmpty == true
      ? existing!.levelId
      : (levels.isNotEmpty ? levels.first.id : null);
  bool isActive = existing?.isActive ?? true;

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? 'Add Class' : 'Edit Class'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Class Name (e.g. P1, S1, Grade 12)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code (optional)',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedLevelId,
                  decoration: const InputDecoration(
                    labelText: 'Educational Level',
                  ),
                  items: levels
                      .map(
                        (l) =>
                            DropdownMenuItem(value: l.id, child: Text(l.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedLevelId = v),
                  validator: (v) => v == null ? 'Select a level' : null,
                ),
                TextFormField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                SchoolClass(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: nameController.text,
                  code: codeController.text,
                  levelId: selectedLevelId ?? '',
                  capacity: int.tryParse(capacityController.text) ?? 0,
                  description: descController.text,
                  isActive: isActive,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showStreamFormDialog(
  BuildContext context, {
  ClassStream? existing,
  required List<SchoolClass> classes,
  required String schoolId,
  required void Function(ClassStream) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final capacityController = TextEditingController(
    text: existing?.capacity.toString() ?? '0',
  );
  String? selectedClassId =
      existing?.classId ?? (classes.isNotEmpty ? classes.first.id : null);
  bool isActive = existing?.isActive ?? true;

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          existing == null ? 'Add Stream / Section' : 'Edit Stream / Section',
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Stream Name (e.g. East, A, Blue)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code (optional)',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedClassId,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: classes
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedClassId = v),
                  validator: (v) => v == null ? 'Select a class' : null,
                ),
                TextFormField(
                  controller: capacityController,
                  decoration: const InputDecoration(labelText: 'Capacity'),
                  keyboardType: TextInputType.number,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                ClassStream(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: nameController.text,
                  code: codeController.text,
                  classId: selectedClassId ?? '',
                  capacity: int.tryParse(capacityController.text) ?? 0,
                  isActive: isActive,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showSubjectFormDialog(
  BuildContext context, {
  Subject? existing,
  required List<Department> departments,
  required String schoolId,
  required void Function(Subject) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final creditController = TextEditingController(
    text: existing?.creditUnits.toString() ?? '0',
  );
  final descController = TextEditingController(text: existing?.description);
  String? selectedDepartmentId = existing?.departmentId.isNotEmpty == true
      ? existing!.departmentId
      : (departments.isNotEmpty ? departments.first.id : null);
  Color selectedColor = existing?.color.isNotEmpty == true
      ? Color(int.parse(existing!.color.replaceFirst('#', '0xff')))
      : kSubjectColorSwatches.first;
  bool isElective = existing?.isElective ?? false;
  bool isPractical = existing?.isPractical ?? false;
  bool isActive = existing?.isActive ?? true;

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? 'Add Subject' : 'Edit Subject'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Subject Name'),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code (optional)',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: selectedDepartmentId,
                  decoration: const InputDecoration(labelText: 'Department'),
                  items: departments
                      .map(
                        (d) =>
                            DropdownMenuItem(value: d.id, child: Text(d.name)),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => selectedDepartmentId = v),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Color',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
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
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: creditController,
                  decoration: const InputDecoration(
                    labelText: 'Credit Units (optional)',
                  ),
                  keyboardType: TextInputType.number,
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
                  title: const Text('Elective'),
                  value: isElective,
                  onChanged: (v) => setState(() => isElective = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Practical'),
                  value: isPractical,
                  onChanged: (v) => setState(() => isPractical = v),
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                Subject(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: nameController.text,
                  code: codeController.text,
                  departmentId: selectedDepartmentId ?? '',
                  color: _colorToHex(selectedColor),
                  description: descController.text,
                  isElective: isElective,
                  isPractical: isPractical,
                  creditUnits: int.tryParse(creditController.text) ?? 0,
                  isActive: isActive,
                  assignedLevelIds: existing?.assignedLevelIds ?? const [],
                  assignedClassIds: existing?.assignedClassIds ?? const [],
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showDepartmentFormDialog(
  BuildContext context, {
  Department? existing,
  required String schoolId,
  required void Function(Department) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final codeController = TextEditingController(text: existing?.code);
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(existing == null ? 'Add Department' : 'Edit Department'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Department Name',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: codeController,
                  decoration: const InputDecoration(
                    labelText: 'Code (optional)',
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                Department(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: nameController.text,
                  code: codeController.text,
                  description: descController.text,
                  headOfDepartmentStaffId:
                      existing?.headOfDepartmentStaffId ?? '',
                  isActive: isActive,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<void> showDesignationFormDialog(
  BuildContext context, {
  StaffDesignation? existing,
  required String schoolId,
  required void Function(StaffDesignation) onSave,
}) {
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: existing?.name);
  final descController = TextEditingController(text: existing?.description);
  bool isActive = existing?.isActive ?? true;

  return showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          existing == null ? 'Add Staff Designation' : 'Edit Staff Designation',
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Designation (e.g. Principal, Bursar)',
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Required' : null,
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              onSave(
                StaffDesignation(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: nameController.text,
                  description: descController.text,
                  isActive: isActive,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(existing == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    ),
  );
}

Future<bool?> showDeleteConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String? impactMessage,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message),
          if (impactMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              impactMessage,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
}

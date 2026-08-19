import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../add_staff_wizard_controller.dart';

const _employmentTypes = ['Permanent', 'Contract', 'Part-Time', 'Volunteer'];

// Offered as quick-pick starting points when a school has no designations
// configured yet, so Add Staff never dead-ends on an empty required
// dropdown - not auto-seeded, only created if the admin picks one.
const _designationPresets = [
  'Teacher',
  'Class Teacher',
  'Head of Department',
  'Deputy Head Teacher',
  'Head Teacher',
  'School Nurse',
  'Librarian',
  'Bursar',
  'Counselor',
  'Sports Coach',
  'Lab Technician',
  'IT Support',
  'Security Officer',
  'Cook / Catering Staff',
  'Cleaner',
  'Driver',
];

const _addNewDesignationValue = '__add_new__';

class Step04EmploymentInfo extends StatefulWidget {
  const Step04EmploymentInfo({super.key});

  @override
  State<Step04EmploymentInfo> createState() => _Step04EmploymentInfoState();
}

class _Step04EmploymentInfoState extends State<Step04EmploymentInfo> {
  final _formKey = GlobalKey<FormState>();
  late final StructureRepository _structureRepository;

  @override
  void initState() {
    super.initState();
    _structureRepository = di.sl<StructureRepository>();
  }

  Future<StaffDesignation?> _addDesignation(
    BuildContext context,
    String schoolId, {
    required Set<String> existingNames,
  }) async {
    final available = _designationPresets
        .where((p) => !existingNames.contains(p.toLowerCase()))
        .toList();
    final customController = TextEditingController();

    final chosenName = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(sheetContext).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add Designation',
              style: Theme.of(
                sheetContext,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (available.isNotEmpty) ...[
              Text(
                'Quick pick',
                style: Theme.of(sheetContext).textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: available
                    .map(
                      (name) => ActionChip(
                        label: Text(name),
                        onPressed: () => Navigator.pop(sheetContext, name),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
            ],
            Text(
              'Or type a custom title',
              style: Theme.of(sheetContext).textTheme.labelMedium,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: customController,
              decoration: const InputDecoration(
                hintText: 'e.g. Guidance Counselor',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final custom = customController.text.trim();
                  if (custom.isNotEmpty) Navigator.pop(sheetContext, custom);
                },
                child: const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );

    if (chosenName == null || chosenName.trim().isEmpty) return null;
    if (existingNames.contains(chosenName.trim().toLowerCase())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$chosenName" already exists.')),
        );
      }
      return null;
    }

    final designation = StaffDesignation(
      id: const Uuid().v4(),
      schoolId: schoolId,
      name: chosenName.trim(),
    );
    try {
      await _structureRepository.addDesignation(designation);
      return designation;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not add designation: $e')),
        );
      }
      return null;
    }
  }

  Future<void> _pickDate(AddStaffWizardController controller) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.draft.dateJoined,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      controller.draft.dateJoined = picked;
      controller.notifyDraftChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;
    final schoolId = controller.schoolId;

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.employmentInfo),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        onNext: () {
          if (!_formKey.currentState!.validate()) return;
          controller.next();
        },
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardStepCaption(
              number: 3,
              title: 'Employment Information',
              subtitle: 'Add employment details',
            ),
            const SizedBox(height: 20),
            TextFormField(
              enabled: false,
              initialValue: 'Auto-generated on creation',
              decoration: const InputDecoration(
                labelText: 'Staff Code',
                prefixIcon: Icon(Icons.badge_outlined),
              ),
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: draft.employmentType,
              decoration: const InputDecoration(
                labelText: 'Employment Type *',
                prefixIcon: Icon(Icons.work_outline),
              ),
              items: _employmentTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  draft.employmentType = v;
                  controller.notifyDraftChanged();
                }
              },
            ),
            const SizedBox(height: 14),
            StreamBuilder<List<Department>>(
              stream: _structureRepository.watchDepartments(schoolId),
              builder: (context, snapshot) {
                final departments =
                    (snapshot.data ?? const [])
                        .where((d) => d.isActive)
                        .toList()
                      ..sort((a, b) => a.name.compareTo(b.name));
                return DropdownButtonFormField<String>(
                  initialValue:
                      departments.any((d) => d.id == draft.departmentId)
                      ? draft.departmentId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Department *',
                    prefixIcon: Icon(Icons.apartment_outlined),
                  ),
                  items: departments
                      .map(
                        (d) =>
                            DropdownMenuItem(value: d.id, child: Text(d.name)),
                      )
                      .toList(),
                  onChanged: (v) {
                    final picked = departments
                        .where((d) => d.id == v)
                        .firstOrNull;
                    if (picked != null) {
                      draft.departmentId = picked.id;
                      draft.department = picked.name;
                      controller.notifyDraftChanged();
                    }
                  },
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Required' : null,
                );
              },
            ),
            const SizedBox(height: 14),
            StreamBuilder<List<StaffDesignation>>(
              stream: _structureRepository.watchDesignations(schoolId),
              builder: (context, snapshot) {
                final designations =
                    (snapshot.data ?? const [])
                        .where((d) => d.isActive)
                        .toList()
                      ..sort((a, b) => a.name.compareTo(b.name));
                return DropdownButtonFormField<String>(
                  initialValue:
                      designations.any((d) => d.id == draft.designationId)
                      ? draft.designationId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Designation / Title *',
                    prefixIcon: Icon(Icons.work_outline),
                  ),
                  items: [
                    ...designations.map(
                      (d) =>
                          DropdownMenuItem(value: d.id, child: Text(d.name)),
                    ),
                    const DropdownMenuItem(
                      value: _addNewDesignationValue,
                      child: Text('+ Add new designation'),
                    ),
                  ],
                  onChanged: (v) async {
                    if (v == _addNewDesignationValue) {
                      final added = await _addDesignation(
                        context,
                        schoolId,
                        existingNames: designations
                            .map((d) => d.name.toLowerCase())
                            .toSet(),
                      );
                      if (added != null) {
                        draft.designationId = added.id;
                        draft.designation = added.name;
                        controller.notifyDraftChanged();
                      }
                      return;
                    }
                    final picked = designations
                        .where((d) => d.id == v)
                        .firstOrNull;
                    if (picked != null) {
                      draft.designationId = picked.id;
                      draft.designation = picked.name;
                      controller.notifyDraftChanged();
                    }
                  },
                  validator: (v) =>
                      (v == null || v.isEmpty || v == _addNewDesignationValue)
                      ? 'Required'
                      : null,
                );
              },
            ),
            const SizedBox(height: 14),
            StreamBuilder<List<Campus>>(
              stream: _structureRepository.watchCampuses(schoolId),
              builder: (context, snapshot) {
                final campuses =
                    (snapshot.data ?? const [])
                        .where((c) => c.isActive)
                        .toList()
                      ..sort((a, b) => a.order.compareTo(b.order));
                if (campuses.length <= 1) {
                  // No meaningful choice to make for a single-campus school.
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: DropdownButtonFormField<String>(
                    initialValue: campuses.any((c) => c.id == draft.campusId)
                        ? draft.campusId
                        : null,
                    decoration: const InputDecoration(
                      labelText: 'Campus',
                      prefixIcon: Icon(Icons.location_city_outlined),
                    ),
                    items: campuses
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      draft.campusId = v;
                      controller.notifyDraftChanged();
                    },
                  ),
                );
              },
            ),
            InkWell(
              onTap: () => _pickDate(controller),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date Joined *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
                child: Text(
                  '${draft.dateJoined.day}/${draft.dateJoined.month}/${draft.dateJoined.year}',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

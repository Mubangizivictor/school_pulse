import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/components/wizard_scaffold.dart';

import '../add_staff_wizard_controller.dart';

const _employmentTypes = ['Permanent', 'Contract', 'Part-Time', 'Volunteer'];

class Step04EmploymentInfo extends StatefulWidget {
  const Step04EmploymentInfo({super.key});

  @override
  State<Step04EmploymentInfo> createState() => _Step04EmploymentInfoState();
}

class _Step04EmploymentInfoState extends State<Step04EmploymentInfo> {
  late final TextEditingController _department;
  late final TextEditingController _designation;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final draft = context.read<AddStaffWizardController>().draft;
    _department = TextEditingController(text: draft.department);
    _designation = TextEditingController(text: draft.designation);
  }

  @override
  void dispose() {
    _department.dispose();
    _designation.dispose();
    super.dispose();
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

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.employmentInfo),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        onNext: () {
          if (!_formKey.currentState!.validate()) return;
          draft.department = _department.text.trim();
          draft.designation = _designation.text.trim();
          controller.next();
        },
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardStepCaption(
              number: 5,
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
            TextFormField(
              controller: _department,
              decoration: const InputDecoration(
                labelText: 'Department *',
                prefixIcon: Icon(Icons.apartment_outlined),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _designation,
              decoration: const InputDecoration(
                labelText: 'Designation / Title *',
                prefixIcon: Icon(Icons.work_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
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

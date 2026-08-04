import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';

class Step02PersonalInfo extends StatefulWidget {
  const Step02PersonalInfo({super.key});

  @override
  State<Step02PersonalInfo> createState() => _Step02PersonalInfoState();
}

class _Step02PersonalInfoState extends State<Step02PersonalInfo> {
  late final TextEditingController _first;
  late final TextEditingController _middle;
  late final TextEditingController _last;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final draft = context.read<AddStaffWizardController>().draft;
    _first = TextEditingController(text: draft.firstName);
    _middle = TextEditingController(text: draft.middleName);
    _last = TextEditingController(text: draft.lastName);
  }

  @override
  void dispose() {
    _first.dispose();
    _middle.dispose();
    _last.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(AddStaffWizardController controller) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      controller.draft.photo = File(picked.path);
      controller.notifyDraftChanged();
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.personalInfo),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        onNext: () {
          if (!_formKey.currentState!.validate()) return;
          draft.firstName = _first.text.trim();
          draft.middleName = _middle.text.trim();
          draft.lastName = _last.text.trim();
          controller.next();
        },
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WizardStepCaption(
              number: 3,
              title: 'Personal Information',
              subtitle: 'Enter staff personal details',
            ),
            const SizedBox(height: 20),
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: AppColors.surfaceContainer(context),
                    backgroundImage: draft.photo != null
                        ? FileImage(draft.photo!)
                        : null,
                    child: draft.photo == null
                        ? Icon(
                            Icons.person,
                            size: 44,
                            color: AppColors.textMuted(context),
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _pickPhoto(controller),
                      child: CircleAvatar(
                        radius: 15,
                        backgroundColor: AppColors.electricBlue,
                        child: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => _pickPhoto(controller),
                child: const Text('Change Photo'),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _first,
              decoration: const InputDecoration(
                labelText: 'First Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _middle,
              decoration: const InputDecoration(
                labelText: 'Middle Name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _last,
              decoration: const InputDecoration(
                labelText: 'Last Name *',
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            Text(
              'Gender',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _GenderChip(
                    label: 'Male',
                    selected: draft.gender == 'Male',
                    onTap: () {
                      draft.gender = 'Male';
                      controller.notifyDraftChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _GenderChip(
                    label: 'Female',
                    selected: draft.gender == 'Female',
                    onTap: () {
                      draft.gender = 'Female';
                      controller.notifyDraftChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.electricBlue
              : AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary(context),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/components/phone_number_field.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';

import '../link_parent_wizard_controller.dart';

/// Step 1 - "Link parent to learners": parent legal name, relationship,
/// Uganda-aware +256 phone (international via PhoneNumberField), optional
/// email, and a searchable multi-learner selector with per-learner
/// relationship + primary-contact + remove.
class LinkParentStepDetails extends StatefulWidget {
  final List<Student> roster;

  const LinkParentStepDetails({super.key, required this.roster});

  @override
  State<LinkParentStepDetails> createState() => _LinkParentStepDetailsState();
}

class _LinkParentStepDetailsState extends State<LinkParentStepDetails> {
  bool _submitted = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LinkParentWizardController>();
    final q = _query.trim().toLowerCase();
    final available = widget.roster
        .where((s) => !controller.selectedLearners.any((l) => l.student.id == s.id))
        .where((s) =>
            q.isEmpty ||
            s.name.toLowerCase().contains(q) ||
            s.studentCode.toLowerCase().contains(q) ||
            s.admissionNumber.toLowerCase().contains(q))
        .take(50)
        .toList();

    return WizardStageScaffold(
      title: 'Link parent to learners',
      stageLabels: kLinkParentStageLabels,
      currentStageIndex: linkParentStageIndexFor(LinkParentStage.details),
      onBack: () => Navigator.of(context).maybePop(),
      footer: WizardFooterButtons(
        nextLabel: 'Review invitation',
        loading: controller.checkingDuplicate,
        onNext: () async {
          setState(() => _submitted = true);
          if (controller.canProceedFromDetails) await controller.next();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'Parent details',
            subtitle: "Enter the parent or guardian's details below.",
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WizardSectionLabel(label: 'Parent/guardian name'),
                    TextField(
                      controller: controller.parentNameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'e.g. Naluwagga Sarah',
                        errorText: _submitted && !controller.isNameValid
                            ? "Enter the parent or guardian's legal name"
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WizardSectionLabel(label: 'Relationship'),
                    DropdownButtonFormField<String>(
                      initialValue: controller.relationship,
                      items: kLinkParentRelationships
                          .map((r) =>
                              DropdownMenuItem(value: r, child: Text(r)))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) controller.relationship = v;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const WizardSectionLabel(label: 'Phone number'),
          PhoneNumberField(
            dialCode: controller.dialCode,
            nationalNumber: controller.nationalNumber,
            onDialCodeChanged: (v) => controller.dialCode = v,
            onNationalNumberChanged: (v) => controller.nationalNumber = v,
            errorText: _submitted && !controller.isPhoneValid
                ? 'Enter a valid phone number'
                : null,
          ),
          const SizedBox(height: 16),
          const WizardSectionLabel(
            label: 'Email',
            helper: 'Optional - a verified invitation link is emailed here.',
          ),
          TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              hintText: 'sarah.naluwagga@example.com',
              errorText: _submitted && !controller.isEmailValid
                  ? 'Enter a valid email address'
                  : null,
            ),
          ),
          const SizedBox(height: 28),
          const WizardStageHeading(
            title: 'Link learners',
            subtitle:
                'Search for the learner(s) to link with this parent. You can '
                'add more than one.',
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search, size: 18),
              hintText: 'Search by student name or admission number...',
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.selectedLearners.map(
            (learner) => _SelectedLearnerRow(
              learner: learner,
              atCap: controller.learnerAtCap(learner.student.id),
              onRemove: () => controller.removeLearner(learner.student.id),
              onRelationshipChanged: (v) =>
                  controller.setLearnerRelationship(learner.student.id, v),
              onPrimaryChanged: (v) =>
                  controller.setPrimaryContact(learner.student.id, v),
            ),
          ),
          if (controller.selectedLearners.isEmpty && _submitted)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Select at least one learner to link.',
                style: TextStyle(
                    color: AppColors.danger(context), fontSize: 12),
              ),
            ),
          if (_query.isNotEmpty) ...[
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border(context)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: available.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'No matching learners.',
                        style: TextStyle(
                            color: AppColors.textMuted(context), fontSize: 13),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: available.length,
                      itemBuilder: (context, i) {
                        final s = available[i];
                        return ListTile(
                          dense: true,
                          title: Text(s.name),
                          subtitle: Text(
                            [s.studentCode, s.admissionNumber]
                                .where((v) => v.isNotEmpty)
                                .join(' · '),
                          ),
                          trailing: const Icon(Icons.add, size: 18),
                          onTap: () {
                            controller.addLearner(s);
                            setState(() => _query = '');
                          },
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
          ],
          OutlinedButton.icon(
            onPressed: () => setState(() => _query = _query.isEmpty ? ' ' : ''),
            icon: const Icon(Icons.person_add_alt, size: 16),
            label: const Text('Add another learner'),
          ),
          const SizedBox(height: 16),
          _InfoNote(
            'One parent may link to several learners; each learner can have up '
            'to ${controller.maxGuardians} parents/guardians.',
          ),
        ],
      ),
    );
  }
}

class _SelectedLearnerRow extends StatelessWidget {
  final SelectedLearner learner;
  final bool atCap;
  final VoidCallback onRemove;
  final ValueChanged<String> onRelationshipChanged;
  final ValueChanged<bool> onPrimaryChanged;

  const _SelectedLearnerRow({
    required this.learner,
    required this.atCap,
    required this.onRemove,
    required this.onRelationshipChanged,
    required this.onPrimaryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: atCap
              ? AppColors.danger(context)
              : AppColors.border(context),
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.textPrimary(context),
                child: Text(
                  learner.student.name.isNotEmpty
                      ? learner.student.name[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    color: AppColors.background(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      learner.student.name,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      [learner.student.studentCode, learner.student.admissionNumber]
                          .where((v) => v.isNotEmpty)
                          .join(' · '),
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close,
                    size: 18, color: AppColors.textMuted(context)),
                onPressed: onRemove,
                tooltip: 'Remove learner',
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: learner.relationship,
                  isDense: true,
                  decoration: const InputDecoration(
                    labelText: 'Relationship',
                    isDense: true,
                  ),
                  items: kLinkParentRelationships
                      .map((r) => DropdownMenuItem(
                            value: r,
                            child: Text(r,
                                style: const TextStyle(fontSize: 12.5)),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onRelationshipChanged(v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  Text(
                    'Primary contact',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: AppColors.textMuted(context),
                    ),
                  ),
                  Switch(
                    value: learner.isPrimaryContact,
                    onChanged: onPrimaryChanged,
                  ),
                ],
              ),
            ],
          ),
          if (atCap)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'This learner already has the maximum number of linked '
                'parents. Remove it or reallocate an existing link.',
                style: TextStyle(
                    color: AppColors.danger(context), fontSize: 11.5),
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoNote extends StatelessWidget {
  final String text;
  const _InfoNote(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.informationSurface(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline,
              size: 16, color: AppColors.information(context)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.information(context),
                fontSize: 12.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

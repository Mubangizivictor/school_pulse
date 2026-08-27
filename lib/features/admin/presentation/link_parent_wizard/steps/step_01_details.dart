import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../link_parent_wizard_controller.dart';

const _kRelationships = ['Mother', 'Father', 'Guardian', 'Other'];

/// Step 1 - "Link parent to learners": parent identity, country-coded phone,
/// and one or more linked learners, each with its own relationship value.
class LinkParentStepDetails extends StatefulWidget {
  const LinkParentStepDetails({super.key});

  @override
  State<LinkParentStepDetails> createState() => _LinkParentStepDetailsState();
}

class _LinkParentStepDetailsState extends State<LinkParentStepDetails> {
  bool _submitted = false;
  bool _loadingStudents = true;
  List<Student> _students = [];
  String _studentQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final controller = context.read<LinkParentWizardController>();
    final result = await di.sl<GetAllStudents>()(schoolId: controller.schoolId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _loadingStudents = false),
      (students) => setState(() {
        _students = students;
        _loadingStudents = false;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<LinkParentWizardController>();
    final filtered = _students
        .where(
          (s) =>
              s.name.toLowerCase().contains(_studentQuery.toLowerCase()) ||
              s.studentCode.toLowerCase().contains(_studentQuery.toLowerCase()),
        )
        .toList();

    return WizardStageScaffold(
      title: 'Link parent to learners',
      stageLabels: kLinkParentStageLabels,
      currentStageIndex: linkParentStageIndexFor(LinkParentStage.details),
      onBack: () => Navigator.of(context).maybePop(),
      footer: WizardFooterButtons(
        nextLabel: 'Review invitation',
        onNext: () {
          setState(() => _submitted = true);
          if (controller.canProceedFromDetails) controller.next();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'Parent details',
            subtitle: 'Enter the parent or guardian being linked.',
          ),
          const SizedBox(height: 20),
          WizardSectionLabel(label: 'Parent/guardian name', helper: null),
          _RequiredField(
            controller: controller.parentNameController,
            hintText: 'e.g. Sarah Jansen',
            errorText: _submitted && !controller.isNameValid
                ? 'Enter the parent or guardian\'s name'
                : null,
          ),
          const SizedBox(height: 16),
          const WizardSectionLabel(label: 'Phone number'),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CountryCodePicker(
                value: controller.countryCode,
                onChanged: (code) => controller.countryCode = code,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller.phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    hintText: '772 123 456',
                    errorText: _submitted && !controller.isPhoneValid
                        ? 'Enter a valid phone number'
                        : null,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Linked learners (${controller.selectedLearners.length})',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 13.5,
            ),
          ),
          const SizedBox(height: 8),
          if (controller.selectedLearners.isEmpty && _submitted)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Select at least one learner to link.',
                style: TextStyle(
                  color: AppColors.danger(context),
                  fontSize: 12,
                ),
              ),
            ),
          ...controller.selectedLearners.map(
            (learner) => _SelectedLearnerRow(
              learner: learner,
              onRemove: () => controller.removeLearner(learner.student.id),
              onRelationshipChanged: (value) =>
                  controller.setRelationship(learner.student.id, value),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) => setState(() => _studentQuery = v),
            decoration: const InputDecoration(
              hintText: 'Search students to add...',
              prefixIcon: Icon(Icons.search, size: 18),
              isDense: true,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: _loadingStudents
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final student = filtered[index];
                      final selected = controller.selectedLearners.any(
                        (l) => l.student.id == student.id,
                      );
                      return CheckboxListTile(
                        dense: true,
                        title: Text(student.name),
                        subtitle: Text(student.studentCode),
                        value: selected,
                        onChanged: (val) {
                          if (val == true) {
                            controller.addLearner(student);
                          } else {
                            controller.removeLearner(student.id);
                          }
                        },
                      );
                    },
                  ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'One parent can be linked to several learners. Each '
                    'learner may have up to two parents.',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedLearnerRow extends StatelessWidget {
  final SelectedLearner learner;
  final VoidCallback onRemove;
  final ValueChanged<String> onRelationshipChanged;

  const _SelectedLearnerRow({
    required this.learner,
    required this.onRemove,
    required this.onRelationshipChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
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
                  learner.student.studentCode,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: learner.relationship,
            underline: const SizedBox.shrink(),
            items: _kRelationships
                .map(
                  (r) => DropdownMenuItem(
                    value: r,
                    child: Text(r, style: const TextStyle(fontSize: 12.5)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) onRelationshipChanged(value);
            },
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: AppColors.textMuted(context),
            ),
            onPressed: onRemove,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

class _RequiredField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? errorText;

  const _RequiredField({
    required this.controller,
    required this.hintText,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(hintText: hintText, errorText: errorText),
    );
  }
}

/// Minimal inline country-code picker (no external phone package is used
/// elsewhere in the codebase); a compact dropdown covering the school's
/// primary regions, defaulting to +256 (Uganda).
class _CountryCodePicker extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const _CountryCodePicker({required this.value, required this.onChanged});

  static const _codes = [
    {'flag': '🇺🇬', 'code': '+256', 'name': 'Uganda'},
    {'flag': '🇰🇪', 'code': '+254', 'name': 'Kenya'},
    {'flag': '🇹🇿', 'code': '+255', 'name': 'Tanzania'},
    {'flag': '🇷🇼', 'code': '+250', 'name': 'Rwanda'},
    {'flag': '🇳🇬', 'code': '+234', 'name': 'Nigeria'},
    {'flag': '🇬🇭', 'code': '+233', 'name': 'Ghana'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: _codes
              .map(
                (c) => DropdownMenuItem(
                  value: c['code'],
                  child: Text('${c['flag']} ${c['code']}'),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/responsive/responsive_builder.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/campus_entities.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../add_staff_wizard_controller.dart';

const _employmentTypes = ['Permanent', 'Contract', 'Part-Time', 'Volunteer'];

/// Roles authorised to see and configure compensation - "Restricted to HR &
/// Finance" per the design. Deliberately narrower than
/// [UserRoleDisplay.adminRoles]: an ordinary School Admin/Director/Head
/// Teacher can create a staff profile without ever seeing pay, matching the
/// "never expose pay details to ordinary administrators" requirement.
const _compensationRoles = {UserRole.hrOfficer, UserRole.bursar};

/// Stage 2 - Work: "Where will they work?" Collects employment details
/// (campus, employment type, start date, department, job title) plus a
/// restricted compensation-setup choice. No salary/bank/tax fields or money
/// values are ever shown on this screen - "Configure pay now" only appears to
/// HR/Finance and opens the secure Salary Structure workflow, never inline.
class Stage02Work extends StatefulWidget {
  final VoidCallback onSaveDraft;

  const Stage02Work({super.key, required this.onSaveDraft});

  @override
  State<Stage02Work> createState() => _Stage02WorkState();
}

class _Stage02WorkState extends State<Stage02Work> {
  final _formKey = GlobalKey<FormState>();
  late final StructureRepository _structureRepository;

  @override
  void initState() {
    super.initState();
    _structureRepository = di.sl<StructureRepository>();
  }

  bool _canConfigurePayNow(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return false;
    return authState.user.roles.any(_compensationRoles.contains);
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
    final canConfigurePayNow = _canConfigurePayNow(context);

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.work),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue',
        onBack: () => controller.back(),
        onNext: () {
          if (!_formKey.currentState!.validate()) return;
          if (draft.campusId == null || draft.campusId!.isEmpty) return;
          controller.next();
        },
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WizardStageHeading(
              title: 'Where will they work?',
              subtitle:
                  "Set employment details and the staff member's starting "
                  'point at your school.',
            ),
            const SizedBox(height: 20),
            ResponsiveBuilder(
              builder: (context, layout) {
                final employmentCard = _EmploymentDetailsCard(
                  structureRepository: _structureRepository,
                  schoolId: schoolId,
                  draft: draft,
                  onChanged: controller.notifyDraftChanged,
                  onPickDate: () => _pickDate(controller),
                );
                final compensationCard = _CompensationCard(
                  canConfigurePayNow: canConfigurePayNow,
                  payNow: draft.compensationSetUpNow,
                  onChanged: (value) {
                    draft.compensationSetUpNow = value;
                    controller.notifyDraftChanged();
                  },
                  onConfigurePayNow: () => context.push(
                    '/staff/admin/school-setup/structure/people/salary-structures',
                  ),
                );
                if (layout == ResponsiveLayout.desktop) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: employmentCard),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: compensationCard),
                    ],
                  );
                }
                return Column(
                  children: [
                    employmentCard,
                    const SizedBox(height: 20),
                    compensationCard,
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _EmploymentDetailsCard extends StatelessWidget {
  final StructureRepository structureRepository;
  final String schoolId;
  final dynamic draft;
  final VoidCallback onChanged;
  final VoidCallback onPickDate;

  const _EmploymentDetailsCard({
    required this.structureRepository,
    required this.schoolId,
    required this.draft,
    required this.onChanged,
    required this.onPickDate,
  });

  @override
  Widget build(BuildContext context) {
    return PulseCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Employment details',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 15,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            context,
            'Employment type',
            required: true,
            field: DropdownButtonFormField<String>(
              initialValue: draft.employmentType,
              decoration: const InputDecoration(
                hintText: 'Select employment type',
              ),
              items: _employmentTypes
                  .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                  .toList(),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Select an employment type' : null,
              onChanged: (v) {
                if (v != null) {
                  draft.employmentType = v;
                  onChanged();
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            context,
            'Start date',
            required: true,
            field: InkWell(
              onTap: onPickDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  hintText: 'Select start date',
                ),
                child: Text(
                  '${draft.dateJoined.day}/${draft.dateJoined.month}/${draft.dateJoined.year}',
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            context,
            'Primary campus',
            required: true,
            field: StreamBuilder<List<Campus>>(
              stream: structureRepository.watchCampuses(schoolId),
              builder: (context, snapshot) {
                final campuses =
                    (snapshot.data ?? const [])
                        .where((c) => c.isActive)
                        .toList()
                      ..sort((a, b) => a.order.compareTo(b.order));
                if (campuses.isNotEmpty &&
                    !campuses.any((c) => c.id == draft.campusId)) {
                  draft.campusId = null;
                }
                return DropdownButtonFormField<String>(
                  initialValue: draft.campusId,
                  decoration: const InputDecoration(hintText: 'Select campus'),
                  items: campuses
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Select a campus' : null,
                  onChanged: (v) {
                    draft.campusId = v;
                    onChanged();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            context,
            'Department',
            required: true,
            field: StreamBuilder<List<Department>>(
              stream: structureRepository.watchDepartments(schoolId),
              builder: (context, snapshot) {
                final departments =
                    (snapshot.data ?? const [])
                        .where((d) => d.isActive)
                        .toList()
                      ..sort(
                        (a, b) => a.displayOrder.compareTo(b.displayOrder),
                      );
                if (departments.isNotEmpty &&
                    !departments.any((d) => d.id == draft.departmentId)) {
                  draft.departmentId = null;
                }
                return DropdownButtonFormField<String>(
                  initialValue: draft.departmentId,
                  decoration: const InputDecoration(
                    hintText: 'Select department',
                  ),
                  items: departments
                      .map(
                        (d) =>
                            DropdownMenuItem(value: d.id, child: Text(d.name)),
                      )
                      .toList(),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Select a department' : null,
                  onChanged: (v) {
                    draft.departmentId = v;
                    onChanged();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            context,
            'Job title',
            required: true,
            field: StreamBuilder<List<StaffDesignation>>(
              stream: structureRepository.watchDesignations(schoolId),
              builder: (context, snapshot) {
                final designations =
                    (snapshot.data ?? const [])
                        .where((d) => d.isActive && !d.isArchived)
                        .toList()
                      ..sort(
                        (a, b) => a.displayOrder.compareTo(b.displayOrder),
                      );
                if (designations.isNotEmpty &&
                    !designations.any((d) => d.id == draft.designationId)) {
                  draft.designationId = null;
                }
                return DropdownButtonFormField<String>(
                  initialValue: draft.designationId,
                  decoration: const InputDecoration(
                    hintText: 'Select job title',
                  ),
                  items: designations
                      .map(
                        (d) =>
                            DropdownMenuItem(value: d.id, child: Text(d.name)),
                      )
                      .toList(),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Select a job title' : null,
                  onChanged: (v) {
                    draft.designationId = v;
                    onChanged();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            context,
            'Staff code',
            field: InputDecorator(
              decoration: const InputDecoration(
                hintText: 'Generated when staff is created',
              ),
              child: Text(
                'Generated when staff is created',
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Available campuses and departments come from your school '
                  'structure.',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _labeledField(
    BuildContext context,
    String label, {
    required Widget field,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: RichText(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
              ),
              children: required
                  ? [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: AppColors.danger(context)),
                      ),
                    ]
                  : const [],
            ),
          ),
        ),
        field,
      ],
    );
  }
}

class _CompensationCard extends StatelessWidget {
  final bool canConfigurePayNow;
  final bool payNow;
  final ValueChanged<bool> onChanged;
  final VoidCallback onConfigurePayNow;

  const _CompensationCard({
    required this.canConfigurePayNow,
    required this.payNow,
    required this.onChanged,
    required this.onConfigurePayNow,
  });

  @override
  Widget build(BuildContext context) {
    return PulseCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Compensation setup',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              if (canConfigurePayNow)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer(context),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: 13,
                        color: AppColors.primary(context),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Restricted to HR & Finance',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary(context),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Pay details are not required to create a staff profile.',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 16),
          if (canConfigurePayNow)
            _CompensationChoice(
              title: 'Configure pay now',
              subtitle: 'Continue to secure HR/Finance pay setup.',
              selected: payNow,
              onTap: () {
                onChanged(true);
                onConfigurePayNow();
              },
            ),
          if (canConfigurePayNow) const SizedBox(height: 10),
          _CompensationChoice(
            title: 'Set up later',
            subtitle:
                'Create the staff profile first; authorised HR/Finance can '
                'complete pay later.',
            selected: !payNow,
            onTap: () => onChanged(false),
          ),
          const SizedBox(height: 14),
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
                  Icons.shield_outlined,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pay details are visible only to authorised HR and '
                    'Finance users.',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
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

class _CompensationChoice extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _CompensationChoice({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected
                ? AppColors.primary(context)
                : AppColors.border(context),
            width: selected ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              size: 18,
              color: selected
                  ? AppColors.primary(context)
                  : AppColors.textMuted(context),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

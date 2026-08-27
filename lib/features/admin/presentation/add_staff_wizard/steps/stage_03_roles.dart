import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/assignable_staff_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

import '../add_staff_wizard_controller.dart';
import '../models/role_assignment_draft.dart';
import '../role_config/role_assignment_config_registry.dart';
import '../role_config/role_config_form.dart';

/// Stage 3 - Roles: "What will this person do?" Internally holds three
/// screens - select roles, configure each selected role one at a time
/// ("Role N of M"), and a roles summary - matching the reference design.
class Stage03Roles extends StatefulWidget {
  final VoidCallback onSaveDraft;

  const Stage03Roles({super.key, required this.onSaveDraft});

  @override
  State<Stage03Roles> createState() => _Stage03RolesState();
}

class _Stage03RolesState extends State<Stage03Roles> {
  final _structureRepository = di.sl<StructureRepository>();
  List<String> _classNames = [];
  List<String> _subjectNames = [];
  StreamSubscription? _classesSub;
  StreamSubscription? _subjectsSub;
  String _roleQuery = '';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    _classesSub = _structureRepository.watchClasses(schoolId).listen((classes) {
      if (mounted) {
        setState(() => _classNames = classes.map((c) => c.name).toList());
      }
    });
    _subjectsSub = _structureRepository.watchSubjects(schoolId).listen((
      subjects,
    ) {
      if (mounted) {
        setState(() => _subjectNames = subjects.map((s) => s.name).toList());
      }
    });
  }

  @override
  void dispose() {
    _classesSub?.cancel();
    _subjectsSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    switch (controller.rolesSubStep) {
      case RolesSubStep.select:
        return _buildSelect(controller);
      case RolesSubStep.configure:
        return _buildConfigure(controller);
      case RolesSubStep.summary:
        return _buildSummary(controller);
    }
  }

  Widget _buildSelect(AddStaffWizardController controller) {
    final draft = controller.draft;
    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.roles),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue',
        onBack: () => controller.back(),
        onNext: draft.rolesSelected ? () => controller.next() : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'What will this person do?',
            subtitle: "Choose one or more roles. You'll set the scope next.",
          ),
          const SizedBox(height: 20),
          TextField(
            decoration: InputDecoration(
              hintText: 'Search roles',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: AppColors.surfaceContainer(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (v) =>
                setState(() => _roleQuery = v.trim().toLowerCase()),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${draft.selectedRoles.length} selected',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (draft.selectedRoles.isNotEmpty)
                TextButton(
                  onPressed: () {
                    draft.selectedRoles.clear();
                    draft.roleConfigs.clear();
                    controller.notifyDraftChanged();
                  },
                  child: const Text('Clear'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          ...assignableStaffRoleGroups.entries.expand((group) {
            final roles = group.value
                .where(assignableStaffRoles.contains)
                .where(
                  (r) =>
                      _roleQuery.isEmpty ||
                      UserRoleDisplay.name(
                        r,
                      ).toLowerCase().contains(_roleQuery),
                )
                .toList();
            if (roles.isEmpty) return const <Widget>[];
            return [
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 6),
                child: Text(
                  group.key,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border(context)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < roles.length; i++) ...[
                      if (i > 0)
                        Divider(height: 1, color: AppColors.border(context)),
                      _RoleListRow(
                        label: UserRoleDisplay.name(roles[i]),
                        selected: draft.selectedRoles.contains(roles[i]),
                        onTap: () {
                          final role = roles[i];
                          final selected = draft.selectedRoles.contains(role);
                          if (selected) {
                            draft.selectedRoles.remove(role);
                            draft.roleConfigs.remove(role);
                          } else {
                            if (role == UserRole.boardingMatron) {
                              draft.selectedRoles.remove(
                                UserRole.boardingPatron,
                              );
                            } else if (role == UserRole.boardingPatron) {
                              draft.selectedRoles.remove(
                                UserRole.boardingMatron,
                              );
                            }
                            draft.selectedRoles.add(role);
                          }
                          controller.notifyDraftChanged();
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ];
          }),
        ],
      ),
    );
  }

  Widget _buildConfigure(AddStaffWizardController controller) {
    final roles = controller.rolesNeedingConfig;

    if (roles.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => controller.next());
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }

    final index = controller.configureRoleIndex.clamp(0, roles.length - 1);
    final role = roles[index];
    final spec = RoleAssignmentConfigRegistry.forRole(role);
    final draft = controller.draft.roleConfigs.putIfAbsent(
      role,
      () => RoleAssignmentDraft(role: role),
    );

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.roles),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: index < roles.length - 1 ? 'Next role' : 'Continue',
        onBack: () => controller.back(),
        onNext: () => controller.next(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Role ${index + 1} of ${roles.length}',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          WizardStageHeading(
            title: UserRoleDisplay.name(role),
            subtitle:
                'Set the scope for this role. You can add or edit assignments as needed.',
          ),
          const SizedBox(height: 20),
          RoleConfigForm(
            draft: draft,
            spec: spec,
            classNames: _classNames,
            subjectNames: _subjectNames,
            academicYearId: null,
            onChanged: () => controller.notifyDraftChanged(),
          ),
          const SizedBox(height: 12),
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
                    'This staff member can access only the classes and subjects assigned above.',
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

  Widget _buildSummary(AddStaffWizardController controller) {
    final draft = controller.draft;
    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.roles),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Continue',
        onBack: () => controller.back(),
        onNext: () => controller.next(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStageHeading(
            title: 'Assigned roles',
            subtitle: 'Review the roles and scope for this staff member.',
          ),
          const SizedBox(height: 16),
          ...draft.selectedRoles.map((role) {
            final spec = RoleAssignmentConfigRegistry.forRole(role);
            final config = draft.roleConfigs[role];
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border(context)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            UserRoleDisplay.name(role),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _summaryFor(role, config),
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!spec.isEmpty)
                      TextButton(
                        onPressed: () => controller.editRole(role),
                        child: const Text('Edit'),
                      ),
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Add another role',
            icon: Icons.add,
            onPressed: () => controller.goToStage(WizardStage.roles),
          ),
        ],
      ),
    );
  }

  String _summaryFor(UserRole role, RoleAssignmentDraft? config) {
    if (config == null) return 'No additional configuration.';
    if (role == UserRole.classTeacher) {
      return config.className != null
          ? 'Class: ${config.className}'
          : 'Class not selected yet.';
    }
    if (role == UserRole.subjectTeacher) {
      if (config.subjectAssignments.isEmpty) return 'No subjects assigned yet.';
      return config.subjectAssignments
          .map((s) => '${s.subjectName} (${s.className})')
          .join(', ');
    }
    final parts = <String>[
      if (config.departmentId != null) 'Dept: ${config.departmentId}',
      if (config.dormitoryWing != null) 'Wing: ${config.dormitoryWing}',
      if (config.routeId != null) 'Route: ${config.routeId}',
      if (config.facilityId != null) 'Facility: ${config.facilityId}',
      if (config.approvalScope != null) 'Scope: ${config.approvalScope}',
    ];
    return parts.isEmpty ? 'No additional configuration.' : parts.join(' | ');
  }
}

class _RoleListRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleListRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: selected
                  ? AppColors.textPrimary(context)
                  : AppColors.border(context),
            ),
          ],
        ),
      ),
    );
  }
}

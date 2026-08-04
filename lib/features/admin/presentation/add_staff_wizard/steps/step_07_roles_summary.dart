import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';
import '../models/role_assignment_draft.dart';
import '../role_config/role_assignment_config_registry.dart';

class Step07RolesSummary extends StatelessWidget {
  const Step07RolesSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.rolesSummary),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        onNext: () => controller.next(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStepCaption(
            number: 8,
            title: 'Assigned Roles Summary',
            subtitle: 'Review all assigned roles',
          ),
          const SizedBox(height: 16),
          ...draft.selectedRoles.map((role) {
            final spec = RoleAssignmentConfigRegistry.forRole(role);
            final config = draft.roleConfigs[role];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
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
                              fontWeight: FontWeight.w600,
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
            label: 'Add Another Role',
            icon: Icons.add,
            onPressed: () => controller.goTo(WizardStep.selectRoles),
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

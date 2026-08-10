import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';

/// Every role a staff member can hold - excludes parent/student (not staff)
/// and superAdmin (platform-level, never assignable here).
final _assignableRoles = UserRole.values
    .where(
      (r) =>
          r != UserRole.parent &&
          r != UserRole.student &&
          r != UserRole.superAdmin,
    )
    .toList();

class Step05SelectRoles extends StatelessWidget {
  const Step05SelectRoles({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.selectRoles),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        onNext: draft.rolesSelected ? () => controller.next() : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStepCaption(
            number: 4,
            title: 'Select Roles',
            subtitle: 'Choose all roles applicable',
          ),
          const SizedBox(height: 8),
          Text(
            'One login can hold several roles - e.g. Class Teacher + Subject Teacher.',
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
          const SizedBox(height: 16),
          ..._assignableRoles.map((role) {
            final selected = draft.selectedRoles.contains(role);
            return CheckboxListTile(
              value: selected,
              contentPadding: EdgeInsets.zero,
              title: Text(UserRoleDisplay.name(role)),
              onChanged: (val) {
                if (val == true) {
                  if (role == UserRole.boardingMatron) {
                    draft.selectedRoles.remove(UserRole.boardingPatron);
                  } else if (role == UserRole.boardingPatron) {
                    draft.selectedRoles.remove(UserRole.boardingMatron);
                  }
                  draft.selectedRoles.add(role);
                } else {
                  draft.selectedRoles.remove(role);
                  draft.roleConfigs.remove(role);
                }
                controller.notifyDraftChanged();
              },
            );
          }),
        ],
      ),
    );
  }
}

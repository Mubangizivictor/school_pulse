import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/admin/presentation/widgets/assignable_staff_roles.dart';

import '../add_staff_wizard_controller.dart';

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
          const SizedBox(height: 20),
          ...assignableStaffRoleGroups.entries.expand((group) {
            final roles = group.value
                .where(assignableStaffRoles.contains)
                .toList();
            if (roles.isEmpty) return const <Widget>[];
            return [
              Text(
                group.key.toUpperCase(),
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: roles.map((role) {
                  final selected = draft.selectedRoles.contains(role);
                  return _RoleChip(
                    label: UserRoleDisplay.name(role),
                    selected: selected,
                    onTap: () {
                      if (selected) {
                        draft.selectedRoles.remove(role);
                        draft.roleConfigs.remove(role);
                      } else {
                        if (role == UserRole.boardingMatron) {
                          draft.selectedRoles.remove(UserRole.boardingPatron);
                        } else if (role == UserRole.boardingPatron) {
                          draft.selectedRoles.remove(UserRole.boardingMatron);
                        }
                        draft.selectedRoles.add(role);
                      }
                      controller.notifyDraftChanged();
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ];
          }),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = AppColors.primary(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primary : AppColors.border(context),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              size: 16,
              color: selected ? primary : AppColors.textMuted(context),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.textPrimary(context)
                    : AppColors.textSecondary(context),
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

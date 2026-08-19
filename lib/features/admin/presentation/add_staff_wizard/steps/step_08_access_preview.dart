import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';
import '../role_config/access_preview_mapper.dart';

class Step08AccessPreview extends StatelessWidget {
  const Step08AccessPreview({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final entries = AccessPreviewMapper.build(controller.draft.selectedRoles);
    final dashboards = entries.map((e) => e.dashboardPath).toSet().toList();
    final allPermissionIds = entries
        .expand((e) => e.permissionIds)
        .toSet()
        .toList();
    final groupedPermissions = AccessPreviewMapper.groupByModule(
      allPermissionIds,
    );

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.accessPreview),
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
            number: 7,
            title: 'Access Preview',
            subtitle: 'This staff member will have access to:',
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboards',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                ...dashboards.map(
                  (d) => Text(
                    d,
                    style: TextStyle(color: AppColors.textSecondary(context)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Modules & Permissions',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                if (groupedPermissions.isEmpty)
                  Text(
                    'Standard access for the selected role(s); no elevated permissions.',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  )
                else
                  ...groupedPermissions.expand(
                    (group) => [
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 4),
                        child: Text(
                          group.key,
                          style: TextStyle(
                            color: AppColors.primary(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      ...group.value.map(
                        (label) => Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.check,
                                size: 14,
                                color: AppColors.textMuted(context),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Roles',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: controller.draft.selectedRoles
                      .map(
                        (r) => StatusBadge(
                          label: UserRoleDisplay.name(r),
                          color: AppColors.primary(context),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

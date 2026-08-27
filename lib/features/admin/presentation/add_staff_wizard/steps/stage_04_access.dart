import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';
import '../role_config/access_preview_mapper.dart';

/// Stage 4 - Access: "Set up account access". Replaces the previous
/// Access Preview + Login & Security steps with one stage matching the
/// reference design - the login email summary, secure-setup toggles, and
/// an access preview that names role/module scope truthfully.
class Stage04Access extends StatelessWidget {
  final VoidCallback onSaveDraft;

  const Stage04Access({super.key, required this.onSaveDraft});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;
    final entries = AccessPreviewMapper.build(draft.selectedRoles);
    final allPermissionIds = entries
        .expand((e) => e.permissionIds)
        .toSet()
        .toList();
    final groupedPermissions = AccessPreviewMapper.groupByModule(
      allPermissionIds,
    );
    final hasScopedRoles = controller.rolesNeedingConfig.isNotEmpty;

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.access),
      onBack: () => controller.back(),
      onSaveDraft: onSaveDraft,
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
            title: 'Set up account access',
            subtitle: 'Choose how this staff member signs in and stays secure.',
          ),
          const SizedBox(height: 24),
          _labeledField(
            context,
            'Login email',
            TextFormField(
              enabled: false,
              initialValue: draft.email,
              decoration: const InputDecoration(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'This is the email the staff member will use to sign in.',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 20),
          _ToggleRow(
            title: 'Send secure setup link',
            helper:
                'The staff member receives a one-time password setup email.',
            value: draft.sendLoginDetailsViaEmail,
            onChanged: (v) {
              draft.sendLoginDetailsViaEmail = v;
              controller.notifyDraftChanged();
            },
          ),
          const Divider(height: 28),
          _ToggleRow(
            title: 'Require password update after first sign-in',
            helper:
                'Staff will create a new, unique password the first time they sign in.',
            value: draft.forcePasswordChange,
            onChanged: (v) {
              draft.forcePasswordChange = v;
              controller.notifyDraftChanged();
            },
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.shield_outlined,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'We never display or send temporary passwords.',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Divider(height: 1),
          const SizedBox(height: 20),
          const WizardSectionLabel(label: 'Access preview'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${draft.selectedRoles.length} role${draft.selectedRoles.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '• ${hasScopedRoles ? 'Limited to assigned classes' : 'Standard access'}',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                if (groupedPermissions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Text(
                    'Modules & permissions',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...groupedPermissions.expand(
                    (group) => [
                      Padding(
                        padding: const EdgeInsets.only(top: 6, bottom: 2),
                        child: Text(
                          group.key,
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
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
                                size: 13,
                                color: AppColors.textMuted(context),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: AppColors.textSecondary(context),
                                    fontSize: 12.5,
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
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: draft.selectedRoles
                      .map(
                        (r) => Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer(context),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            UserRoleDisplay.name(r),
                            style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textPrimary(context),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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

  Widget _labeledField(BuildContext context, String label, Widget field) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w600,
              fontSize: 13.5,
            ),
          ),
        ),
        field,
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String title;
  final String helper;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleRow({
    required this.title,
    required this.helper,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                helper,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}

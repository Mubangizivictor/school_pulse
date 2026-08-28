import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';
import '../role_config/access_preview_mapper.dart';

/// Stage 4 - Access: "Set up account access". The admin sets an initial
/// password here; the staff member is then forced to choose their own on
/// first sign-in (forcePasswordChange). Also shows the login email summary
/// and a truthful access preview of role/module scope.
class Stage04Access extends StatefulWidget {
  final VoidCallback onSaveDraft;

  const Stage04Access({super.key, required this.onSaveDraft});

  @override
  State<Stage04Access> createState() => _Stage04AccessState();
}

class _Stage04AccessState extends State<Stage04Access> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  @override
  void initState() {
    super.initState();
    final draft = context.read<AddStaffWizardController>().draft;
    _passwordController = TextEditingController(text: draft.initialPassword);
    _confirmController = TextEditingController(text: draft.initialPassword);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

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
          _labeledField(
            context,
            'Initial password',
            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              autofillHints: const [],
              decoration: InputDecoration(
                hintText: 'At least 8 characters',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              onChanged: (v) {
                draft.initialPassword = v;
                controller.notifyDraftChanged();
              },
            ),
          ),
          const SizedBox(height: 16),
          _labeledField(
            context,
            'Confirm password',
            TextFormField(
              controller: _confirmController,
              obscureText: _obscureConfirm,
              autofillHints: const [],
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 18,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_passwordController.text.isNotEmpty &&
              _passwordController.text != _confirmController.text)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Passwords do not match.',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            )
          else if (_passwordController.text.isNotEmpty &&
              _passwordController.text.trim().length < 8)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'Use at least 8 characters.',
                style: TextStyle(color: AppColors.error, fontSize: 12),
              ),
            ),
          const SizedBox(height: 8),
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
                  'Share this password with the staff member securely. They '
                  'will be asked to set their own the first time they sign in.',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
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
              fontSize: 12.5,
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
                  fontSize: 13,
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

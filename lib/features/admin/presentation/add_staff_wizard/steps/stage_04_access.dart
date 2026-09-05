import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';
import '../models/add_staff_draft.dart';
import '../role_config/access_preview_mapper.dart';

/// Elevated system areas that require an explicit elevated-role approval
/// before an invitation or profile can grant access to them. Mirrors the
/// finance/HR/health/safeguarding/security/settings/super-admin sensitivity
/// list called out in the account-access spec.
const Map<String, String> _kElevatedAreas = {
  'finance': 'Finance (invoices, payments, budgets)',
  'hrPay': 'HR & pay (contracts, payroll, staff records)',
  'health': 'Health records',
  'safeguarding': 'Safeguarding & child protection',
  'security': 'Security & gate access',
  'settings': 'School settings (configuration, admin controls)',
};

bool _roleGrantsElevatedArea(UserRole role, String area) {
  switch (area) {
    case 'finance':
      return role == UserRole.bursar;
    case 'hrPay':
      return role == UserRole.hrOfficer;
    case 'health':
      return role == UserRole.nurse;
    case 'safeguarding':
      return role == UserRole.guidanceDiscipline;
    case 'security':
      return role == UserRole.securityHead || role == UserRole.gatekeeper;
    case 'settings':
      return role == UserRole.schoolAdmin ||
          role == UserRole.director ||
          role == UserRole.headTeacher ||
          role == UserRole.superAdmin;
    default:
      return false;
  }
}

/// Stage 4 - Access: "Set up account access". Administrators choose how the
/// staff member signs in - a verified, time-limited invitation, or a
/// profile with no login until one is deliberately issued later. No
/// password is ever created, seen, or stored by an administrator here.
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
    final elevatedAreasGranted = _kElevatedAreas.entries
        .where(
          (e) =>
              draft.selectedRoles.any((r) => _roleGrantsElevatedArea(r, e.key)),
        )
        .map((e) => e.value)
        .toList();
    final restrictedAreas = _kElevatedAreas.entries
        .where(
          (e) => !draft.selectedRoles.any(
            (r) => _roleGrantsElevatedArea(r, e.key),
          ),
        )
        .map((e) => e.value)
        .toList();

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
            subtitle:
                'Choose how this staff member signs in. '
                'They will create their own password securely.',
          ),
          const SizedBox(height: 24),
          const WizardSectionLabel(label: 'Sign-in method'),
          const SizedBox(height: 10),
          _SignInMethodCard(
            title: 'Send secure invitation',
            description:
                'Send a verified, time-limited invite to the staff member\'s '
                'work email. They set their own password.',
            selected: draft.signInMethod == StaffSignInMethod.invite,
            onTap: () {
              draft.signInMethod = StaffSignInMethod.invite;
              controller.notifyDraftChanged();
            },
          ),
          const SizedBox(height: 10),
          _SignInMethodCard(
            title: 'Create profile without login',
            description:
                'Add the staff record now; an authorised administrator can '
                'invite them later.',
            selected: draft.signInMethod == StaffSignInMethod.noLogin,
            onTap: () {
              draft.signInMethod = StaffSignInMethod.noLogin;
              controller.notifyDraftChanged();
            },
          ),
          if (draft.signInMethod == StaffSignInMethod.invite) ...[
            const SizedBox(height: 20),
            _InvitationEmailPanel(draft: draft, controller: controller),
          ] else ...[
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
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Only the staff profile is created now. No Firebase '
                      'sign-in account exists until an authorised '
                      'administrator sends an invitation from this staff '
                      'member\'s profile.',
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
          const SizedBox(height: 20),
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
                  'Access is based on the roles selected in the previous '
                  'step and is rechecked before the invitation is sent.',
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
                Text(
                  'Roles from previous step',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: draft.selectedRoles
                      .map((r) => _Chip(label: UserRoleDisplay.name(r)))
                      .toList(),
                ),
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 18,
                      color: AppColors.textSecondary(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Standard staff access',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  hasScopedRoles
                      ? 'Scoped to the assigned campus, classes and subjects.'
                      : 'Can access classroom, attendance and assigned learners.',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                if (groupedPermissions.isNotEmpty) ...[
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
                        (label) => _AccessRow(
                          icon: Icons.check_circle,
                          iconColor: AppColors.success(context),
                          label: label,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (elevatedAreasGranted.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 2),
                    child: Text(
                      'Elevated access (role-approved)',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  ...elevatedAreasGranted.map(
                    (label) => _AccessRow(
                      icon: Icons.verified_outlined,
                      iconColor: AppColors.warning(context),
                      label: label,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 2),
                  child: Text(
                    'Restricted areas',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                ...restrictedAreas.map(
                  (label) => _AccessRow(
                    icon: Icons.remove_circle_outline,
                    iconColor: AppColors.textMuted(context),
                    label: label,
                  ),
                ),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () => _showPermissionDetail(context, entries),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Review permissions',
                        style: TextStyle(
                          color: AppColors.primary(context),
                          fontWeight: FontWeight.w700,
                          fontSize: 12.5,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 14,
                        color: AppColors.primary(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDetail(
    BuildContext context,
    List<AccessPreviewEntry> entries,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Permission detail',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: AppColors.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),
            for (final entry in entries) ...[
              Text(
                UserRoleDisplay.name(entry.role),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                entry.dashboardPath,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 11.5,
                ),
              ),
              const SizedBox(height: 6),
              ...entry.permissionLabels.map(
                (label) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
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
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _SignInMethodCard extends StatelessWidget {
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _SignInMethodCard({
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = selected
        ? AppColors.primary(context)
        : AppColors.border(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $description',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: borderColor, width: selected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(12),
            color: selected
                ? AppColors.primary(context).withValues(alpha: 0.06)
                : null,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2, right: 10),
                child: Icon(
                  selected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_off,
                  size: 20,
                  color: selected
                      ? AppColors.primary(context)
                      : AppColors.textMuted(context),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _maskEmail(String email) {
  final trimmed = email.trim();
  final at = trimmed.indexOf('@');
  if (at <= 1) return trimmed;
  final visible = trimmed.substring(0, 1);
  final domain = trimmed.substring(at);
  return '$visible${'*' * (at - 1)}$domain';
}

class _InvitationEmailPanel extends StatelessWidget {
  final AddStaffDraft draft;
  final AddStaffWizardController controller;

  const _InvitationEmailPanel({required this.draft, required this.controller});

  @override
  Widget build(BuildContext context) {
    final email = draft.invitationEmailOverride ?? draft.email;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Invitation will be sent to',
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  _maskEmail(email),
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showChangeEmailDialog(context),
                child: const Text('Change email'),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Invitation expires according to your school policy and can be resent.',
            style: TextStyle(
              color: AppColors.textMuted(context),
              fontSize: 11.5,
            ),
          ),
          if (controller.invitationStatus != null) ...[
            const SizedBox(height: 10),
            _StatusChip(status: controller.invitationStatus!),
          ],
        ],
      ),
    );
  }

  Future<void> _showChangeEmailDialog(BuildContext context) async {
    final textController = TextEditingController(
      text: draft.invitationEmailOverride ?? draft.email,
    );
    final newEmail = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change invitation email'),
        content: TextField(
          controller: textController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Work email'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(textController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newEmail == null || newEmail.isEmpty) return;
    // The server revalidates this email for duplicates/tenant match when
    // the invitation is actually issued (createStaffAccount/
    // createStaffInvitation) - this is only a client-side draft edit.
    draft.invitationEmailOverride = newEmail;
    controller.notifyDraftChanged();
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'sent' => ('Sent', AppColors.success(context)),
      'pending' => ('Pending', AppColors.warning(context)),
      'expired' => ('Expired', AppColors.error),
      'resent' => ('Resent', AppColors.success(context)),
      'accepted' => ('Accepted', AppColors.success(context)),
      'cancelled' => ('Cancelled', AppColors.textMuted(context)),
      'failed' => ('Failed', AppColors.error),
      _ => ('Ready', AppColors.textMuted(context)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11.5,
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;

  const _Chip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.5,
          color: AppColors.textPrimary(context),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _AccessRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;

  const _AccessRow({
    required this.icon,
    required this.iconColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 14, color: iconColor),
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
    );
  }
}

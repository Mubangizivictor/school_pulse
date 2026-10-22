import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/wizard_scaffold.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/admin/presentation/add_staff_wizard/widgets/staff_documents_uploader.dart';
import 'package:school_pulse/features/admin/presentation/pages/staff_detail_screen.dart';

import '../add_staff_wizard_controller.dart';
import '../models/add_staff_draft.dart';

/// Stage 5 - "Review & invite": final confirmation step of the 5-step Add
/// Staff flow. Desktop/tablet renders a two-column layout (left: tappable
/// review rows with Edit; right: a "Ready to create staff profile" panel);
/// mobile stacks the same content with fixed bottom actions via
/// WizardStageScaffold/WizardFooterButtons. A confirmation checkbox gates
/// submission in addition to the existing RBAC/validation gates already
/// enforced by controller.submit(). Submission states (loading/error/success)
/// reuse the existing controller.submit() contract unchanged.
class Stage05Review extends StatefulWidget {
  final VoidCallback onSaveDraft;

  const Stage05Review({super.key, required this.onSaveDraft});

  @override
  State<Stage05Review> createState() => _Stage05ReviewState();
}

class _Stage05ReviewState extends State<Stage05Review> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    if (controller.stage == WizardStage.success) {
      return const _SuccessScreen();
    }

    final draft = controller.draft;
    final authState = context.watch<AuthBloc>().state;
    final adminRoles = authState is AuthAuthenticated
        ? authState.user.roles
        : <UserRole>[];
    final canSubmit = AddStaffWizardController.canSubmit(adminRoles);
    final hasUploadsRemaining =
        draft.photo != null || draft.documents.isNotEmpty;

    final rows = _buildRows(controller, draft);

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.review),
      onBack: () => controller.back(),
      onSaveDraft: widget.onSaveDraft,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ConfirmationCheckbox(
            confirmed: _confirmed,
            onConfirmedChanged: (v) => setState(() => _confirmed = v),
          ),
          const SizedBox(height: 12),
          WizardFooterButtons(
            backLabel: 'Back',
            nextLabel: 'Create staff & send invitation',
            loading: controller.submitting,
            onNext: (canSubmit && _confirmed)
                ? () => _submit(context, controller)
                : null,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardStageHeading(
            title:
                'Ready to add ${draft.fullName.isEmpty ? 'this staff member' : draft.fullName}?',
            subtitle: 'Check the staff profile and access before creating it.',
          ),
          const SizedBox(height: 20),
          if (!canSubmit)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AlertBanner(
                title: 'You cannot finalize this yourself',
                message:
                    'Only Directors, Head Teachers, or School Admins can complete staff creation. Ask one of them to submit this.',
                color: AppColors.warning(context),
              ),
            ),
          if (controller.submitError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: AlertBanner(
                title: 'Failed to create staff account',
                message: controller.submitError!,
                color: AppColors.danger(context),
              ),
            ),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 760;
              final left = _ReviewSummaryCard(
                fullName: draft.fullName,
                photo: draft.photo,
                rows: rows,
                hasUploadsRemaining: hasUploadsRemaining,
              );
              final right = const _ReadyToCreatePanel();
              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [left, const SizedBox(height: 20), right],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: left),
                  const SizedBox(width: 20),
                  Expanded(flex: 2, child: right),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  List<_ReviewRowData> _buildRows(
    AddStaffWizardController controller,
    AddStaffDraft draft,
  ) {
    return [
      _ReviewRowData(
        icon: Icons.person_outline,
        title: 'Profile',
        subtitle: 'Name and contact details',
        summary: [
          draft.fullName,
          if (draft.email.isNotEmpty) draft.email,
          if (draft.phoneNumber.isNotEmpty) draft.phoneNumber,
        ].where((s) => s.isNotEmpty).join(' · '),
        status: draft.personalInfoComplete && draft.contactInfoComplete
            ? _RowStatus.complete
            : _RowStatus.incomplete,
        onEdit: () => controller.goToStage(WizardStage.profile),
      ),
      _ReviewRowData(
        icon: Icons.work_outline,
        title: 'Work details',
        subtitle: 'Campus, department and title',
        summary: [draft.employmentType].where((s) => s.isNotEmpty).join(' · '),
        status: draft.employmentInfoComplete
            ? _RowStatus.complete
            : _RowStatus.incomplete,
        onEdit: () => controller.goToStage(WizardStage.work),
      ),
      _ReviewRowData(
        icon: Icons.groups_outlined,
        title: 'Roles & responsibilities',
        subtitle: 'Selected roles and scope',
        summary: draft.selectedRoles.isEmpty
            ? 'No roles selected'
            : draft.selectedRoles.map(UserRoleDisplay.name).join(', ') +
                  (controller.rolesNeedingConfig.isNotEmpty
                      ? ' · scoped to assigned classes'
                      : ''),
        status: draft.rolesSelected
            ? _RowStatus.complete
            : _RowStatus.incomplete,
        onEdit: () => controller.goToStage(WizardStage.roles),
      ),
      _ReviewRowData(
        icon: Icons.lock_outline,
        title: 'Account access',
        subtitle: 'Send secure invitation',
        summary: draft.signInMethod == StaffSignInMethod.invite
            ? 'Secure invitation will be sent to ${draft.email.trim()}'
            : 'Profile only — no login until an admin sends an invitation',
        status: draft.signInMethod == StaffSignInMethod.invite
            ? _RowStatus.readyToInvite
            : _RowStatus.complete,
        onEdit: () => controller.goToStage(WizardStage.access),
      ),
      _ReviewRowData(
        icon: Icons.payments_outlined,
        title: 'Compensation',
        subtitle: 'Set up later (restricted to HR & Finance)',
        summary: draft.compensationSetUpNow
            ? '${draft.selectedPayComponentIds.length} optional allowance(s) selected'
            : 'Not set up yet — can be completed later by HR & Finance',
        status: _RowStatus.setUpLater,
        onEdit: () => controller.goToStage(WizardStage.work),
      ),
    ];
  }

  Future<void> _submit(
    BuildContext context,
    AddStaffWizardController controller,
  ) async {
    // Idempotent/retry-safe: draft.idempotencyKey is generated once (lazily,
    // inside controller.submit()) and reused across retries, so a duplicate
    // tap after a transient failure doesn't create a second account -
    // AuthRemoteDataSource/Cloud Function dedupe on it server-side.
    final result = await controller.submit();
    if (!context.mounted) return;
    if (result.isLeft()) {
      return; // error already surfaced via controller.submitError
    }

    // Account creation already succeeded at this point; any failure below
    // (audit log, photo/doc upload) must never be reported as if staff
    // creation itself failed.
    await controller.logAudit();
    if (controller.resultUid != null) {
      final uploader = StaffDocumentsUploader();
      final uid = controller.resultUid!;
      String? photoWarning;
      if (controller.draft.photo != null) {
        final ok = await uploader.uploadPhoto(
          schoolId: controller.schoolId,
          uid: uid,
          photo: controller.draft.photo!,
        );
        if (!ok) photoWarning = 'the profile photo failed to upload';
      }
      List<String> failedDocuments = const [];
      if (controller.draft.documents.isNotEmpty) {
        failedDocuments = await uploader.uploadAll(
          schoolId: controller.schoolId,
          uid: uid,
          documents: controller.draft.documents,
        );
      }
      if (context.mounted &&
          (photoWarning != null || failedDocuments.isNotEmpty)) {
        final parts = [
          ?photoWarning,
          if (failedDocuments.isNotEmpty)
            '${failedDocuments.length} document(s) failed to upload',
        ];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account created, but ${parts.join(' and ')}.'),
          ),
        );
      }
    }
    controller.next();
  }
}

enum _RowStatus { complete, incomplete, readyToInvite, setUpLater }

extension on _RowStatus {
  String label(String defaultCompleteLabel) => switch (this) {
    _RowStatus.complete => defaultCompleteLabel,
    _RowStatus.incomplete => 'Incomplete',
    _RowStatus.readyToInvite => 'Ready to invite',
    _RowStatus.setUpLater => 'Set up later',
  };

  IconData get icon => switch (this) {
    _RowStatus.complete => Icons.check_circle,
    _RowStatus.readyToInvite => Icons.check_circle,
    _RowStatus.incomplete => Icons.error_outline,
    _RowStatus.setUpLater => Icons.schedule,
  };

  Color color(BuildContext context) => switch (this) {
    _RowStatus.complete => AppColors.success(context),
    _RowStatus.readyToInvite => AppColors.success(context),
    _RowStatus.incomplete => AppColors.warning(context),
    _RowStatus.setUpLater => AppColors.textMuted(context),
  };
}

class _ReviewRowData {
  final IconData icon;
  final String title;
  final String subtitle;
  final String summary;
  final _RowStatus status;
  final VoidCallback onEdit;

  const _ReviewRowData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.summary,
    required this.status,
    required this.onEdit,
  });
}

/// Left column: identity header + the "Staff setup checklist" of compact
/// review rows (Profile, Work details, Roles & responsibilities, Account
/// access, Compensation), each with a status indicator and an Edit action.
class _ReviewSummaryCard extends StatelessWidget {
  final String fullName;
  final File? photo;
  final List<_ReviewRowData> rows;
  final bool hasUploadsRemaining;

  const _ReviewSummaryCard({
    required this.fullName,
    required this.photo,
    required this.rows,
    required this.hasUploadsRemaining,
  });

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    final first = parts.first[0];
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Review staff setup',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'All required information is complete.',
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceContainer(context),
                backgroundImage: photo != null ? FileImage(photo!) : null,
                child: photo == null
                    ? Text(
                        _initials(fullName),
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  fullName.isEmpty ? 'Unnamed staff' : fullName,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w700,
                    fontSize: 15.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...rows.map((r) => _ReviewRow(data: r)),
          if (hasUploadsRemaining) ...[
            const SizedBox(height: 10),
            Text(
              'Photo/documents upload after the account is created.',
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 11.5,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  final _ReviewRowData data;

  const _ReviewRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: data.onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border(context))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainer(context),
                shape: BoxShape.circle,
              ),
              child: Icon(
                data.icon,
                size: 18,
                color: AppColors.textSecondary(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                  if (data.summary.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      data.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.status.icon,
                      size: 14,
                      color: data.status.color(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data.status.label('Complete'),
                      style: TextStyle(
                        color: data.status.color(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Edit',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: AppColors.textMuted(context),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Right column: explains what happens on submit, plus the audit-log info
/// banner. The confirmation checkbox that gates "Create staff & send
/// invitation" lives in the wizard's fixed footer instead - see
/// [_ConfirmationCheckbox].
class _ReadyToCreatePanel extends StatelessWidget {
  const _ReadyToCreatePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ready to create staff profile',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.w700,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.person_outline,
            title: 'Staff profile will be created',
            detail: 'The staff member will be added to your school.',
          ),
          _InfoRow(
            icon: Icons.mail_outline,
            title: 'Secure invitation will be sent to verified work email',
            detail: 'They will receive an invitation to set up their account.',
          ),
          _InfoRow(
            icon: Icons.lock_outline,
            title: 'Staff member creates their own password',
            detail: 'They will choose a secure password on first sign-in.',
          ),
          _InfoRow(
            icon: Icons.shield_outlined,
            title: 'Access is limited to assigned role scope',
            detail:
                'They will only have access to the features you\'ve assigned.',
          ),
          _InfoRow(
            icon: Icons.payments_outlined,
            title: 'Compensation can be completed later',
            detail:
                'This can only be managed by authorised HR & Finance staff.',
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.information(context).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.information(context).withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppColors.information(context),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Creation and invitation are recorded in your school audit log.',
                    style: TextStyle(
                      color: AppColors.information(context),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
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

/// The final "I have reviewed..." confirmation gate for staff creation.
///
/// Deliberately rendered in the wizard's fixed footer (above the action
/// buttons) rather than inside the scrollable review body: on some
/// combinations of review content and viewport height the body's
/// SingleChildScrollView did not respond to scroll gestures in practice,
/// permanently hiding this checkbox and the primary action beneath it below
/// the visible area with no way to reach either. Keeping it in the
/// always-visible footer guarantees it can never become unreachable
/// regardless of how tall the review content grows.
class _ConfirmationCheckbox extends StatelessWidget {
  final bool confirmed;
  final ValueChanged<bool> onConfirmedChanged;

  const _ConfirmationCheckbox({
    required this.confirmed,
    required this.onConfirmedChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onConfirmedChanged(!confirmed),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: confirmed,
            onChanged: (v) => onConfirmedChanged(v ?? false),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'I have reviewed the setup above',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'You must confirm before creating the staff profile.',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 16,
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
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
    );
  }
}

class _SuccessScreen extends StatelessWidget {
  const _SuccessScreen();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: AppColors.success(context),
                size: 88,
              ),
              const SizedBox(height: 20),
              Text(
                'Staff profile created',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                draft.fullName,
                style: TextStyle(color: AppColors.textMuted(context)),
              ),
              const SizedBox(height: 24),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Staff Code',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      controller.resultStaffCode ?? '—',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Account setup',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      draft.signInMethod == StaffSignInMethod.invite
                          ? 'A secure invitation has been sent to ${draft.email.trim()}. '
                                'The staff member will set their own password to sign in.'
                          : 'No login has been set up. An administrator can send a '
                                'sign-in invitation from this staff member\'s profile at any time.',
                      style: TextStyle(color: AppColors.textPrimary(context)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'View staff profile',
                  onPressed: controller.resultUid == null
                      ? null
                      : () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  StaffDetailScreen(uid: controller.resultUid!),
                            ),
                          );
                        },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: SecondaryButton(
                  label: 'Add another staff',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => context.go('/staff/admin/users'),
                child: Text(
                  'Return to Staff',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

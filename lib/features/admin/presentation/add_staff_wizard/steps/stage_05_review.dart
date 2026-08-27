import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

/// Stage 5 - Review: "Ready to add [Staff Name]?" Compact identity header,
/// tappable grouped review rows (Personal / Work / Roles & scope / Pay /
/// Account access) each with Edit, then Create staff account with an
/// accurate confirmation line. Submission states (loading/error/success)
/// reuse the existing controller.submit() contract unchanged.
class Stage05Review extends StatelessWidget {
  final VoidCallback onSaveDraft;

  const Stage05Review({super.key, required this.onSaveDraft});

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

    return WizardStageScaffold(
      title: 'Add staff',
      stageLabels: kWizardStageLabels,
      currentStageIndex: stageIndexFor(WizardStage.review),
      onBack: () => controller.back(),
      onSaveDraft: onSaveDraft,
      footer: WizardFooterButtons(
        backLabel: 'Back',
        nextLabel: 'Create staff account',
        loading: controller.submitting,
        onNext: canSubmit ? () => _submit(context, controller) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WizardStageHeading(
            title:
                'Ready to add ${draft.fullName.isEmpty ? 'this staff member' : draft.fullName}?',
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
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.surfaceContainer(context),
                backgroundImage: draft.photo != null
                    ? FileImage(draft.photo!)
                    : null,
                child: draft.photo == null
                    ? Text(
                        _initials(draft.fullName),
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontWeight: FontWeight.w700,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      draft.fullName.isEmpty ? 'Unnamed staff' : draft.fullName,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w700,
                        fontSize: 15.5,
                      ),
                    ),
                    if (draft.designation.isNotEmpty)
                      Text(
                        draft.designation,
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 12.5,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _ReviewRow(
            icon: Icons.person_outline,
            title: 'Personal',
            summary: [
              draft.fullName,
              if (draft.email.isNotEmpty) draft.email,
              if (draft.phoneNumber.isNotEmpty) draft.phoneNumber,
            ].where((s) => s.isNotEmpty).join(' · '),
            onEdit: () => controller.goToStage(WizardStage.profile),
          ),
          _ReviewRow(
            icon: Icons.work_outline,
            title: 'Work',
            summary: [
              if (draft.designation.isNotEmpty) draft.designation,
              if (draft.department.isNotEmpty) draft.department,
              draft.employmentType,
            ].where((s) => s.isNotEmpty).join(' · '),
            onEdit: () => controller.goToStage(WizardStage.work),
          ),
          _ReviewRow(
            icon: Icons.groups_outlined,
            title: 'Roles & scope',
            summary: draft.selectedRoles.isEmpty
                ? 'No roles selected'
                : draft.selectedRoles.map(UserRoleDisplay.name).join(', ') +
                      (controller.rolesNeedingConfig.isNotEmpty
                          ? ' · scoped to assigned classes'
                          : ''),
            onEdit: () {
              controller.goToStage(WizardStage.roles);
            },
          ),
          _ReviewRow(
            icon: Icons.payments_outlined,
            title: 'Pay',
            summary: draft.selectedPayComponentIds.isEmpty
                ? 'Standard pay structure'
                : '${draft.selectedPayComponentIds.length} optional allowance(s) selected',
            onEdit: () => controller.goToStage(WizardStage.work),
          ),
          _ReviewRow(
            icon: Icons.lock_outline,
            title: 'Account access',
            summary: [
              draft.sendLoginDetailsViaEmail
                  ? 'Secure setup link will be sent'
                  : 'No setup email will be sent',
              draft.forcePasswordChange
                  ? 'password update required'
                  : 'no forced password update',
            ].join(' · '),
            onEdit: () => controller.goToStage(WizardStage.access),
          ),
          const SizedBox(height: 20),
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
                    draft.sendLoginDetailsViaEmail
                        ? 'A secure setup email will be sent.'
                        : 'No setup email will be sent.',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  String _initials(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '';
    final first = parts.first[0];
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return (first + last).toUpperCase();
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

class _ReviewRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String summary;
  final VoidCallback onEdit;

  const _ReviewRow({
    required this.icon,
    required this.title,
    required this.summary,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    if (summary.trim().isEmpty) return const SizedBox.shrink();
    return InkWell(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border(context))),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary(context)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    summary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Row(
              children: [
                Text(
                  'Edit',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.textMuted(context),
                ),
              ],
            ),
          ],
        ),
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
                draft.fullName,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'has been added successfully',
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
                      draft.sendLoginDetailsViaEmail
                          ? 'A secure password-setup link has been sent. No password is displayed or emailed.'
                          : 'No setup email was sent, as selected. No password is displayed or emailed.',
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
                  label: 'Add another staff member',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

import '../add_staff_wizard_controller.dart';

class Step11ReviewConfirm extends StatelessWidget {
  final String? currentAcademicYearId;
  const Step11ReviewConfirm({super.key, this.currentAcademicYearId});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<AddStaffWizardController>();
    final draft = controller.draft;
    final authState = context.watch<AuthBloc>().state;
    final adminRoles = authState is AuthAuthenticated
        ? authState.user.roles
        : <UserRole>[];
    final canSubmit = AddStaffWizardController.canSubmit(adminRoles);

    return WizardScaffold(
      title: 'Add Staff Member',
      currentStep: stepNumberFor(WizardStep.reviewConfirm),
      totalSteps: kWizardTotalSteps,
      onBack: () => controller.back(),
      footer: WizardFooterButtons(
        onBack: () => controller.back(),
        nextLabel: 'Confirm & Add Staff',
        loading: controller.submitting,
        onNext: canSubmit ? () => _submit(context, controller) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WizardStepCaption(
            number: 10,
            title: 'Review & Confirm',
            subtitle: 'Please review all details before adding',
          ),
          const SizedBox(height: 16),
          if (!canSubmit)
            AlertBanner(
              title: 'You cannot finalize this yourself',
              message:
                  'Only Directors, Head Teachers, or School Admins can complete staff creation. Ask one of them to submit this.',
              color: AppColors.warning(context),
            ),
          if (controller.submitError != null)
            AlertBanner(
              title: 'Failed to create staff account',
              message: controller.submitError!,
              color: AppColors.danger(context),
            ),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personal Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  draft.fullName,
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                Text(
                  draft.email,
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                Text(
                  draft.phoneNumber,
                  style: TextStyle(color: AppColors.textSecondary(context)),
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
                  'Employment Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  draft.designation,
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                Text(
                  draft.department,
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: draft.selectedRoles
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
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Login Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Email: ${draft.email}',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
                Text(
                  'Temporary password generated on creation',
                  style: TextStyle(color: AppColors.textSecondary(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(
    BuildContext context,
    AddStaffWizardController controller,
  ) async {
    final result = await controller.submit();
    if (!context.mounted) return;
    if (result.isLeft()) {
      return; // error already surfaced via controller.submitError
    }

    await controller.logAudit();
    if (controller.resultUid != null) {
      final uploader = StaffDocumentsUploader();
      final uid = controller.resultUid!;
      String? photoWarning;
      if (controller.draft.photo != null) {
        final ok = await uploader.uploadPhoto(
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
      if (context.mounted && (photoWarning != null || failedDocuments.isNotEmpty)) {
        final parts = [
          if (photoWarning != null) photoWarning,
          if (failedDocuments.isNotEmpty)
            '${failedDocuments.length} document(s) failed to upload',
        ];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account created, but ${parts.join(' and ')}.')),
        );
      }
    }
    controller.next();
  }
}

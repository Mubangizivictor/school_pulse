import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

import '../add_staff_wizard_controller.dart';
import '../../pages/staff_detail_screen.dart';

class Step12Success extends StatelessWidget {
  const Step12Success({super.key});

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
                      'A secure password-setup link is sent only when selected. No password is displayed or emailed.',
                      style: TextStyle(color: AppColors.textPrimary(context)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Password setup and first-login requirements follow the options selected during enrolment.',
                      style: TextStyle(
                        color: AppColors.textMuted(context),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  label: 'View Staff Profile',
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
                  label: 'Add Another Staff',
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

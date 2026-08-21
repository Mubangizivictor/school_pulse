import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

/// Student leave requests (a parent asking to take a day-scholar out early,
/// for example) have no backing entity or repository yet - only boarding
/// leave (Matron/Patron) and staff leave (HR) are built. This is an honest
/// "not yet available" state, not fabricated request data.
class TeacherStudentLeaveApplicationsScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentLeaveApplicationsScreen({
    super.key,
    required this.studentId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Leave Applications',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.exit_to_app_outlined,
                size: 40,
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
              const SizedBox(height: AppSpacing.l),
              Text(
                'Leave applications are not available yet',
                textAlign: TextAlign.center,
                style: AppTypography.titleMedium.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppSpacing.s),
              Text(
                'This feature is coming soon. For now, leave arrangements '
                'go through the school office directly.',
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

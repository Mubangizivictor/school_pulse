import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';

/// What a Class Teacher is allowed to see is the alert flag the roster
/// already carries - clinical detail (allergies, medication, conditions) is
/// the Health module's own record, gated to nurse/health-staff roles, not
/// duplicated here.
class TeacherStudentHealthInfoScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentHealthInfoScreen({super.key, required this.studentId});

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
          'Health Information',
          style: AppTypography.headlineSmall.copyWith(
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
        ),
      ),
      body: BlocBuilder<ClassStudentsBloc, ClassStudentsState>(
        builder: (context, state) {
          final student = state.students
              .where((s) => s.studentId == studentId)
              .firstOrNull;

          if (state.isLoading && student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final hasAlert = student?.hasHealthAlert ?? false;

          return Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: (hasAlert ? AppColors.errorRed : AppColors.successGreen)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppSpacing.l),
                    border: Border.all(
                      color: hasAlert
                          ? AppColors.errorRed
                          : AppColors.successGreen,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        hasAlert
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline,
                        color: hasAlert
                            ? AppColors.errorRed
                            : AppColors.successGreen,
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Expanded(
                        child: Text(
                          hasAlert
                              ? 'This student has an active health alert on '
                                    'file with the school nurse.'
                              : 'No health alerts on file for this student.',
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Class Teachers see only whether an alert exists. Clinical '
                  'detail - allergies, medication, conditions - is kept with '
                  'the school nurse for privacy. Contact the clinic if you '
                  'need to know how to respond to this student\'s alert.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark
                        ? AppColors.textMutedDark
                        : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

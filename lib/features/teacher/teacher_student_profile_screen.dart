import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson_attendance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';

class TeacherStudentProfileScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentProfileScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Student Profile',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_horiz, color: AppColors.textPrimary(context)),
            onPressed: () => context.push('/staff/students/$studentId/more-options'),
          ),
        ],
      ),
      body: BlocBuilder<ClassStudentsBloc, ClassStudentsState>(
        builder: (context, state) {
          final student = state.students
              .where((s) => s.studentId == studentId)
              .firstOrNull;

          if (state.isLoading && student == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (student == null) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Center(
                child: Text(
                  'This student is not on your class roster.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
            );
          }

          final status = state.statusOf(student.studentId);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary(
                          context,
                        ).withValues(alpha: 0.1),
                        backgroundImage: (student.photoUrl?.isNotEmpty ?? false)
                            ? NetworkImage(student.photoUrl!)
                            : null,
                        child: (student.photoUrl?.isNotEmpty ?? false)
                            ? null
                            : Text(
                                student.initials,
                                style: AppTypography.headlineLarge.copyWith(
                                  color: AppColors.primary(context),
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.l),
                      Text(
                        student.name,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admission No: ${student.admissionNumber}',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textMuted(context),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.m,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor(
                                context,
                                status,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppSpacing.s),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: _statusColor(context, status),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  status.label,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: _statusColor(context, status),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x3l),
                _buildProfileTabs(context),
                const SizedBox(height: AppSpacing.xl),
                _buildPersonalInfo(context, student),
                const SizedBox(height: AppSpacing.x3l),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        context.push('/staff/students/$studentId/communications'),
                    icon: const Icon(
                      Icons.chat_bubble_outline,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Message Parent',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.l,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.m),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileTabs(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ProfileTabItem(icon: Icons.person, label: 'Profile', isSelected: true),
        _ProfileTabItem(
          icon: Icons.calendar_today,
          label: 'Attendance',
          onTap: () => context.push('/staff/students/$studentId/attendance'),
        ),
        _ProfileTabItem(
          icon: Icons.analytics_outlined,
          label: 'Performance',
          onTap: () => context.push('/staff/students/$studentId/performance'),
        ),
        _ProfileTabItem(
          icon: Icons.gavel,
          label: 'Behaviour',
          onTap: () => context.push('/staff/students/$studentId/behaviour'),
        ),
        _ProfileTabItem(
          icon: Icons.grid_view,
          label: 'More',
          onTap: () => context.push('/staff/students/$studentId/more-options'),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo(BuildContext context, ClassStudentSummary student) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.l),
        _InfoRow(label: 'Class', value: student.className),
        if (student.streamName != null)
          _InfoRow(label: 'Stream', value: student.streamName!),
        if (student.gender != null)
          _InfoRow(label: 'Gender', value: student.gender!),
        _InfoRow(
          label: 'Residency',
          value: student.residency == ResidencyType.boarding
              ? 'Boarding'
              : student.residency == ResidencyType.day
              ? 'Day'
              : 'Not recorded',
        ),
        if (student.houseName != null)
          _InfoRow(label: 'House', value: student.houseName!),
        if (student.hasHealthAlert)
          _InfoRow(label: 'Health', value: 'Has an active alert'),
      ],
    );
  }

  static Color _statusColor(
    BuildContext context,
    LessonAttendanceStatus status,
  ) {
    if (status == LessonAttendanceStatus.notMarked) {
      return AppColors.textMuted(context);
    }
    if (status.countsAsPresent) return AppColors.success(context);
    if (status.isAuthorisedAbsence) return AppColors.warning(context);
    return AppColors.danger(context);
  }
}

class _ProfileTabItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const _ProfileTabItem({
    required this.icon,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary(context)
                  : AppColors.surfaceElevated(context),
              borderRadius: BorderRadius.circular(AppSpacing.m),
              border: isSelected
                  ? null
                  : Border.all(color: AppColors.border(context)),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textMuted(context),
              size: 20,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: isSelected
                  ? AppColors.primary(context)
                  : AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

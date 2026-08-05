import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';

class TeacherStudentProfileScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentProfileScreen({super.key, required this.studentId});

  @override
  State<TeacherStudentProfileScreen> createState() =>
      _TeacherStudentProfileScreenState();
}

class _TeacherStudentProfileScreenState
    extends State<TeacherStudentProfileScreen> {
  final Student student = Student(
    id: 'student_1',
    schoolId: 'school_1',
    name: 'Abalo Peter',
    admissionNumber: '2021/PE/015',
    studentCode: 'STU001',
    dateOfBirth: DateTime(2014, 5, 12),
    gender: Gender.male,
    classId: 'P.4 Blue',
    academicYearId: '2024',
    status: StudentStatus.active,
    level: EducationLevel.primary,
  );

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
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=1',
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
                          color: AppColors.success(
                            context,
                          ).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppSpacing.s),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 8,
                              color: AppColors.success(context),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Present',
                              style: AppTypography.labelMedium.copyWith(
                                color: AppColors.success(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.m),
                      Text(
                        'Age: 10 yrs',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),
            _buildProfileTabs(),
            const SizedBox(height: AppSpacing.xl),
            _buildPersonalInfo(),
            const SizedBox(height: AppSpacing.x3l),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
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
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSpacing.m),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ProfileTabItem(icon: Icons.person, label: 'Profile', isSelected: true),
        _ProfileTabItem(
          icon: Icons.calendar_today,
          label: 'Attendance',
          onTap: () =>
              context.push('/staff/students/${widget.studentId}/attendance'),
        ),
        _ProfileTabItem(
          icon: Icons.analytics_outlined,
          label: 'Performance',
          onTap: () =>
              context.push('/staff/students/${widget.studentId}/performance'),
        ),
        _ProfileTabItem(
          icon: Icons.gavel,
          label: 'Behaviour',
          onTap: () =>
              context.push('/staff/students/${widget.studentId}/behaviour'),
        ),
        _ProfileTabItem(
          icon: Icons.grid_view,
          label: 'More',
          onTap: () =>
              context.push('/staff/students/${widget.studentId}/more-options'),
        ),
      ],
    );
  }

  Widget _buildPersonalInfo() {
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
        _InfoRow(label: 'Date of Birth', value: '12 May 2014'),
        _InfoRow(label: 'Gender', value: 'Male'),
        _InfoRow(label: 'Phone (Parent)', value: '+256 700 123456'),
        _InfoRow(label: 'Address', value: 'Gulu, Uganda'),
        _InfoRow(label: 'House', value: 'Blue House'),
        _InfoRow(label: 'Blood Group', value: 'O+'),
      ],
    );
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

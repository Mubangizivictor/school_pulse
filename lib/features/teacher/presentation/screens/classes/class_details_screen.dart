import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';

class ClassDetailsScreen extends StatelessWidget {
  final String classId;
  const ClassDetailsScreen({super.key, required this.classId});

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
          'Class Details',
          style: AppTypography.headlineSmall.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildClassHeader(context),
            const SizedBox(height: AppSpacing.xl),
            _buildTabs(context),
            const SizedBox(height: AppSpacing.xl),
            Text(
              'Class Overview',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    '32',
                    'Total Students',
                    AppColors.primary(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '30',
                    'Present Today',
                    AppColors.success(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: _buildStatCard(
                    context,
                    '2',
                    'Absent Today',
                    AppColors.danger(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            PulseCard(
              child: Column(
                children: [
                  _buildTeacherInfo(context),
                  const Divider(height: AppSpacing.x3l),
                  _buildDetailRow(context, 'Room', 'Room 12'),
                  _buildDetailRow(context, 'Stream / Section', 'East'),
                  _buildDetailRow(
                    context,
                    'Subjects Taught',
                    'Mathematics, Social Studies',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Class Timetable',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.push('/staff/classes/$classId/timetable'),
                  child: Text(
                    'View Timetable',
                    style: TextStyle(color: AppColors.primary(context)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary(context),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.m),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppSpacing.m),
            ),
            child: const Icon(Icons.groups, color: Colors.white, size: 32),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'P5 East',
                  style: AppTypography.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Primary Five • 2024',
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Text(
                  '32 Students • 18 Boys, 14 Girls',
                  style: AppTypography.bodySmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.m,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: AppColors.success(context),
              borderRadius: BorderRadius.circular(AppSpacing.s),
            ),
            child: Text(
              'Active',
              style: AppTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabItem(context, 'Overview', true, () {}),
          _buildTabItem(
            context,
            'Students',
            false,
            () => context.push('/staff/classes/$classId/students'),
          ),
          _buildTabItem(
            context,
            'Attendance',
            false,
            () => context.push('/staff/classes/$classId/attendance'),
          ),
          _buildTabItem(
            context,
            'Performance',
            false,
            () => context.push('/staff/classes/$classId/performance'),
          ),
          _buildTabItem(
            context,
            'More',
            false,
            () => context.push('/staff/classes/$classId/more'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: AppSpacing.m),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.l,
          vertical: AppSpacing.s,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.m),
          border: isSelected
              ? null
              : Border.all(color: AppColors.border(context)),
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected ? Colors.white : AppColors.textSecondary(context),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String value,
    String label,
    Color color,
  ) {
    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        children: [
          Text(
            value,
            style: AppTypography.headlineSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherInfo(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=teacher'),
        ),
        const SizedBox(width: AppSpacing.m),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Class Teacher',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textMuted(context),
                ),
              ),
              Text(
                'Mrs. Achieng Mary',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
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

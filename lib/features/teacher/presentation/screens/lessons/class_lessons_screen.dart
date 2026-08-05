import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';

class ClassLessonsScreen extends StatelessWidget {
  final String classId;
  const ClassLessonsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.surfaceElevated(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        title: Column(
          children: [
            Text(
              'Grade 10A (Science)',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Mathematics • Section A',
              style: TextStyle(
                color: AppColors.textSecondary(context),
                fontSize: 12,
              ),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border(context).withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildTab(context, 'Lessons', true),
                const SizedBox(width: 12),
                _buildTab(
                  context,
                  'Notes',
                  false,
                  () => context.push('/staff/lessons/notes/123'),
                ),
                const SizedBox(width: 12),
                _buildTab(
                  context,
                  'Resources',
                  false,
                  () => context.push('/staff/lessons/resources/123'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                Text(
                  'This Week',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimelineItem(
                  context,
                  'Mon, 20 May 2025',
                  '10:00 AM - 10:45 AM',
                  'Linear Equations',
                  'Completed',
                  AppColors.success(context),
                ),
                _buildTimelineItem(
                  context,
                  'Tue, 21 May 2025',
                  '10:00 AM - 10:45 AM',
                  'Quadratic Equations',
                  'Scheduled',
                  AppColors.primary(context),
                ),
                _buildTimelineItem(
                  context,
                  'Wed, 22 May 2025',
                  '10:00 AM - 10:45 AM',
                  'Inequalities',
                  'Scheduled',
                  AppColors.primary(context),
                ),
                const SizedBox(height: 24),
                Text(
                  'Next Week',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildTimelineItem(
                  context,
                  'Mon, 27 May 2025',
                  '10:00 AM - 10:45 AM',
                  'Functions',
                  'Scheduled',
                  AppColors.primary(context),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary(context),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTab(
    BuildContext context,
    String label,
    bool isActive, [
    VoidCallback? onTap,
  ]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary(context) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isActive
              ? null
              : Border.all(color: AppColors.border(context)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary(context),
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    BuildContext context,
    String date,
    String time,
    String title,
    String status,
    Color statusColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          AppCard(
            onTap: () => context.push('/staff/lessons/details/123'),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          color: AppColors.textSecondary(context),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        title,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(label: status, color: statusColor),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: AppColors.textMuted(context),
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

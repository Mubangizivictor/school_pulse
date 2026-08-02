import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class MarksDashboardScreen extends StatelessWidget {
  const MarksDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildClassSelector(context),
              const SizedBox(height: 16),
              _buildSubjectCard(context, theme),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent Assessments',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/staff/marks/history'),
                    child: Text('View All', style: TextStyle(color: AppColors.primary(context))),
                  ),
                ],
              ),
              _buildRecentAssessments(context),
              const SizedBox(height: 100), // Bottom nav space
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const AvatarInitials(name: 'MJ', size: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Good Afternoon,',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
              ),
              Text(
                'Mr. Okot John',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Subject Teacher • Mathematics',
                style: TextStyle(color: AppColors.primary(context), fontSize: 12),
              ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.chat_bubble_outline, color: AppColors.textPrimary(context)),
          onPressed: () {},
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.notifications_none, color: AppColors.textPrimary(context)),
              onPressed: () {},
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: AppColors.danger(context), shape: BoxShape.circle),
                child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text('Class: ', style: TextStyle(color: AppColors.textSecondary(context))),
              Text(
                'Grade 10A (Science)',
                style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Icon(Icons.keyboard_arrow_down, color: AppColors.textPrimary(context)),
        ],
      ),
    );
  }

  Widget _buildSubjectCard(BuildContext context, ThemeData theme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
              ? [const Color(0xFF1E1B4B), AppColors.surfaceElevated(context)]
              : [AppColors.primary(context).withValues(alpha: 0.1), AppColors.surfaceElevated(context)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.functions, color: AppColors.primary(context), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mathematics',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Term 2, 2024/2025',
                      style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMetric(context, '5', 'Assessments'),
              _buildMetric(context, '18', 'Marks Entered'),
              _buildMetric(context, '84%', 'Average Score', valueColor: AppColors.goldenYellow),
              _buildMetric(context, '2', 'Pending', valueColor: AppColors.deepOrange),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(BuildContext context, String value, String label, {Color? valueColor}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? AppColors.textPrimary(context),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: AppColors.textMuted(context), fontSize: 10)),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(context, 'Enter Marks', Icons.edit_note, '/staff/marks/select-assessment'),
        const SizedBox(width: 12),
        _buildActionItem(context, 'Import Marks', Icons.file_upload_outlined, '/staff/marks/import'),
        const SizedBox(width: 12),
        _buildActionItem(context, 'Mark Analytics', Icons.bar_chart, '/staff/marks/analytics'),
      ],
    );
  }

  Widget _buildActionItem(BuildContext context, String label, IconData icon, String route) {
    return Expanded(
      child: InkWell(
        onTap: () => context.push(route),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary(context)),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentAssessments(BuildContext context) {
    return Column(
      children: [
        _buildAssessmentItem(context, 'Mid Term Test', 'Test', 'Completed', AppColors.success(context)),
        _buildAssessmentItem(context, 'Assignment 2', 'Assignment', 'Pending', AppColors.warning(context)),
        _buildAssessmentItem(context, 'Quiz 1', 'Quiz', 'Completed', AppColors.success(context)),
      ],
    );
  }

  Widget _buildAssessmentItem(BuildContext context, String title, String type, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold),
                ),
                Text(
                  type,
                  style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right, color: AppColors.textMuted(context), size: 16),
        ],
      ),
    );
  }
}

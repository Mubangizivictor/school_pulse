import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherReportsScreen extends StatelessWidget {
  const TeacherReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ReportCategoryTile(
            icon: Icons.analytics_outlined,
            iconColor: Colors.orange,
            title: 'Class Performance Reports',
            subtitle: 'View and generate class reports',
            onTap: () {},
          ),
          _ReportCategoryTile(
            icon: Icons.assessment_outlined,
            iconColor: Colors.blue,
            title: 'Assessment Reports',
            subtitle: 'Workload analysis and analysis',
            onTap: () {},
          ),
          _ReportCategoryTile(
            icon: Icons.fact_check_outlined,
            iconColor: Colors.green,
            title: 'Attendance Reports',
            subtitle: 'View attendance statistics',
            onTap: () {},
          ),
          _ReportCategoryTile(
            icon: Icons.menu_book_outlined,
            iconColor: Colors.deepOrange,
            title: 'Subject Reports',
            subtitle: 'Detailed reports by subject',
            onTap: () {},
          ),
          _ReportCategoryTile(
            icon: Icons.psychology_outlined,
            iconColor: Colors.purple,
            title: 'Behaviour Reports',
            subtitle: 'View behaviour and remarks',
            onTap: () {},
          ),
          _ReportCategoryTile(
            icon: Icons.dashboard_customize_outlined,
            iconColor: Colors.indigo,
            title: 'Custom Reports',
            subtitle: 'Create custom reports',
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _ReportCategoryTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ReportCategoryTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary(context),
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
      ),
    );
  }
}

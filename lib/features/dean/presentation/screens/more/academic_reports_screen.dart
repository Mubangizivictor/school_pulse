import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class _ReportType {
  final String name;
  final String description;
  final IconData icon;

  const _ReportType(this.name, this.description, this.icon);
}

class AcademicReportsScreen extends StatelessWidget {
  const AcademicReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const reports = [
      _ReportType(
        'School Performance',
        'Whole-school average, pass rate, grade distribution',
        Icons.insights_outlined,
      ),
      _ReportType(
        'Class Performance',
        'Per-class averages and comparison',
        Icons.bar_chart_outlined,
      ),
      _ReportType(
        'Subject Performance',
        'Per-subject pass rates and trends',
        Icons.menu_book_outlined,
      ),
      _ReportType(
        'Teacher Workload',
        'Periods/week, lessons delivered, missed lessons',
        Icons.assignment_ind_outlined,
      ),
      _ReportType(
        'Curriculum Coverage',
        'Coverage % by subject and class',
        Icons.fact_check_outlined,
      ),
      _ReportType(
        'Marks Completion',
        'Entry completion by class and subject',
        Icons.grading_outlined,
      ),
      _ReportType(
        'At-Risk Learners',
        'Students flagged for academic risk',
        Icons.warning_amber_outlined,
      ),
      _ReportType(
        'Intervention Outcomes',
        'Before/after comparison for active interventions',
        Icons.psychology_outlined,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Academic Reports')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: reports.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
        itemBuilder: (context, index) {
          final report = reports[index];
          return AppCard(
            onTap: () => _showExportSheet(context, report.name),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context).withValues(alpha: 0.12),
                    borderRadius: AppRadius.medium,
                  ),
                  child: Icon(report.icon, color: AppColors.primary(context)),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.name,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        report.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showExportSheet(BuildContext context, String reportName) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SectionHeader(title: reportName),
            const SizedBox(height: AppSpacing.l),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf_outlined),
              title: const Text('Export as PDF'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.table_chart_outlined),
              title: const Text('Export as Excel'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: const Text('Export as CSV'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: AppSpacing.l),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

enum _SchemeStatus { draft, submitted, hodReview, approved, inProgress }

extension on _SchemeStatus {
  String get label => switch (this) {
    _SchemeStatus.draft => 'Draft',
    _SchemeStatus.submitted => 'Submitted',
    _SchemeStatus.hodReview => 'HOD Review',
    _SchemeStatus.approved => 'Approved',
    _SchemeStatus.inProgress => 'In Progress',
  };

  Color color(BuildContext context) => switch (this) {
    _SchemeStatus.draft => AppColors.textMuted(context),
    _SchemeStatus.submitted => AppColors.information(context),
    _SchemeStatus.hodReview => AppColors.warning(context),
    _SchemeStatus.approved => AppColors.success(context),
    _SchemeStatus.inProgress => AppColors.primary(context),
  };
}

class _Scheme {
  final String subject;
  final String className;
  final String teacher;
  final _SchemeStatus status;
  final double weeksCovered;
  final double weeksTotal;

  const _Scheme(
    this.subject,
    this.className,
    this.teacher,
    this.status,
    this.weeksCovered,
    this.weeksTotal,
  );
}

class SchemesOfWorkScreen extends StatelessWidget {
  const SchemesOfWorkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const schemes = [
      _Scheme(
        'Mathematics',
        'S2A',
        'Mr. Ssemanda',
        _SchemeStatus.inProgress,
        6,
        12,
      ),
      _Scheme('English', 'S3B', 'Ms. Nakato', _SchemeStatus.approved, 9, 12),
      _Scheme('Biology', 'S2B', 'Ms. Achieng', _SchemeStatus.hodReview, 5, 12),
      _Scheme('History', 'S1A', 'Mr. Kato', _SchemeStatus.submitted, 3, 12),
      _Scheme('Physics', 'S4A', 'Mr. Ogwang', _SchemeStatus.draft, 1, 12),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Schemes of Work')),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: schemes.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
        itemBuilder: (context, index) {
          final scheme = schemes[index];
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${scheme.subject} • ${scheme.className}',
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.textPrimary(context),
                            ),
                          ),
                          Text(
                            scheme.teacher,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    StatusBadge(
                      label: scheme.status.label,
                      color: scheme.status.color(context),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.l),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: scheme.weeksCovered / scheme.weeksTotal,
                    minHeight: 6,
                    backgroundColor: AppColors.border(context),
                    color: scheme.status.color(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  '${scheme.weeksCovered.toStringAsFixed(0)}/${scheme.weeksTotal.toStringAsFixed(0)} weeks planned',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted(context),
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

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';

class ReportsDashboardScreen extends StatelessWidget {
  const ReportsDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Report Making'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          Text(
            'Generate and manage academic reports',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textMuted(context),
            ),
          ),
          const SizedBox(height: AppSpacing.x3l),
          PulseCard(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.description_rounded,
                  color: AppColors.royalBlue,
                  size: 32,
                ),
                const SizedBox(height: AppSpacing.m),
                Text('Class Reports', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Complete termly reports for your assigned class',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          PulseCard(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.subject_rounded,
                  color: AppColors.successGreen,
                  size: 32,
                ),
                const SizedBox(height: AppSpacing.m),
                Text('Subject Reports', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Enter comments and grades for specific subjects',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          PulseCard(
            onTap: () {},
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.analytics_rounded,
                  color: AppColors.electricBlue,
                  size: 32,
                ),
                const SizedBox(height: AppSpacing.m),
                Text('Performance Analytics', style: AppTypography.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'View grade distribution and trends',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

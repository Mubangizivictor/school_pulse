import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class MarksAnalyticsScreen extends StatelessWidget {
  const MarksAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Performance Analytics',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCard(context),
            const SizedBox(height: 24),
            Text(
              'Grade Distribution',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildGradeDistribution(context),
            const SizedBox(height: 24),
            Text(
              'Top Performing Students',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTopStudents(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat(
                context,
                'Avg Score',
                '78%',
                AppColors.primary(context),
              ),
              _buildStat(
                context,
                'Pass Rate',
                '92%',
                AppColors.success(context),
              ),
              _buildStat(
                context,
                'Highest',
                '98%',
                AppColors.secondary(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: AppColors.border(context).withValues(alpha: 0.5)),
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(
                Icons.trending_up,
                color: AppColors.success(context),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance improved by 4.2% since last term',
                style: TextStyle(
                  color: AppColors.textSecondary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStat(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary(context),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGradeDistribution(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      height: 200,
      child: Center(
        child: Text(
          '[Chart: Distribution of Grades A-F]',
          style: TextStyle(color: AppColors.textSecondary(context)),
        ),
      ),
    );
  }

  Widget _buildTopStudents(BuildContext context) {
    return Column(
      children: List.generate(5, (index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border(context).withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary(
                  context,
                ).withValues(alpha: 0.1),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(color: AppColors.primary(context)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Student Name',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Grade 10A',
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${98 - index * 2}%',
                style: TextStyle(
                  color: AppColors.success(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

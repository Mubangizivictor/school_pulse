import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class StudentMarksDetailScreen extends StatelessWidget {
  final String studentId;
  const StudentMarksDetailScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
        title: Text('Student Marks Detail',
            style: TextStyle(
                color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage('https://placeholder.com/150'),
            ),
            const SizedBox(height: 12),
            Text('Akena Brian',
                style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('ADM/2022/001',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
            Text('Grade 10A',
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
            const SizedBox(height: 32),
            _buildAssessmentSummary(context),
            const SizedBox(height: 24),
            _buildComponentBreakdown(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentSummary(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text('Mid Term Test',
              style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: 16 / 40,
                      strokeWidth: 8,
                      backgroundColor: AppColors.border(context),
                      color: AppColors.success(context),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('16',
                          style: TextStyle(
                              color: AppColors.textPrimary(context),
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      Text('/ 40',
                          style: TextStyle(color: AppColors.textSecondary(context), fontSize: 10)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatItem(context, 'Percentage', '40%', AppColors.success(context)),
                  const SizedBox(height: 12),
                  _buildStatItem(context, 'Grade', 'C', AppColors.warning(context)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildComponentBreakdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Component Breakdown',
            style: TextStyle(
                color: AppColors.textPrimary(context), fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        _buildComponentItem(context, 'Section A', '16 / 20', AppColors.success(context)),
        _buildComponentItem(context, 'Section B', '-- / 10', AppColors.textMuted(context)),
        _buildComponentItem(context, 'Section C', '-- / 10', AppColors.textMuted(context)),
      ],
    );
  }

  Widget _buildComponentItem(BuildContext context, String name, String score, Color scoreColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border(context).withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14)),
          Text(score, style: TextStyle(color: scoreColor, fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}


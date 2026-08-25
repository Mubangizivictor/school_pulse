import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';

class MyClassesScreen extends StatelessWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('My Classes (Subject)'),
        backgroundColor: AppColors.surfaceElevated(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border(context), height: 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildTab(context, 'Subject Classes', true),
                const SizedBox(width: 12),
                _buildTab(context, 'Other Subjects', false),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildClassItem(
                  context,
                  '10A',
                  'Grade 10A (Science)',
                  'Section A',
                  'Mathematics',
                  '28 Students',
                  '10:00 AM',
                ),
                const SizedBox(height: 16),
                _buildClassItem(
                  context,
                  '10B',
                  'Grade 10B (Science)',
                  'Section B',
                  'Mathematics',
                  '25 Students',
                  '01:00 PM',
                  nextTimeColor: AppColors.secondary(context),
                ),
                const SizedBox(height: 16),
                _buildClassItem(
                  context,
                  '9A',
                  'Grade 9A (Science)',
                  'Section A',
                  'Mathematics',
                  '27 Students',
                  'Tomorrow\n02:00 PM',
                  nextTimeColor: AppColors.primary(context),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: PrimaryButton(label: 'View Timetable', onPressed: () {}),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(BuildContext context, String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary(context) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isActive ? null : Border.all(color: AppColors.border(context)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : AppColors.textSecondary(context),
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildClassItem(
    BuildContext context,
    String code,
    String name,
    String section,
    String subject,
    String students,
    String nextLesson, {
    Color? nextTimeColor,
  }) {
    final effectiveNextTimeColor = nextTimeColor ?? AppColors.primary(context);
    return AppCard(
      onTap: () => context.push('/staff/lessons/class/10A'),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary(context),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(
              code,
              style: TextStyle(
                color: AppColors.primary(context),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  section,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subject,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.people_outline,
                      color: AppColors.textMuted(context),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      students,
                      style: TextStyle(
                        color: AppColors.textSecondary(context),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Next Lesson',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                nextLesson,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: effectiveNextTimeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

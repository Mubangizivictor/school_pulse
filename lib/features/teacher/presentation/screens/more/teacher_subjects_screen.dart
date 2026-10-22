import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class TeacherSubjectsScreen extends StatelessWidget {
  const TeacherSubjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('My Subjects')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SubjectCard(
            subject: 'Mathematics',
            className: 'P3 East',
            students: 32,
            periodsPerWeek: 6,
            iconColor: AppColors.electricBlue,
          ),
          const SizedBox(height: 12),
          _SubjectCard(
            subject: 'Mathematics',
            className: 'P6 West',
            students: 38,
            periodsPerWeek: 5,
            iconColor: AppColors.goldenYellow,
          ),
          const SizedBox(height: 12),
          _SubjectCard(
            subject: 'Additional Mathematics',
            className: 'S1 East',
            students: 34,
            periodsPerWeek: 4,
            iconColor: AppColors.successGreen,
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String subject;
  final String className;
  final int students;
  final int periodsPerWeek;
  final Color iconColor;

  const _SubjectCard({
    required this.subject,
    required this.className,
    required this.students,
    required this.periodsPerWeek,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.menu_book_rounded, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  className,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$students',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Students',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$periodsPerWeek',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Periods/Week',
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

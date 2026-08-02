import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';

class LessonNotesScreen extends StatelessWidget {
  final String lessonId;
  const LessonNotesScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lesson Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/staff/lessons/add-note/123'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildLessonHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                _buildNoteItem(
                  context,
                  'Introduction to Linear Equations',
                  'Key concepts and definitions',
                  'By you • 20 May 2025',
                ),
                _buildNoteItem(
                  context,
                  'Solving Linear Equations',
                  'Examples and class practice',
                  'By you • 20 May 2025',
                ),
                _buildNoteItem(
                  context,
                  'Homework',
                  'Exercise 1 - 10 page 45',
                  'By you • 20 May 2025',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonHeader(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primarySoft(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.book, color: AppColors.primary(context), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Linear Equations',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Grade 10A (Science) • Section A',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                Text(
                  'Mon, 20 May 2025 • 10:00 AM - 10:45 AM',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteItem(
    BuildContext context,
    String title,
    String subtitle,
    String author,
  ) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.primary(context),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  author,
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary(context),
              size: 20,
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

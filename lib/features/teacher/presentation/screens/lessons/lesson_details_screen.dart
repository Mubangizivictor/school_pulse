import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';

class LessonDetailsScreen extends StatelessWidget {
  final String lessonId;
  const LessonDetailsScreen({super.key, required this.lessonId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: const Text('Lesson Details'),
        backgroundColor: AppColors.surfaceElevated(context),
        foregroundColor: AppColors.textPrimary(context),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: AppColors.border(context).withValues(alpha: 0.5),
            height: 1,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary(context).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.book, color: AppColors.primary(context), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Linear Equations',
                                style: TextStyle(
                                  color: AppColors.textPrimary(context),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            Text('Grade 10A (Science) • Section A',
                                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                          ],
                        ),
                      ),
                      StatusBadge(label: 'Completed', color: AppColors.success(context)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildDetailRow(context, Icons.calendar_today_outlined, 'Date', 'Mon, 20 May 2025'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.access_time, 'Time', '10:00 AM - 10:45 AM'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.location_on_outlined, 'Room', 'Room 12'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.people_outline, 'Students', '28 Enrolled'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.assignment_outlined, 'Related Assessment', 'Mid Term Test - Test 1'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.note_alt_outlined, 'Notes', '1 Note'),
                  const SizedBox(height: 16),
                  _buildDetailRow(context, Icons.folder_open, 'Resources', '2 Files'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text('Actions',
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildActionButton(context, 'Take\nAttendance', Icons.how_to_reg, AppColors.success(context),
                    () => context.push('/staff/lessons/attendance/123')),
                const SizedBox(width: 12),
                _buildActionButton(context, 'Lesson\nNotes', Icons.description_outlined, AppColors.secondary(context),
                    () => context.push('/staff/lessons/notes/123')),
                const SizedBox(width: 12),
                _buildActionButton(
                    context, 'Edit\nLesson', Icons.edit_outlined, AppColors.primary(context), () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary(context), size: 18),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 14)),
        const Spacer(),
        Text(value,
            style: TextStyle(color: AppColors.textPrimary(context), fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildActionButton(
      BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 12),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}


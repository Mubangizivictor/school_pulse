import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/app_components.dart';

class LessonsHomeScreen extends StatelessWidget {
  const LessonsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Lessons',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary(context),
                        ),
                  ),
                  Stack(
                    children: [
                      IconButton(
                        icon: Icon(Icons.notifications_none, color: AppColors.textPrimary(context)),
                        onPressed: () {},
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: AppColors.errorRed, shape: BoxShape.circle),
                          child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 8)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                'Manage your lessons and teaching',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary(context)),
              ),
              const SizedBox(height: 24),
              _buildSummaryCard(context),
              const SizedBox(height: 24),
              SectionHeader(
                title: "Today's Lessons",
                actionLabel: 'View Timetable',
                onActionPressed: () {},
              ),
              const SizedBox(height: 8),
              _buildLessonItem(
                context,
                time: '10:00 AM - 10:45 AM',
                subject: 'Mathematics',
                grade: 'Grade 10A (Science) • Section A',
                room: 'Room 12',
                status: 'ONGOING',
                statusColor: AppColors.primary(context),
              ),
              const SizedBox(height: 12),
              _buildLessonItem(
                context,
                time: '01:00 PM - 01:45 PM',
                subject: 'Mathematics',
                grade: 'Grade 10B (Science) • Section B',
                room: 'Room 15',
                status: 'UPCOMING',
                statusColor: AppColors.secondary(context),
              ),
              const SizedBox(height: 24),
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickAction(context, 'Take Attendance', Icons.how_to_reg, AppColors.success(context)),
                  const SizedBox(width: 12),
                  _buildQuickAction(context, 'Lesson Notes', Icons.description_outlined, AppColors.secondary(context)),
                  const SizedBox(width: 12),
                  _buildQuickAction(context, 'View Resources', Icons.folder_open, AppColors.primary(context)),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Column(
      children: [
        AppCard(
          onTap: () => context.push('/staff/lessons/my-classes'),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.book_outlined, color: AppColors.primary(context)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Classes (Subject)',
                        style: TextStyle(color: AppColors.textPrimary(context), fontWeight: FontWeight.bold)),
                    Text('3 Classes', style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildStatCard(context, '8', 'Lessons Today'),
            const SizedBox(width: 12),
            _buildStatCard(context, '2', 'Upcoming Lessons'),
            const SizedBox(width: 12),
            _buildStatCard(context, '0', 'Cancelled Lessons'),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary(context), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonItem(BuildContext context,
      {required String time,
      required String subject,
      required String grade,
      required String room,
      required String status,
      required Color statusColor}) {
    return AppCard(
      onTap: () => context.push('/staff/lessons/details/123'),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
              StatusBadge(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: 8),
          Text(subject,
              style: TextStyle(color: AppColors.textPrimary(context), fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(grade, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.textSecondary(context), size: 14),
              const SizedBox(width: 4),
              Text(room, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 12)),
              const Spacer(),
              Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String label, IconData icon, Color color) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary(context), fontSize: 10, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}


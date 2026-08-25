import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class _Meeting {
  final String title;
  final DateTime dateTime;
  final String attendees;
  final bool isPast;

  const _Meeting(this.title, this.dateTime, this.attendees, this.isPast);
}

class MeetingsScreen extends StatelessWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final meetings = [
      _Meeting(
        'HOD Weekly Sync',
        now.add(const Duration(days: 1, hours: 2)),
        'All Heads of Department',
        false,
      ),
      _Meeting(
        'Exam Briefing',
        now.add(const Duration(days: 3)),
        'Invigilators',
        false,
      ),
      _Meeting(
        'Curriculum Review',
        now.add(const Duration(days: 7)),
        'Subject Teachers',
        false,
      ),
      _Meeting(
        'Academic Committee',
        now.subtract(const Duration(days: 4)),
        'Committee Members',
        true,
      ),
      _Meeting(
        'Term Planning',
        now.subtract(const Duration(days: 12)),
        'All Staff',
        true,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Meetings')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showScheduleMeetingSheet(context),
        child: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: meetings.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
        itemBuilder: (context, index) {
          final meeting = meetings[index];
          return AppCard(
            onTap: () => _showMeetingDetails(context, meeting),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.m),
                  decoration: BoxDecoration(
                    color: (meeting.isPast
                        ? AppColors.textMuted(context)
                        : AppColors.primary(context)),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups_2_outlined,
                    color: meeting.isPast
                        ? AppColors.textMuted(context)
                        : AppColors.primary(context),
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meeting.title,
                        style: AppTypography.titleSmall.copyWith(
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                      Text(
                        DateFormat('d MMM, h:mm a').format(meeting.dateTime),
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                      Text(
                        meeting.attendees,
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    ],
                  ),
                ),
                if (meeting.isPast)
                  StatusBadge(
                    label: 'Past',
                    color: AppColors.textMuted(context),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showMeetingDetails(BuildContext context, _Meeting meeting) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(meeting.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('EEEE, d MMMM • h:mm a').format(meeting.dateTime)),
            const SizedBox(height: 8),
            Text('Attendees: ${meeting.attendees}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showScheduleMeetingSheet(BuildContext context) {
    final titleController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'Schedule Meeting'),
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: 'Meeting Title'),
            ),
            const SizedBox(height: AppSpacing.l),
            const TextField(
              decoration: InputDecoration(labelText: 'Attendees'),
            ),
            const SizedBox(height: AppSpacing.x3l),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '"${titleController.text}" will be scheduled once meeting creation is available.',
                    ),
                  ),
                );
              },
              child: const Text('Schedule'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

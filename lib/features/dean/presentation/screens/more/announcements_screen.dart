import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class _Announcement {
  final String title;
  final String audience;
  final DateTime sentAt;

  const _Announcement(this.title, this.audience, this.sentAt);
}

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final announcements = [
      _Announcement(
        'Exam timetable released',
        'All Teachers',
        now.subtract(const Duration(days: 1)),
      ),
      _Announcement(
        'Marks entry deadline: Friday',
        'Subject Teachers',
        now.subtract(const Duration(days: 3)),
      ),
      _Announcement(
        'Scheme of work submission reminder',
        'Heads of Department',
        now.subtract(const Duration(days: 5)),
      ),
      _Announcement(
        'Report cards published',
        'Parents',
        now.subtract(const Duration(days: 10)),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(title: const Text('Announcements')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showComposeSheet(context),
        icon: const Icon(Icons.campaign_outlined),
        label: const Text('New Announcement'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: announcements.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.l),
        itemBuilder: (context, index) {
          final a = announcements[index];
          return AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Row(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 14,
                      color: AppColors.textMuted(context),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      a.audience,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.l),
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.textMuted(context),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      DateFormat('d MMM').format(a.sentAt),
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showComposeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: AppSpacing.xl,
          right: AppSpacing.xl,
          top: AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'New Announcement'),
            const SizedBox(height: AppSpacing.xl),
            const TextField(decoration: InputDecoration(labelText: 'Title')),
            const SizedBox(height: AppSpacing.l),
            const TextField(
              decoration: InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
            const SizedBox(height: AppSpacing.l),
            DropdownButtonFormField<String>(
              initialValue: 'All Teachers',
              decoration: InputDecoration(
                labelText: 'Audience',
                border: OutlineInputBorder(borderRadius: AppRadius.medium),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'All Teachers',
                  child: Text('All Teachers'),
                ),
                DropdownMenuItem(
                  value: 'Heads of Department',
                  child: Text('Heads of Department'),
                ),
                DropdownMenuItem(
                  value: 'Subject Teachers',
                  child: Text('Subject Teachers'),
                ),
                DropdownMenuItem(value: 'Parents', child: Text('Parents')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: AppSpacing.x3l),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Send'),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

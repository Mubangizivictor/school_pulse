import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';

class ClassAnnouncementsScreen extends StatelessWidget {
  final String classId;
  const ClassAnnouncementsScreen({super.key, required this.classId});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Announcements',
              style: AppTypography.titleLarge.copyWith(color: primaryColor, fontWeight: FontWeight.bold),
            ),
            Text(
              'P5 East',
              style: AppTypography.labelSmall.copyWith(color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.xl),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.m),
              itemBuilder: (context, index) => _buildAnnouncementItem(index, isDark),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: PulseButton(
              label: 'New Announcement',
              icon: Icons.add,
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnnouncementItem(int index, bool isDark) {
    final announcements = [
      {
        'title': "Parents' Meeting",
        'content': 'There will be a parents meeting on 25th May 2024 at 2:00 PM.',
        'date': '15 May 2024 • 10:00 AM',
        'icon': Icons.campaign,
        'iconColor': AppColors.successGreen
      },
      {
        'title': 'Half Term Break',
        'content': 'School will be closed from 28th May to 3rd June 2024.',
        'date': '12 May 2024 • 09:00 AM',
        'icon': Icons.info,
        'iconColor': AppColors.royalBlue
      },
      {
        'title': 'Sports Day',
        'content': 'P5 East will participate in Sports Day on 5th June 2024.',
        'date': '8 May 2024 • 03:30 PM',
        'icon': Icons.emoji_events,
        'iconColor': AppColors.goldenYellow
      },
    ];

    final announcement = announcements[index];

    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.s),
                decoration: BoxDecoration(
                  color: (announcement['iconColor'] as Color).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppSpacing.s),
                ),
                child: Icon(announcement['icon'] as IconData, color: announcement['iconColor'] as Color, size: 20),
              ),
              const SizedBox(width: AppSpacing.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      announcement['title'] as String,
                      style: AppTypography.titleMedium.copyWith(
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      announcement['date'] as String,
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.more_vert, size: 20, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            announcement['content'] as String,
            style: AppTypography.bodyMedium.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}

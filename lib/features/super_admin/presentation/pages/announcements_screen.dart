import 'package:flutter/material.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Announcements')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2l,
              AppSpacing.xl,
              AppSpacing.x2l,
              AppSpacing.s,
            ),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: null,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Create New Announcement'),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.x2l,
              AppSpacing.xl,
              AppSpacing.x2l,
              AppSpacing.m,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.l),
                  decoration: BoxDecoration(
                    color: AppColors.primary(context),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.campaign_rounded,
                    color: AppColors.primary(context),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Text(
                  'Recent Announcements',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.x2l,
                0,
                AppSpacing.x2l,
                AppSpacing.x3l,
              ),
              children: const [
                _AnnouncementTile(
                  title: 'System Maintenance',
                  message:
                      'Platform will be down for scheduled maintenance on '
                      'June 5th, 2:00 AM - 4:00 AM UTC.',
                  target: 'All Schools',
                  date: 'Today, 10:30 AM',
                  status: 'Published',
                ),
                _AnnouncementTile(
                  title: 'New Feature: AI Reports',
                  message:
                      'We are excited to announce that AI-powered reports '
                      'are now available for all premium subscribers.',
                  target: 'Premium Schools',
                  date: 'Yesterday, 2:15 PM',
                  status: 'Published',
                ),
                _AnnouncementTile(
                  title: 'Price Adjustment Notice',
                  message:
                      'Starting July 1st, there will be a minor adjustment '
                      'to our subscription plans.',
                  target: 'All Schools',
                  date: 'May 28, 2024',
                  status: 'Draft',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnnouncementTile extends StatelessWidget {
  const _AnnouncementTile({
    required this.title,
    required this.message,
    required this.target,
    required this.date,
    required this.status,
  });

  final String title;
  final String message;
  final String target;
  final String date;
  final String status;

  @override
  Widget build(BuildContext context) {
    final bool isPublished = status == 'Published';
    final statusColor = isPublished
        ? AppColors.success(context)
        : AppColors.warning(context);

    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              StatusBadge(label: status, color: statusColor),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            message,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary(context),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.l),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Target: $target',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary(context),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.s),
              Text(
                date,
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import '../../domain/entities/announcement_entity.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;
  final VoidCallback? onTap;

  const AnnouncementCard({super.key, required this.announcement, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDraft = announcement.status == AnnouncementStatus.draft;
    return AppCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  announcement.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.textPrimary(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(
                label: isDraft ? 'Draft' : 'Published',
                color: isDraft
                    ? AppColors.warning(context)
                    : AppColors.success(context),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            announcement.body,
            style: TextStyle(color: AppColors.textSecondary(context)),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            'By ${announcement.authorName}',
            style: TextStyle(color: AppColors.textMuted(context), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

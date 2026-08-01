import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class BroadcastDetailsScreen extends StatelessWidget {
  final String broadcastId;

  const BroadcastDetailsScreen({
    super.key,
    required this.broadcastId,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text('Broadcast Info', style: AppTypography.titleLarge),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.royalBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      size: 50,
                      color: AppColors.royalBlue,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'School Announcement List',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Broadcast • 128 recipients',
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x3l),
            Text(
              'Recipients',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.royalBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 5,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=school'),
                  ),
                  title: Text('Parent Name $index', style: AppTypography.bodyLarge),
                  subtitle: Text('Grade ${index + 1} Parent', style: AppTypography.bodySmall),
                  trailing: Text(
                    'Delivered',
                    style: AppTypography.labelSmall.copyWith(color: Colors.green),
                  ),
                );
              },
            ),
            TextButton(
              onPressed: () {},
              child: const Text('View all 128 recipients'),
            ),
            const SizedBox(height: AppSpacing.x3l),
            _buildInfoTile(
              context,
              icon: Icons.info_outline,
              title: 'Description',
              subtitle: 'Weekly updates and important announcements for all parents in the primary section.',
            ),
            _buildInfoTile(
              context,
              icon: Icons.calendar_today_outlined,
              title: 'Created',
              subtitle: 'October 12, 2023',
            ),
            const SizedBox(height: AppSpacing.x3l),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.deepOrange,
                  side: const BorderSide(color: AppColors.deepOrange),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                ),
                child: const Text('Delete Broadcast List'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 24, color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.titleSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  subtitle,
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
      backgroundColor: AppColors.bgDark,
      appBar: AppBar(
        title: Text(
          'Broadcast Info',
          style: AppTypography.titleLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
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
                      color: AppColors.electricBlue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.2), width: 1),
                    ),
                    child: const Icon(
                      Icons.campaign_rounded,
                      size: 50,
                      color: AppColors.electricBlue,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'School Announcement List',
                    style: AppTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Broadcast • 128 recipients',
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white60,
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
                color: AppColors.electricBlue,
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
              ),
              child: Column(
                children: [
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 5,
                    separatorBuilder: (context, index) => Divider(
                      height: 1,
                      color: Colors.white.withValues(alpha: 0.05),
                      indent: 72,
                    ),
                    itemBuilder: (context, index) {
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        leading: CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=school$index'),
                        ),
                        title: Text(
                          'Parent Name $index',
                          style: AppTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          'Grade ${index + 1} Parent',
                          style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                        ),
                        trailing: Text(
                          'Delivered',
                          style: AppTypography.labelSmall.copyWith(color: Colors.greenAccent),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: Colors.white10),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'View all 128 recipients',
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.electricBlue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
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
              child: TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: Colors.redAccent, width: 1),
                  ),
                ),
                child: const Text('Delete Broadcast List', style: TextStyle(fontWeight: FontWeight.bold)),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.l),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 20, color: Colors.white70),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

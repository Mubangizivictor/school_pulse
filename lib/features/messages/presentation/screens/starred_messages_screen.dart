import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class StarredMessagesScreen extends StatelessWidget {
  const StarredMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Starred Messages', style: AppTypography.titleLarge),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: AppColors.textPrimary(context)),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppColors.royalBlue,
                        child: Text('A', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mrs. Amina', style: AppTypography.titleSmall),
                            Text('in P7 - Parents Group', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                          ],
                        ),
                      ),
                      const Icon(Icons.star, size: 18, color: AppColors.goldenYellow),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Reminder: PTA meeting this Friday at 4PM. Please ensure all documents are ready for discussion.',
                    style: AppTypography.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text('10:30 AM • 12/06/24', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

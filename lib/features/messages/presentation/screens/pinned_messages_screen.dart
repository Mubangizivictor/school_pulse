import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class PinnedMessagesScreen extends StatelessWidget {
  const PinnedMessagesScreen({super.key});

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
        title: Text('Pinned Messages', style: AppTypography.titleLarge),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.electricBlue.withValues(alpha: 0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.push_pin, size: 16, color: AppColors.electricBlue),
                      const SizedBox(width: 8),
                      Text('Pinned by Mrs. Amina', style: AppTypography.labelSmall.copyWith(color: AppColors.electricBlue)),
                      const Spacer(),
                      Text('Yesterday', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    index == 0 
                      ? 'Important: PTA meeting this Friday at 4PM. All parents are requested to attend for the term review.' 
                      : 'School will be closing at 1PM on Friday due to the upcoming public holiday.', 
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 12),
                  Text('in P7 - Parents Group', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

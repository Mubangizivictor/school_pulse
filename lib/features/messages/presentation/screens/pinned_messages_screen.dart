import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class PinnedMessagesScreen extends StatelessWidget {
  const PinnedMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinned Messages'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: 2,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.m),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.push_pin, size: 14, color: AppColors.electricBlue),
                      const SizedBox(width: 8),
                      Text('Pinned by Mrs. Amina', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    index == 0 
                      ? 'PTA meeting this Friday at 4PM.' 
                      : 'School will be closing at 1PM on Friday.', 
                    style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w500)
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('in P7 - Parents Group', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                      Text('Yesterday', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
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

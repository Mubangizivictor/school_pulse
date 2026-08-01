import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';

class StarredMessagesScreen extends StatelessWidget {
  const StarredMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Starred Messages'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.m),
        itemCount: 3,
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
                      const CircleAvatar(radius: 12, child: Icon(Icons.person, size: 12)),
                      const SizedBox(width: 8),
                      Text('Mrs. Amina', style: AppTypography.labelMedium.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      const Icon(Icons.star, size: 16, color: Colors.amber),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Reminder: PTA meeting this Friday at 4PM.', style: AppTypography.bodyMedium),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('in P7 - Parents Group', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
                      Text('10:30 AM', style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted(context))),
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

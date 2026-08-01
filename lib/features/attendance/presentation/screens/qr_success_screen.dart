import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class QRSuccessScreen extends StatelessWidget {
  const QRSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 24),
          onPressed: () => context.pop(),
        ),
        title: const Text('Scan Success'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.l),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xl),
                  FadeInSlide(
                    duration: const Duration(milliseconds: 600),
                    child: Column(
                      children: [
                        Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: semantic.success, width: 3),
                              ),
                              child: const CircleAvatar(
                                radius: 60,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=kato'),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: semantic.success,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Kato Mercy',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SH-2026-0482',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        StatusBadge(label: 'Sunset House', color: AppColors.royalBlue),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 200),
                    child: AppCard(
                      color: semantic.success.withValues(alpha: 0.05),
                      borderColor: semantic.success.withValues(alpha: 0.2),
                      padding: const EdgeInsets.all(AppSpacing.m),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time, color: semantic.success, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Marked Present at 08:46 PM',
                            style: TextStyle(
                              color: semantic.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated(context),
              border: Border(top: BorderSide(color: AppColors.border(context))),
            ),
            child: SafeArea(
              top: false,
              child: FadeInSlide(
                delay: const Duration(milliseconds: 400),
                direction: FadeInSlideDirection.btt,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PrimaryButton(
                      label: 'Next Student',
                      onPressed: () => context.pop(),
                    ),
                    const SizedBox(height: 12),
                    SecondaryButton(
                      label: 'View Summary',
                      onPressed: () => context.push('/staff/attendance/summary'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

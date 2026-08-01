import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class AttendanceSummaryScreen extends StatelessWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('Attendance Summary'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.l),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: FadeInSlide(
                        duration: const Duration(milliseconds: 800),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final size = constraints.maxWidth * 0.5 > 200.0 ? 200.0 : constraints.maxWidth * 0.5;
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: size,
                                  height: size,
                                  child: CircularProgressIndicator(
                                    value: 23 / 25,
                                    strokeWidth: size * 0.07,
                                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.success(context)),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '92%',
                                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                            fontWeight: FontWeight.w900,
                                            color: AppColors.success(context),
                                            fontSize: size * 0.22,
                                          ),
                                    ),
                                    Text(
                                      'Attendance Rate',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                            color: Theme.of(context).hintColor,
                                            fontWeight: FontWeight.w600,
                                            fontSize: size * 0.06,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeInSlide(
                      delay: const Duration(milliseconds: 200),
                      child: Column(
                        children: [
                          Text(
                            'Sunset House — Evening',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'January 6, 2026 • 08:46 PM',
                            style: TextStyle(color: Theme.of(context).hintColor),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 300),
                            child: _SummaryCard(
                              icon: Icons.check_circle_rounded,
                              count: '23',
                              label: 'Present',
                              color: AppColors.success(context),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 400),
                            child: _SummaryCard(
                              icon: Icons.cancel_rounded,
                              count: '2',
                              label: 'Absent',
                              color: AppColors.errorRed,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FadeInSlide(
                            delay: const Duration(milliseconds: 500),
                            child: _SummaryCard(
                              icon: Icons.access_time_filled_rounded,
                              count: '0',
                              label: 'Late',
                              color: AppColors.warning(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    FadeInSlide(
                      delay: const Duration(milliseconds: 600),
                      child: AppCard(
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.royalBlue.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.description_outlined, color: AppColors.royalBlue, size: 20),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Detailed Report', style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text('View full student breakdown', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.push('/staff/attendance/list'),
                              child: const Text('View List'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
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
              child: PrimaryButton(
                label: 'Finish Roll Call',
                onPressed: () => context.go('/staff/dashboard'),
              ),
            ),
          ),
        ],
      ),
    );

  }
}

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final String count;
  final String label;
  final Color color;

  const _SummaryCard({
    required this.icon,
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            count,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

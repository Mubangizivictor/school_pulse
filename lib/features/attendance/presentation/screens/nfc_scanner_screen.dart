import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class NFCScannerScreen extends StatelessWidget {
  const NFCScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('NFC Verification'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const _RippleAnimation(),
                const SizedBox(height: 60),
                FadeInSlide(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    children: [
                      Text(
                        'Ready to Scan',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Hold the student ID card near the back\nof your device to verify identity.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).hintColor,
                            ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                FadeInSlide(
                  delay: const Duration(milliseconds: 300),
                  child: AppCard(
                    padding: const EdgeInsets.all(AppSpacing.m),
                    color: AppColors.surfaceElevated(context),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.blue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.sensors, color: Colors.blue, size: 24),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('NFC Sensor Active', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text('Ensure NFC is enabled in settings', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
              ],
            ),
          ),
          // For demo purposes, tapping the screen takes us to success
          Positioned.fill(
            child: GestureDetector(
              onTap: () => context.push('/staff/attendance/nfc-success'),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

class _RippleAnimation extends StatefulWidget {
  const _RippleAnimation();

  @override
  State<_RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<_RippleAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            ...List.generate(3, (index) {
              final progress = (_controller.value + (index / 3)) % 1.0;
              final size = 100 + (180 * progress);
              final opacity = (1.0 - progress).clamp(0.0, 1.0);
              
              return Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primaryColor.withValues(alpha: opacity * 0.4),
                    width: 2,
                  ),
                ),
              );
            }),
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 2),
              ),
              child: Icon(
                Icons.contactless_outlined,
                size: 80,
                color: primaryColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

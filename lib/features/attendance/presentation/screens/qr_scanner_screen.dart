import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mock Camera View
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
          ),
          
          // Overlay
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.m, vertical: AppSpacing.s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () => context.pop(),
                      ),
                      const Text(
                        'QR Scanner',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      IconButton(
                        icon: const Icon(Icons.flashlight_on, color: Colors.white, size: 24),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    const Text(
                      'Scan Student QR Code',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Position the QR code within the frame',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 40),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // QR Frame with corners
                        _ScannerFrame(),
                        // Mock QR Code Image
                        Image.network(
                          'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=KatoMercy',
                          width: 180,
                          height: 180,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        // Scanning Line
                        const _ScanningLine(),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: AppCard(
                    color: Colors.white.withValues(alpha: 0.1),
                    showBorder: false,
                    showShadow: false,
                    padding: const EdgeInsets.all(AppSpacing.m),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.white70),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Make sure there is enough light for a faster scan',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
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
              onTap: () => context.push('/staff/attendance/qr-success'),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      child: Stack(
        children: [
          // Corners
          _FrameCorner(top: 0, left: 0, angle: 0),
          _FrameCorner(top: 0, right: 0, angle: 90),
          _FrameCorner(bottom: 0, left: 0, angle: 270),
          _FrameCorner(bottom: 0, right: 0, angle: 180),
        ],
      ),
    );
  }
}

class _FrameCorner extends StatelessWidget {
  final double? top, bottom, left, right;
  final double angle;

  const _FrameCorner({this.top, this.bottom, this.left, this.right, required this.angle});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: RotationTransition(
        turns: AlwaysStoppedAnimation(angle / 360),
        child: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.electricBlue, width: 4),
              left: BorderSide(color: AppColors.electricBlue, width: 4),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScanningLine extends StatefulWidget {
  const _ScanningLine();

  @override
  State<_ScanningLine> createState() => _ScanningLineState();
}

class _ScanningLineState extends State<_ScanningLine> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: 40 + (200 * _controller.value),
          child: Container(
            width: 240,
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricBlue.withValues(alpha: 0),
                  AppColors.electricBlue,
                  AppColors.electricBlue.withValues(alpha: 0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

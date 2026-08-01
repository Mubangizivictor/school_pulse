import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';

class QrScannerScreen extends StatelessWidget {
  const QrScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
        title: const Text('QR Scanner'),
      ),
      body: Stack(
        children: [
          // Mock Camera View
          Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Scan Student QR Code',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  'Position the QR code within the frame',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 32),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // QR Frame
                    Container(
                      width: 260,
                      height: 260,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    // Mock QR Code Image
                    Image.network(
                      'https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=KatoMercy',
                      width: 180,
                      height: 180,
                      color: Colors.white,
                    ),
                    // Scanning Line
                    const _ScanningLine(),
                  ],
                ),
                const SizedBox(height: 48),
                IconButton(
                  icon: const Icon(Icons.flashlight_on, color: Colors.white, size: 32),
                  onPressed: () {},
                ),
                const SizedBox(height: 16),
                const Text(
                  'Scanning will happen automatically',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // For demo purposes, tapping the screen takes us to success
          Positioned.fill(
            child: GestureDetector(
              onTap: () => context.push('/attendance/qr/success'),
              child: Container(color: Colors.transparent),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(context),
    );
  }

  Widget _buildBottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 1,
      backgroundColor: const Color(0xFF0E1012),
      unselectedItemColor: Colors.grey,
      selectedItemColor: AppColors.electricBlue,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
        BottomNavigationBarItem(icon: Icon(Icons.domain_outlined), label: 'Dorms'),
        BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart_outlined), label: 'Analytics'),
        BottomNavigationBarItem(icon: Icon(Icons.more_horiz_outlined), label: 'More'),
      ],
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
          top: 30 + (200 * _controller.value),
          child: Container(
            width: 240,
            height: 2,
            decoration: BoxDecoration(
              color: AppColors.electricBlue,
              boxShadow: [
                BoxShadow(
                  color: AppColors.electricBlue.withValues(alpha: 0.5),
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

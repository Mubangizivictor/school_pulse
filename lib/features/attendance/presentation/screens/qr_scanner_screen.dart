import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_bloc.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_event.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class QRScannerScreen extends StatelessWidget {
  const QRScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AttendanceQrBloc>(),
      child: const _QRScannerView(),
    );
  }
}

class _QRScannerView extends StatefulWidget {
  const _QRScannerView();

  @override
  State<_QRScannerView> createState() => _QRScannerViewState();
}

class _QRScannerViewState extends State<_QRScannerView> {
  late final MobileScannerController _controller;
  bool _isScanning = true;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;
    setState(() => _isScanning = false);
    context.read<AttendanceQrBloc>().add(ScanStudentQrEvent(code));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AttendanceQrBloc, AttendanceQrState>(
      listener: (context, state) {
        if (state is StudentScannedSuccess) {
          context
              .push('/staff/attendance/qr-success', extra: state.student)
              .then((_) {
                if (mounted) setState(() => _isScanning = true);
              });
        } else if (state is AttendanceQrError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
          setState(() => _isScanning = true);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            MobileScanner(controller: _controller, onDetect: _onDetect),

            // Overlay
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.m,
                      vertical: AppSpacing.s,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () => context.pop(),
                        ),
                        Text(
                          'QR Scanner',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.flashlight_on,
                            color: Colors.white,
                            size: 24,
                          ),
                          onPressed: () => _controller.toggleTorch(),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  FadeInSlide(
                    child: Column(
                      children: [
                        const Text(
                          'Scan Student QR Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Position the QR code within the frame',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            // QR Frame with corners
                            _ScannerFrame(),
                            // Scanning Line
                            const _ScanningLine(),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: FadeInSlide(
                      direction: FadeInDirection.bt,
                      delay: const Duration(milliseconds: 400),
                      child: AppCard(
                        color: Colors.white.withValues(alpha: 0.1),
                        showBorder: false,
                        showShadow: false,
                        padding: const EdgeInsets.all(AppSpacing.m),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Make sure there is enough light for a faster scan',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerFrame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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

  const _FrameCorner({
    this.top,
    this.bottom,
    this.left,
    this.right,
    required this.angle,
  });

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

class _ScanningLineState extends State<_ScanningLine>
    with SingleTickerProviderStateMixin {
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

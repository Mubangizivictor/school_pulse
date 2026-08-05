import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_bloc.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_event.dart';
import 'package:school_pulse/features/attendance_qr_integration/presentation/bloc/attendance_qr_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// No real NFC hardware read/write engine exists anywhere reachable in
/// this app (Phase 4's NFC work covers cross-device ID-card sync, a
/// different subsystem) - the OS-level tap-to-read flow this screen's copy
/// describes has nothing real to connect to. Rather than leave the fake
/// tap-anywhere gesture in place, this repoints to the same
/// AttendanceQrBloc.ScanStudentQrEvent path the QR scanner uses, keyed by
/// a manually-typed student code, since identity lookup by uniqueSystemId
/// doesn't care whether the code came from a camera or a keyboard.
class NFCScannerScreen extends StatelessWidget {
  const NFCScannerScreen({super.key});

  Future<void> _promptForCode(BuildContext context) async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Enter Student Code'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'e.g. SP-STUDENT-a82jd92',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Verify'),
          ),
        ],
      ),
    );
    if (code == null || code.isEmpty || !context.mounted) return;
    context.read<AttendanceQrBloc>().add(ScanStudentQrEvent(code));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AttendanceQrBloc>(),
      child: _NFCScannerView(onScanRequested: _promptForCode),
    );
  }
}

class _NFCScannerView extends StatelessWidget {
  final Future<void> Function(BuildContext) onScanRequested;

  const _NFCScannerView({required this.onScanRequested});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AttendanceQrBloc, AttendanceQrState>(
      listener: (context, state) {
        if (state is StudentScannedSuccess) {
          context.push('/staff/attendance/qr-success', extra: state.student);
        } else if (state is AttendanceQrError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
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
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Hold the student ID card near the back\nof your device to verify identity.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
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
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.sensors,
                              color: theme.colorScheme.primary,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'NFC Sensor Active',
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Ensure NFC is enabled in settings',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
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
            Positioned.fill(
              child: GestureDetector(
                onTap: () => onScanRequested(context),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RippleAnimation extends StatefulWidget {
  const _RippleAnimation();

  @override
  State<_RippleAnimation> createState() => _RippleAnimationState();
}

class _RippleAnimationState extends State<_RippleAnimation>
    with SingleTickerProviderStateMixin {
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
                border: Border.all(
                  color: primaryColor.withValues(alpha: 0.2),
                  width: 2,
                ),
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

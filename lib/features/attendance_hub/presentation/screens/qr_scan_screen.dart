import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../data/datasources/device_id_provider.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/scan_result_card.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

enum _ScanState {
  scanning,
  resolving,
  success,
  duplicate,
  invalid,
  denied,
  failed,
}

class _QrScanScreenState extends State<QrScanScreen> {
  late final MobileScannerController _controller;
  _ScanState _state = _ScanState.scanning;
  String _name = '';
  String _subtitle = '';
  String? _photoUrl;
  DateTime? _scannedAt;
  String _deniedMessage = '';

  @override
  void initState() {
    super.initState();
    // DetectionSpeed.noDuplicates blocks re-detecting the SAME code until a
    // DIFFERENT one is scanned - wrong here, since a student's QR code is
    // permanent and may legitimately need to be re-scanned (retry after a
    // duplicate/invalid result, or a second category later the same day).
    // `normal` re-arms after its scanTimeout instead.
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      detectionTimeoutMs: 1000,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_state != _ScanState.scanning) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _state = _ScanState.resolving);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    final identityRepo = di.sl<StudentIdentityRepository>();
    final result = await identityRepo.getStudentByUniqueId(code);
    if (!mounted) return;

    final student = result.fold((failure) => null, (s) => s);
    if (student == null) {
      setState(() => _state = _ScanState.invalid);
      return;
    }

    setState(() {
      _name = student.name;
      _subtitle = student.studentCode;
      _photoUrl = student.photoUrl;
      _scannedAt = DateTime.now();
    });

    final deviceId = await DeviceIdProvider().getDeviceId();
    if (!mounted) return;
    final record = AttendanceRecord(
      id: '',
      schoolId: user.schoolId,
      category: AttendanceCategory.students,
      scopeId: student.classId,
      scopeName: student.classId,
      date: _scannedAt!,
      personId: student.id,
      personName: student.name,
      status: AttendanceStatus.present,
      method: AttendanceMethod.qr,
      markedBy: user.name,
      operatorId: user.id,
      deviceId: deviceId,
      createdAt: _scannedAt!,
    );

    if (!mounted) return;
    context.read<AttendanceBloc>().add(
      MarkAttendanceRequested(record: record, operatorUser: user),
    );
  }

  void _reset() {
    setState(() => _state = _ScanState.scanning);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceMarkSuccess) {
          setState(() => _state = _ScanState.success);
        } else if (state is AttendanceDuplicate) {
          setState(() => _state = _ScanState.duplicate);
        } else if (state is AttendanceActionDenied) {
          setState(() {
            _deniedMessage = state.message;
            _state = _ScanState.denied;
          });
        } else if (state is AttendanceError) {
          setState(() => _state = _ScanState.failed);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('QR Code Scanner'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _ScanState.scanning:
      case _ScanState.resolving:
        return Stack(
          children: [
            MobileScanner(
              controller: _controller,
              onDetect: _onDetect,
              errorBuilder: (context, error, child) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_photography,
                        color: AppColors.danger(context),
                        size: 48,
                      ),
                      const SizedBox(height: AppSpacing.m),
                      Text(
                        'Camera unavailable. Check camera permission in Settings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Center(
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.primary(context),
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            if (_state == _ScanState.resolving)
              Container(
                color: Colors.black54,
                child: const Center(child: SchoolPulseLoader()),
              ),
            Positioned(
              bottom: AppSpacing.xl,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
              child: Text(
                'Align QR code within the frame',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        );
      case _ScanState.success:
        return ScanResultCard(
          name: _name,
          subtitle: _subtitle,
          timeLabel: _scannedAt != null
              ? '${_scannedAt!.hour.toString().padLeft(2, '0')}:${_scannedAt!.minute.toString().padLeft(2, '0')}'
              : '',
          statusLabel: 'Present',
          photoUrl: _photoUrl,
          onScanAnother: _reset,
          onDone: () => Navigator.of(context).pop(),
        );
      case _ScanState.duplicate:
        return ScanResultCard(
          isDuplicate: true,
          name: _name,
          subtitle: _subtitle,
          timeLabel: '',
          statusLabel: 'Already marked today',
          photoUrl: _photoUrl,
          onScanAnother: _reset,
          onDone: () => Navigator.of(context).pop(),
        );
      case _ScanState.invalid:
        return ScanResultCard(
          isInvalid: true,
          name: '',
          subtitle: '',
          timeLabel: '',
          statusLabel: '',
          onScanAnother: _reset,
          onDone: () => Navigator.of(context).pop(),
        );
      case _ScanState.denied:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.block, color: AppColors.danger(context), size: 64),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  _deniedMessage.isEmpty
                      ? 'This person is not part of your assigned attendance group.'
                      : _deniedMessage,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Ask your administrator if this assignment looks incorrect.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
                const SizedBox(height: AppSpacing.xl),
                FilledButton(
                  onPressed: _reset,
                  child: const Text('Scan Another'),
                ),
              ],
            ),
          ),
        );
      case _ScanState.failed:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                color: AppColors.danger(context),
                size: 64,
              ),
              const SizedBox(height: AppSpacing.xl),
              const Text('Scan failed. Please try again.'),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: _reset, child: const Text('Retry')),
            ],
          ),
        );
    }
  }
}

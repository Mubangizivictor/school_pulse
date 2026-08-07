import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/verification/data/datasources/verification_local_data_source.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../data/datasources/device_id_provider.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/scan_result_card.dart';

class NfcScanScreen extends StatefulWidget {
  const NfcScanScreen({super.key});

  @override
  State<NfcScanScreen> createState() => _NfcScanScreenState();
}

enum _ScanState { ready, scanning, resolving, success, duplicate, invalid, failed }

class _NfcScanScreenState extends State<NfcScanScreen> {
  final _adapter = NfcCredentialReaderAdapter();
  StreamSubscription<ScanCredential>? _subscription;
  Timer? _scanTimeout;
  _ScanState _state = _ScanState.ready;
  String _name = '';
  String _subtitle = '';
  String? _photoUrl;
  DateTime? _scannedAt;

  @override
  void dispose() {
    _subscription?.cancel();
    _scanTimeout?.cancel();
    _adapter.stop();
    _adapter.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    final available = await _adapter.isAvailable();
    if (!available) {
      setState(() => _state = _ScanState.failed);
      return;
    }
    setState(() => _state = _ScanState.scanning);

    // A fresh session replaces any prior listener/timeout rather than
    // stacking another one on the adapter's broadcast stream - without
    // this, cancelling and re-starting a scan would fire _resolveCard
    // twice (once per stale listener) on the next card read.
    await _subscription?.cancel();
    _scanTimeout?.cancel();

    _subscription = _adapter.credentials.listen((credential) async {
      if (credential is! NfcScanCredential) return;
      _scanTimeout?.cancel();
      await _adapter.stop();
      await _resolveCard(credential.cardUid);
    });

    // NfcCredentialReaderAdapter's onError only flips an internal flag and
    // never surfaces to this screen's state, so a hardware session error
    // would otherwise leave the UI stuck on "Scanning..." forever.
    _scanTimeout = Timer(const Duration(seconds: 30), () {
      if (_state == _ScanState.scanning) {
        _adapter.stop();
        setState(() => _state = _ScanState.failed);
      }
    });

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;
    final deviceId = await DeviceIdProvider().getDeviceId();

    // start()'s implementation never reads context.gate/purpose - only
    // IdentityResolver (deliberately bypassed here, see _resolveCard) does -
    // so this placeholder Gate never influences the actual hardware read.
    await _adapter.start(
      VerificationContext(
        gate: Gate(
          id: '',
          name: '',
          type: '',
          location: '',
          assignedOfficerIds: const [],
          operatingHours: const {},
          allowedUserRoles: const [],
          requiredVerificationMethods: const [],
          schoolId: user.schoolId,
        ),
        operatorUser: user,
        purpose: 'attendance.nfc.scan',
        deviceId: deviceId,
        requestedAt: DateTime.now(),
      ),
    );
  }

  Future<void> _resolveCard(String cardUid) async {
    setState(() => _state = _ScanState.resolving);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    final localDataSource = di.sl<VerificationLocalDataSource>();
    final cached = await localDataSource.findCredential(cardUid, user.schoolId);
    if (!mounted) return;

    if (cached == null || cached.status != 'active') {
      setState(() => _state = _ScanState.invalid);
      return;
    }

    if (cached.identityType != 'student') {
      // Staff NFC attendance has no roster/lookup path yet (see plan) -
      // surfaced as invalid rather than silently marking the wrong flow.
      setState(() => _state = _ScanState.invalid);
      return;
    }

    final identityRepo = di.sl<StudentIdentityRepository>();
    final result = await identityRepo.getStudentByUniqueId(cached.identityId);
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
      method: AttendanceMethod.nfc,
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
    _scanTimeout?.cancel();
    _subscription?.cancel();
    _subscription = null;
    setState(() => _state = _ScanState.ready);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is AttendanceMarkSuccess) {
          setState(() => _state = _ScanState.success);
        } else if (state is AttendanceDuplicate) {
          setState(() => _state = _ScanState.duplicate);
        } else if (state is AttendanceActionDenied ||
            state is AttendanceError) {
          setState(() => _state = _ScanState.failed);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('NFC Scan'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _ScanState.ready:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NfcCircle(color: AppColors.success(context)),
                const SizedBox(height: AppSpacing.x3l),
                Text(
                  'Ready to scan',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Hold ID card near the NFC reader',
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
                const SizedBox(height: AppSpacing.x3l),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _startScan,
                    child: const Text('Start Scanning'),
                  ),
                ),
                const SizedBox(height: AppSpacing.m),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      case _ScanState.scanning:
      case _ScanState.resolving:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NfcCircle(color: AppColors.primary(context), pulsing: true),
                const SizedBox(height: AppSpacing.x3l),
                Text(
                  'Scanning...',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Keep the ID card on the reader',
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
                const SizedBox(height: AppSpacing.xl),
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.x3l),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () async {
                      _scanTimeout?.cancel();
                      await _subscription?.cancel();
                      await _adapter.stop();
                      _reset();
                    },
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
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
              const Text('NFC scan failed. Please try again.'),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: _reset, child: const Text('Retry')),
            ],
          ),
        );
    }
  }
}

class _NfcCircle extends StatefulWidget {
  final Color color;
  final bool pulsing;

  const _NfcCircle({required this.color, this.pulsing = false});

  @override
  State<_NfcCircle> createState() => _NfcCircleState();
}

class _NfcCircleState extends State<_NfcCircle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.pulsing) _controller.repeat();
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
        final scale = widget.pulsing ? 1.0 + (_controller.value * 0.15) : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.color.withValues(alpha: 0.12),
              border: Border.all(color: widget.color, width: 2),
            ),
            child: Icon(Icons.wifi_tethering, color: widget.color, size: 64),
          ),
        );
      },
    );
  }
}

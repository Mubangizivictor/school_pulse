import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/identity_resolver.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../data/datasources/device_id_provider.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_scope.dart';
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
  resolvingScope,
  pickingScope,
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
  _ScanState _state = _ScanState.resolvingScope;
  String _name = '';
  String _subtitle = '';
  String? _photoUrl;
  DateTime? _scannedAt;
  String _deniedMessage = '';
  AttendanceScope? _scope;
  List<AttendanceScope> _availableScopes = const [];
  final Set<String> _presentPersonIds = {};

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
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<AttendanceBloc>().add(
        LoadScopesRequested(
          schoolId: auth.user.schoolId,
          category: AttendanceCategory.students,
          operatorUser: auth.user,
        ),
      );
      context.read<AttendanceBloc>().add(
        SyncPendingAttendanceRequested(schoolId: auth.user.schoolId),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_state != _ScanState.scanning || _scope == null) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _state = _ScanState.resolving);

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final user = authState.user;

    final verificationContext = VerificationContext(
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
      purpose: 'attendance.qr.scan',
      deviceId: await DeviceIdProvider().getDeviceId(),
      requestedAt: DateTime.now(),
    );
    final result = await di.sl<IdentityResolver>().resolve(
      QrScanCredential(rawPayload: code, scannedAt: DateTime.now()),
      verificationContext,
    );
    if (!mounted) return;

    final identity = result.fold((_) => null, (value) => value);
    if (identity is! StudentResolvedIdentity) {
      setState(() => _state = _ScanState.invalid);
      _scheduleAutoContinue();
      return;
    }

    if (identity.classId != _scope!.id) {
      setState(() {
        _name = identity.name;
        _subtitle = identity.studentCode;
        _photoUrl = identity.photoUrl;
        _state = _ScanState.denied;
        _deniedMessage = 'Not in this class';
      });
      _scheduleAutoContinue();
      return;
    }

    setState(() {
      _name = identity.name;
      _subtitle = identity.studentCode;
      _photoUrl = identity.photoUrl;
      _scannedAt = DateTime.now();
    });

    final deviceId = await DeviceIdProvider().getDeviceId();
    if (!mounted) return;
    final record = AttendanceRecord(
      id: '',
      schoolId: user.schoolId,
      category: AttendanceCategory.students,
      scopeId: _scope!.id,
      scopeName: _scope!.name,
      sessionType: 'daily',
      date: _scannedAt!,
      personId: identity.id,
      personName: identity.name,
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

  void _scheduleAutoContinue() {
    Future<void>.delayed(const Duration(milliseconds: 1400), () {
      if (mounted) _reset();
    });
  }

  void _selectScope(AttendanceScope scope) {
    setState(() {
      _scope = scope;
      _state = _ScanState.scanning;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is ScopesLoaded) {
          if (state.scopes.length == 1) {
            _selectScope(state.scopes.single);
          } else if (state.scopes.isEmpty) {
            setState(() {
              _deniedMessage = 'No class has been assigned to your account.';
              _state = _ScanState.denied;
            });
          } else {
            setState(() {
              _availableScopes = state.scopes;
              _state = _ScanState.pickingScope;
            });
          }
        } else if (state is AttendanceMarkSuccess) {
          HapticFeedback.lightImpact();
          _presentPersonIds.add(state.record.personId);
          setState(() => _state = _ScanState.success);
          _scheduleAutoContinue();
        } else if (state is AttendanceDuplicate) {
          setState(() => _state = _ScanState.duplicate);
          _scheduleAutoContinue();
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
          title: Text(_scope?.name ?? 'Attendance'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _ScanState.resolvingScope:
        return const Center(child: SchoolPulseLoader());
      case _ScanState.pickingScope:
        return ListView.builder(
          itemCount: _availableScopes.length,
          itemBuilder: (_, index) => ListTile(
            title: Text(_availableScopes[index].name),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _selectScope(_availableScopes[index]),
          ),
        );
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
          statusLabel: 'Already marked present',
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
          statusLabel: 'Not a School Pulse student card',
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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/verification/domain/entities/resolved_identity.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/domain/repositories/identity_resolver.dart';
import 'package:school_pulse/features/gate_ops/domain/entities/gate.dart';
import 'package:school_pulse/core/services/nfc/nfc_credential_reader_adapter.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../data/datasources/device_id_provider.dart';
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_scope.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import '../widgets/scan_result_card.dart';

class NfcScanScreen extends StatefulWidget {
  const NfcScanScreen({super.key});

  @override
  State<NfcScanScreen> createState() => _NfcScanScreenState();
}

enum _ScanState {
  resolvingScope,
  pickingScope,
  ready,
  scanning,
  resolving,
  success,
  duplicate,
  invalid,
  wrongClass,
  denied,
  failed,
}

class _NfcScanScreenState extends State<NfcScanScreen> {
  final _adapter = NfcCredentialReaderAdapter();
  StreamSubscription<ScanCredential>? _subscription;
  Timer? _scanTimeout;
  Timer? _autoContinueTimer;
  Timer? _syncTimer;
  _ScanState _state = _ScanState.resolvingScope;
  String _name = '';
  String _subtitle = '';
  String? _photoUrl;
  DateTime? _scannedAt;
  String _deniedMessage = '';
  VerificationContext? _verificationContext;

  AttendanceScope? _scope;
  List<AttendanceScope> _availableScopes = const [];
  final Set<String> _presentPersonIds = {};
  int _rosterSize = 0;

  static const _sessionType = 'daily';

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AttendanceBloc>().add(
        LoadScopesRequested(
          schoolId: authState.user.schoolId,
          category: AttendanceCategory.students,
          operatorUser: authState.user,
        ),
      );
      context.read<AttendanceBloc>().add(
        SyncPendingAttendanceRequested(schoolId: authState.user.schoolId),
      );
    }
    // A 30s sweep is frequent enough that a mid-session reconnect clears the
    // queue before DONE, without hammering Firestore while mostly offline.
    _syncTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      final auth = context.read<AuthBloc>().state;
      if (auth is AuthAuthenticated) {
        context.read<AttendanceBloc>().add(
          SyncPendingAttendanceRequested(schoolId: auth.user.schoolId),
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _scanTimeout?.cancel();
    _autoContinueTimer?.cancel();
    _syncTimer?.cancel();
    _adapter.stop();
    _adapter.dispose();
    super.dispose();
  }

  void _selectScope(AttendanceScope scope) {
    setState(() {
      _scope = scope;
      _state = _ScanState.ready;
    });
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<AttendanceBloc>().add(
        LoadRosterRequested(
          schoolId: authState.user.schoolId,
          category: AttendanceCategory.students,
          scopeId: scope.id,
          operatorUser: authState.user,
        ),
      );
    }
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
    // IdentityResolver (used in _resolveCard) does - so this placeholder
    // Gate never influences the actual hardware read. schoolId is real
    // since that's what IdentityResolver._resolveNfc scopes the lookup by.
    _verificationContext = VerificationContext(
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
    );
    await _adapter.start(_verificationContext!);
  }

  Future<void> _resolveCard(String cardUid) async {
    setState(() => _state = _ScanState.resolving);

    final verificationContext = _verificationContext;
    if (verificationContext == null) return;

    // Routes through the shared IdentityResolver rather than reading the
    // local credential cache directly: the resolver also checks revocation
    // (a lost/stolen card must not still mark attendance) and falls back to
    // Firestore on a cache miss (a card assigned on a different device
    // resolves here too, not just "invalid" until this device happens to
    // sync some other way).
    final resolverResult = await di.sl<IdentityResolver>().resolve(
      NfcScanCredential(cardUid: cardUid, scannedAt: DateTime.now()),
      verificationContext,
    );
    if (!mounted) return;

    final identity = resolverResult.fold((failure) => null, (r) => r);
    if (identity is! StudentResolvedIdentity) {
      HapticFeedback.heavyImpact();
      setState(() => _state = _ScanState.invalid);
      _scheduleAutoContinue();
      return;
    }

    final scope = _scope;
    if (scope != null && identity.classId != scope.id) {
      HapticFeedback.heavyImpact();
      setState(() {
        _name = identity.name;
        _subtitle = identity.studentCode;
        _photoUrl = identity.photoUrl;
        _state = _ScanState.wrongClass;
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

    final user = verificationContext.operatorUser;
    final deviceId = await DeviceIdProvider().getDeviceId();
    if (!mounted) return;
    final record = AttendanceRecord(
      id: '',
      schoolId: user.schoolId,
      category: AttendanceCategory.students,
      scopeId: scope?.id ?? identity.classId,
      scopeName: scope?.name ?? identity.classId,
      sessionType: _sessionType,
      date: _scannedAt!,
      personId: identity.id,
      personName: identity.name,
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

  /// Rapid-attendance UX per spec section 4/5: the teacher never presses
  /// "Scan Another" after a normal tap - the overlay clears itself and a
  /// fresh session opens automatically after a short pause.
  void _scheduleAutoContinue() {
    _autoContinueTimer?.cancel();
    _autoContinueTimer = Timer(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      _startScan();
    });
  }

  void _finishDone() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listener: (context, state) {
        if (state is ScopesLoaded) {
          if (state.scopes.length == 1) {
            _selectScope(state.scopes.first);
          } else if (state.scopes.isEmpty) {
            setState(() {
              _deniedMessage =
                  'No class has been assigned to your account. Contact your '
                  'Institution Administrator.';
              _state = _ScanState.denied;
            });
          } else {
            setState(() {
              _availableScopes = state.scopes;
              _state = _ScanState.pickingScope;
            });
          }
        } else if (state is RosterLoaded) {
          setState(() => _rosterSize = state.roster.length);
        } else if (state is AttendanceMarkSuccess) {
          HapticFeedback.lightImpact();
          setState(() {
            _presentPersonIds.add(state.record.personId);
            _state = _ScanState.success;
          });
          _scheduleAutoContinue();
        } else if (state is AttendanceDuplicate) {
          HapticFeedback.selectionClick();
          setState(() => _state = _ScanState.duplicate);
          _scheduleAutoContinue();
        } else if (state is AttendanceActionDenied) {
          HapticFeedback.heavyImpact();
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
          title: Text(_scope == null ? 'Attendance' : _scope!.name),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            if (_scope != null)
              TextButton(onPressed: _finishDone, child: const Text('DONE')),
          ],
        ),
        body: Column(
          children: [
            if (_scope != null) _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final remaining = (_rosterSize - _presentPersonIds.length).clamp(
      0,
      _rosterSize,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        AppSpacing.m,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Present: ${_presentPersonIds.length} / $_rosterSize',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.success(context),
            ),
          ),
          Text(
            'Remaining: $remaining',
            style: TextStyle(color: AppColors.textMuted(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_state) {
      case _ScanState.resolvingScope:
        return const Center(child: SchoolPulseLoader());
      case _ScanState.pickingScope:
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: _availableScopes.length,
          itemBuilder: (context, index) {
            final scope = _availableScopes[index];
            return Card(
              margin: const EdgeInsets.only(bottom: AppSpacing.m),
              child: ListTile(
                title: Text(scope.name),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _selectScope(scope),
              ),
            );
          },
        );
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
                  'Tap student card',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Hold the card near the top of the phone.',
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
                  'Tap student card',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Hold the card near the top of the phone.',
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
                const SizedBox(height: AppSpacing.xl),
                const SchoolPulseLoader(),
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
          onScanAnother: _startScan,
          onDone: _finishDone,
        );
      case _ScanState.duplicate:
        return ScanResultCard(
          isDuplicate: true,
          name: _name,
          subtitle: _subtitle,
          timeLabel: '',
          statusLabel: 'Already marked present',
          photoUrl: _photoUrl,
          onScanAnother: _startScan,
          onDone: _finishDone,
        );
      case _ScanState.invalid:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.help_outline,
                  color: AppColors.danger(context),
                  size: 64,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Card not recognised',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: AppColors.textPrimary(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Ask the School Admin to register this card.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
              ],
            ),
          ),
        );
      case _ScanState.wrongClass:
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: _photoUrl != null
                      ? NetworkImage(_photoUrl!)
                      : null,
                  child: _photoUrl == null ? const Icon(Icons.person) : null,
                ),
                const SizedBox(height: AppSpacing.l),
                Text(
                  _name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: AppSpacing.s),
                Text(
                  'Not in this class',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning(context),
                  ),
                ),
              ],
            ),
          ),
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
                  onPressed: () => setState(() => _state = _ScanState.ready),
                  child: const Text('Continue'),
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
              const Text('Card was moved too quickly. Tap again.'),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(onPressed: _startScan, child: const Text('Retry')),
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

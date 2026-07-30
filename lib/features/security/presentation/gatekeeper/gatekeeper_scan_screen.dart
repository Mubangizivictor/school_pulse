import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/gatekeeper_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/qr_scanner/domain/entities/scanner_mode.dart';
import 'package:school_pulse/features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/presentation/widgets/verification_scan_screen.dart';
import 'package:school_pulse/features/visitors/domain/entities/visitor.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_bloc.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_event.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_state.dart';
import 'gatekeeper_shared.dart';

enum _ScanResultKind { none, visitorCheckout, visitorPreApproved }

/// Gatekeeper Simple Mode's unified scanner: opens the camera immediately.
/// A raw code is handed to the shared verification engine (identity
/// resolution, permission/gate-scoping, suggested direction, and movement
/// recording all happen the same way as the Reception-mode workflow) -
/// see `VerificationScanScreen`. JSON visitor payloads (pre-approved
/// check-in / visitor-pass checkout) are pre-visitors-phase: out of scope
/// for the shared engine in Phase 1, so they keep using the same inline
/// handling this screen already had.
class GatekeeperScanScreen extends StatefulWidget {
  final Gate gate;
  const GatekeeperScanScreen({super.key, required this.gate});

  @override
  State<GatekeeperScanScreen> createState() => _GatekeeperScanScreenState();
}

class _GatekeeperScanScreenState extends State<GatekeeperScanScreen> {
  _ScanResultKind _kind = _ScanResultKind.none;
  bool _isSubmitting = false;

  String? _visitorId;
  String? _visitorName;
  DateTime? _visitorArrival;
  String? _preApprovedId;
  String? _preApprovedName;
  String? _preApprovedPhone;
  String? _preApprovedHost;
  String? _preApprovedPurpose;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openScanner());
  }

  Future<void> _openScanner() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(
          mode: ScannerMode.security,
          onScan: _handleScan,
        ),
      ),
    );
  }

  Future<void> _handleScan(String code) async {
    Navigator.of(context, rootNavigator: true).pop();
    if (!mounted) return;

    Map<String, dynamic>? data;
    try {
      final decoded = jsonDecode(code);
      if (decoded is Map<String, dynamic>) data = decoded;
    } catch (_) {
      data = null;
    }

    if (data != null && data['type'] == 'pre_approved') {
      setState(() {
        _kind = _ScanResultKind.visitorPreApproved;
        _preApprovedId = data!['id'] as String?;
        _preApprovedName = data['name'] as String?;
        _preApprovedPhone = data['phone'] as String?;
        _preApprovedHost = data['host'] as String?;
        _preApprovedPurpose = data['purpose'] as String?;
      });
      return;
    }

    if (data != null && data['id'] != null && data['name'] != null && data['arrival'] != null) {
      setState(() {
        _kind = _ScanResultKind.visitorCheckout;
        _visitorId = data!['id'] as String;
        _visitorName = data['name'] as String;
        _visitorArrival = DateTime.tryParse(data['arrival'] as String);
      });
      return;
    }

    await _openVerificationEngine(code);
  }

  Future<void> _openVerificationEngine(String rawPayload) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final deviceId = await DeviceIdService().getDeviceId();
    if (!mounted) return;

    final verificationContext = VerificationContext(
      gate: widget.gate,
      operatorUser: authState.user,
      purpose: 'security.identity.verify',
      deviceId: deviceId,
      requestedAt: DateTime.now(),
    );

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => VerificationScanScreen(
          context: verificationContext,
          initialCredential: QrScanCredential(rawPayload: rawPayload, scannedAt: DateTime.now()),
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  bool _isBlacklisted(String? phone, String? name) {
    final visitorsState = context.read<VisitorsBloc>().state;
    if (visitorsState is! VisitorsLoaded) return false;
    return visitorsState.blacklist.any((b) =>
        (phone != null && phone.isNotEmpty && b.phone == phone) ||
        (name != null && name.isNotEmpty && b.fullName.toLowerCase() == name.toLowerCase()));
  }

  void _confirmVisitorCheckout() {
    if (_visitorId == null || _visitorArrival == null) return;
    setState(() => _isSubmitting = true);
    final now = DateTime.now();
    context.read<VisitorsBloc>().add(CheckOutVisitorEvent(
          visitorId: _visitorId!,
          departureTime: now,
          duration: formatVisitDuration(_visitorArrival!, now),
        ));
    Navigator.of(context).pop();
  }

  void _confirmPreApprovedCheckIn() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _preApprovedId == null) return;
    setState(() => _isSubmitting = true);

    final visitor = Visitor(
      id: const Uuid().v4(),
      schoolId: authState.user.schoolId,
      fullName: _preApprovedName ?? 'Visitor',
      phone: _preApprovedPhone ?? '',
      host: _preApprovedHost ?? '',
      department: '',
      purpose: _preApprovedPurpose ?? '',
      arrivalTime: DateTime.now(),
      status: VisitorStatus.checkedIn,
      deviceId: '',
      gateId: widget.gate.id,
    );
    context.read<VisitorsBloc>().add(CheckInNewVisitor(visitor, preApprovedId: _preApprovedId));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan')),
      body: switch (_kind) {
        _ScanResultKind.none => const Center(child: CircularProgressIndicator()),
        _ScanResultKind.visitorCheckout => _buildVisitorCheckoutConfirm(context),
        _ScanResultKind.visitorPreApproved => _buildPreApprovedConfirm(context),
      },
    );
  }

  Widget _buildVisitorCheckoutConfirm(BuildContext context) {
    final name = _visitorName ?? 'Visitor';
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarInitials(name: name, size: 96),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          if (_visitorArrival != null)
            Text('Arrived ${formatVisitDuration(_visitorArrival!, DateTime.now())} ago', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 32),
          GatekeeperPrimaryButton(
            label: 'CHECK OUT',
            icon: Icons.logout,
            tone: GatekeeperButtonTone.info,
            isLoading: _isSubmitting,
            onPressed: _confirmVisitorCheckout,
          ),
        ],
      ),
    );
  }

  Widget _buildPreApprovedConfirm(BuildContext context) {
    final name = _preApprovedName ?? 'Visitor';
    final blacklisted = _isBlacklisted(_preApprovedPhone, _preApprovedName);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarInitials(name: name, size: 96),
          const SizedBox(height: 16),
          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          if (_preApprovedHost != null) Text('Visiting: $_preApprovedHost', style: Theme.of(context).textTheme.bodyMedium),
          if (_preApprovedPurpose != null) Text(_preApprovedPurpose!, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          if (blacklisted)
            AlertBanner(
              title: 'Security Alert',
              message: 'This person is on the security blacklist. Call a supervisor before allowing entry.',
              color: Colors.red,
              icon: Icons.warning_amber_rounded,
            ),
          const SizedBox(height: 20),
          GatekeeperPrimaryButton(
            label: blacklisted ? 'BLOCKED — CALL SUPERVISOR' : 'CHECK IN',
            icon: blacklisted ? Icons.block : Icons.login,
            tone: blacklisted ? GatekeeperButtonTone.danger : GatekeeperButtonTone.success,
            isLoading: _isSubmitting,
            onPressed: blacklisted ? null : _confirmPreApprovedCheckIn,
          ),
        ],
      ),
    );
  }
}

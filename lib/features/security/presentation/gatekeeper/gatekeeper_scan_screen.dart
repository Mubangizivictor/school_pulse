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
import 'package:school_pulse/features/security/data/models/security_models.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_event.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/features/visitors/domain/entities/visitor.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_bloc.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_event.dart';
import 'package:school_pulse/features/visitors/presentation/bloc/visitors_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'gatekeeper_shared.dart';

enum _ScanResultKind { none, student, visitorCheckout, visitorPreApproved, notFound }

/// Gatekeeper Simple Mode's unified scanner: opens the camera immediately,
/// then routes the decoded code to the right flow automatically - a raw
/// code resolves as a student ID (StudentIdentityRepository), a JSON
/// `{type:'pre_approved', ...}` payload as a pre-approved visitor, and any
/// other JSON payload with id/name/arrival as a visitor pass checkout
/// (mirrors VisitorScannerScreen's existing QR encoding, Reception mode).
class GatekeeperScanScreen extends StatefulWidget {
  final Gate gate;
  const GatekeeperScanScreen({super.key, required this.gate});

  @override
  State<GatekeeperScanScreen> createState() => _GatekeeperScanScreenState();
}

class _GatekeeperScanScreenState extends State<GatekeeperScanScreen> {
  _ScanResultKind _kind = _ScanResultKind.none;
  bool _isSubmitting = false;

  Student? _student;
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

    final result = await di.sl<StudentIdentityRepository>().getStudentByUniqueId(code);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _kind = _ScanResultKind.notFound),
      (student) {
        if (student == null) {
          setState(() => _kind = _ScanResultKind.notFound);
        } else {
          setState(() {
            _kind = _ScanResultKind.student;
            _student = student;
          });
        }
      },
    );
  }

  bool _isBlacklisted(String? phone, String? name) {
    final visitorsState = context.read<VisitorsBloc>().state;
    if (visitorsState is! VisitorsLoaded) return false;
    return visitorsState.blacklist.any((b) =>
        (phone != null && phone.isNotEmpty && b.phone == phone) ||
        (name != null && name.isNotEmpty && b.fullName.toLowerCase() == name.toLowerCase()));
  }

  Future<void> _confirmStudentMovement(String direction) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _student == null) return;
    setState(() => _isSubmitting = true);
    final deviceId = await DeviceIdService().getDeviceId();
    if (!mounted) return;

    final movement = StudentMovementModel(
      id: const Uuid().v4(),
      studentId: _student!.id,
      studentName: _student!.name,
      className: _student!.classId,
      timestamp: DateTime.now(),
      gateId: widget.gate.id,
      direction: direction,
      movementType: computeMovementType(widget.gate, direction),
      verificationMethod: 'QR Student ID',
      officerId: authState.user.id,
      deviceId: deviceId,
      schoolId: authState.user.schoolId,
    );
    context.read<SecurityBloc>().add(RecordStudentMovementRequested(movement));
    if (mounted) Navigator.of(context).pop();
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
        _ScanResultKind.notFound => _buildNotFound(context),
        _ScanResultKind.student => _buildStudentConfirm(context),
        _ScanResultKind.visitorCheckout => _buildVisitorCheckoutConfirm(context),
        _ScanResultKind.visitorPreApproved => _buildPreApprovedConfirm(context),
      },
    );
  }

  Widget _buildNotFound(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 72, color: Theme.of(context).colorScheme.error),
          const SizedBox(height: 16),
          const Text('No match found', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('This code isn\'t recognized. Try scanning again.', textAlign: TextAlign.center),
          const SizedBox(height: 24),
          GatekeeperPrimaryButton(
            label: 'SCAN AGAIN',
            icon: Icons.qr_code_scanner,
            tone: GatekeeperButtonTone.info,
            onPressed: _openScanner,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentConfirm(BuildContext context) {
    final student = _student!;
    final securityState = context.watch<SecurityBloc>().state;
    final suggestedDirection = suggestStudentDirection(securityState.studentMovements, student.id);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AvatarInitials(name: student.name, size: 96),
          const SizedBox(height: 16),
          Text(student.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(student.studentCode, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 12),
          StatusBadge(
            label: suggestedDirection == 'In' ? 'Suggested: Enter' : 'Suggested: Leave',
            color: suggestedDirection == 'In' ? Colors.green : Colors.blueGrey,
            icon: suggestedDirection == 'In' ? Icons.login : Icons.logout,
          ),
          const SizedBox(height: 32),
          GatekeeperPrimaryButton(
            label: 'ENTER',
            icon: Icons.login,
            tone: GatekeeperButtonTone.success,
            isLoading: _isSubmitting,
            onPressed: () => _confirmStudentMovement('In'),
          ),
          const SizedBox(height: 12),
          GatekeeperPrimaryButton(
            label: 'LEAVE',
            icon: Icons.logout,
            tone: GatekeeperButtonTone.info,
            isLoading: _isSubmitting,
            onPressed: () => _confirmStudentMovement('Out'),
          ),
        ],
      ),
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

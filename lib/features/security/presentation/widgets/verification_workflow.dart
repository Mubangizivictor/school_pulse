import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/qr_scanner/domain/entities/scanner_mode.dart';
import 'package:school_pulse/features/qr_scanner/presentation/screens/qr_scanner_screen.dart';
import 'package:school_pulse/features/student/domain/entities/parent_access_code.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/resolve_parent_access_code.dart';
import 'package:school_pulse/features/student/domain/usecases/search_students.dart';
import 'package:school_pulse/features/student_identity/domain/repositories/student_identity_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../data/models/security_models.dart';
import '../../domain/entities/security_entities.dart';
import '../../domain/entities/verification_method.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_event.dart';
import '../bloc/security_state.dart';

enum _Step { gateSelect, methodSelect, manualStudentSearch, staffSearch, parentCode, fingerprintStub, confirm }

class VerificationWorkflow extends StatefulWidget {
  const VerificationWorkflow({super.key});

  @override
  State<VerificationWorkflow> createState() => _VerificationWorkflowState();
}

class _VerificationWorkflowState extends State<VerificationWorkflow> {
  _Step _step = _Step.gateSelect;
  Gate? _selectedGate;
  VerificationMethod? _selectedMethod;

  Student? _resolvedStudent;
  UserEntity? _resolvedStaff;
  ParentAccessCode? _resolvedParentCode;
  String? _selectedChildIdFromParentCode;
  String? _selectedChildNameFromParentCode;

  bool _isSearching = false;
  bool _isSubmitting = false;
  List<Student> _studentResults = [];
  List<UserEntity> _staffResults = [];
  final _searchController = TextEditingController();
  final _parentCodeController = TextEditingController();

  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _parentCodeController.dispose();
    super.dispose();
  }

  void _goTo(_Step step) => setState(() => _step = step);

  void _selectGate(Gate gate) {
    setState(() {
      _selectedGate = gate;
      _step = _Step.methodSelect;
    });
  }

  Future<void> _selectMethod(VerificationMethod method) async {
    setState(() => _selectedMethod = method);

    switch (method) {
      case VerificationMethod.qrStudentId:
      case VerificationMethod.digitalId:
        await _scanQrCode();
        break;
      case VerificationMethod.manualSearch:
        _goTo(_Step.manualStudentSearch);
        break;
      case VerificationMethod.staffId:
        _goTo(_Step.staffSearch);
        break;
      case VerificationMethod.parentCode:
        _goTo(_Step.parentCode);
        break;
      case VerificationMethod.fingerprint:
        _goTo(_Step.fingerprintStub);
        break;
      case VerificationMethod.visitorPass:
        Navigator.of(context).pop();
        if (mounted) context.push('/staff/security/visitors/scan');
        break;
    }
  }

  Future<void> _scanQrCode() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(
          mode: ScannerMode.security,
          onScan: (code) async {
            Navigator.of(context, rootNavigator: true).pop();
            final result = await di.sl<StudentIdentityRepository>().getStudentByUniqueId(code);
            result.fold(
              (failure) => _showSnack('Lookup failed: ${failure.message}', isError: true),
              (student) {
                if (student == null) {
                  _showSnack('No student found for this code', isError: true);
                  _goTo(_Step.methodSelect);
                } else {
                  setState(() {
                    _resolvedStudent = student;
                    _step = _Step.confirm;
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _searchStudents(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final result = await di.sl<SearchStudents>()(schoolId: _schoolId, query: query.trim());
    if (!mounted) return;
    result.fold(
      (failure) => _showSnack('Search failed: ${failure.message}', isError: true),
      (students) => setState(() => _studentResults = students),
    );
    setState(() => _isSearching = false);
  }

  Future<void> _searchStaff(String query) async {
    setState(() => _isSearching = true);
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    result.fold(
      (failure) => _showSnack('Search failed: ${failure.message}', isError: true),
      (members) {
        final q = query.trim().toLowerCase();
        setState(() {
          _staffResults = members.where((m) {
            if (m.schoolId != _schoolId) return false;
            if (q.isEmpty) return true;
            return m.name.toLowerCase().contains(q) || (m.staffCode ?? '').toLowerCase().contains(q);
          }).toList();
        });
      },
    );
    setState(() => _isSearching = false);
  }

  Future<void> _verifyParentCode(String code) async {
    if (code.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final result = await di.sl<ResolveParentAccessCode>()(code.trim());
    if (!mounted) return;
    result.fold(
      (failure) => _showSnack('Invalid or inactive code', isError: true),
      (accessCode) => setState(() => _resolvedParentCode = accessCode),
    );
    setState(() => _isSearching = false);
  }

  void _showSnack(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null),
    );
  }

  /// Arrival/Late Arrival on the way in, Departure/Early Departure on the
  /// way out, computed from the gate's configured operating hours (falls
  /// back to a plain Arrival/Departure if the gate has none set).
  String _computeMovementType(String direction) {
    final hours = _selectedGate?.operatingHours ?? const {};
    final open = _parseTimeToday(hours['open'] as String?);
    final close = _parseTimeToday(hours['close'] as String?);
    final now = DateTime.now();

    if (direction == 'In') {
      if (open != null && now.isAfter(open.add(const Duration(minutes: 15)))) return 'Late Arrival';
      return 'Arrival';
    } else {
      if (close != null && now.isBefore(close)) return 'Early Departure';
      return 'Departure';
    }
  }

  DateTime? _parseTimeToday(String? hhmm) {
    if (hhmm == null || !hhmm.contains(':')) return null;
    final parts = hhmm.split(':');
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  Future<void> _confirmMovement(String direction) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _selectedGate == null) return;
    final securityBloc = context.read<SecurityBloc>();

    setState(() => _isSubmitting = true);
    final deviceId = await DeviceIdService().getDeviceId();
    if (!mounted) return;
    final movementType = _computeMovementType(direction);

    if (_resolvedStaff != null) {
      final movement = StaffMovementModel(
        id: '',
        staffId: _resolvedStaff!.id,
        staffName: _resolvedStaff!.name,
        timestamp: DateTime.now(),
        gateId: _selectedGate!.id,
        direction: direction,
        verificationMethod: _selectedMethod?.label ?? 'Staff ID',
        officerId: authState.user.id,
        schoolId: authState.user.schoolId,
      );
      securityBloc.add(RecordStaffMovementRequested(movement));
    } else if (_resolvedStudent != null) {
      final movement = StudentMovementModel(
        id: '',
        studentId: _resolvedStudent!.id,
        studentName: _resolvedStudent!.name,
        className: _resolvedStudent!.classId,
        timestamp: DateTime.now(),
        gateId: _selectedGate!.id,
        direction: direction,
        movementType: movementType,
        verificationMethod: _selectedMethod?.label ?? 'Manual',
        officerId: authState.user.id,
        deviceId: deviceId,
        schoolId: authState.user.schoolId,
      );
      securityBloc.add(RecordStudentMovementRequested(movement));
    } else if (_resolvedParentCode != null && _selectedChildIdFromParentCode != null) {
      final movement = StudentMovementModel(
        id: '',
        studentId: _selectedChildIdFromParentCode!,
        studentName: _selectedChildNameFromParentCode ?? 'Student',
        className: '',
        timestamp: DateTime.now(),
        gateId: _selectedGate!.id,
        direction: direction,
        movementType: direction == 'Out' ? 'Authorized Pickup' : movementType,
        verificationMethod: VerificationMethod.parentCode.label,
        officerId: authState.user.id,
        deviceId: deviceId,
        schoolId: authState.user.schoolId,
        pickupDetails: {
          'parentCode': _resolvedParentCode!.parentCode,
          'parentName': _resolvedParentCode!.parentName,
          'phoneNumber': _resolvedParentCode!.phoneNumber,
        },
      );
      securityBloc.add(RecordStudentMovementRequested(movement));
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7,
      child: switch (_step) {
        _Step.gateSelect => _buildGateSelect(),
        _Step.methodSelect => _buildMethodSelect(),
        _Step.manualStudentSearch => _buildStudentSearch(),
        _Step.staffSearch => _buildStaffSearch(),
        _Step.parentCode => _buildParentCode(),
        _Step.fingerprintStub => _buildFingerprintStub(),
        _Step.confirm => _buildConfirm(),
      },
    );
  }

  Widget _buildGateSelect() {
    return BlocBuilder<SecurityBloc, SecurityState>(
      builder: (context, state) {
        if (state.gates.isEmpty) {
          return const Center(child: Text('No gates configured. Ask an admin to set up a gate first.'));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Gate', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: state.gates.length,
                itemBuilder: (context, index) {
                  final gate = state.gates[index];
                  return ListTile(
                    leading: const Icon(Icons.door_front_door_outlined),
                    title: Text(gate.name),
                    subtitle: Text(gate.location),
                    onTap: () => _selectGate(gate),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMethodSelect() {
    final methods = (_selectedGate?.requiredVerificationMethods ?? const [])
        .map((id) => VerificationMethod.fromId(id))
        .whereType<VerificationMethod>()
        .toList();
    final options = methods.isEmpty ? VerificationMethod.values : methods;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_selectedGate?.name ?? ''} — Select Verification Method',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: options.map((method) => _MethodCard(
                icon: _iconFor(method),
                label: method.label,
                onTap: () => _selectMethod(method),
              )).toList(),
        ),
      ],
    );
  }

  IconData _iconFor(VerificationMethod method) {
    switch (method) {
      case VerificationMethod.qrStudentId:
      case VerificationMethod.digitalId:
        return Icons.qr_code_scanner;
      case VerificationMethod.fingerprint:
        return Icons.fingerprint;
      case VerificationMethod.manualSearch:
        return Icons.search;
      case VerificationMethod.parentCode:
        return Icons.family_restroom;
      case VerificationMethod.visitorPass:
        return Icons.badge_outlined;
      case VerificationMethod.staffId:
        return Icons.badge;
    }
  }

  Widget _buildStudentSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Search Student', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Name, student code or admission number',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _searchStudents(_searchController.text),
            ),
          ),
          onSubmitted: _searchStudents,
        ),
        const SizedBox(height: 12),
        if (_isSearching) const Center(child: CircularProgressIndicator()),
        Expanded(
          child: ListView.builder(
            itemCount: _studentResults.length,
            itemBuilder: (context, index) {
              final student = _studentResults[index];
              return ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(student.name),
                subtitle: Text(student.studentCode),
                onTap: () => setState(() {
                  _resolvedStudent = student;
                  _step = _Step.confirm;
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStaffSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Search Staff', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Name or staff code',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          ),
          onChanged: _searchStaff,
        ),
        const SizedBox(height: 12),
        if (_isSearching) const Center(child: CircularProgressIndicator()),
        Expanded(
          child: ListView.builder(
            itemCount: _staffResults.length,
            itemBuilder: (context, index) {
              final staff = _staffResults[index];
              return ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: Text(staff.name),
                subtitle: Text(staff.staffCode ?? staff.email),
                onTap: () => setState(() {
                  _resolvedStaff = staff;
                  _step = _Step.confirm;
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildParentCode() {
    final code = _resolvedParentCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Parent Code Verification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _parentCodeController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Parent access code',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => _verifyParentCode(_parentCodeController.text),
            ),
          ),
          onSubmitted: _verifyParentCode,
        ),
        const SizedBox(height: 16),
        if (_isSearching) const Center(child: CircularProgressIndicator()),
        if (code != null) ...[
          Text('Linked children — select who is being picked up:', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: code.studentIds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.child_care),
                  title: Text(code.studentNames.length > index ? code.studentNames[index] : 'Student'),
                  onTap: () => setState(() {
                    _selectedChildIdFromParentCode = code.studentIds[index];
                    _selectedChildNameFromParentCode = code.studentNames.length > index ? code.studentNames[index] : 'Student';
                    _step = _Step.confirm;
                  }),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFingerprintStub() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.fingerprint, size: 64, color: Colors.grey),
        const SizedBox(height: 16),
        const Text('Fingerprint verification is not available on this device yet.', textAlign: TextAlign.center),
        const SizedBox(height: 16),
        TextButton(onPressed: () => _goTo(_Step.methodSelect), child: const Text('Choose another method')),
      ],
    );
  }

  Widget _buildConfirm() {
    final name = _resolvedStaff?.name ?? _resolvedStudent?.name ?? _selectedChildNameFromParentCode ?? 'Unknown';
    final subtitle = _resolvedStaff != null
        ? 'Staff • ${_resolvedStaff!.staffCode ?? ''}'
        : _resolvedStudent != null
            ? 'Student • ${_resolvedStudent!.studentCode}'
            : 'Student (via parent code)';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(radius: 32, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?')),
        const SizedBox(height: 12),
        Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _isSubmitting ? null : () => _confirmMovement('In'),
              icon: const Icon(Icons.login),
              label: const Text('Confirm In'),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : () => _confirmMovement('Out'),
              style: FilledButton.styleFrom(backgroundColor: Colors.blueGrey),
              icon: const Icon(Icons.logout),
              label: const Text('Confirm Out'),
            ),
          ],
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MethodCard({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        width: 90,
        child: Column(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

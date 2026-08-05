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
import 'package:school_pulse/features/verification/domain/entities/scan_credential.dart';
import 'package:school_pulse/features/verification/domain/entities/verification_context.dart';
import 'package:school_pulse/features/verification/presentation/widgets/verification_scan_screen.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/security_entities.dart';
import '../../domain/entities/verification_method.dart';
import '../bloc/security_bloc.dart';
import '../bloc/security_state.dart';

enum _Step {
  gateSelect,
  methodSelect,
  manualStudentSearch,
  staffSearch,
  parentCode,
  fingerprintStub,
}

class VerificationWorkflow extends StatefulWidget {
  const VerificationWorkflow({super.key});

  @override
  State<VerificationWorkflow> createState() => _VerificationWorkflowState();
}

class _VerificationWorkflowState extends State<VerificationWorkflow> {
  _Step _step = _Step.gateSelect;
  Gate? _selectedGate;

  bool _isSearching = false;
  List<Student> _studentResults = [];
  List<UserEntity> _staffResults = [];
  final _searchController = TextEditingController();
  final _parentCodeController = TextEditingController();
  ParentAccessCode? _resolvedParentCode;

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

  Future<VerificationContext> _buildContext() async {
    final authState = context.read<AuthBloc>().state;
    final operatorUser = (authState as AuthAuthenticated).user;
    final deviceId = await DeviceIdService().getDeviceId();
    return VerificationContext(
      gate: _selectedGate!,
      operatorUser: operatorUser,
      purpose: 'security.identity.verify',
      deviceId: deviceId,
      requestedAt: DateTime.now(),
    );
  }

  Future<void> _openScanScreen(ScanCredential credential) async {
    final verificationContext = await _buildContext();
    if (!mounted) return;
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => VerificationScanScreen(
          context: verificationContext,
          initialCredential: credential,
        ),
      ),
    );
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _scanQrCode() async {
    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (_) => QrScannerScreen(
          mode: ScannerMode.security,
          onScan: (code) async {
            Navigator.of(context, rootNavigator: true).pop();
            await _openScanScreen(
              QrScanCredential(rawPayload: code, scannedAt: DateTime.now()),
            );
          },
        ),
      ),
    );
  }

  Future<void> _searchStudents(String query) async {
    if (query.trim().isEmpty) return;
    setState(() => _isSearching = true);
    final result = await di.sl<SearchStudents>()(
      schoolId: _schoolId,
      query: query.trim(),
    );
    if (!mounted) return;
    result.fold(
      (failure) =>
          _showSnack('Search failed: ${failure.message}', isError: true),
      (students) => setState(() => _studentResults = students),
    );
    setState(() => _isSearching = false);
  }

  Future<void> _searchStaff(String query) async {
    setState(() => _isSearching = true);
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    result.fold(
      (failure) =>
          _showSnack('Search failed: ${failure.message}', isError: true),
      (members) {
        final q = query.trim().toLowerCase();
        setState(() {
          _staffResults = members.where((m) {
            if (m.schoolId != _schoolId) return false;
            if (q.isEmpty) return true;
            return m.name.toLowerCase().contains(q) ||
                (m.staffCode ?? '').toLowerCase().contains(q);
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
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : null,
      ),
    );
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
      },
    );
  }

  Widget _buildGateSelect() {
    return BlocBuilder<SecurityBloc, SecurityState>(
      builder: (context, state) {
        if (state.gates.isEmpty) {
          return const Center(
            child: Text(
              'No gates configured. Ask an admin to set up a gate first.',
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Gate',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
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
        Text(
          '${_selectedGate?.name ?? ''} — Select Verification Method',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: options
              .map(
                (method) => _MethodCard(
                  icon: _iconFor(method),
                  label: method.label,
                  onTap: () => _selectMethod(method),
                ),
              )
              .toList(),
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
        const Text(
          'Search Student',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
                onTap: () => _openScanScreen(
                  ManualCodeScanCredential(code: student.studentCode),
                ),
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
        const Text(
          'Search Staff',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        TextField(
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'Name or staff code',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
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
                onTap: () => _openScanScreen(
                  StaffLookupScanCredential(staffId: staff.id),
                ),
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
        const Text(
          'Parent Code Verification',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
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
          Text(
            'Linked children — select who is being picked up:',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: code.studentIds.length,
              itemBuilder: (context, index) {
                final childName = code.studentNames.length > index
                    ? code.studentNames[index]
                    : 'Student';
                return ListTile(
                  leading: const Icon(Icons.child_care),
                  title: Text(childName),
                  onTap: () => _openScanScreen(
                    ParentCodeScanCredential(
                      code: code.parentCode,
                      preSelectedChildId: code.studentIds[index],
                      preSelectedChildName: childName,
                    ),
                  ),
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
        const Text(
          'Fingerprint verification is not available on this device yet.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => _goTo(_Step.methodSelect),
          child: const Text('Choose another method'),
        ),
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MethodCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

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
            Text(
              label,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

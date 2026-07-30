import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/notification/notification_service.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/security/data/models/security_models.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/domain/entities/verification_method.dart';
import 'package:school_pulse/features/security/domain/usecases/security_usecases.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_event.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/features/visitors/presentation/widgets/signature_pad.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../bloc/visitors_bloc.dart';
import '../bloc/visitors_event.dart';
import '../../domain/entities/visitor.dart';
import 'package:uuid/uuid.dart';

class StudentPickupPage extends StatefulWidget {
  const StudentPickupPage({super.key});

  @override
  State<StudentPickupPage> createState() => _StudentPickupPageState();
}

class _StudentPickupPageState extends State<StudentPickupPage> {
  final _searchController = TextEditingController();
  final _guardianNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _relationController = TextEditingController();

  Student? _selectedStudent;
  bool _isVerified = false;
  bool _isSubmitting = false;

  List<PickupAuthorization> _authorizations = [];
  bool _isLoadingAuthorizations = false;
  PickupAuthorization? _matchedAuthorization;
  bool _overrideNotAuthorized = false;
  Gate? _selectedGate;

  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void initState() {
    super.initState();
    context.read<SecurityBloc>().add(WatchGatesRequested(_schoolId));
    _guardianNameController.addListener(_matchGuardianName);
  }

  @override
  void dispose() {
    _guardianNameController.removeListener(_matchGuardianName);
    super.dispose();
  }

  void _matchGuardianName() {
    final query = _guardianNameController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() => _matchedAuthorization = null);
      return;
    }
    PickupAuthorization? match;
    for (final auth in _authorizations) {
      if (auth.authorizedPersonName.toLowerCase() == query) {
        match = auth;
        break;
      }
    }
    setState(() => _matchedAuthorization = match);
  }

  Future<void> _loadAuthorizations(String studentId) async {
    setState(() => _isLoadingAuthorizations = true);
    final result = await di.sl<GetPickupAuthorizations>()(_schoolId, studentId);
    if (!mounted) return;
    result.fold(
      (failure) => setState(() => _authorizations = []),
      (authorizations) => setState(() => _authorizations = authorizations),
    );
    setState(() => _isLoadingAuthorizations = false);
  }

  bool get _canSubmit =>
      _isVerified && _selectedGate != null && (_matchedAuthorization != null || _overrideNotAuthorized) && !_isSubmitting;

  Future<void> _submitPickup() async {
    if (!_canSubmit || _selectedStudent == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    final securityBloc = context.read<SecurityBloc>();
    final student = _selectedStudent!;
    final gate = _selectedGate!;

    setState(() => _isSubmitting = true);

    final visitor = Visitor(
      id: const Uuid().v4(),
      schoolId: authState.user.schoolId,
      fullName: _guardianNameController.text,
      phone: _phoneController.text,
      host: student.name,
      department: 'Student Pickup',
      purpose: 'Picking up student: ${student.name} (${student.studentId})',
      category: VisitorCategory.parent,
      arrivalTime: DateTime.now(),
      status: VisitorStatus.checkedIn,
      deviceId: 'local_device',
      studentId: student.id,
    );
    context.read<VisitorsBloc>().add(CheckInNewVisitor(visitor));

    final deviceId = await DeviceIdService().getDeviceId();
    if (!mounted) return;

    final movement = StudentMovementModel(
      id: const Uuid().v4(),
      studentId: student.id,
      studentName: student.name,
      className: student.classId,
      timestamp: DateTime.now(),
      gateId: gate.id,
      direction: 'Out',
      movementType: 'Authorized Pickup',
      verificationMethod: VerificationMethod.manualSearch.label,
      officerId: authState.user.id,
      deviceId: deviceId,
      schoolId: authState.user.schoolId,
      pickupDetails: {
        'guardianName': _guardianNameController.text.trim(),
        'guardianPhone': _phoneController.text.trim(),
        'relationship': _relationController.text.trim(),
        'matchedAuthorizationId': _matchedAuthorization?.id,
        'overrideNotAuthorized': _matchedAuthorization == null && _overrideNotAuthorized,
      },
    );
    securityBloc.add(RecordStudentMovementRequested(movement));

    if (student.parentIds.isNotEmpty) {
      await NotificationService().sendStudentAlert(
        studentId: student.id,
        parentIds: student.parentIds,
        title: 'Pickup Confirmed',
        body: '${student.name} was picked up by ${_guardianNameController.text.trim()} at ${TimeOfDay.now().format(context)}.',
      );
    }

    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Pickup logged for ${student.name}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Pickup Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BlocBuilder<SecurityBloc, SecurityState>(
              builder: (context, state) {
                if (state.gates.isEmpty) return const SizedBox.shrink();
                _selectedGate ??= state.gates.first;
                return DropdownButtonFormField<Gate>(
                  initialValue: state.gates.contains(_selectedGate) ? _selectedGate : state.gates.first,
                  decoration: const InputDecoration(labelText: 'Gate', border: OutlineInputBorder()),
                  items: state.gates.map((g) => DropdownMenuItem(value: g, child: Text(g.name))).toList(),
                  onChanged: (g) => setState(() => _selectedGate = g),
                );
              },
            ),
            const SizedBox(height: 16),
            const Text('Search Student', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Enter Student ID or Name',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      context.read<StudentsBloc>().add(SearchStudents(_searchController.text));
                    }
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  context.read<StudentsBloc>().add(SearchStudents(value));
                }
              },
            ),
            const SizedBox(height: 16),
            BlocBuilder<StudentsBloc, StudentsState>(
              builder: (context, state) {
                if (state is StudentsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StudentsError) {
                  return Text(state.message, style: const TextStyle(color: Colors.red));
                } else if (state is StudentsLoaded) {
                  if (state.students.isEmpty) {
                    return const Text('No students found.');
                  }
                  return Column(
                    children: state.students.map((student) => ListTile(
                      title: Text(student.name),
                      subtitle: Text('${student.className} - ${student.studentId}'),
                      trailing: _selectedStudent?.id == student.id
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedStudent = student;
                          _matchedAuthorization = null;
                          _overrideNotAuthorized = false;
                        });
                        _loadAuthorizations(student.id);
                      },
                    )).toList(),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            if (_selectedStudent != null) ...[
              const SizedBox(height: 24),
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 30, child: Icon(Icons.school)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_selectedStudent!.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text('Class: ${_selectedStudent!.className}'),
                            Text('ID: ${_selectedStudent!.studentId}'),
                          ],
                        ),
                      ),
                      const Icon(Icons.verified, color: Colors.green),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Authorized Pickup Persons', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              if (_isLoadingAuthorizations)
                const Center(child: CircularProgressIndicator())
              else if (_authorizations.isEmpty)
                const Text('No one is pre-authorized for this student. An override reason will be required.',
                    style: TextStyle(color: Colors.orange))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _authorizations.map((auth) => Chip(
                        avatar: auth.photoUrl != null ? CircleAvatar(backgroundImage: NetworkImage(auth.photoUrl!)) : null,
                        label: Text('${auth.authorizedPersonName} (${auth.relationship})'),
                      )).toList(),
                ),
              const SizedBox(height: 24),
              const Text('Guardian Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _guardianNameController,
                decoration: InputDecoration(
                  labelText: 'Guardian Full Name',
                  border: const OutlineInputBorder(),
                  suffixIcon: _matchedAuthorization != null ? const Icon(Icons.verified, color: Colors.green) : null,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _relationController,
                decoration: const InputDecoration(labelText: 'Relationship to Student', border: OutlineInputBorder()),
              ),
              if (_matchedAuthorization == null) ...[
                const SizedBox(height: 12),
                CheckboxListTile(
                  value: _overrideNotAuthorized,
                  onChanged: (v) => setState(() => _overrideNotAuthorized = v ?? false),
                  title: const Text('This person is not on the authorized list — override and log anyway'),
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
              const SizedBox(height: 24),
              const Text('Guardian Signature', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SignaturePad(onChanged: (img) => setState(() => _isVerified = img != null)),
              const SizedBox(height: 32),
              PrimaryButton(
                label: 'Confirm & Log Pickup',
                onPressed: _canSubmit ? _submitPickup : null,
              ),
            ]
          ],
        ),
      ),
    );
  }
}

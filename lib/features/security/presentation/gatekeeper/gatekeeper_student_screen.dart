import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/core/utils/device_id_service.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/gatekeeper_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/security/data/models/security_models.dart';
import 'package:school_pulse/features/security/domain/entities/security_entities.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_bloc.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_event.dart';
import 'package:school_pulse/features/security/presentation/bloc/security_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/search_students.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'gatekeeper_shared.dart';

/// Gatekeeper Simple Mode student entry/exit: search -> pick -> ENTER/LEAVE.
/// A large-button rebuild of the relevant parts of VerificationWorkflow
/// (Reception mode), reusing the same SearchStudents use case and
/// RecordStudentMovementRequested event - no new domain logic.
class GatekeeperStudentScreen extends StatefulWidget {
  final Gate gate;
  const GatekeeperStudentScreen({super.key, required this.gate});

  @override
  State<GatekeeperStudentScreen> createState() => _GatekeeperStudentScreenState();
}

class _GatekeeperStudentScreenState extends State<GatekeeperStudentScreen> {
  final _controller = TextEditingController();
  bool _isSearching = false;
  bool _isSubmitting = false;
  List<Student> _results = [];
  Student? _selected;

  String get _schoolId {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _results = []);
      return;
    }
    setState(() => _isSearching = true);
    final result = await di.sl<SearchStudents>()(schoolId: _schoolId, query: query.trim());
    if (!mounted) return;
    result.fold(
      (failure) => _showSnack('Search failed. Try again.', isError: true),
      (students) => setState(() => _results = students),
    );
    setState(() => _isSearching = false);
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: isError ? Colors.red : null),
    );
  }

  Future<void> _confirm(String direction) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || _selected == null) return;
    setState(() => _isSubmitting = true);
    final deviceId = await DeviceIdService().getDeviceId();
    if (!mounted) return;

    final movement = StudentMovementModel(
      id: const Uuid().v4(),
      studentId: _selected!.id,
      studentName: _selected!.name,
      className: _selected!.classId,
      timestamp: DateTime.now(),
      gateId: widget.gate.id,
      direction: direction,
      movementType: computeMovementType(widget.gate, direction),
      verificationMethod: 'Manual Search',
      officerId: authState.user.id,
      deviceId: deviceId,
      schoolId: authState.user.schoolId,
    );
    context.read<SecurityBloc>().add(RecordStudentMovementRequested(movement));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student')),
      body: BlocListener<SecurityBloc, SecurityState>(
        listenWhen: (p, c) => !identical(p.feedback, c.feedback) && c.feedback != null,
        listener: (context, state) {
          final feedback = state.feedback!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(feedback.message), backgroundColor: feedback.isError ? Colors.red : Colors.green),
          );
        },
        child: _selected == null ? _buildSearch(context) : _buildConfirm(context),
      ),
    );
  }

  Widget _buildSearch(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Search by name or student code', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            autofocus: true,
            style: const TextStyle(fontSize: 18),
            decoration: InputDecoration(
              hintText: 'e.g. Nakato Grace',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(icon: const Icon(Icons.arrow_forward), onPressed: () => _search(_controller.text)),
            ),
            onSubmitted: _search,
            onChanged: _search,
          ),
          const SizedBox(height: 16),
          if (_isSearching) const Center(child: CircularProgressIndicator()),
          Expanded(
            child: ListView.separated(
              itemCount: _results.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final student = _results[index];
                return AppCard(
                  onTap: () => setState(() => _selected = student),
                  child: Row(
                    children: [
                      AvatarInitials(name: student.name, size: 44),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(student.studentCode, style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirm(BuildContext context) {
    final student = _selected!;
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
            onPressed: () => _confirm('In'),
          ),
          const SizedBox(height: 12),
          GatekeeperPrimaryButton(
            label: 'LEAVE',
            icon: Icons.logout,
            tone: GatekeeperButtonTone.info,
            isLoading: _isSubmitting,
            onPressed: () => _confirm('Out'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _isSubmitting ? null : () => setState(() => _selected = null),
            child: const Text('Not this student — search again'),
          ),
        ],
      ),
    );
  }
}

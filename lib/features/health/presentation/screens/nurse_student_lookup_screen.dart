import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/nurse_student_view.dart';
import '../../domain/services/nurse_student_projection_service.dart';

/// The "lookups through NFC/QR/Barcode/Student ID/Manual search/Parent
/// search must return permission-filtered information" requirement, for
/// the Nurse role. Manual search only for now (by name/code) - scan-based
/// lookup would go through the shared verification engine, which is a
/// separate, larger piece of work (see NfcCredentialRepository's own
/// scope note about cross-device sync).
class NurseStudentLookupScreen extends StatefulWidget {
  const NurseStudentLookupScreen({super.key});

  @override
  State<NurseStudentLookupScreen> createState() =>
      _NurseStudentLookupScreenState();
}

class _NurseStudentLookupScreenState extends State<NurseStudentLookupScreen> {
  final _searchController = TextEditingController();
  final _studentRepository = sl<StudentRepository>();
  final _projectionService = sl<NurseStudentProjectionService>();

  List<Student> _results = [];
  bool _searching = false;
  Student? _selectedStudent;
  NurseStudentView? _view;
  String? _error;
  bool _loadingView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      _searching = true;
      _selectedStudent = null;
      _view = null;
      _error = null;
    });

    final result = await _studentRepository.searchStudents(
      schoolId: authState.user.schoolId,
      query: query,
    );
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (students) => setState(() => _results = students),
    );
    if (mounted) setState(() => _searching = false);
  }

  Future<void> _selectStudent(Student student) async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() {
      _selectedStudent = student;
      _view = null;
      _error = null;
      _loadingView = true;
    });

    final result = await _projectionService.getStudentView(
      studentId: student.id,
      schoolId: authState.user.schoolId,
      operatorUser: authState.user,
    );
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (view) => setState(() => _view = view),
    );
    if (mounted) setState(() => _loadingView = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Health Lookup')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search by name or student code',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: _searching ? null : _search,
                  child: _searching
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Search'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_selectedStudent == null) ...[
              Expanded(
                child: _results.isEmpty
                    ? const Center(
                        child: Text(
                          'Search for a student to view their health record',
                        ),
                      )
                    : ListView.builder(
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          final student = _results[index];
                          return ListTile(
                            title: Text(student.name),
                            subtitle: Text(student.studentCode),
                            onTap: () => _selectStudent(student),
                          );
                        },
                      ),
              ),
            ] else ...[
              TextButton.icon(
                onPressed: () => setState(() {
                  _selectedStudent = null;
                  _view = null;
                }),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Back to results'),
              ),
              if (_loadingView) const Center(child: SchoolPulseLoader()),
              if (_error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              if (_view != null) Expanded(child: _NurseViewCard(view: _view!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _NurseViewCard extends StatelessWidget {
  final NurseStudentView view;
  const _NurseViewCard({required this.view});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: view.photoUrl != null
                    ? NetworkImage(view.photoUrl!)
                    : null,
                child: view.photoUrl == null
                    ? const Icon(Icons.person, size: 32)
                    : null,
              ),
              const SizedBox(height: 12),
              Text(view.name, style: Theme.of(context).textTheme.titleLarge),
              Text('Class ${view.classId} · Age ${view.age ?? '—'}'),
              const Divider(height: 32),
              if (!view.hasClinicalAccess)
                const Text(
                  'Clinical details (allergies, medications, emergency contacts) require '
                  'additional permission.',
                  style: TextStyle(color: Colors.grey),
                )
              else ...[
                _InfoRow(
                  'Allergies',
                  (view.allergies ?? []).join(', ').isEmpty
                      ? 'None recorded'
                      : view.allergies!.join(', '),
                ),
                _InfoRow(
                  'Chronic conditions',
                  (view.chronicIllnesses ?? []).join(', ').isEmpty
                      ? 'None recorded'
                      : view.chronicIllnesses!.join(', '),
                ),
                _InfoRow(
                  'Current medications',
                  (view.currentMedications ?? []).join(', ').isEmpty
                      ? 'None recorded'
                      : view.currentMedications!.join(', '),
                ),
                _InfoRow('Emergency contact', view.emergencyContactName ?? '—'),
                _InfoRow('Emergency phone', view.emergencyContactPhone ?? '—'),
                _InfoRow(
                  'Recent clinic visits',
                  '${view.recentClinicVisitCount ?? 0}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

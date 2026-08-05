import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/entities/transport_student_view.dart';
import '../../domain/services/transport_student_projection_service.dart';

class TransportStudentLookupScreen extends StatefulWidget {
  const TransportStudentLookupScreen({super.key});

  @override
  State<TransportStudentLookupScreen> createState() =>
      _TransportStudentLookupScreenState();
}

class _TransportStudentLookupScreenState
    extends State<TransportStudentLookupScreen> {
  final _searchController = TextEditingController();
  final _studentRepository = sl<StudentRepository>();
  final _projectionService = sl<TransportStudentProjectionService>();

  List<Student> _results = [];
  bool _searching = false;
  Student? _selectedStudent;
  TransportStudentView? _view;
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
      appBar: AppBar(title: const Text('Transport Assignment Lookup')),
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
                          'Search for a student to view their route assignment',
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
              if (_loadingView)
                const Center(child: CircularProgressIndicator()),
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
              if (_view != null) _TransportViewCard(view: _view!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TransportViewCard extends StatelessWidget {
  final TransportStudentView view;
  const _TransportViewCard({required this.view});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(view.name, style: Theme.of(context).textTheme.titleLarge),
            const Divider(height: 32),
            _InfoRow('Route', view.routeName),
            _InfoRow('Stop', view.stopName),
            _InfoRow('Status', view.status),
          ],
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
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

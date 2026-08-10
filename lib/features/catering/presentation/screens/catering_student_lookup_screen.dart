import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/entities/catering_eligibility_view.dart';
import '../../domain/services/catering_eligibility_service.dart';

class CateringStudentLookupScreen extends StatefulWidget {
  const CateringStudentLookupScreen({super.key});

  @override
  State<CateringStudentLookupScreen> createState() =>
      _CateringStudentLookupScreenState();
}

class _CateringStudentLookupScreenState
    extends State<CateringStudentLookupScreen> {
  final _searchController = TextEditingController();
  final _studentRepository = sl<StudentRepository>();
  final _eligibilityService = sl<CateringEligibilityService>();

  List<Student> _results = [];
  bool _searching = false;
  Student? _selectedStudent;
  CateringEligibilityView? _view;
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

    final result = await _eligibilityService.getEligibility(
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
      appBar: AppBar(title: const Text('Meal Eligibility Lookup')),
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
                          'Search for a student to verify meal eligibility',
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
                const Center(child: SchoolPulseLoader()),
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
              if (_view != null) _CateringViewCard(view: _view!),
            ],
          ],
        ),
      ),
    );
  }
}

class _CateringViewCard extends StatelessWidget {
  final CateringEligibilityView view;
  const _CateringViewCard({required this.view});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: view.photoUrl != null
                      ? NetworkImage(view.photoUrl!)
                      : null,
                  child: view.photoUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Text(view.name, style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text(view.eligible ? 'Meal Authorized' : 'Not Authorized'),
              backgroundColor: view.eligible
                  ? Colors.green.shade100
                  : Colors.red.shade100,
            ),
            const SizedBox(height: 8),
            Text(view.message),
            if (view.dietaryRestrictions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Dietary restrictions: ${view.dietaryRestrictions.join(', ')}',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

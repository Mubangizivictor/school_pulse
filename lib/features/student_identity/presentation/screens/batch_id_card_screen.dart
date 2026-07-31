import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../../domain/repositories/student_identity_repository.dart';
import '../../domain/services/id_card_service.dart';

/// Prints ID cards for every student in a class as one batch, instead of
/// printing one card at a time from each student's own identity screen.
class BatchIdCardScreen extends StatefulWidget {
  const BatchIdCardScreen({super.key});

  @override
  State<BatchIdCardScreen> createState() => _BatchIdCardScreenState();
}

class _BatchIdCardScreenState extends State<BatchIdCardScreen> {
  final _structureRepository = sl<StructureRepository>();
  final _studentRepository = sl<StudentRepository>();
  final _studentIdentityRepository = sl<StudentIdentityRepository>();
  final _idCardService = sl<IdCardService>();

  List<SchoolClass> _classes = [];
  SchoolClass? _selectedClass;
  StreamSubscription<List<SchoolClass>>? _classesSub;

  List<Student> _students = [];
  final Set<String> _selectedStudentIds = {};
  bool _loadingStudents = false;
  bool _printing = false;

  @override
  void initState() {
    super.initState();
    _classesSub = _structureRepository.watchClasses().listen((classes) {
      setState(() => _classes = classes);
    });
  }

  @override
  void dispose() {
    _classesSub?.cancel();
    super.dispose();
  }

  Future<void> _onClassSelected(SchoolClass? schoolClass) async {
    setState(() {
      _selectedClass = schoolClass;
      _students = [];
      _selectedStudentIds.clear();
    });
    if (schoolClass == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    setState(() => _loadingStudents = true);
    final result = await _studentRepository.searchStudents(
      schoolId: authState.user.schoolId,
      classId: schoolClass.id,
    );
    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(failure.message)));
        }
      },
      (students) {
        setState(() {
          _students = students;
          _selectedStudentIds.addAll(students.map((s) => s.id));
        });
      },
    );
    if (mounted) setState(() => _loadingStudents = false);
  }

  Future<void> _printBatch() async {
    if (_selectedStudentIds.isEmpty) return;
    setState(() => _printing = true);

    final schoolName = context.read<ThemeProvider>().config?.schoolName ?? 'School Pulse Academy';
    final entries = <IdCardBatchEntry>[];
    var skipped = 0;

    for (final student in _students.where((s) => _selectedStudentIds.contains(s.id))) {
      final identityResult = await _studentIdentityRepository.getStudentIdentity(student.id);
      identityResult.fold(
        (_) => skipped++,
        (identity) => entries.add(IdCardBatchEntry(
          studentName: student.name,
          admissionNumber: student.studentId,
          studentId: identity.uniqueSystemId,
          className: student.className,
          stream: '',
          uniqueSystemId: identity.uniqueSystemId,
        )),
      );
    }

    if (entries.isEmpty) {
      setState(() => _printing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('None of the selected students have a generated ID card yet')),
        );
      }
      return;
    }

    try {
      final pdfData = await _idCardService.generateBatchIdCardsPdf(schoolName: schoolName, entries: entries);
      await _idCardService.printIdCard(pdfData);
      if (mounted && skipped > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Printed ${entries.length} card(s). Skipped $skipped without a generated identity.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to print batch: $e')));
      }
    } finally {
      if (mounted) setState(() => _printing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Batch Print ID Cards')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<SchoolClass>(
              initialValue: _selectedClass,
              decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
              items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
              onChanged: _onClassSelected,
              hint: _classes.isEmpty ? const Text('Loading classes…') : const Text('Select a class'),
            ),
          ),
          if (_loadingStudents) const Expanded(child: Center(child: CircularProgressIndicator())),
          if (!_loadingStudents && _selectedClass != null && _students.isEmpty)
            const Expanded(child: Center(child: Text('No students in this class'))),
          if (!_loadingStudents && _students.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _students.length,
                itemBuilder: (context, index) {
                  final student = _students[index];
                  return CheckboxListTile(
                    value: _selectedStudentIds.contains(student.id),
                    title: Text(student.name),
                    subtitle: Text(student.studentCode),
                    onChanged: (checked) {
                      setState(() {
                        if (checked ?? false) {
                          _selectedStudentIds.add(student.id);
                        } else {
                          _selectedStudentIds.remove(student.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: _students.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: _printing ? null : _printBatch,
              icon: _printing
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.print),
              label: Text('Print ${_selectedStudentIds.length} Card(s)'),
            ),
    );
  }
}

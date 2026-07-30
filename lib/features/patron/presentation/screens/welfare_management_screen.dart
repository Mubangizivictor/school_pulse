import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;

class WelfareManagementScreen extends StatefulWidget {
  const WelfareManagementScreen({super.key});

  @override
  State<WelfareManagementScreen> createState() =>
      _WelfareManagementScreenState();
}

class _WelfareManagementScreenState extends State<WelfareManagementScreen> {
  List<Student> _students = const [];

  AuthAuthenticated? get _auth {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state : null;
  }

  @override
  void initState() {
    super.initState();
    final schoolId = _auth?.user.schoolId ?? '';
    context.read<PatronBloc>().add(WatchWelfareRecords(schoolId: schoolId));
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final auth = _auth;
    if (auth == null || auth.user.schoolId.isEmpty) return;
    final result = await di.sl<GetAllStudents>()(schoolId: auth.user.schoolId);
    if (!mounted) return;
    result.fold((_) => null, (students) {
      setState(() {
        _students = students
            .where((student) => student.gender.name == 'male')
            .toList();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welfare Monitoring')),
      body: BlocConsumer<PatronBloc, PatronState>(
        listenWhen: (_, current) =>
            current is PatronActionSuccess || current is PatronError,
        listener: (context, state) {
          if (state is PatronActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        buildWhen: (_, current) =>
            current is WelfareRecordsLoaded ||
            current is PatronLoading ||
            current is PatronError,
        builder: (context, state) {
          if (state is PatronLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PatronError) {
            return EmptyState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load welfare records',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: () => context.read<PatronBloc>().add(
                WatchWelfareRecords(schoolId: _auth?.user.schoolId ?? ''),
              ),
            );
          }
          if (state is! WelfareRecordsLoaded) return const SizedBox.shrink();
          final records = state.records;
          if (records.isEmpty) {
            return const EmptyState(
              icon: Icons.health_and_safety_outlined,
              title: 'No welfare records',
              message: 'Welfare concerns recorded by the Patron appear here.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        record.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      _buildCategoryChip(record.category),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(record.note),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            DateFormat('MMM d, yyyy').format(record.date),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            'By: ${record.recordedBy}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogWelfareDialog(context),
        label: const Text('Log Welfare'),
        icon: const Icon(Icons.add_moderator),
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    Color color;
    switch (category) {
      case 'Concern':
        color = Colors.orange;
        break;
      case 'Counseling':
        color = Colors.blue;
        break;
      case 'Check-up':
        color = Colors.green;
        break;
      case 'Observation':
        color = Colors.purple;
        break;
      default:
        color = Colors.grey;
    }
    return Chip(
      label: Text(
        category,
        style: const TextStyle(color: Colors.white, fontSize: 10),
      ),
      backgroundColor: color,
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  void _showLogWelfareDialog(BuildContext context) {
    final noteController = TextEditingController();
    String selectedCategory = 'Concern';
    Student? selectedStudent;
    var isPrivate = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Log Welfare Concern'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SearchablePickerField<Student>(
                    label: 'Student',
                    value: selectedStudent,
                    items: _students,
                    labelBuilder: (student) => student.name,
                    subtitleBuilder: (student) => student.className,
                    onChanged: (student) =>
                        setState(() => selectedStudent = student),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    initialValue: selectedCategory,
                    items: ['Concern', 'Counseling', 'Check-up', 'Observation']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: noteController,
                    decoration: const InputDecoration(
                      labelText: 'Observations / Notes',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (_) => setState(() {}),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Private record'),
                    subtitle: const Text(
                      'Only boarding staff and administrators can view it',
                    ),
                    value: isPrivate,
                    onChanged: (value) =>
                        setState(() => isPrivate = value ?? false),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    selectedStudent == null || noteController.text.isEmpty
                    ? null
                    : () {
                        final record = WelfareRecord(
                          id: '', // Generated by repo
                          schoolId: _auth?.user.schoolId ?? '',
                          studentId: selectedStudent!.id,
                          studentName: selectedStudent!.name,
                          category: selectedCategory,
                          note: noteController.text.trim(),
                          date: DateTime.now(),
                          recordedBy: _auth?.user.name ?? 'Patron',
                          isPrivate: isPrivate,
                        );
                        context.read<PatronBloc>().add(
                          LogWelfareRecordEvent(record),
                        );
                        Navigator.pop(context);
                      },
                child: const Text('Save Record'),
              ),
            ],
          );
        },
      ),
    );
  }
}

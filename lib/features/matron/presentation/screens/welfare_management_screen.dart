import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../bloc/matron_bloc.dart';
import '../bloc/matron_event.dart';
import '../bloc/matron_state.dart';
import '../../domain/entities/boarding_entities.dart';

class WelfareManagementScreen extends StatefulWidget {
  const WelfareManagementScreen({super.key});

  @override
  State<WelfareManagementScreen> createState() =>
      _WelfareManagementScreenState();
}

class _WelfareManagementScreenState extends State<WelfareManagementScreen> {
  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  String? _schoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : null;
  }

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(
      WelfareRecordsRequested(
        schoolId: _schoolId(context),
        gender: _genderScope(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Welfare')),
      body: BlocBuilder<MatronBloc, MatronState>(
        buildWhen: (previous, current) =>
            current is WelfareRecordsLoaded ||
            current is MatronLoading ||
            current is MatronError,
        builder: (context, state) {
          if (state is MatronLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is MatronError) return Center(child: Text(state.message));
          if (state is WelfareRecordsLoaded) {
            if (state.records.isEmpty) {
              return const Center(child: Text('No welfare records found.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.records.length,
              itemBuilder: (context, index) {
                final record = state.records[index];
                return _WelfareCard(record: record);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddWelfareSheet(context),
        label: const Text('Record Concern'),
        icon: const Icon(Icons.add_comment_outlined),
      ),
    );
  }

  void _showAddWelfareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddWelfareSheet(),
    );
  }
}

class _WelfareCard extends StatelessWidget {
  final WelfareRecord record;
  const _WelfareCard({required this.record});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.studentName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              StatusBadge(
                label: record.category,
                color: _getCategoryColor(record.category),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(record.note),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By: ${record.recordedBy}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(record.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          if (record.isPrivate)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Private Record',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'concern':
        return Colors.red;
      case 'counseling':
        return Colors.blue;
      case 'check-up':
        return Colors.green;
      case 'observation':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _AddWelfareSheet extends StatefulWidget {
  const _AddWelfareSheet();

  @override
  State<_AddWelfareSheet> createState() => _AddWelfareSheetState();
}

class _AddWelfareSheetState extends State<_AddWelfareSheet> {
  List<Student> _students = const [];
  Student? _selectedStudent;
  bool _loadingStudents = true;
  String? _studentLoadError;
  String _selectedCategory = 'Concern';
  final _noteController = TextEditingController();
  bool _isPrivate = false;

  final List<String> _categories = [
    'Concern',
    'Counseling',
    'Check-up',
    'Observation',
    'Health Follow-up',
  ];

  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      if (mounted) {
        setState(() {
          _loadingStudents = false;
          _studentLoadError = 'You must be signed in.';
        });
      }
      return;
    }
    final result = await di.sl<GetAllStudents>()(
      schoolId: authState.user.schoolId,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loadingStudents = false;
        _studentLoadError = failure.message;
      }),
      (students) {
        final gender = _genderScope(context)?.toLowerCase();
        setState(() {
          _loadingStudents = false;
          _studentLoadError = null;
          _students = gender == null
              ? students
              : students
                    .where((student) => student.gender.name == gender)
                    .toList();
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SafeArea(
        child: EmptyState(
          icon: Icons.lock_outline,
          title: 'Sign in required',
          message: 'Sign in before recording a welfare concern.',
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronSuccess) {
            final messenger = ScaffoldMessenger.of(context);
            context.read<MatronBloc>().add(
              WelfareRecordsRequested(
                schoolId: authState.user.schoolId,
                gender: _genderScope(context),
              ),
            );
            Navigator.pop(context);
            messenger.showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          // This is a simplified way to get students - in reality, we'd have a search or specific list
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'New Welfare Record',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (_loadingStudents)
                const LinearProgressIndicator()
              else if (_studentLoadError != null)
                EmptyState(
                  icon: Icons.person_off_outlined,
                  title: 'Could not load students',
                  message: _studentLoadError!,
                  ctaLabel: 'Retry',
                  onCtaPressed: _loadStudents,
                )
              else
                SearchablePickerField<Student>(
                  label: 'Student',
                  value: _selectedStudent,
                  items: _students,
                  labelBuilder: (student) => student.name,
                  subtitleBuilder: (student) => student.className,
                  onChanged: (student) =>
                      setState(() => _selectedStudent = student),
                ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observation / Note',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              CheckboxListTile(
                title: const Text('Mark as Private'),
                subtitle: const Text('Restricted to boarding staff and admins'),
                value: _isPrivate,
                onChanged: (val) => setState(() => _isPrivate = val ?? false),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed:
                      (_selectedStudent != null &&
                          _noteController.text.trim().isNotEmpty)
                      ? () {
                          context.read<MatronBloc>().add(
                            AddWelfareRecordRequested(
                              WelfareRecord(
                                id: '',
                                schoolId: authState.user.schoolId,
                                studentId: _selectedStudent!.id,
                                studentName: _selectedStudent!.name,
                                category: _selectedCategory,
                                note: _noteController.text.trim(),
                                date: DateTime.now(),
                                recordedBy: authState.user.name,
                                isPrivate: _isPrivate,
                              ),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Save Record'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

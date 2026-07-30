import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/matron_bloc.dart';
import '../bloc/matron_event.dart';
import '../bloc/matron_state.dart';
import '../../domain/entities/boarding_entities.dart';

class BoardingDisciplineScreen extends StatefulWidget {
  const BoardingDisciplineScreen({super.key});

  @override
  State<BoardingDisciplineScreen> createState() => _BoardingDisciplineScreenState();
}

class _BoardingDisciplineScreenState extends State<BoardingDisciplineScreen> {
  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(DisciplineCasesRequested(gender: _genderScope(context)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boarding Discipline'),
      ),
      body: BlocBuilder<MatronBloc, MatronState>(
        buildWhen: (previous, current) => current is DisciplineCasesLoaded || current is MatronLoading || current is MatronError,
        builder: (context, state) {
          if (state is MatronLoading) return const Center(child: CircularProgressIndicator());
          if (state is MatronError) return Center(child: Text(state.message));
          if (state is DisciplineCasesLoaded) {
            if (state.cases.isEmpty) {
              return const Center(child: Text('No discipline cases recorded.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.cases.length,
              itemBuilder: (context, index) {
                final disciplineCase = state.cases[index];
                return _DisciplineCard(disciplineCase: disciplineCase);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDisciplineSheet(context),
        label: const Text('Record Incident'),
        icon: const Icon(Icons.gavel_outlined),
      ),
    );
  }

  void _showAddDisciplineSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AddDisciplineSheet(),
    );
  }
}

class _DisciplineCard extends StatelessWidget {
  final DisciplineCase disciplineCase;
  const _DisciplineCard({required this.disciplineCase});

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
              Text(disciplineCase.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              StatusBadge(
                label: disciplineCase.status,
                color: _getStatusColor(disciplineCase.status),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            disciplineCase.incident,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text('Action: ${disciplineCase.actionTaken}'),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By: ${disciplineCase.recordedBy}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                DateFormat('MMM dd, yyyy').format(disciplineCase.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending': return Colors.orange;
      case 'resolved': return Colors.green;
      case 'follow-up': return Colors.blue;
      default: return Colors.grey;
    }
  }
}

class _AddDisciplineSheet extends StatefulWidget {
  const _AddDisciplineSheet();

  @override
  State<_AddDisciplineSheet> createState() => _AddDisciplineSheetState();
}

class _AddDisciplineSheetState extends State<_AddDisciplineSheet> {
  String? _selectedStudentName;
  final _incidentController = TextEditingController();
  final _actionController = TextEditingController();
  String _selectedCategory = 'Misconduct';
  String _selectedStatus = 'Pending';

  final List<String> _categories = ['Misconduct', 'Bullying', 'Theft', 'Cleanliness', 'Late to Dorm', 'Other'];
  final List<String> _statuses = ['Pending', 'Resolved', 'Follow-up'];

  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state as AuthAuthenticated;

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
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
            context.read<MatronBloc>().add(DisciplineCasesRequested(gender: _genderScope(context)));
          }
        },
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Record Incident', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(labelText: 'Student Name', border: OutlineInputBorder()),
                onChanged: (val) => _selectedStudentName = val,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _incidentController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Incident Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _actionController,
                decoration: const InputDecoration(labelText: 'Action Taken', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: _statuses.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_selectedStudentName != null && _incidentController.text.isNotEmpty)
                      ? () {
                          context.read<MatronBloc>().add(AddDisciplineCaseRequested(
                                DisciplineCase(
                                  id: '',
                                  studentId: 'TEMP_ID',
                                  studentName: _selectedStudentName!,
                                  incident: _incidentController.text,
                                  category: _selectedCategory,
                                  actionTaken: _actionController.text,
                                  date: DateTime.now(),
                                  status: _selectedStatus,
                                  recordedBy: authState.user.name,
                                ),
                              ));
                        }
                      : null,
                  child: const Text('Save Incident'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

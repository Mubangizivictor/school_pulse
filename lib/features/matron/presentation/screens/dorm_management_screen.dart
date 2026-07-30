import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/matron_bloc.dart';
import '../bloc/matron_event.dart';
import '../bloc/matron_state.dart';
import '../../domain/entities/boarding_entities.dart';

class DormManagementScreen extends StatefulWidget {
  const DormManagementScreen({super.key});

  @override
  State<DormManagementScreen> createState() => _DormManagementScreenState();
}

class _DormManagementScreenState extends State<DormManagementScreen> {
  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(DormitoriesRequested(gender: _genderScope(context)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dormitory Management'),
      ),
      body: BlocBuilder<MatronBloc, MatronState>(
        buildWhen: (previous, current) => current is DormitoriesLoaded || current is MatronLoading || current is MatronError,
        builder: (context, state) {
          if (state is MatronLoading) return const Center(child: CircularProgressIndicator());
          if (state is MatronError) return Center(child: Text(state.message));
          if (state is DormitoriesLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.dormitories.length,
              itemBuilder: (context, index) {
                final dorm = state.dormitories[index];
                return _DormCard(dorm: dorm);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAllocationSheet(context),
        label: const Text('Allocate Student'),
        icon: const Icon(Icons.person_add_alt_1_outlined),
      ),
    );
  }

  void _showAllocationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _AllocationSheet(),
    );
  }
}

class _DormCard extends StatelessWidget {
  final Dormitory dorm;
  const _DormCard({required this.dorm});

  @override
  Widget build(BuildContext context) {
    final occupancy = dorm.occupantCount / dorm.capacity;
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      onTap: () {
        // TODO: Navigate to dorm details / student list
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dorm.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              StatusBadge(
                label: '${dorm.occupantCount}/${dorm.capacity}',
                color: occupancy >= 1.0 ? semanticColors.error : semanticColors.success,
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: occupancy,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.star_border, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                dorm.roomLeaderName != null ? 'Leader: ${dorm.roomLeaderName}' : 'No Room Leader Assigned',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AllocationSheet extends StatefulWidget {
  const _AllocationSheet();

  @override
  State<_AllocationSheet> createState() => _AllocationSheetState();
}

class _AllocationSheetState extends State<_AllocationSheet> {
  String? _selectedStudentId;
  String? _selectedDormId;
  final _bedController = TextEditingController();

  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(UnallocatedStudentsRequested(gender: _genderScope(context)));
    context.read<MatronBloc>().add(DormitoriesRequested(gender: _genderScope(context)));
  }

  @override
  Widget build(BuildContext context) {
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
            context.read<MatronBloc>().add(DormitoriesRequested(gender: _genderScope(context)));
          }
        },
        builder: (context, state) {
          List<BoardingStudent> students = [];
          List<Dormitory> dorms = [];

          if (state is UnallocatedStudentsLoaded) students = state.students;
          if (state is DormitoriesLoaded) dorms = state.dormitories;

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Allocate Student', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Student', border: OutlineInputBorder()),
                items: students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                onChanged: (val) => setState(() => _selectedStudentId = val),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Dormitory', border: OutlineInputBorder()),
                items: dorms.map((d) => DropdownMenuItem(value: d.id, child: Text('${d.name} (${d.occupantCount}/${d.capacity})'))).toList(),
                onChanged: (val) => setState(() => _selectedDormId = val),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _bedController,
                decoration: const InputDecoration(labelText: 'Bed Number (Optional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_selectedStudentId != null && _selectedDormId != null)
                      ? () {
                          context.read<MatronBloc>().add(AllocateStudentRequested(
                                studentId: _selectedStudentId!,
                                dormitoryId: _selectedDormId!,
                                bedNumber: _bedController.text.isEmpty ? null : _bedController.text,
                              ));
                        }
                      : null,
                  child: const Text('Confirm Allocation'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

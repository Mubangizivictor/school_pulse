import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../bloc/matron_bloc.dart';
import '../bloc/matron_event.dart';
import '../bloc/matron_state.dart';
import '../../domain/repositories/matron_repository.dart';

class DormAllocationScreen extends StatefulWidget {
  const DormAllocationScreen({super.key});

  @override
  State<DormAllocationScreen> createState() => _DormAllocationScreenState();
}

class _DormAllocationScreenState extends State<DormAllocationScreen> {
  String? _selectedDormitoryId;
  String? _selectedStudentId;

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(UnallocatedStudentsRequested());
    context.read<MatronBloc>().add(MatronDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dormitory Allocation'),
      ),
      body: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is AllocationSuccessful) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Student allocated successfully')),
            );
            context.read<MatronBloc>().add(UnallocatedStudentsRequested());
            context.read<MatronBloc>().add(MatronDashboardRequested());
            setState(() {
              _selectedStudentId = null;
            });
          }
        },
        builder: (context, state) {
          List<Student> unallocated = [];

          if (state is UnallocatedStudentsLoaded) {
            unallocated = state.students;
          }

          // This is a bit tricky with Bloc because states are exclusive.
          // In a real app, I'd probably use a more complex state or separate blocs.
          // For now, I'll rely on the dashboard being loaded first or concurrently.

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Unallocated Students (${unallocated.length})', 
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: unallocated.length,
                    itemBuilder: (context, index) {
                      final student = unallocated[index];
                      final isSelected = _selectedStudentId == student.id;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStudentId = student.id),
                        child: AppCard(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                backgroundColor: isSelected ? Theme.of(context).colorScheme.primary : null,
                                child: Icon(Icons.person, color: isSelected ? Colors.white : null),
                              ),
                              const SizedBox(height: 4),
                              Text(student.name, style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Dormitory Capacity', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Expanded(
                  child: BlocBuilder<MatronBloc, MatronState>(
                    buildWhen: (previous, current) => current is MatronLoaded,
                    builder: (context, state) {
                      if (state is! MatronLoaded) return const Center(child: CircularProgressIndicator());
                      
                      return GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemCount: state.dormitories.length,
                        itemBuilder: (context, index) {
                          final dorm = state.dormitories[index];
                          final isSelected = _selectedDormitoryId == dorm.id;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedDormitoryId = dorm.id),
                            child: AppCard(
                              padding: const EdgeInsets.all(16),
                              color: isSelected ? Theme.of(context).colorScheme.primaryContainer : null,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(dorm.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text('${dorm.currentOccupants} / ${dorm.capacity}', 
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const Text('Occupants', style: TextStyle(fontSize: 10)),
                                  const SizedBox(height: 12),
                                  LinearProgressIndicator(
                                    value: dorm.currentOccupants / dorm.capacity,
                                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_selectedStudentId != null && _selectedDormitoryId != null)
                        ? () {
                            context.read<MatronBloc>().add(AllocateStudentRequested(
                                  studentId: _selectedStudentId!,
                                  dormitoryId: _selectedDormitoryId!,
                                ));
                          }
                        : null,
                    child: const Text('Confirm Allocation'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

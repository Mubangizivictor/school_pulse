import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/matron_bloc.dart';
import '../bloc/matron_event.dart';
import '../bloc/matron_state.dart';
import '../../domain/repositories/matron_repository.dart';

class NightAttendanceScreen extends StatefulWidget {
  const NightAttendanceScreen({super.key});

  @override
  State<NightAttendanceScreen> createState() => _NightAttendanceScreenState();
}

class _NightAttendanceScreenState extends State<NightAttendanceScreen> {
  final Map<String, bool> _attendance = {};
  String? _selectedDormitoryId;

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(MatronDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Night Attendance'),
        actions: [
          IconButton(
            onPressed: (_selectedDormitoryId != null && _attendance.isNotEmpty)
                ? () {
                    context.read<MatronBloc>().add(SubmitNightAttendanceRequested(
                          dormitoryId: _selectedDormitoryId!,
                          attendance: _attendance,
                        ));
                  }
                : null,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is AttendanceSubmittedSuccessfully) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance saved successfully')),
            );
          }
        },
        builder: (context, state) {
          List<Student> students = [];

          if (state is DormitoryStudentsLoaded) {
            students = state.students;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<MatronBloc, MatronState>(
                  buildWhen: (prev, curr) => curr is MatronLoaded,
                  builder: (context, state) {
                    final dorms = state is MatronLoaded ? state.dormitories : <DormitoryStatus>[];
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Select Dormitory'),
                      initialValue: _selectedDormitoryId,
                      items: dorms.map((dorm) => DropdownMenuItem(
                            value: dorm.id,
                            child: Text(dorm.name),
                          )).toList(),
                      onChanged: (v) {
                        setState(() {
                          _selectedDormitoryId = v;
                          _attendance.clear();
                        });
                        if (v != null) {
                          context.read<MatronBloc>().add(DormitoryStudentsRequested(v));
                        }
                      },
                    );
                  },
                ),
              ),
              Expanded(
                child: BlocBuilder<MatronBloc, MatronState>(
                  builder: (context, state) {
                    if (state is MatronLoading && _selectedDormitoryId != null) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    
                    if (students.isEmpty && _selectedDormitoryId != null) {
                      return const Center(child: Text('No students found in this dormitory'));
                    }

                    if (_selectedDormitoryId == null) {
                      return const Center(child: Text('Please select a dormitory first'));
                    }

                    return ListView.builder(
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return CheckboxListTile(
                          title: Text(student.name),
                          subtitle: Text(student.bedNumber ?? 'No Bed Assigned'),
                          value: _attendance[student.id] ?? true,
                          onChanged: (val) => setState(() => _attendance[student.id] = val ?? false),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

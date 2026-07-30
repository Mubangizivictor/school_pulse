import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/matron_bloc.dart';
import '../bloc/matron_event.dart';
import '../bloc/matron_state.dart';
import '../../domain/entities/boarding_entities.dart';

class NightAttendanceScreen extends StatefulWidget {
  const NightAttendanceScreen({super.key});

  @override
  State<NightAttendanceScreen> createState() => _NightAttendanceScreenState();
}

class _NightAttendanceScreenState extends State<NightAttendanceScreen> {
  final Map<String, bool> _attendance = {};
  String? _selectedDormitoryId;

  String? _genderScope(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return null;
    return UserRoleDisplay.matronGenderScope(authState.user.role);
  }

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(MatronDashboardRequested(gender: _genderScope(context)));
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
                    context.read<MatronBloc>().add(SubmitAttendanceRequested(
                          dormitoryId: _selectedDormitoryId!,
                          type: 'Night',
                          attendance: _attendance.map(
                            (studentId, present) => MapEntry(studentId, present ? 'Present' : 'Absent'),
                          ),
                        ));
                  }
                : null,
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: BlocConsumer<MatronBloc, MatronState>(
        listener: (context, state) {
          if (state is MatronSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Attendance saved successfully')),
            );
          }
        },
        builder: (context, state) {
          List<BoardingStudent> students = [];

          if (state is DormitoryStudentsLoaded) {
            students = state.students;
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: BlocBuilder<MatronBloc, MatronState>(
                  buildWhen: (prev, curr) => curr is MatronDashboardLoaded,
                  builder: (context, state) {
                    final dorms = state is MatronDashboardLoaded ? state.data.dormitories : <Dormitory>[];
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

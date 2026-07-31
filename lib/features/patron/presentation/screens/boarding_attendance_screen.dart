import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';

const _kAttendanceTypes = ['Morning', 'Evening', 'Weekend', 'Holiday', 'Study', 'Activity'];
const _kAttendanceStatuses = ['Present', 'Absent', 'Late', 'Sick'];

class BoardingAttendanceScreen extends StatefulWidget {
  const BoardingAttendanceScreen({super.key});

  @override
  State<BoardingAttendanceScreen> createState() => _BoardingAttendanceScreenState();
}

class _BoardingAttendanceScreenState extends State<BoardingAttendanceScreen> {
  String? selectedDormId;
  String selectedType = 'Evening';
  DateTime selectedDate = DateTime.now();
  Map<String, String> attendanceMap = {};

  @override
  void initState() {
    super.initState();
    context.read<PatronBloc>().add(WatchDormitories());
    _loadAttendance();
  }

  void _loadAttendance() {
    context.read<PatronBloc>().add(WatchAttendance(
          date: selectedDate,
          dormitoryId: selectedDormId,
          type: selectedType,
        ));
    if (selectedDormId != null) {
      context.read<PatronBloc>().add(WatchBoardingStudents(dormitoryId: selectedDormId));
    }
  }

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Patron';
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    return Scaffold(
      appBar: AppBar(title: const Text('Boarding Attendance')),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(height: 1),
          Expanded(
            child: BlocConsumer<PatronBloc, PatronState>(
              listener: (context, state) {
                if (state is PatronActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              buildWhen: (previous, current) =>
                  current is BoardingStudentsLoaded || current is AttendanceLoaded || current is PatronLoading,
              builder: (context, state) {
                List<BoardingStudent> students = [];
                if (state is BoardingStudentsLoaded) {
                  students = state.students;
                }
                if (state is AttendanceLoaded) {
                  for (var record in state.attendance) {
                    attendanceMap[record.studentId] = record.status;
                  }
                }

                if (selectedDormId == null) {
                  return const EmptyState(
                    icon: Icons.how_to_reg_outlined,
                    title: 'Select a Dormitory',
                    message: 'Choose a dormitory above to begin roll call.',
                  );
                }

                if (students.isEmpty) {
                  return const EmptyState(
                    icon: Icons.people_outline,
                    title: 'No Boarders Found',
                    message: 'This dormitory has no allocated students.',
                  );
                }

                final missingCount = students.where((s) => (attendanceMap[s.id] ?? 'Present') == 'Absent').length;

                return Column(
                  children: [
                    if (missingCount > 0)
                      Container(
                        width: double.infinity,
                        color: semanticColors.error.withValues(alpha: 0.1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          '$missingCount marked absent - will alert parents on save.',
                          style: TextStyle(color: semanticColors.error, fontWeight: FontWeight.w600),
                        ),
                      ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final status = attendanceMap[student.id] ?? 'Present';
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: student.photoUrl != null ? NetworkImage(student.photoUrl!) : null,
                              child: student.photoUrl == null ? const Icon(Icons.person) : null,
                            ),
                            title: Text(student.name),
                            subtitle: Text('Bed: ${student.bedNumber ?? 'N/A'}'),
                            trailing: DropdownButton<String>(
                              value: status,
                              items: _kAttendanceStatuses
                                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                                  .toList(),
                              onChanged: (val) {
                                if (val == null) return;
                                setState(() => attendanceMap[student.id] = val);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
          onPressed: selectedDormId == null ? null : () => _saveAttendance(context),
          child: const Text('Save Attendance'),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          BlocBuilder<PatronBloc, PatronState>(
            buildWhen: (p, c) => c is DormitoriesLoaded,
            builder: (context, state) {
              List<Dormitory> dorms = [];
              if (state is DormitoriesLoaded) {
                dorms = state.dormitories;
              }
              return DropdownButtonFormField<String>(
                initialValue: selectedDormId,
                decoration: const InputDecoration(labelText: 'Dormitory', border: OutlineInputBorder()),
                items: dorms.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedDormId = val;
                    attendanceMap.clear();
                  });
                  _loadAttendance();
                },
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Session', border: OutlineInputBorder()),
                  items: _kAttendanceTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                  onChanged: (val) {
                    setState(() => selectedType = val!);
                    _loadAttendance();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 90)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setState(() => selectedDate = date);
                      _loadAttendance();
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _saveAttendance(BuildContext context) {
    final state = context.read<PatronBloc>().state;
    if (state is BoardingStudentsLoaded) {
      final recordedBy = _currentUserName(context);
      final records = state.students.map((s) {
        return BoardingAttendance(
          id: '',
          studentId: s.id,
          studentName: s.name,
          dormitoryId: selectedDormId!,
          date: selectedDate,
          type: selectedType,
          status: attendanceMap[s.id] ?? 'Present',
          recordedBy: recordedBy,
        );
      }).toList();

      context.read<PatronBloc>().add(BulkRecordAttendanceEvent(records));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';

class BoardingAttendanceScreen extends StatefulWidget {
  const BoardingAttendanceScreen({super.key});

  @override
  State<BoardingAttendanceScreen> createState() => _BoardingAttendanceScreenState();
}

class _BoardingAttendanceScreenState extends State<BoardingAttendanceScreen> {
  String? selectedDormId;
  String selectedType = 'Evening'; // Morning, Evening, Weekend
  DateTime selectedDate = DateTime.now();
  Map<String, String> attendanceMap = {}; // studentId -> status

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Boarding Attendance'),
      ),
      body: Column(
        children: [
          _buildFilters(),
          const Divider(),
          Expanded(
            child: BlocBuilder<PatronBloc, PatronState>(
              buildWhen: (previous, current) => 
                current is BoardingStudentsLoaded || current is AttendanceLoaded || current is PatronLoading,
              builder: (context, state) {
                if (state is PatronLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<BoardingStudent> students = [];
                if (state is BoardingStudentsLoaded) {
                  students = state.students;
                }

                // If we have attendance records, populate the map
                if (state is AttendanceLoaded) {
                  for (var record in state.attendance) {
                    attendanceMap[record.studentId] = record.status;
                  }
                }

                if (selectedDormId == null) {
                  return const Center(child: Text('Select a dormitory to begin roll call'));
                }

                if (students.isEmpty) {
                  return const Center(child: Text('No students found in this dormitory'));
                }

                return ListView.builder(
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
                      trailing: SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(value: 'Present', label: Text('P')),
                          ButtonSegment(value: 'Absent', label: Text('A')),
                          ButtonSegment(value: 'Leave', label: Text('L')),
                        ],
                        selected: {status},
                        onSelectionChanged: (newSelection) {
                          setState(() {
                            attendanceMap[student.id] = newSelection.first;
                          });
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
          ),
          onPressed: selectedDormId == null ? null : _saveAttendance,
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
                decoration: const InputDecoration(labelText: 'Dormitory'),
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
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: ['Morning', 'Evening', 'Weekend']
                      .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                      .toList(),
                  onChanged: (val) {
                    setState(() => selectedType = val!);
                    _loadAttendance();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton.icon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now().subtract(const Duration(days: 30)),
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

  void _saveAttendance() {
    final state = context.read<PatronBloc>().state;
    if (state is BoardingStudentsLoaded) {
      final records = state.students.map((s) {
        return BoardingAttendance(
          id: '', // Generated by remote
          studentId: s.id,
          studentName: s.name,
          dormitoryId: selectedDormId!,
          date: selectedDate,
          type: selectedType,
          status: attendanceMap[s.id] ?? 'Present',
          recordedBy: 'Current Patron', // TODO: Get from Auth
        );
      }).toList();

      context.read<PatronBloc>().add(BulkRecordAttendanceEvent(records));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Attendance records saved successfully')),
      );
    }
  }
}

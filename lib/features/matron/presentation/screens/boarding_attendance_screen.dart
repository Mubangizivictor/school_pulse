import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/matron_bloc.dart';
import '../bloc/matron_event.dart';
import '../bloc/matron_state.dart';
import '../../domain/entities/boarding_entities.dart';

class BoardingAttendanceScreen extends StatefulWidget {
  const BoardingAttendanceScreen({super.key});

  @override
  State<BoardingAttendanceScreen> createState() => _BoardingAttendanceScreenState();
}

class _BoardingAttendanceScreenState extends State<BoardingAttendanceScreen> {
  String? _selectedDormId;
  String _selectedType = 'Evening';
  final List<String> _types = ['Morning', 'Evening', 'Night', 'Weekend'];

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
        title: const Text('Boarding Attendance'),
      ),
      body: BlocBuilder<MatronBloc, MatronState>(
        buildWhen: (previous, current) => current is DormitoriesLoaded || current is MatronLoading,
        builder: (context, state) {
          if (state is MatronLoading && _selectedDormId == null) return const Center(child: CircularProgressIndicator());
          
          List<Dormitory> dorms = [];
          if (state is DormitoriesLoaded) dorms = state.dormitories;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedDormId,
                        decoration: const InputDecoration(labelText: 'Dormitory', border: OutlineInputBorder()),
                        items: dorms.map((d) => DropdownMenuItem(value: d.id, child: Text(d.name))).toList(),
                        onChanged: (val) {
                          setState(() => _selectedDormId = val);
                          if (val != null) {
                            context.read<MatronBloc>().add(DormitoryStudentsRequested(val));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(labelText: 'Type', border: OutlineInputBorder()),
                        items: _types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _selectedDormId == null
                    ? const Center(child: Text('Select a dormitory to begin roll call'))
                    : const _AttendanceList(),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _selectedDormId == null ? null : _SubmitBar(dormitoryId: _selectedDormId!, type: _selectedType),
    );
  }
}

class _AttendanceList extends StatefulWidget {
  const _AttendanceList();

  @override
  State<_AttendanceList> createState() => _AttendanceListState();
}

class _AttendanceListState extends State<_AttendanceList> {
  final Map<String, String> _attendance = {};

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatronBloc, MatronState>(
      listener: (context, state) {
        if (state is DormitoryStudentsLoaded) {
          for (var s in state.students) {
            _attendance[s.id] = s.status ?? 'Present';
          }
        }
      },
      buildWhen: (previous, current) => current is DormitoryStudentsLoaded || current is MatronLoading,
      builder: (context, state) {
        if (state is MatronLoading) return const Center(child: CircularProgressIndicator());
        if (state is DormitoryStudentsLoaded) {
          return ListView.builder(
            itemCount: state.students.length,
            itemBuilder: (context, index) {
              final student = state.students[index];
              final currentStatus = _attendance[student.id] ?? 'Present';

              return ListTile(
                title: Text(student.name),
                subtitle: Text(student.bedNumber != null ? 'Bed: ${student.bedNumber}' : 'No Bed Assigned'),
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Present', label: Text('P'), icon: Icon(Icons.check, size: 16)),
                    ButtonSegment(value: 'Absent', label: Text('A'), icon: Icon(Icons.close, size: 16)),
                    ButtonSegment(value: 'Leave', label: Text('L'), icon: Icon(Icons.exit_to_app, size: 16)),
                  ],
                  selected: {currentStatus},
                  onSelectionChanged: (val) {
                    setState(() => _attendance[student.id] = val.first);
                    // Pass to parent or store in a way _SubmitBar can access
                    _AttendanceProvider.of(context).update(student.id, val.first);
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

// Simple InheritedWidget to share attendance state with the submit bar
class _AttendanceProvider extends InheritedWidget {
  final Function(String, String) update;
  final Map<String, String> attendance;

  const _AttendanceProvider({
    required this.update,
    required this.attendance,
    required super.child,
  });

  static _AttendanceProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_AttendanceProvider>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

class _SubmitBar extends StatefulWidget {
  final String dormitoryId;
  final String type;
  const _SubmitBar({required this.dormitoryId, required this.type});

  @override
  State<_SubmitBar> createState() => _SubmitBarState();
}

class _SubmitBarState extends State<_SubmitBar> {
  final Map<String, String> _attendance = {};

  void _update(String id, String status) {
    _attendance[id] = status;
  }

  @override
  Widget build(BuildContext context) {
    return _AttendanceProvider(
      update: _update,
      attendance: _attendance,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: BlocConsumer<MatronBloc, MatronState>(
            listener: (context, state) {
              if (state is MatronSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
                Navigator.pop(context);
              }
            },
            builder: (context, state) {
              return SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: state is MatronLoading
                      ? null
                      : () {
                          context.read<MatronBloc>().add(SubmitAttendanceRequested(
                                dormitoryId: widget.dormitoryId,
                                type: widget.type.toLowerCase(),
                                attendance: _attendance,
                              ));
                        },
                  child: state is MatronLoading ? const CircularProgressIndicator() : const Text('Submit Roll Call'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

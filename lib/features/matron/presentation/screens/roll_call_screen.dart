import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';
import 'package:school_pulse/features/shared/boarding/boarding_list_widgets.dart';
import 'package:school_pulse/features/shared/boarding/roll_call_checklist_screen.dart';
import 'package:school_pulse/features/shared/boarding/roll_call_overview_screen.dart';

/// Thin Matron (girls) wrapper: wires `MatronBloc` and renders the shared,
/// role-agnostic Roll Call overview/checklist screens. Mirrors the Patron
/// wrapper exactly - only the bloc type and gender-scoped data differ.
class MatronRollCallScreen extends StatefulWidget {
  const MatronRollCallScreen({super.key});

  @override
  State<MatronRollCallScreen> createState() => _MatronRollCallScreenState();
}

class _MatronRollCallScreenState extends State<MatronRollCallScreen> {
  String _selectedType = 'Morning';
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(WatchDormitories());
    _loadAttendance();
  }

  void _loadAttendance() {
    context.read<MatronBloc>().add(
      WatchAttendance(
        schoolId: _schoolId(context),
        date: _selectedDate,
        type: _selectedType,
      ),
    );
  }

  String _schoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : '';
  }

  String _userName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Matron';
  }

  void _onTypeChanged(String type) {
    setState(() => _selectedType = type);
    _loadAttendance();
  }

  void _onDateChanged(DateTime date) {
    setState(() => _selectedDate = date);
    _loadAttendance();
  }

  void _onStartRollCall(String dormitoryId, String dormitoryName) {
    context.read<MatronBloc>().add(
      WatchBoardingStudents(dormitoryId: dormitoryId),
    );
    context.read<MatronBloc>().add(
      WatchAttendance(
        schoolId: _schoolId(context),
        date: _selectedDate,
        dormitoryId: dormitoryId,
        type: _selectedType,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<MatronBloc>(),
          child: _MatronRollCallChecklistWrapper(
            dormitoryId: dormitoryId,
            dormitoryName: dormitoryName,
            type: _selectedType,
            date: _selectedDate,
            schoolId: _schoolId(context),
            recordedBy: _userName(context),
          ),
        ),
      ),
    ).then((_) => _loadAttendance());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatronBloc, MatronState>(
      buildWhen: (previous, current) =>
          current is DormitoriesLoaded ||
          current is AttendanceLoaded ||
          current is MatronLoading,
      builder: (context, state) {
        final blocState = context.read<MatronBloc>().state;
        List<Dormitory> dorms = [];
        List<BoardingAttendance> attendance = [];

        if (state is DormitoriesLoaded) dorms = state.dormitories;
        if (state is AttendanceLoaded) attendance = state.attendance;
        if (blocState is DormitoriesLoaded && dorms.isEmpty) {
          dorms = blocState.dormitories;
        }
        if (blocState is AttendanceLoaded && attendance.isEmpty) {
          attendance = blocState.attendance;
        }

        final isLoading = state is MatronLoading && dorms.isEmpty;

        return RollCallOverviewScreen(
          title: 'Roll Call',
          selectedType: _selectedType,
          onTypeChanged: _onTypeChanged,
          selectedDate: _selectedDate,
          onDateChanged: _onDateChanged,
          isLoading: isLoading,
          dormitories: dorms
              .map((d) => RollCallDormitory(id: d.id, name: d.name))
              .toList(),
          attendanceRecords: attendance
              .map(
                (a) => RollCallAttendanceRecord(
                  studentId: a.studentId,
                  dormitoryId: a.dormitoryId,
                  status: a.status,
                ),
              )
              .toList(),
          onStartRollCall: _onStartRollCall,
        );
      },
    );
  }
}

class _MatronRollCallChecklistWrapper extends StatelessWidget {
  final String dormitoryId;
  final String dormitoryName;
  final String type;
  final DateTime date;
  final String schoolId;
  final String recordedBy;

  const _MatronRollCallChecklistWrapper({
    required this.dormitoryId,
    required this.dormitoryName,
    required this.type,
    required this.date,
    required this.schoolId,
    required this.recordedBy,
  });

  AttendanceQuickStatus _toQuickStatus(String status) {
    return AttendanceQuickStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => AttendanceQuickStatus.present,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MatronBloc, MatronState>(
      listener: (context, state) {
        if (state is MatronActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.success(context),
            ),
          );
          Navigator.of(context).pop();
        }
      },
      buildWhen: (previous, current) =>
          current is BoardingStudentsLoaded ||
          current is AttendanceLoaded ||
          current is MatronLoading,
      builder: (context, state) {
        final blocState = context.read<MatronBloc>().state;
        List<BoardingStudent> students = [];
        List<BoardingAttendance> attendance = [];

        if (state is BoardingStudentsLoaded) students = state.students;
        if (state is AttendanceLoaded) attendance = state.attendance;
        if (blocState is BoardingStudentsLoaded && students.isEmpty) {
          students = blocState.students;
        }
        if (blocState is AttendanceLoaded && attendance.isEmpty) {
          attendance = blocState.attendance;
        }

        final isLoading = state is MatronLoading && students.isEmpty;

        final initialAttendance = <String, AttendanceQuickStatus>{
          for (final a in attendance)
            if (a.dormitoryId == dormitoryId)
              a.studentId: _toQuickStatus(a.status),
        };

        return RollCallChecklistScreen(
          dormitoryId: dormitoryId,
          dormitoryName: dormitoryName,
          type: type,
          date: date,
          isLoading: isLoading,
          students: students
              .map(
                (s) => RollCallStudent(
                  id: s.id,
                  name: s.name,
                  photoUrl: s.photoUrl,
                  bedNumber: s.bedNumber,
                  studentClass: s.studentClass,
                ),
              )
              .toList(),
          initialAttendance: initialAttendance,
          onSave: (marks) {
            final records = marks
                .map(
                  (m) => BoardingAttendance(
                    id: '',
                    schoolId: schoolId,
                    studentId: m.studentId,
                    studentName: students
                        .firstWhere((s) => s.id == m.studentId)
                        .name,
                    dormitoryId: dormitoryId,
                    date: date,
                    type: type,
                    status: m.status.name,
                    recordedBy: recordedBy,
                  ),
                )
                .toList();
            context.read<MatronBloc>().add(BulkRecordAttendanceEvent(records));
          },
        );
      },
    );
  }
}

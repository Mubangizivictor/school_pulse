import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';
import 'package:school_pulse/features/shared/boarding/dorm_student_roster_screen.dart';

/// Matron (girls) wrapper for the shared dormitory student roster - wires
/// [MatronBloc] to watch this dormitory's boarders plus today's attendance,
/// and hands plain data down to the role-agnostic screen.
class MatronDormStudentRosterScreen extends StatefulWidget {
  final Dormitory dormitory;
  const MatronDormStudentRosterScreen({super.key, required this.dormitory});

  @override
  State<MatronDormStudentRosterScreen> createState() =>
      _MatronDormStudentRosterScreenState();
}

class _MatronDormStudentRosterScreenState
    extends State<MatronDormStudentRosterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(
      WatchBoardingStudents(dormitoryId: widget.dormitory.id),
    );
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<MatronBloc>().add(
        WatchAttendance(
          schoolId: authState.user.schoolId,
          date: DateTime.now(),
          dormitoryId: widget.dormitory.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatronBloc, MatronState>(
      buildWhen: (previous, current) =>
          current is BoardingStudentsLoaded ||
          current is AttendanceLoaded ||
          current is MatronLoading,
      builder: (context, state) {
        final students = state is BoardingStudentsLoaded
            ? state.students
            : (state is AttendanceLoaded ? null : <BoardingStudent>[]);

        Map<String, String> attendanceByStudent = {};
        if (state is AttendanceLoaded) {
          for (final record in state.attendance) {
            attendanceByStudent[record.studentId] = record.status;
          }
        }

        final rosterStudents = (students ?? const <BoardingStudent>[])
            .map(
              (s) => RosterStudent(
                id: s.id,
                name: s.name,
                photoUrl: s.photoUrl,
                bedLabel: s.bedNumber != null ? 'Bed ${s.bedNumber}' : null,
                classLabel: s.studentClass,
                attendanceStatus: attendanceByStudent[s.id],
              ),
            )
            .toList();

        return DormStudentRosterScreen(
          dormitoryName: widget.dormitory.name,
          students: rosterStudents,
          isLoading: students == null,
          onStudentTap: (studentId) =>
              context.push('/staff/matron/students/$studentId'),
        );
      },
    );
  }
}

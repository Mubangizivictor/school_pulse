import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:school_pulse/features/shared/boarding/dorm_student_roster_screen.dart';

/// Patron (boys) wrapper for the shared dormitory student roster - wires
/// [PatronBloc] to watch this dormitory's boarders plus today's attendance,
/// and hands plain data down to the role-agnostic screen.
class PatronDormStudentRosterScreen extends StatefulWidget {
  final Dormitory dormitory;
  const PatronDormStudentRosterScreen({super.key, required this.dormitory});

  @override
  State<PatronDormStudentRosterScreen> createState() =>
      _PatronDormStudentRosterScreenState();
}

class _PatronDormStudentRosterScreenState
    extends State<PatronDormStudentRosterScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PatronBloc>().add(
      WatchBoardingStudents(dormitoryId: widget.dormitory.id),
    );
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PatronBloc>().add(
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
    return BlocBuilder<PatronBloc, PatronState>(
      buildWhen: (previous, current) =>
          current is BoardingStudentsLoaded ||
          current is AttendanceLoaded ||
          current is PatronLoading,
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
              context.push('/staff/patron/students/$studentId'),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:school_pulse/features/shared/boarding/boarding_student_profile_screen.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Patron (boys) wrapper for the shared boarding student profile - resolves
/// the richer [Student] record (admission number, DOB, guardian contact) by
/// id, layers on the boarding-specific dormitory/bed/attendance data from
/// [PatronBloc], and hands plain data down to the role-agnostic screen.
class PatronStudentProfileScreen extends StatefulWidget {
  final String studentId;
  const PatronStudentProfileScreen({super.key, required this.studentId});

  @override
  State<PatronStudentProfileScreen> createState() =>
      _PatronStudentProfileScreenState();
}

class _PatronStudentProfileScreenState
    extends State<PatronStudentProfileScreen> {
  Student? _student;
  bool _loadingStudent = true;

  @override
  void initState() {
    super.initState();
    _loadStudent();
    context.read<PatronBloc>().add(WatchBoardingStudents());
    final schoolId = _schoolId(context);
    if (schoolId != null) {
      context.read<PatronBloc>().add(
        WatchAttendance(schoolId: schoolId, date: DateTime.now()),
      );
    }
  }

  String? _schoolId(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.schoolId : null;
  }

  Future<void> _loadStudent() async {
    final schoolId = _schoolId(context);
    final result = await di.sl<GetAllStudents>()(schoolId: schoolId);
    if (!mounted) return;
    result.fold((_) => setState(() => _loadingStudent = false), (students) {
      setState(() {
        _student = students
            .where((s) => s.id == widget.studentId)
            .firstOrNull;
        _loadingStudent = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatronBloc, PatronState>(
      buildWhen: (previous, current) =>
          current is BoardingStudentsLoaded || current is AttendanceLoaded,
      builder: (context, state) {
        String? dormitoryName;
        String? bedNumber;
        String status = 'Active';
        if (state is BoardingStudentsLoaded) {
          final match = state.students
              .where((s) => s.id == widget.studentId)
              .firstOrNull;
          if (match != null) {
            dormitoryName = match.dormitoryName;
            bedNumber = match.bedNumber;
            status = match.status;
          }
        }

        TodaysAttendanceRow attendance = const TodaysAttendanceRow();
        if (state is AttendanceLoaded) {
          String? statusFor(String type) => state.attendance
              .where(
                (a) => a.studentId == widget.studentId && a.type == type,
              )
              .firstOrNull
              ?.status;
          attendance = TodaysAttendanceRow(
            morningStatus: statusFor('Morning'),
            eveningStatus: statusFor('Evening'),
            weekendStatus: statusFor('Weekend'),
          );
        }

        final student = _student;
        final profile = BoardingStudentProfile(
          id: widget.studentId,
          name: student?.name ?? '',
          photoUrl: student?.photoUrl,
          admissionNumber: student?.admissionNumber ?? '—',
          studentClass: student?.className ?? '—',
          dormitoryName: dormitoryName,
          bedNumber: bedNumber,
          dateOfBirth: student?.dateOfBirth,
          guardianPhone: student?.emergencyContacts.firstOrNull?.phoneNumber,
          guardianName: student?.emergencyContacts.firstOrNull?.name,
          status: status,
        );

        return BoardingStudentProfileScreen(
          profile: profile,
          attendance: attendance,
          isLoading: _loadingStudent,
          onWelfareNotes: () => context.push('/staff/patron/welfare'),
          onDisciplineRecords: () => context.push('/staff/patron/discipline'),
          onLeaveHistory: () => context.push('/staff/patron/leave'),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/dashboard_screen.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/screens/subject_teacher_dashboard.dart';

/// Decides which staff panel a teacher lands on.
///
/// The choice comes from the responsibility currently in effect, never from a
/// job title on the user record: one account holds a Class Teacher assignment
/// for P5 East and Subject Teacher assignments for three other classes at the
/// same time, and `user.role` cannot express which of them the teacher is
/// acting under right now. Switching responsibility therefore swaps the panel
/// here, with no logout and no second account.
class StaffPanelHost extends StatefulWidget {
  const StaffPanelHost({super.key});

  @override
  State<StaffPanelHost> createState() => _StaffPanelHostState();
}

class _StaffPanelHostState extends State<StaffPanelHost> {
  @override
  void initState() {
    super.initState();
    // Resolution is shared: this bloc restores the teacher's last-used
    // responsibility whatever its type, and each panel's own context bloc
    // then adopts it rather than re-selecting.
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<SubjectTeacherContextBloc>().add(
        ContextRequested(
          schoolId: authState.user.schoolId,
          userId: authState.user.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      buildWhen: (previous, current) =>
          previous.active?.roleType != current.active?.roleType ||
          previous.isLoading != current.isLoading,
      builder: (context, state) {
        // Subject teaching is the only responsibility with a panel of its
        // own so far; everything else - including a teacher with no
        // assignment yet - lands on the Class Teacher panel, which renders
        // its own explanatory state rather than an error.
        if (state.active?.roleType == StaffResponsibilityType.subjectTeacher) {
          return const SubjectTeacherDashboard();
        }
        return const TeacherDashboardScreen();
      },
    );
  }
}

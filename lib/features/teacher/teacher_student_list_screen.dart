import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/presentation/screens/admin_students_list_screen.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson_attendance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';

/// Role-aware student entry point.
///
/// School leadership is bounced to the rebuilt admin Students module
/// (AdminStudentsListScreen, which provides its own StudentsBloc). A class
/// teacher keeps the scoped class roster below.
class TeacherStudentListScreen extends StatelessWidget {
  const TeacherStudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is AuthAuthenticated &&
        auth.user.roles.any(UserRoleDisplay.adminConsoleRoles.contains)) {
      // Rebuilt admin Students module lives under /staff/admin/students -
      // this route stays only as the legacy entry point shared with the
      // class-teacher roster below, so an admin landing here is bounced
      // straight to the real screen instead of the retired directory.
      return const AdminStudentsListScreen();
    }
    return const _ClassTeacherStudentListScreen();
  }
}

class _ClassTeacherStudentListScreen extends StatefulWidget {
  const _ClassTeacherStudentListScreen();

  @override
  State<_ClassTeacherStudentListScreen> createState() =>
      _ClassTeacherStudentListScreenState();
}

class _ClassTeacherStudentListScreenState
    extends State<_ClassTeacherStudentListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load({bool forceRefresh = false}) {
    if (!mounted) return;
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null) return;
    context.read<ClassStudentsBloc>().add(
      ClassStudentsRequested(active, forceRefresh: forceRefresh),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Students',
          style: AppTypography.headlineMedium.copyWith(
            color: AppColors.textPrimary(context),
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
        builder: (context, contextState) {
          if (contextState.active == null) {
            return EmptyState(
              icon: Icons.class_outlined,
              title: 'No class assigned',
              message:
                  'You are not currently the Class Teacher for any class, so there is no class list to show.',
            );
          }

          return BlocBuilder<ClassStudentsBloc, ClassStudentsState>(
            builder: (context, state) => Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => context
                        .read<ClassStudentsBloc>()
                        .add(ClassStudentsSearched(value)),
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search students...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppSpacing.m),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.l),
                Expanded(child: _body(context, state)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _body(BuildContext context, ClassStudentsState state) {
    if (state.isLoading && state.students.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: 6,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.l),
          child: Skeleton(height: 72, borderRadius: AppSpacing.l),
        ),
      );
    }
    if (state.students.isEmpty && state.errorMessage != null) {
      return EmptyState(
        icon: Icons.cloud_off,
        title: 'Could not load your class list',
        message: state.errorMessage!,
        ctaLabel: 'Retry',
        onCtaPressed: () => _load(forceRefresh: true),
      );
    }
    if (state.students.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outline,
        title: 'No students yet',
        message:
            'No students have been placed in your class for this academic year. Admissions adds them.',
      );
    }
    final visible = state.visibleStudents;
    if (visible.isEmpty) {
      return const EmptyState(
        icon: Icons.search_off,
        title: 'No matching students',
        message: 'No student in your class matches the current search.',
      );
    }
    return RefreshIndicator(
      onRefresh: () async => _load(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.xl),
        itemCount: visible.length,
        itemBuilder: (context, index) {
          final student = visible[index];
          return _StudentListTile(
            student: student,
            status: state.statusOf(student.studentId),
            onTap: () => context.push('/staff/students/${student.studentId}'),
          );
        },
      ),
    );
  }
}

class _StudentListTile extends StatelessWidget {
  const _StudentListTile({
    required this.student,
    required this.status,
    required this.onTap,
  });

  final ClassStudentSummary student;
  final LessonAttendanceStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 24,
          backgroundImage: (student.photoUrl?.isNotEmpty ?? false)
              ? NetworkImage(student.photoUrl!)
              : null,
          child: (student.photoUrl?.isNotEmpty ?? false)
              ? null
              : Text(student.initials),
        ),
        title: Text(
          student.name,
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text('Admission No: ${student.admissionNumber}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              status.label,
              style: AppTypography.labelMedium.copyWith(
                color: status.countsAsPresent
                    ? AppColors.success(context)
                    : AppColors.textMuted(context),
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

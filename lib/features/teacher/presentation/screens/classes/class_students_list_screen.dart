import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson_attendance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';

class ClassStudentsListScreen extends StatefulWidget {
  final String classId;
  const ClassStudentsListScreen({super.key, required this.classId});

  @override
  State<ClassStudentsListScreen> createState() =>
      _ClassStudentsListScreenState();
}

class _ClassStudentsListScreenState extends State<ClassStudentsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassStudentsBloc>().add(ClassStudentsRequested(active));
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
      builder: (context, contextState) {
        final active = contextState.active;
        final placement = active == null
            ? ''
            : [
                active.className,
                active.streamName,
              ].where((e) => e != null && e.isNotEmpty).join(' ');

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Students',
                  style: AppTypography.headlineSmall.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      placement.isEmpty ? 'No class assigned' : placement,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                    if (placement.isNotEmpty)
                      Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.textSecondary(context),
                      ),
                  ],
                ),
              ],
            ),
            actions: [
              Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(right: AppSpacing.l),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated(context),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border(context)),
                ),
                child: IconButton(
                  tooltip: 'Filter students',
                  icon: Icon(
                    Icons.filter_list,
                    color: AppColors.textPrimary(context),
                  ),
                  onPressed: active == null
                      ? null
                      : () => _showRefineSheet(context),
                ),
              ),
            ],
          ),
          body: active == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.x3l),
                    child: Text(
                      'You are not currently the Class Teacher for any class, '
                      'so there are no students to show.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                )
              : BlocBuilder<ClassStudentsBloc, ClassStudentsState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: SchoolPulseLoader());
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<ClassStudentsBloc>().add(
                          ClassStudentsRequested(active, forceRefresh: true),
                        );
                      },
                      child: ListView(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        children: [
                          if (state.errorMessage != null) ...[
                            _buildErrorBanner(context, state.errorMessage!),
                            const SizedBox(height: AppSpacing.l),
                          ],
                          _buildStatsCard(context, state),
                          const SizedBox(height: AppSpacing.xl),
                          _buildSearchField(context),
                          const SizedBox(height: AppSpacing.l),
                          _buildQuickFilters(context, state),
                          const SizedBox(height: AppSpacing.m),
                          _buildStudentsList(context, state),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildErrorBanner(BuildContext context, String message) {
    return PulseCard(
      backgroundColor: AppColors.danger(context).withValues(alpha: 0.08),
      borderColor: AppColors.danger(context).withValues(alpha: 0.3),
      padding: const EdgeInsets.all(AppSpacing.l),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: AppColors.danger(context)),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ClassStudentsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.xl,
        horizontal: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary(context).withValues(alpha: 0.12),
            AppColors.primary(context).withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.xl),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.groups_rounded,
              iconColor: AppColors.primary(context),
              value: '${state.students.length}',
              label: 'Total Students',
            ),
          ),
          _statDivider(context),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.check_circle_rounded,
              iconColor: AppColors.success(context),
              value: '${state.presentCount}',
              label: 'Present Today',
            ),
          ),
          _statDivider(context),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.cancel_rounded,
              iconColor: AppColors.danger(context),
              value: '${state.absentCount}',
              label: 'Absent Today',
            ),
          ),
          _statDivider(context),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.schedule_rounded,
              iconColor: AppColors.warning(context),
              value: '${state.lateCount}',
              label: 'Late Today',
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider(BuildContext context) {
    return Container(width: 1, height: 48, color: AppColors.border(context));
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.s),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppSpacing.m),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: AppSpacing.s),
        Text(
          value,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return PulseTextField(
      controller: _searchController,
      hint: 'Search students...',
      prefixIcon: Icons.search,
      onChanged: (value) =>
          context.read<ClassStudentsBloc>().add(ClassStudentsSearched(value)),
    );
  }

  Widget _buildStudentsList(BuildContext context, ClassStudentsState state) {
    final students = List<ClassStudentSummary>.from(state.visibleStudents)
      ..sort((a, b) => a.name.compareTo(b.name));

    if (state.students.isEmpty) {
      return _buildEmptyState(
        context,
        title: 'No students found',
        message: 'There are no students enrolled in this class yet.',
        showAddButton: true,
      );
    }

    if (students.isEmpty) {
      return _buildEmptyState(
        context,
        title: 'No matches',
        message: 'No students match your search or filter.',
        showAddButton: false,
      );
    }

    return Column(
      children: [
        for (final student in students) ...[
          _buildStudentItem(context, state, student),
          const SizedBox(height: AppSpacing.m),
        ],
      ],
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String message,
    required bool showAddButton,
  }) {
    return PulseCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.x3l,
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_rounded,
              size: 48,
              color: AppColors.primary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.l),
          Text(
            title,
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          if (showAddButton) ...[
            const SizedBox(height: AppSpacing.xl),
            PulseButton(
              label: 'Add Student',
              icon: Icons.add,
              onPressed: () => _openAddStudent(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStudentItem(
    BuildContext context,
    ClassStudentsState state,
    ClassStudentSummary student,
  ) {
    final status = state.statusOf(student.studentId);
    final statusColor = _colorForStatus(context, status);

    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.m),
      onTap: () => context.push('/staff/students/${student.studentId}'),
      child: Row(
        children: [
          _buildAvatar(context, student),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.name,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  student.admissionNumber,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppSpacing.s),
            ),
            child: Text(
              status.label,
              style: AppTypography.labelSmall.copyWith(
                color: statusColor,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, ClassStudentSummary student) {
    if (student.photoUrl != null && student.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(student.photoUrl!),
      );
    }
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary(context).withValues(alpha: 0.12),
      child: Text(
        student.initials,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.primary(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _colorForStatus(BuildContext context, LessonAttendanceStatus status) {
    return switch (status) {
      LessonAttendanceStatus.present => AppColors.success(context),
      LessonAttendanceStatus.late => AppColors.warning(context),
      LessonAttendanceStatus.absent => AppColors.danger(context),
      LessonAttendanceStatus.excused ||
      LessonAttendanceStatus.medical ||
      LessonAttendanceStatus.approvedLeave => AppColors.information(context),
      LessonAttendanceStatus.notMarked => AppColors.textMuted(context),
    };
  }

  Widget _buildQuickFilters(BuildContext context, ClassStudentsState state) {
    return PulseCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.m,
        vertical: AppSpacing.s,
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Text(
              'Quick Filters',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      context,
                      'All',
                      ClassRosterFilter.all,
                      state,
                    ),
                    _buildFilterChip(
                      context,
                      'Present',
                      ClassRosterFilter.present,
                      state,
                    ),
                    _buildFilterChip(
                      context,
                      'Absent',
                      ClassRosterFilter.absent,
                      state,
                    ),
                    _buildFilterChip(
                      context,
                      'Late',
                      ClassRosterFilter.late,
                      state,
                    ),
                    _buildFilterChip(
                      context,
                      'No Data',
                      ClassRosterFilter.noData,
                      state,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    ClassRosterFilter filter,
    ClassStudentsState state,
  ) {
    final isSelected = state.filter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.m),
      child: GestureDetector(
        onTap: () => context.read<ClassStudentsBloc>().add(
          ClassStudentsFiltered(filter),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.l,
            vertical: AppSpacing.s,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary(context).withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppSpacing.m),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary(context)
                  : AppColors.border(context),
            ),
          ),
          child: Text(
            label,
            style: AppTypography.labelMedium.copyWith(
              color: isSelected
                  ? AppColors.primary(context)
                  : AppColors.textSecondary(context),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  void _showRefineSheet(BuildContext context) {
    final bloc = context.read<ClassStudentsBloc>();
    final currentState = bloc.state;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xl),
        ),
      ),
      builder: (sheetContext) {
        String? gender = currentState.genderFilter;
        ResidencyType? residency = currentState.residencyFilter;

        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Refine Roster',
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.textPrimary(sheetContext),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Gender',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textMuted(sheetContext),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Wrap(
                    spacing: AppSpacing.s,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: gender == null,
                        onSelected: (_) => setSheetState(() => gender = null),
                      ),
                      ChoiceChip(
                        label: const Text('Male'),
                        selected: gender == 'male',
                        onSelected: (_) => setSheetState(() => gender = 'male'),
                      ),
                      ChoiceChip(
                        label: const Text('Female'),
                        selected: gender == 'female',
                        onSelected: (_) =>
                            setSheetState(() => gender = 'female'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Residency',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.textMuted(sheetContext),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Wrap(
                    spacing: AppSpacing.s,
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: residency == null,
                        onSelected: (_) =>
                            setSheetState(() => residency = null),
                      ),
                      ChoiceChip(
                        label: const Text('Day'),
                        selected: residency == ResidencyType.day,
                        onSelected: (_) =>
                            setSheetState(() => residency = ResidencyType.day),
                      ),
                      ChoiceChip(
                        label: const Text('Boarding'),
                        selected: residency == ResidencyType.boarding,
                        onSelected: (_) => setSheetState(
                          () => residency = ResidencyType.boarding,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PulseButton(
                    label: 'Apply',
                    onPressed: () {
                      bloc.add(
                        ClassStudentsRefined(
                          gender: gender,
                          residency: residency,
                          clearGender: gender == null,
                          clearResidency: residency == null,
                        ),
                      );
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _openAddStudent(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Student enrollment is managed by your school administrator. '
            'Ask your admin office to add students to this class.',
          ),
        ),
      );
  }
}

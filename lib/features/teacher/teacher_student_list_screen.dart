import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/domain/entities/lesson_attendance.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';

class TeacherStudentListScreen extends StatefulWidget {
  const TeacherStudentListScreen({super.key});

  @override
  State<TeacherStudentListScreen> createState() => _TeacherStudentListScreenState();
}

class _TeacherStudentListScreenState extends State<TeacherStudentListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  static const _tabFilters = [
    ClassRosterFilter.all,
    ClassRosterFilter.present,
    ClassRosterFilter.absent,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabFilters.length, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      context
          .read<ClassStudentsBloc>()
          .add(ClassStudentsFiltered(_tabFilters[_tabController.index]));
    });
    _load();
  }

  void _load({bool forceRefresh = false}) {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active == null) return;
    context
        .read<ClassStudentsBloc>()
        .add(ClassStudentsRequested(active, forceRefresh: forceRefresh));
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(context),
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
        builder: (context, contextState) {
          if (contextState.active == null) {
            return EmptyState(
              icon: Icons.class_outlined,
              title: 'No class assigned',
              message: 'You are not currently the Class Teacher for any class, '
                  'so there is no class list to show.',
            );
          }

          return BlocBuilder<ClassStudentsBloc, ClassStudentsState>(
            builder: (context, state) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated(context),
                              borderRadius: BorderRadius.circular(AppSpacing.m),
                              border: Border.all(
                                color: AppColors.border(context),
                              ),
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
                                hintStyle: AppTypography.bodyMedium.copyWith(
                                  color: AppColors.textMuted(context),
                                ),
                                prefixIcon: Icon(
                                  Icons.search,
                                  color: AppColors.textMuted(context),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.m),
                        GestureDetector(
                          onTap: () => _openFilters(context, state),
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated(context),
                              borderRadius: BorderRadius.circular(AppSpacing.m),
                              border: Border.all(
                                color: _hasRefinements(state)
                                    ? AppColors.primary(context)
                                    : AppColors.border(context),
                              ),
                            ),
                            child: Icon(
                              Icons.tune,
                              color: _hasRefinements(state)
                                  ? AppColors.primary(context)
                                  : AppColors.textPrimary(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    indicatorColor: AppColors.primary(context),
                    labelColor: AppColors.primary(context),
                    unselectedLabelColor: AppColors.textMuted(context),
                    labelStyle:
                        AppTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: AppTypography.labelLarge,
                    dividerColor: Colors.transparent,
                    tabs: [
                      Tab(text: 'All (${state.students.length})'),
                      Tab(text: 'Present (${state.presentCount})'),
                      Tab(text: 'Absent (${state.absentCount})'),
                    ],
                  ),
                  Expanded(child: _buildBody(context, state)),
                ],
              );
            },
          );
        },
      ),
    );
  }

  static bool _hasRefinements(ClassStudentsState state) =>
      state.genderFilter != null || state.residencyFilter != null;

  Widget _buildBody(BuildContext context, ClassStudentsState state) {
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
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No students yet',
        message: 'No students have been placed in your class for this academic '
            'year. Admissions adds them.',
      );
    }

    final visible = state.visibleStudents;
    if (visible.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No matching students',
        message: 'No student in your class matches the current search and '
            'filters.',
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

  /// The filters the school actually records for this class - a school that
  /// does not capture boarding status is not offered a boarding filter.
  Future<void> _openFilters(BuildContext context, ClassStudentsState state) async {
    final bloc = context.read<ClassStudentsBloc>();
    final genders = state.students
        .map((s) => s.gender)
        .whereType<String>()
        .where((g) => g.isNotEmpty)
        .toSet()
        .toList()
      ..sort();
    final residencies = state.students
        .map((s) => s.residency)
        .where((r) => r != ResidencyType.unknown)
        .toSet()
        .toList();

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.l)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter class list',
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(sheetContext),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (genders.isEmpty && residencies.isEmpty) ...[
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Your school does not record any filterable details for '
                    'this class.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted(sheetContext),
                    ),
                  ),
                ],
                if (genders.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Gender',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary(sheetContext),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Wrap(
                    spacing: AppSpacing.s,
                    children: [
                      for (final gender in genders)
                        FilterChip(
                          label: Text(gender),
                          selected: state.genderFilter == gender,
                          onSelected: (selected) {
                            bloc.add(ClassStudentsRefined(
                              gender: selected ? gender : null,
                              clearGender: !selected,
                            ));
                            Navigator.of(sheetContext).pop();
                          },
                        ),
                    ],
                  ),
                ],
                if (residencies.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.l),
                  Text(
                    'Residency',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary(sheetContext),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.s),
                  Wrap(
                    spacing: AppSpacing.s,
                    children: [
                      for (final residency in residencies)
                        FilterChip(
                          label: Text(residency == ResidencyType.boarding
                              ? 'Boarding'
                              : 'Day'),
                          selected: state.residencyFilter == residency,
                          onSelected: (selected) {
                            bloc.add(ClassStudentsRefined(
                              residency: selected ? residency : null,
                              clearResidency: !selected,
                            ));
                            Navigator.of(sheetContext).pop();
                          },
                        ),
                    ],
                  ),
                ],
                if (_hasRefinements(state)) ...[
                  const SizedBox(height: AppSpacing.l),
                  TextButton(
                    onPressed: () {
                      bloc.add(const ClassStudentsRefined(
                        clearGender: true,
                        clearResidency: true,
                      ));
                      Navigator.of(sheetContext).pop();
                    },
                    child: const Text('Clear filters'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StudentListTile extends StatelessWidget {
  final ClassStudentSummary student;
  final LessonAttendanceStatus status;
  final VoidCallback onTap;

  const _StudentListTile({
    required this.student,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.l),
        padding: const EdgeInsets.all(AppSpacing.m),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(AppSpacing.l),
          border: Border.all(
            color: AppColors.border(context),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary(context).withValues(alpha: 0.1),
              backgroundImage: (student.photoUrl?.isNotEmpty ?? false)
                  ? NetworkImage(student.photoUrl!)
                  : null,
              child: (student.photoUrl?.isNotEmpty ?? false)
                  ? null
                  : Text(
                      student.initials,
                      style: AppTypography.headlineSmall
                          .copyWith(color: AppColors.primary(context)),
                    ),
            ),
            const SizedBox(width: AppSpacing.l),
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
                    'Admission No: ${student.admissionNumber}',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              status.label,
              style: AppTypography.labelMedium.copyWith(
                color: _statusColor(context, status),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.s),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  /// Unmarked is muted rather than red: nobody has said this student is
  /// absent, and colouring it as an absence would put a claim on the row that
  /// no teacher made.
  static Color _statusColor(BuildContext context, LessonAttendanceStatus status) {
    if (status == LessonAttendanceStatus.notMarked) {
      return AppColors.textMuted(context);
    }
    if (status.countsAsPresent) return AppColors.success(context);
    if (status.isAuthorisedAbsence) return AppColors.warning(context);
    return AppColors.danger(context);
  }
}

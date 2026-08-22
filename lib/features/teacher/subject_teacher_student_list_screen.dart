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

import 'domain/entities/subject_enrollment.dart';
import 'presentation/bloc/subject_students/subject_students_bloc.dart';
import 'presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';

/// Subject Teacher's own student list - scoped to the students enrolled in
/// the active subject+class, never the whole class roster. Mirrors
/// TeacherStudentListScreen's visual language (same stats card, search,
/// quick filters, roster tiles) so the two panels feel like one product, but
/// reads from SubjectStudentsBloc/SubjectStudentRepository so a subject
/// teacher can never see students who don't take their subject.
///
/// The search and filter icons in the app bar are functional here (they
/// weren't wired to anything useful on the shared screen this was split
/// from) - search opens the inline search field below the stats card, filter
/// opens the refine sheet.
class SubjectTeacherStudentListScreen extends StatefulWidget {
  const SubjectTeacherStudentListScreen({super.key});

  @override
  State<SubjectTeacherStudentListScreen> createState() =>
      _SubjectTeacherStudentListScreenState();
}

class _SubjectTeacherStudentListScreenState
    extends State<SubjectTeacherStudentListScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load({bool forceRefresh = false}) {
    if (!mounted) return;
    final active = context.read<SubjectTeacherContextBloc>().state.active;
    if (active == null) return;
    context.read<SubjectStudentsBloc>().add(
      SubjectStudentsRequested(active, forceRefresh: forceRefresh),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      builder: (context, contextState) {
        final active = contextState.active;
        final placement = active == null
            ? ''
            : [
                active.subjectName,
                active.className,
              ].where((e) => e != null && e.isNotEmpty).join(' • ');

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
                Text(
                  placement.isEmpty ? 'No subject assigned' : placement,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary(context),
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.search, color: AppColors.textPrimary(context)),
                onPressed: () => setState(() => _showSearch = !_showSearch),
              ),
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: AppColors.textPrimary(context),
                ),
                onPressed: active == null
                    ? null
                    : () => _showRefineSheet(context),
              ),
              const SizedBox(width: AppSpacing.s),
            ],
          ),
          body: active == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.x3l),
                    child: Text(
                      'You are not currently teaching any subject, '
                      'so there are no students to show.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary(context),
                      ),
                    ),
                  ),
                )
              : BlocBuilder<SubjectStudentsBloc, SubjectStudentsState>(
                  builder: (context, state) {
                    if (state.isLoading && state.students.isEmpty) {
                      return const Center(child: SchoolPulseLoader());
                    }

                    return RefreshIndicator(
                      onRefresh: () async => _load(forceRefresh: true),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          children: [
                            const SizedBox(height: AppSpacing.l),
                            if (state.errorMessage != null) ...[
                              _buildErrorBanner(context, state.errorMessage!),
                              const SizedBox(height: AppSpacing.l),
                            ],
                            _buildStatsCard(context, state),
                            const SizedBox(height: AppSpacing.l),
                            if (_showSearch) ...[
                              _buildSearchField(context),
                              const SizedBox(height: AppSpacing.m),
                            ],
                            _buildQuickFilters(context, state),
                            const SizedBox(height: AppSpacing.m),
                            Expanded(child: _buildStudentsList(context, state)),
                            const SizedBox(height: AppSpacing.m),
                          ],
                        ),
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

  Widget _buildStatsCard(BuildContext context, SubjectStudentsState state) {
    final average = state.subjectAverage;
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
              label: 'Enrolled',
            ),
          ),
          _statDivider(context),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.assignment_turned_in_rounded,
              iconColor: AppColors.success(context),
              value:
                  '${state.students.where((s) => s.assessmentsMarked > 0).length}',
              label: 'Marked',
            ),
          ),
          _statDivider(context),
          Expanded(
            child: _buildStatItem(
              context,
              icon: Icons.trending_up_rounded,
              iconColor: AppColors.warning(context),
              value: average == null ? '–' : average.toStringAsFixed(0),
              label: 'Subject Avg',
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
      onChanged: (value) => context.read<SubjectStudentsBloc>().add(
        SubjectStudentsSearched(value),
      ),
    );
  }

  Widget _buildStudentsList(BuildContext context, SubjectStudentsState state) {
    if (state.students.isEmpty && state.errorMessage != null) {
      return _buildEmptyState(
        context,
        title: 'Could not load your student list',
        message: state.errorMessage!,
        showRetryButton: true,
      );
    }

    if (state.students.isEmpty) {
      return _buildEmptyState(
        context,
        title: 'No students found',
        message: 'No students are enrolled in this subject yet.',
        showRetryButton: false,
      );
    }

    final students = List<SubjectStudentSummary>.from(state.visibleStudents)
      ..sort((a, b) => a.name.compareTo(b.name));

    if (students.isEmpty) {
      return _buildEmptyState(
        context,
        title: 'No matching students',
        message: 'No enrolled student matches the current search.',
        showRetryButton: false,
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: students.length,
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.m),
      itemBuilder: (context, index) =>
          _buildStudentItem(context, students[index]),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required String title,
    required String message,
    required bool showRetryButton,
  }) {
    return Center(
      child: SingleChildScrollView(
        child: PulseCard(
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.x3l,
            horizontal: AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
              if (showRetryButton) ...[
                const SizedBox(height: AppSpacing.xl),
                PulseButton(
                  label: 'Retry',
                  icon: Icons.refresh,
                  onPressed: () => _load(forceRefresh: true),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentItem(
    BuildContext context,
    SubjectStudentSummary student,
  ) {
    final rate = student.attendanceRate;
    final statusColor = rate == null
        ? AppColors.textMuted(context)
        : rate >= 75
        ? AppColors.success(context)
        : rate >= 50
        ? AppColors.warning(context)
        : AppColors.danger(context);
    final statusLabel = rate == null
        ? 'No data'
        : '${rate.toStringAsFixed(0)}%';

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
              statusLabel,
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

  Widget _buildAvatar(BuildContext context, SubjectStudentSummary student) {
    if (student.photoUrl != null && student.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: NetworkImage(student.photoUrl!),
      );
    }
    final initials = student.name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();
    return CircleAvatar(
      radius: 24,
      backgroundColor: AppColors.primary(context).withValues(alpha: 0.12),
      child: Text(
        initials,
        style: AppTypography.titleMedium.copyWith(
          color: AppColors.primary(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildQuickFilters(BuildContext context, SubjectStudentsState state) {
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
                      SubjectRosterFilter.all,
                      state,
                    ),
                    _buildFilterChip(
                      context,
                      'No Marks',
                      SubjectRosterFilter.noMarks,
                      state,
                    ),
                    _buildFilterChip(
                      context,
                      'Below Average',
                      SubjectRosterFilter.belowAverage,
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
    SubjectRosterFilter filter,
    SubjectStudentsState state,
  ) {
    final isSelected = state.filter == filter;
    return Padding(
      padding: const EdgeInsets.only(right: AppSpacing.m),
      child: GestureDetector(
        onTap: () => context.read<SubjectStudentsBloc>().add(
          SubjectStudentsFiltered(filter),
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
    final bloc = context.read<SubjectStudentsBloc>();
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
        SubjectRosterFilter filter = currentState.filter;

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
                    'Show',
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
                        selected: filter == SubjectRosterFilter.all,
                        onSelected: (_) => setSheetState(
                          () => filter = SubjectRosterFilter.all,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('No Marks'),
                        selected: filter == SubjectRosterFilter.noMarks,
                        onSelected: (_) => setSheetState(
                          () => filter = SubjectRosterFilter.noMarks,
                        ),
                      ),
                      ChoiceChip(
                        label: const Text('Below Average'),
                        selected: filter == SubjectRosterFilter.belowAverage,
                        onSelected: (_) => setSheetState(
                          () => filter = SubjectRosterFilter.belowAverage,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  PulseButton(
                    label: 'Apply',
                    onPressed: () {
                      bloc.add(SubjectStudentsFiltered(filter));
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
}

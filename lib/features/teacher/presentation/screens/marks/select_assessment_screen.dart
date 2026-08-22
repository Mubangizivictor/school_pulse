import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/domain/repositories/marks_repository.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';
import 'package:school_pulse/injection_container.dart' as di;

enum _AssessmentLifecycle { upcoming, open, closed }

class SelectAssessmentScreen extends StatefulWidget {
  const SelectAssessmentScreen({super.key});

  @override
  State<SelectAssessmentScreen> createState() => _SelectAssessmentScreenState();
}

class _SelectAssessmentScreenState extends State<SelectAssessmentScreen> {
  String _termFilter = 'All';
  final MarksRepository _marksRepository = di.sl<MarksRepository>();

  /// Per-assessment (studentsEntered, totalStudents) computed from real
  /// mark-entry records - fetched once per assessment id since there is no
  /// backend aggregate to read this from directly.
  final Map<String, int> _enteredCountByAssessment = {};
  final Set<String> _loadingProgressFor = {};

  void _loadProgressIfNeeded(SubjectAssessment assessment) {
    if (_enteredCountByAssessment.containsKey(assessment.id) ||
        _loadingProgressFor.contains(assessment.id)) {
      return;
    }
    final marksContext = context.read<MarksBloc>().state.context;
    if (marksContext == null) return;

    _loadingProgressFor.add(assessment.id);
    _fetchEnteredCount(marksContext, assessment).then((count) {
      if (!mounted) return;
      setState(() {
        _enteredCountByAssessment[assessment.id] = count;
        _loadingProgressFor.remove(assessment.id);
      });
    });
  }

  Future<int> _fetchEnteredCount(
    ActiveResponsibilityContext marksContext,
    SubjectAssessment assessment,
  ) async {
    final studentIds = <String>{};
    for (final component in assessment.markableComponents) {
      final result = await _marksRepository.getMarks(
        context: marksContext,
        assessment: assessment,
        component: component,
      );
      result.fold((_) {}, (entries) {
        for (final entry in entries) {
          if (entry.status.isResolved) studentIds.add(entry.studentId);
        }
      });
    }
    return studentIds.length;
  }

  _AssessmentLifecycle _lifecycleOf(SubjectAssessment assessment) {
    if (assessment.status == AssessmentAvailability.locked ||
        assessment.status == AssessmentAvailability.archived ||
        (assessment.isOverdue && !assessment.status.acceptsEntry)) {
      return _AssessmentLifecycle.closed;
    }
    if (!assessment.hasOpened) return _AssessmentLifecycle.upcoming;
    return _AssessmentLifecycle.open;
  }

  ({String label, Color color}) _lifecycleStyle(
    BuildContext context,
    _AssessmentLifecycle lifecycle,
  ) {
    return switch (lifecycle) {
      _AssessmentLifecycle.open => (
        label: 'Open',
        color: AppColors.success(context),
      ),
      _AssessmentLifecycle.upcoming => (
        label: 'Upcoming',
        color: AppColors.warning(context),
      ),
      _AssessmentLifecycle.closed => (
        label: 'Closed',
        color: AppColors.textMuted(context),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      body: SafeArea(
        child: BlocBuilder<MarksBloc, MarksState>(
          builder: (context, state) {
            return BlocBuilder<StructureBloc, StructureState>(
              builder: (context, structureState) {
                final terms = structureState.academicTerms;
                final termNames = <String>{
                  'All',
                  for (final t in terms) t.name,
                }.toList();

                final visible = state.assessments.where((a) {
                  if (_termFilter == 'All') return true;
                  final term = terms.where((t) => t.id == a.termId).firstOrNull;
                  return term?.name == _termFilter;
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: _buildHeader(context, state),
                    ),
                    const SizedBox(height: 12),
                    if (termNames.length > 1)
                      _buildTermTabs(context, termNames),
                    const SizedBox(height: 12),
                    _buildInfoBanner(context),
                    Expanded(
                      child: state.isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : visible.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Text(
                                  'No assessments found for this filter.',
                                  style: TextStyle(
                                    color: AppColors.textMuted(context),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          : ListView(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                              children: [
                                Text(
                                  'Assessments',
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                for (final assessment in visible)
                                  _buildAssessmentCard(
                                    context,
                                    assessment,
                                    state,
                                    terms,
                                  ),
                                const SizedBox(height: 12),
                                _buildCantFindBanner(context),
                              ],
                            ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, MarksState state) {
    return Row(
      children: [
        IconButton(
          onPressed: () => context.pop(),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
          icon: Icon(
            Icons.arrow_back,
            color: AppColors.textPrimary(context),
            size: 22,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select Assessment',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                [
                  state.context?.className,
                  state.context?.streamName,
                ].where((e) => e != null && e.isNotEmpty).join(' '),
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTermTabs(BuildContext context, List<String> termNames) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: termNames.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = termNames[index];
          final isSelected = label == _termFilter;
          return InkWell(
            onTap: () => setState(() => _termFilter = label),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary(context)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: isSelected
                    ? null
                    : Border.all(
                        color: AppColors.border(context).withValues(alpha: 0.6),
                      ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textSecondary(context),
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.primary(context).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary(context),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calendar_today,
                color: Colors.white,
                size: 15,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mark Entry Status',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Select an assessment to enter or manage marks for your students.',
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCantFindBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary(context).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: AppColors.primary(context),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Can't find an assessment?",
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Assessments are created by the Academic Office.',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard(
    BuildContext context,
    SubjectAssessment assessment,
    MarksState state,
    List<AcademicTerm> terms,
  ) {
    _loadProgressIfNeeded(assessment);

    final lifecycle = _lifecycleOf(assessment);
    final style = _lifecycleStyle(context, lifecycle);
    final totalStudents = state.students.length;
    final entered = _enteredCountByAssessment[assessment.id];
    final isLoadingProgress = entered == null;
    final completion = (totalStudents > 0 && entered != null)
        ? ((entered / totalStudents) * 100).round()
        : 0;
    final term = terms.where((t) => t.id == assessment.termId).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          context.read<MarksBloc>().add(MarksAssessmentSelected(assessment));
          context.push('/staff/marks/select-component');
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeadingIcon(context, assessment),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assessment.title.isEmpty
                              ? assessment.assessmentTypeName
                              : assessment.title,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                            fontWeight: FontWeight.bold,
                            fontSize: 14.5,
                          ),
                        ),
                        Text(
                          assessment.assessmentTypeName.isNotEmpty
                              ? assessment.assessmentTypeName
                              : (term?.name ?? ''),
                          style: TextStyle(
                            color: AppColors.textSecondary(context),
                            fontSize: 12,
                          ),
                        ),
                        if (assessment.assessmentDate != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.calendar_today_outlined,
                                  size: 11,
                                  color: AppColors.textMuted(context),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDate(assessment.assessmentDate!),
                                  style: TextStyle(
                                    color: AppColors.textMuted(context),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: style.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          style.label,
                          style: TextStyle(
                            color: style.color,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textMuted(context),
                        size: 18,
                      ),
                    ],
                  ),
                ],
              ),
              const Divider(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStat(
                      context,
                      icon: Icons.groups_outlined,
                      label: '$totalStudents Students',
                    ),
                  ),
                  Expanded(
                    child: _buildStat(
                      context,
                      icon: Icons.assignment_turned_in_outlined,
                      label: isLoadingProgress
                          ? 'Loading…'
                          : (totalStudents == 0
                                ? 'Not started'
                                : '$entered Marks Entered'),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: isLoadingProgress
                            ? CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary(context),
                              )
                            : CircularProgressIndicator(
                                value: completion / 100,
                                strokeWidth: 2,
                                backgroundColor: AppColors.border(
                                  context,
                                ).withValues(alpha: 0.4),
                                color: completion == 100
                                    ? AppColors.success(context)
                                    : AppColors.primary(context),
                              ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isLoadingProgress ? '' : '$completion%',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(BuildContext context, SubjectAssessment assessment) {
    final icon = switch (assessment.assessmentTypeName.toLowerCase()) {
      final t when t.contains('oral') => Icons.mic_none_rounded,
      final t when t.contains('project') => Icons.list_alt,
      final t when t.contains('mid') => Icons.description_outlined,
      _ => Icons.article_outlined,
    };
    final color = AppColors.primary(context);

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildStat(
    BuildContext context, {
    required IconData icon,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary(context)),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 11.5,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

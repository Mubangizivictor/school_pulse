import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/active_responsibility_context.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/subject_teacher_context/subject_teacher_context_state.dart';

/// Marks entry serves both responsibilities: a Subject Teacher's own subject,
/// and a Class Teacher entering marks for any subject taught in their class.
/// Whichever context bloc actually holds an active responsibility right now
/// is the one this screen uses - never both, and never a mix of their data.
class MarksDashboardScreen extends StatefulWidget {
  const MarksDashboardScreen({super.key});

  @override
  State<MarksDashboardScreen> createState() => _MarksDashboardScreenState();
}

class _MarksDashboardScreenState extends State<MarksDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final active = _activeContext();
    if (active != null) {
      context.read<MarksBloc>().add(MarksRequested(active));
    }
  }

  ActiveResponsibilityContext? _activeContext() {
    final subjectActive = context
        .read<SubjectTeacherContextBloc>()
        .state
        .active;
    if (subjectActive != null) return subjectActive;
    return context.read<ClassTeacherContextBloc>().state.active;
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('$feature coming soon')));
  }

  Future<void> _openCreateAssessmentDialog() async {
    final titleController = TextEditingController();
    final maxMarkController = TextEditingController(text: '100');
    String assessmentType = 'Test';
    const types = ['Test', 'Exam', 'Assignment', 'Practical', 'Project'];

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Create Assessment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'e.g. Term 2 Mid-term Test',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: assessmentType,
                decoration: const InputDecoration(labelText: 'Type'),
                items: types
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => assessmentType = value);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: maxMarkController,
                keyboardType: const TextInputType.numberWithOptions(),
                decoration: const InputDecoration(labelText: 'Maximum mark'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );

    if (result != true || !mounted) return;

    final maximumMark = double.tryParse(maxMarkController.text.trim());
    if (titleController.text.trim().isEmpty || maximumMark == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a title and a valid maximum mark.'),
        ),
      );
      return;
    }

    context.read<MarksBloc>().add(
      MarksAssessmentCreated(
        title: titleController.text.trim(),
        assessmentType: assessmentType,
        maximumMark: maximumMark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubjectTeacherContextBloc, SubjectTeacherContextState>(
      builder: (context, subjectContextState) {
        return BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
          builder: (context, classContextState) {
            final active =
                subjectContextState.active ?? classContextState.active;

            return Scaffold(
              backgroundColor: AppColors.background(context),
              body: SafeArea(
                child: active == null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'You are not currently assigned to a subject or '
                            'class, so there are no marks to enter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                            ),
                          ),
                        ),
                      )
                    : BlocListener<MarksBloc, MarksState>(
                        listenWhen: (previous, current) =>
                            previous.errorMessage != current.errorMessage ||
                            previous.successMessage != current.successMessage,
                        listener: (context, state) {
                          final message =
                              state.errorMessage ?? state.successMessage;
                          if (message == null) return;
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(message)));
                          context.read<MarksBloc>().add(
                            const MarksFeedbackCleared(),
                          );
                        },
                        child: BlocBuilder<MarksBloc, MarksState>(
                          builder: (context, state) {
                            if (state.isLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (state.needsSubjectSelection) {
                              return _buildSubjectPicker(
                                context,
                                active,
                                state,
                              );
                            }

                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    12,
                                    16,
                                    0,
                                  ),
                                  child: _buildHeader(
                                    context,
                                    active,
                                    subjectNameOverride:
                                        state.selectedSubject?.name,
                                  ),
                                ),
                                Expanded(
                                  child: SingleChildScrollView(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 14),
                                        _buildStatsCard(context, active, state),
                                        const SizedBox(height: 18),
                                        Text(
                                          'Quick Actions',
                                          style: TextStyle(
                                            color: AppColors.textPrimary(
                                              context,
                                            ),
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        _buildQuickActions(context),
                                        const SizedBox(height: 18),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Assessments',
                                              style: TextStyle(
                                                color: AppColors.textPrimary(
                                                  context,
                                                ),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                minimumSize: Size.zero,
                                                padding: EdgeInsets.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              onPressed: () => context.push(
                                                '/staff/marks/history',
                                              ),
                                              child: Text(
                                                'View All',
                                                style: TextStyle(
                                                  color: AppColors.primary(
                                                    context,
                                                  ),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _buildAssessmentsSection(
                                          context,
                                          state.assessments,
                                        ),
                                        const SizedBox(height: 18),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Recent Activity',
                                              style: TextStyle(
                                                color: AppColors.textPrimary(
                                                  context,
                                                ),
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            TextButton(
                                              style: TextButton.styleFrom(
                                                minimumSize: Size.zero,
                                                padding: EdgeInsets.zero,
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              onPressed: () {},
                                              child: Text(
                                                'View All',
                                                style: TextStyle(
                                                  color: AppColors.primary(
                                                    context,
                                                  ),
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        _buildRecentActivityCard(context),
                                        const SizedBox(height: 24),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
              ),
            );
          },
        );
      },
    );
  }

  /// Only reached for a Class Teacher, whose context names no subject of its
  /// own - marks for another teacher's subject need to say which subject
  /// before anything else on this screen can mean anything.
  Widget _buildSubjectPicker(
    BuildContext context,
    ActiveResponsibilityContext active,
    MarksState state,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: _buildHeader(context, active),
        ),
        Expanded(
          child: state.classSubjects.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      'No subjects are set up for ${active.className ?? 'this class'} yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted(context)),
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    Text(
                      'Which subject are you entering marks for?',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final subject in state.classSubjects)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => context.read<MarksBloc>().add(
                            MarksSubjectSelected(subject),
                          ),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 14,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceElevated(context),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.border(
                                  context,
                                ).withValues(alpha: 0.5),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    subject.name,
                                    style: TextStyle(
                                      color: AppColors.textPrimary(context),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(
                                  Icons.chevron_right,
                                  color: AppColors.textMuted(context),
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _buildHeader(
    BuildContext context,
    ActiveResponsibilityContext active, {
    String? subjectNameOverride,
  }) {
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
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.primary(context).withValues(alpha: 0.15),
          child: Icon(
            Icons.menu_book_rounded,
            color: AppColors.primary(context),
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                subjectNameOverride ?? active.subjectName ?? 'Subject',
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                [
                  active.className,
                  active.streamName,
                ].where((e) => e != null && e.isNotEmpty).join(' '),
                style: TextStyle(
                  color: AppColors.primary(context),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        _buildYearSelector(context),
      ],
    );
  }

  Widget _buildYearSelector(BuildContext context) {
    final now = DateTime.now();
    final startYear = now.month >= 9 ? now.year : now.year - 1;
    final label = '$startYear/${startYear + 1}';

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showComingSoon('Academic year selection'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.border(context).withValues(alpha: 0.6),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 13,
              color: AppColors.textSecondary(context),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: AppColors.textSecondary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(
    BuildContext context,
    ActiveResponsibilityContext active,
    MarksState state,
  ) {
    final total = state.assessments.length;
    final pending = state.assessments
        .where((a) => a.status.acceptsEntry)
        .length;
    final completed = state.assessments
        .where(
          (a) =>
              a.status == AssessmentAvailability.approved ||
              a.status == AssessmentAvailability.published ||
              a.status == AssessmentAvailability.submitted,
        )
        .length;
    final completionRate = total == 0 ? 0 : ((completed / total) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetric(
              context,
              icon: Icons.assignment_turned_in_outlined,
              iconColor: AppColors.primary(context),
              value: '$total',
              label: 'Assessments',
            ),
          ),
          Expanded(
            child: _buildMetric(
              context,
              icon: Icons.groups_outlined,
              iconColor: AppColors.success(context),
              value: '${state.students.length}',
              label: 'Students',
            ),
          ),
          Expanded(
            child: _buildMetric(
              context,
              icon: Icons.edit_outlined,
              iconColor: AppColors.warning(context),
              value: '$pending',
              label: 'Open for entry',
            ),
          ),
          Expanded(
            child: _buildMetric(
              context,
              icon: Icons.check_circle_outline,
              iconColor: AppColors.information(context),
              value: '$completionRate%',
              label: 'Completion',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetric(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary(context),
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textMuted(context), fontSize: 9),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _buildActionItem(
          context,
          label: 'Enter Marks',
          subtitle: 'Enter marks\nmanually',
          icon: Icons.edit_outlined,
          iconColor: AppColors.primary(context),
          onTap: () => context.push('/staff/marks/select-assessment'),
        ),
        const SizedBox(width: 10),
        _buildActionItem(
          context,
          label: 'Import Marks',
          subtitle: 'Import from\nExcel / CSV',
          icon: Icons.file_upload_outlined,
          iconColor: AppColors.success(context),
          onTap: () => context.push('/staff/marks/import'),
        ),
        const SizedBox(width: 10),
        _buildActionItem(
          context,
          label: 'Analytics',
          subtitle: 'View subject\nperformance',
          icon: Icons.bar_chart,
          iconColor: AppColors.information(context),
          onTap: () => context.push('/staff/marks/analytics'),
        ),
        const SizedBox(width: 10),
        _buildActionItem(
          context,
          label: 'Export Marks',
          subtitle: 'Export marks\ndata',
          icon: Icons.file_download_outlined,
          iconColor: AppColors.warning(context),
          onTap: () => _showComingSoon('Export marks'),
        ),
      ],
    );
  }

  Widget _buildActionItem(
    BuildContext context, {
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated(context),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border(context).withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary(context),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textMuted(context),
                  fontSize: 8.5,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentsSection(
    BuildContext context,
    List<SubjectAssessment> assessments,
  ) {
    if (assessments.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.border(context).withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 40,
              color: AppColors.primary(context).withValues(alpha: 0.6),
            ),
            const SizedBox(height: 10),
            Text(
              'No assessments yet',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Create your first assessment to start entering marks.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textMuted(context),
                fontSize: 11.5,
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openCreateAssessmentDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary(context),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text(
                  'Create Assessment',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        for (final assessment in assessments.take(5))
          _buildAssessmentItem(context, assessment),
      ],
    );
  }

  Widget _buildRecentActivityCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.list_alt,
              color: AppColors.primary(context),
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'No recent activity',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Activities will appear here once you start.',
                  style: TextStyle(
                    color: AppColors.textMuted(context),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textMuted(context),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentItem(
    BuildContext context,
    SubjectAssessment assessment,
  ) {
    final statusColor = switch (assessment.status) {
      AssessmentAvailability.approved ||
      AssessmentAvailability.published ||
      AssessmentAvailability.submitted => AppColors.success(context),
      AssessmentAvailability.locked ||
      AssessmentAvailability.archived => AppColors.textMuted(context),
      _ => AppColors.warning(context),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
      ),
      child: InkWell(
        onTap: () {
          context.read<MarksBloc>().add(MarksAssessmentSelected(assessment));
          context.push('/staff/marks/select-component');
        },
        child: Row(
          children: [
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
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    assessment.assessmentTypeName,
                    style: TextStyle(
                      color: AppColors.textSecondary(context),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                assessment.status.label,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted(context),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

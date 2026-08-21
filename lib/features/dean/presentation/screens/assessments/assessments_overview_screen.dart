import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/domain/entities/assessment_moderation.dart';
import 'package:school_pulse/features/dean/presentation/widgets/glass_icon_button.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

/// Assessments Overview — root of the Assessments tab. Lists every
/// [AssessmentModeration] with a status badge; tapping it can push
/// Marks Completion Matrix / Interventions (handled by the shell's tab
/// navigator per the plan's tab mapping).
class AssessmentsOverviewScreen extends StatefulWidget {
  const AssessmentsOverviewScreen({super.key});

  @override
  State<AssessmentsOverviewScreen> createState() =>
      _AssessmentsOverviewScreenState();
}

class _AssessmentsOverviewScreenState extends State<AssessmentsOverviewScreen> {
  String? _selectedType;
  String? _selectedTerm;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    return BlocProvider(
      create: (context) =>
          sl<DeanBloc>()..add(AssessmentsOverviewRequested(schoolId: schoolId)),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          backgroundColor: AppColors.surfaceContainer(context),
          automaticallyImplyLeading: false,
          title: Text('Assessments Overview', style: AppTypography.titleLarge),
          actions: [
            GlassIconButton(
              icon: Icons.grid_on_outlined,
              tooltip: 'Marks Completion Matrix',
              onPressed: () =>
                  Navigator.of(context).pushNamed('marks-completion'),
            ),
            const SizedBox(width: AppSpacing.l),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showCreateAssessmentSheet(context),
          child: const Icon(Icons.add),
        ),
        body: BlocConsumer<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              context.read<DeanBloc>().add(
                AssessmentsOverviewRequested(schoolId: schoolId),
              );
            }
          },
          builder: (context, state) {
            if (state is AssessmentsOverviewLoaded) {
              if (state.assessments.isEmpty) {
                return const EmptyState(
                  icon: Icons.fact_check_outlined,
                  title: 'No assessments',
                  message: 'No assessments have been submitted yet.',
                );
              }
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Row(
                      children: [
                        Expanded(child: _buildTypeFilter(context)),
                        const SizedBox(width: AppSpacing.l),
                        Expanded(child: _buildTermFilter(context)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.xl,
                        0,
                        AppSpacing.xl,
                        AppSpacing.xl,
                      ),
                      itemCount: state.assessments.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: AppSpacing.l),
                      itemBuilder: (context, index) =>
                          _AssessmentCard(assessment: state.assessments[index]),
                    ),
                  ),
                ],
              );
            }
            if (state is DeanError) {
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Could not load assessments',
                message: state.message,
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildTypeFilter(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: _selectedType,
      decoration: InputDecoration(
        labelText: 'Type',
        filled: true,
        fillColor: AppColors.surfaceContainer(context),
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All Types')),
        DropdownMenuItem(value: 'test', child: Text('Test')),
        DropdownMenuItem(value: 'exam', child: Text('Exam')),
        DropdownMenuItem(value: 'practical', child: Text('Practical')),
      ],
      onChanged: (value) => setState(() => _selectedType = value),
    );
  }

  Widget _buildTermFilter(BuildContext context) {
    return DropdownButtonFormField<String?>(
      initialValue: _selectedTerm,
      decoration: InputDecoration(
        labelText: 'Term',
        filled: true,
        fillColor: AppColors.surfaceContainer(context),
        border: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.medium,
          borderSide: BorderSide.none,
        ),
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('All Terms')),
        DropdownMenuItem(value: 'term1', child: Text('Term 1')),
        DropdownMenuItem(value: 'term2', child: Text('Term 2')),
        DropdownMenuItem(value: 'term3', child: Text('Term 3')),
      ],
      onChanged: (value) => setState(() => _selectedTerm = value),
    );
  }

  void _showCreateAssessmentSheet(BuildContext context) {
    final deanBloc = context.read<DeanBloc>();
    final authState = context.read<AuthBloc>().state;
    final schoolId = authState is AuthAuthenticated
        ? authState.user.schoolId
        : '';
    final campusId = authState is AuthAuthenticated
        ? authState.user.campusId
        : null;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _CreateAssessmentSheet(
        onSubmit: (event) {
          deanBloc.add(event);
        },
        schoolId: schoolId,
        campusId: campusId,
      ),
    );
  }
}

class _CreateAssessmentSheet extends StatefulWidget {
  final void Function(CreateAssessmentRequested) onSubmit;
  final String schoolId;
  final String? campusId;

  const _CreateAssessmentSheet({
    required this.onSubmit,
    required this.schoolId,
    this.campusId,
  });

  @override
  State<_CreateAssessmentSheet> createState() => _CreateAssessmentSheetState();
}

const _assessmentTypes = [
  'Test',
  'Exam',
  'Practical',
  'Quiz',
  'Coursework',
  'Project',
  'CAT',
  'Mock',
  'Mid-Term',
  'End of Term',
];

class _CreateAssessmentSheetState extends State<_CreateAssessmentSheet> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _subject = '';
  String _className = '';
  String? _type = _assessmentTypes.first;
  bool _isCustomType = false;
  final _customTypeController = TextEditingController();
  final _maxScoreController = TextEditingController(text: '100');

  @override
  void dispose() {
    _customTypeController.dispose();
    _maxScoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'New Assessment'),
              const SizedBox(height: AppSpacing.xl),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _title = v!,
              ),
              const SizedBox(height: AppSpacing.l),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _subject = v!,
              ),
              const SizedBox(height: AppSpacing.l),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Class'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _className = v!,
              ),
              const SizedBox(height: AppSpacing.l),
              DropdownButtonFormField<String>(
                initialValue: _isCustomType ? 'custom' : _type,
                decoration: const InputDecoration(labelText: 'Type'),
                items: [
                  for (final type in _assessmentTypes)
                    DropdownMenuItem(value: type, child: Text(type)),
                  const DropdownMenuItem(
                    value: 'custom',
                    child: Text('Custom...'),
                  ),
                ],
                onChanged: (v) => setState(() {
                  _isCustomType = v == 'custom';
                  _type = _isCustomType ? null : v;
                }),
              ),
              if (_isCustomType) ...[
                const SizedBox(height: AppSpacing.l),
                TextFormField(
                  controller: _customTypeController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Assessment Type',
                  ),
                  validator: (v) =>
                      _isCustomType && (v?.isEmpty ?? true) ? 'Required' : null,
                ),
              ],
              const SizedBox(height: AppSpacing.l),
              TextFormField(
                controller: _maxScoreController,
                decoration: const InputDecoration(labelText: 'Maximum Score'),
                keyboardType: TextInputType.number,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.x3l),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    final effectiveType = _isCustomType
                        ? _customTypeController.text
                        : (_type ?? '');
                    final maxScore =
                        double.tryParse(_maxScoreController.text) ?? 100;
                    widget.onSubmit(
                      CreateAssessmentRequested(
                        schoolId: widget.schoolId,
                        campusId: widget.campusId,
                        title: _title,
                        subjectId: _subject,
                        classId: _className,
                        type: effectiveType,
                        maximumMark: maxScore,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Create Assessment'),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final AssessmentModeration assessment;

  const _AssessmentCard({required this.assessment});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  assessment.title,
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              StatusBadge(
                label: _statusLabel(assessment.status),
                color: _statusColor(context, assessment.status),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.s),
          Text(
            '${assessment.subjectName} • ${assessment.className}',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Icon(
                Icons.person_outline,
                size: 16,
                color: AppColors.textMuted(context),
              ),
              const SizedBox(width: AppSpacing.s),
              Expanded(
                child: Text(
                  assessment.teacherName,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
              Text(
                '${assessment.submissionCount}/${assessment.totalStudents}',
                style: AppTypography.titleSmall.copyWith(
                  color: AppColors.textPrimary(context),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (assessment.rejectionReason != null) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Rejected: ${assessment.rejectionReason}',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.danger(context),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _statusLabel(ModerationStatus status) {
    switch (status) {
      case ModerationStatus.pending:
        return 'Pending';
      case ModerationStatus.approved:
        return 'Approved';
      case ModerationStatus.rejected:
        return 'Rejected';
    }
  }

  Color _statusColor(BuildContext context, ModerationStatus status) {
    switch (status) {
      case ModerationStatus.pending:
        return AppColors.warning(context);
      case ModerationStatus.approved:
        return AppColors.success(context);
      case ModerationStatus.rejected:
        return AppColors.danger(context);
    }
  }
}

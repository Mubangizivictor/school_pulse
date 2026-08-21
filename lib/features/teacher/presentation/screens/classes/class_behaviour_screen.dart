import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_button.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_behaviour.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_student_summary.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_work/class_work_bloc.dart';

class ClassBehaviourScreen extends StatefulWidget {
  final String classId;
  const ClassBehaviourScreen({super.key, required this.classId});

  @override
  State<ClassBehaviourScreen> createState() => _ClassBehaviourScreenState();
}

class _ClassBehaviourScreenState extends State<ClassBehaviourScreen> {
  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassWorkBloc>().add(ClassWorkRequested(active));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark
        ? AppColors.textPrimaryDark
        : AppColors.textPrimaryLight;

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
          backgroundColor: isDark ? AppColors.bgDark : AppColors.bgLight,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: primaryColor),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Behaviour Records',
                  style: AppTypography.titleLarge.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  // The teacher's actual class, not a hardcoded label.
                  placement.isEmpty ? 'No class assigned' : placement,
                  style: AppTypography.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          body: active == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.x3l),
                    child: Text(
                      'You are not currently the Class Teacher for any class, '
                      'so there are no behaviour records to show.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                )
              : BlocConsumer<ClassWorkBloc, ClassWorkState>(
                  listenWhen: (previous, current) =>
                      previous.errorMessage != current.errorMessage ||
                      previous.successMessage != current.successMessage,
                  listener: (context, state) {
                    final message = state.successMessage ?? state.errorMessage;
                    if (message == null) return;
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: state.successMessage != null
                              ? AppColors.success(context)
                              : AppColors.danger(context),
                        ),
                      );
                    context.read<ClassWorkBloc>().add(
                      const ClassWorkFeedbackCleared(),
                    );
                  },
                  builder: (context, state) {
                    if (state.isLoading) {
                      return Center(child: const SchoolPulseLoader());
                    }

                    return Column(
                      children: [
                        _buildBehaviourSummary(context, state, isDark),
                        Expanded(
                          child: state.behaviourRecords.isEmpty
                              ? Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(
                                      AppSpacing.x3l,
                                    ),
                                    child: Text(
                                      'No behaviour or achievement records for '
                                      'your class yet.',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyMedium.copyWith(
                                        color: isDark
                                            ? AppColors.textSecondaryDark
                                            : AppColors.textSecondaryLight,
                                      ),
                                    ),
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  itemCount: state.behaviourRecords.length,
                                  separatorBuilder: (context, index) =>
                                      const SizedBox(height: AppSpacing.m),
                                  itemBuilder: (context, index) =>
                                      _buildLogItem(
                                        context,
                                        state,
                                        state.behaviourRecords[index],
                                        isDark,
                                      ),
                                ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: PulseButton(
                            label: 'Log New Incident',
                            icon: Icons.add_moderator,
                            onPressed: state.students.isEmpty
                                ? null
                                : () => _showRecordSheet(context, state),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildBehaviourSummary(
    BuildContext context,
    ClassWorkState state,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            '${state.positiveCount}',
            'Positive',
            AppColors.successGreen,
            isDark,
          ),
          _buildSummaryItem(
            '${state.concernCount}',
            'Concerns',
            AppColors.danger(context),
            isDark,
          ),
          // Open follow-ups replace the invented "Class Grade": it is a real
          // number the teacher can act on, rather than a letter nothing
          // computes.
          _buildSummaryItem(
            '${state.openFollowUps}',
            'Follow-ups',
            AppColors.royalBlue,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    String value,
    String label,
    Color color,
    bool isDark,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ],
    );
  }

  Widget _buildLogItem(
    BuildContext context,
    ClassWorkState state,
    ClassBehaviourRecord record,
    bool isDark,
  ) {
    final category = state.categoryFor(record.categoryCode);
    final isPositive = category?.isPositive ?? false;
    final color = isPositive ? AppColors.successGreen : AppColors.errorRed;

    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.l),
      onTap: record.isOpenFollowUp
          ? () => _closeFollowUp(context, record)
          : null,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.s),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive ? Icons.add_circle : Icons.remove_circle,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.m),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.studentName.isEmpty
                      ? record.studentId
                      : record.studentName,
                  style: AppTypography.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  record.note,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      DateFormat('d MMM yyyy, HH:mm').format(record.recordedAt),
                      style: AppTypography.labelSmall.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                        fontSize: 10,
                      ),
                    ),
                    if (record.isOpenFollowUp) ...[
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        '• Follow-up open',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.royalBlue,
                          fontSize: 10,
                        ),
                      ),
                    ],
                    // An escalated record is the discipline office's; saying
                    // so is clearer than a tap that silently does nothing.
                    if (record.isEscalated) ...[
                      const SizedBox(width: AppSpacing.s),
                      Text(
                        '• With discipline office',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMutedLight,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ],
      ),
    );
  }

  Future<void> _closeFollowUp(
    BuildContext context,
    ClassBehaviourRecord record,
  ) async {
    final bloc = context.read<ClassWorkBloc>();
    final controller = TextEditingController();

    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated(dialogContext),
        title: const Text('Close follow-up'),
        content: TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What was done about this?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              Navigator.of(dialogContext).pop(text);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );

    if (note != null) {
      bloc.add(ClassBehaviourFollowUpClosed(record, note));
    }
  }

  Future<void> _showRecordSheet(
    BuildContext context,
    ClassWorkState state,
  ) async {
    final bloc = context.read<ClassWorkBloc>();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.xl),
        ),
      ),
      builder: (sheetContext) => BlocProvider.value(
        value: bloc,
        child: _RecordSheet(
          students: state.students,
          categories: state.categories,
        ),
      ),
    );
  }
}

class _RecordSheet extends StatefulWidget {
  final List<ClassStudentSummary> students;
  final List<BehaviourCategory> categories;

  const _RecordSheet({required this.students, required this.categories});

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  ClassStudentSummary? _student;
  BehaviourCategory? _category;
  final _noteController = TextEditingController();
  final _recommendationController = TextEditingController();
  bool _followUp = false;

  @override
  void dispose() {
    _noteController.dispose();
    _recommendationController.dispose();
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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Log Behaviour',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            DropdownButtonFormField<ClassStudentSummary>(
              initialValue: _student,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Student'),
              items: [
                for (final student in widget.students)
                  DropdownMenuItem(
                    value: student,
                    child: Text(student.name, overflow: TextOverflow.ellipsis),
                  ),
              ],
              onChanged: (value) => setState(() => _student = value),
            ),
            const SizedBox(height: AppSpacing.m),
            // Categories come from the school's configuration, so a school
            // using its own vocabulary sees its own words here.
            DropdownButtonFormField<BehaviourCategory>(
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                for (final category in widget.categories)
                  DropdownMenuItem(
                    value: category,
                    child: Text(
                      category.label,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (value) => setState(() {
                _category = value;
                _followUp = value?.defaultsToFollowUp ?? false;
              }),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'What happened',
                hintText: 'Describe what you observed',
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            TextField(
              controller: _recommendationController,
              minLines: 1,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Recommendation (optional)',
                // Named a recommendation, not an action: the outcome of a
                // formal case is the discipline office's decision.
                hintText: 'What you suggest happens next',
              ),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              value: _followUp,
              onChanged: (value) => setState(() => _followUp = value),
              title: Text(
                'Needs follow-up',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
            ),
            const SizedBox(height: AppSpacing.m),
            PulseButton(
              label: 'Save Record',
              onPressed: _canSave ? _submit : null,
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  bool get _canSave =>
      _student != null &&
      _category != null &&
      _noteController.text.trim().length >= 5;

  void _submit() {
    final student = _student!;
    final category = _category!;

    context.read<ClassWorkBloc>().add(
      ClassBehaviourRecorded(
        ClassBehaviourRecord(
          id: '',
          // Coordinates are stamped from the verified context by the
          // repository; the form supplies only what the teacher typed.
          schoolId: '',
          classId: student.classId,
          academicYearId: student.academicYearId,
          studentId: student.studentId,
          studentName: student.name,
          categoryCode: category.code,
          note: _noteController.text.trim(),
          recommendation: _recommendationController.text.trim().isEmpty
              ? null
              : _recommendationController.text.trim(),
          followUpRequired: _followUp,
          recordedAt: DateTime.now(),
        ),
      ),
    );
    Navigator.of(context).pop();
  }
}

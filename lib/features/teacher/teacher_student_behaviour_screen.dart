import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_behaviour.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_work/class_work_bloc.dart';

class TeacherStudentBehaviourScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentBehaviourScreen({super.key, required this.studentId});

  @override
  State<TeacherStudentBehaviourScreen> createState() =>
      _TeacherStudentBehaviourScreenState();
}

class _TeacherStudentBehaviourScreenState
    extends State<TeacherStudentBehaviourScreen> {
  BehaviourValence? _filter;

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

    return BlocConsumer<ClassWorkBloc, ClassWorkState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.successMessage != current.successMessage,
      listener: (context, state) {
        final message = state.successMessage ?? state.errorMessage;
        if (message == null) return;
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message)));
      },
      builder: (context, state) {
        final student = state.students
            .where((s) => s.studentId == widget.studentId)
            .firstOrNull;
        final records =
            state.behaviourRecords
                .where((r) => r.studentId == widget.studentId)
                .where(
                  (r) =>
                      _filter == null ||
                      state.categoryFor(r.categoryCode)?.valence == _filter,
                )
                .toList()
              ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary(context),
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Behaviour',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
              ),
            ),
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _buildTabs(isDark),
                    Expanded(
                      child: records.isEmpty
                          ? Center(
                              child: Text(
                                'No behaviour records for this student yet.',
                                style: AppTypography.bodyMedium.copyWith(
                                  color: isDark
                                      ? AppColors.textMutedDark
                                      : AppColors.textMutedLight,
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(AppSpacing.xl),
                              itemCount: records.length,
                              itemBuilder: (context, index) {
                                final record = records[index];
                                final category = state.categoryFor(
                                  record.categoryCode,
                                );
                                return _BehaviourTile(
                                  record: record,
                                  category: category,
                                  isDark: isDark,
                                );
                              },
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: student == null
                              ? null
                              : () => _showRecordSheet(context, student.name),
                          icon: const Icon(Icons.add, color: Colors.white),
                          label: const Text(
                            'Add Record',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.royalBlue,
                            padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.l,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppSpacing.m),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildTabs(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.m),
      ),
      child: Row(
        children: [
          Expanded(
            child: _FilterTab(
              label: 'All',
              isSelected: _filter == null,
              isDark: isDark,
              onTap: () => setState(() => _filter = null),
            ),
          ),
          Expanded(
            child: _FilterTab(
              label: 'Positive',
              isSelected: _filter == BehaviourValence.positive,
              isDark: isDark,
              onTap: () => setState(() => _filter = BehaviourValence.positive),
            ),
          ),
          Expanded(
            child: _FilterTab(
              label: 'Concern',
              isSelected: _filter == BehaviourValence.concern,
              isDark: isDark,
              onTap: () => setState(() => _filter = BehaviourValence.concern),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showRecordSheet(
    BuildContext context,
    String studentName,
  ) async {
    final bloc = context.read<ClassWorkBloc>();
    final state = bloc.state;
    final student = state.students
        .where((s) => s.studentId == widget.studentId)
        .first;

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
        child: _StudentRecordSheet(
          studentId: student.studentId,
          studentName: student.name,
          classId: student.classId,
          academicYearId: student.academicYearId,
          categories: state.categories,
        ),
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _FilterTab({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.s),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary(context) : null,
          borderRadius: BorderRadius.circular(AppSpacing.s),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _BehaviourTile extends StatelessWidget {
  final ClassBehaviourRecord record;
  final BehaviourCategory? category;
  final bool isDark;

  const _BehaviourTile({
    required this.record,
    required this.category,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = category?.valence == BehaviourValence.concern;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.l),
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.l),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isNegative ? AppColors.errorRed : AppColors.successGreen)
                  .withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isNegative
                  ? Icons.warning_amber_rounded
                  : Icons.check_circle_outline,
              color: isNegative ? AppColors.errorRed : AppColors.successGreen,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.l),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.note,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      category?.label ?? record.categoryCode,
                      style: AppTypography.labelSmall.copyWith(
                        color: isNegative
                            ? AppColors.errorRed
                            : AppColors.successGreen,
                      ),
                    ),
                    Text(
                      _formatDate(record.recordedAt),
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textMutedLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
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

class _StudentRecordSheet extends StatefulWidget {
  final String studentId;
  final String studentName;
  final String classId;
  final String academicYearId;
  final List<BehaviourCategory> categories;

  const _StudentRecordSheet({
    required this.studentId,
    required this.studentName,
    required this.classId,
    required this.academicYearId,
    required this.categories,
  });

  @override
  State<_StudentRecordSheet> createState() => _StudentRecordSheetState();
}

class _StudentRecordSheetState extends State<_StudentRecordSheet> {
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
              'Log Behaviour · ${widget.studentName}',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
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
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSave ? _submit : null,
                child: const Text('Save Record'),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  bool get _canSave =>
      _category != null && _noteController.text.trim().length >= 5;

  void _submit() {
    final category = _category!;

    context.read<ClassWorkBloc>().add(
      ClassBehaviourRecorded(
        ClassBehaviourRecord(
          id: '',
          schoolId: '',
          classId: widget.classId,
          academicYearId: widget.academicYearId,
          studentId: widget.studentId,
          studentName: widget.studentName,
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

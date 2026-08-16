import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_enrollment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class EnterMarksScreen extends StatefulWidget {
  const EnterMarksScreen({super.key});

  @override
  State<EnterMarksScreen> createState() => _EnterMarksScreenState();
}

class _EnterMarksScreenState extends State<EnterMarksScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MarksBloc, MarksState>(
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
        final assessment = state.selectedAssessment;
        final component = state.selectedComponent;

        if (assessment == null || component == null) {
          return Scaffold(
            backgroundColor: AppColors.background(context),
            appBar: AppBar(title: const Text('Enter Marks')),
            body: const Center(child: Text('No component selected.')),
          );
        }

        final students = state.students
            .where(
              (s) =>
                  _query.isEmpty ||
                  s.name.toLowerCase().contains(_query.toLowerCase()),
            )
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: AppColors.textPrimary(context),
              ),
              onPressed: () => context.pop(),
            ),
            title: Column(
              children: [
                Text(
                  'Enter Marks',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${assessment.title.isEmpty ? assessment.assessmentTypeName : assessment.title} • ${component.name}',
                  style: TextStyle(
                    color: AppColors.textSecondary(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            centerTitle: true,
          ),
          body: state.isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${state.enteredCount} / ${state.students.length} Entered',
                            style: TextStyle(
                              color: AppColors.textSecondary(context),
                              fontSize: 12,
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: TextField(
                                onChanged: (value) =>
                                    setState(() => _query = value),
                                decoration: InputDecoration(
                                  isDense: true,
                                  hintText: 'Search students...',
                                  hintStyle: TextStyle(
                                    color: AppColors.textMuted(context),
                                    fontSize: 12,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    size: 16,
                                    color: AppColors.textMuted(context),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: students.length,
                        itemBuilder: (context, index) {
                          final student = students[index];
                          final entry = state.entries[student.studentId];
                          return _buildStudentMarkRow(
                            context,
                            index + 1,
                            student,
                            entry,
                            component,
                          );
                        },
                      ),
                    ),
                    _buildBottomActions(context, state),
                  ],
                ),
        );
      },
    );
  }

  Widget _buildStudentMarkRow(
    BuildContext context,
    int rank,
    SubjectStudentSummary student,
    StudentMarkEntry? entry,
    AssessmentComponent component,
  ) {
    final hasScore = entry != null && entry.status == MarkEntryStatus.scored;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(context).withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            rank.toString(),
            style: TextStyle(
              color: AppColors.textSecondary(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.disabled(context),
            backgroundImage: (student.photoUrl?.isNotEmpty ?? false)
                ? NetworkImage(student.photoUrl!)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              student.name,
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontSize: 14,
              ),
            ),
          ),
          GestureDetector(
            onLongPress: () => _showStatusMenu(context, student, component),
            child: Container(
              width: 60,
              height: 36,
              decoration: BoxDecoration(
                color: hasScore
                    ? AppColors.primary(context).withValues(alpha: 0.1)
                    : Colors.transparent,
                border: Border.all(
                  color: hasScore
                      ? AppColors.primary(context)
                      : AppColors.border(context),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: entry != null && entry.status != MarkEntryStatus.scored
                  ? Center(
                      child: Text(
                        _shortLabel(entry.status),
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary(context),
                        ),
                      ),
                    )
                  : TextField(
                      textAlign: TextAlign.center,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      controller: TextEditingController(
                        text: entry?.score?.toStringAsFixed(0) ?? '',
                      )..selection = TextSelection.collapsed(
                          offset: entry?.score?.toStringAsFixed(0).length ?? 0,
                        ),
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (value) {
                        final score = double.tryParse(value);
                        context.read<MarksBloc>().add(
                          MarksEntryChanged(
                            studentId: student.studentId,
                            score: score,
                            status: score == null
                                ? MarkEntryStatus.notEntered
                                : MarkEntryStatus.scored,
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  String _shortLabel(MarkEntryStatus status) => switch (status) {
    MarkEntryStatus.absent => 'ABS',
    MarkEntryStatus.exempted => 'EXM',
    MarkEntryStatus.missing => 'MSG',
    MarkEntryStatus.notAssessed => 'N/A',
    _ => '',
  };

  Future<void> _showStatusMenu(
    BuildContext context,
    SubjectStudentSummary student,
    AssessmentComponent component,
  ) async {
    final bloc = context.read<MarksBloc>();
    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final status in MarkEntryStatus.values.where(
              (s) => s != MarkEntryStatus.notEntered,
            ))
              ListTile(
                title: Text(status.label),
                onTap: () {
                  bloc.add(
                    MarksEntryChanged(
                      studentId: student.studentId,
                      status: status,
                    ),
                  );
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, MarksState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: state.isSaving
                  ? null
                  : () => context.read<MarksBloc>().add(const MarksDraftSaved()),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: AppColors.border(context)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Save Draft',
                style: TextStyle(color: AppColors.textPrimary(context)),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: state.isSaving
                  ? null
                  : () {
                      context.read<MarksBloc>().add(
                        const MarksReviewRequested(),
                      );
                      context.push('/staff/marks/review');
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary(context),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Review & Submit',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

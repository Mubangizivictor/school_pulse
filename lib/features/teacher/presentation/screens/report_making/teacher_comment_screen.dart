import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/report_comment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';

class TeacherCommentScreen extends StatefulWidget {
  final String? studentId;
  final String className;
  final String term;
  final String year;

  const TeacherCommentScreen({
    super.key,
    this.studentId,
    this.className = 'P.1 North',
    this.term = 'Term 1',
    this.year = '2024',
  });

  @override
  State<TeacherCommentScreen> createState() => _TeacherCommentScreenState();
}

class _TeacherCommentScreenState extends State<TeacherCommentScreen> {
  final TextEditingController _commentController = TextEditingController();
  List<String> _recommendations = [
    'Read more storybooks to improve comprehension.',
    'Practice Mathematics problems regularly.',
    'Maintain good attendance and punctuality.',
  ];

  @override
  void initState() {
    super.initState();
    final wizardState = context.read<ReportWizardBloc>().state;
    context.read<TeacherBloc>().add(
      TeacherReportCommentsRequested(
        className: wizardState.selectedClassName ?? widget.className,
        term: wizardState.selectedTerm ?? widget.term,
        year: wizardState.selectedYear ?? widget.year,
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _onSave() {
    final authState = context.read<AuthBloc>().state;
    final wizardState = context.read<ReportWizardBloc>().state;

    if (authState is AuthAuthenticated) {
      context.read<TeacherBloc>().add(
        TeacherReportCommentSaved(
          ReportComment(
            id: '',
            studentId:
                widget.studentId ??
                (wizardState.selectedStudentIds.isNotEmpty
                    ? wizardState.selectedStudentIds.first
                    : 'mock_student_id'),
            className: wizardState.selectedClassName ?? widget.className,
            term: wizardState.selectedTerm ?? widget.term,
            year: wizardState.selectedYear ?? widget.year,
            comment: _commentController.text,
            recommendations: _recommendations,
            teacherId: authState.user.id,
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }
  }

  void _showAddRecommendationDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated(context),
        title: Text(
          'Add Recommendation',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: AppColors.textPrimary(context)),
          decoration: InputDecoration(
            hintText: 'Enter recommendation...',
            hintStyle: TextStyle(color: AppColors.textMuted(context)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.border(context)),
            ),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary(context)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(context),
              foregroundColor: AppColors.white,
            ),
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _recommendations.add(controller.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherBloc, TeacherState>(
      listener: (context, state) {
        if (state is TeacherOperationSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          context.push('/staff/reports/preview');
        } else if (state is TeacherReportCommentsLoaded) {
          if (widget.studentId != null) {
            final comment = state.comments
                .where((c) => c.studentId == widget.studentId)
                .firstOrNull;
            if (comment != null && _commentController.text.isEmpty) {
              _commentController.text = comment.comment;
              if (comment.recommendations.isNotEmpty) {
                _recommendations = List.from(comment.recommendations);
              }
            }
          }
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text('Teacher\'s Comment')),
          body: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(title: 'Comment for Student (General)'),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextFormField(
                            controller: _commentController,
                            maxLines: 6,
                            onChanged: (val) => setState(() {}),
                            style: TextStyle(
                              color: AppColors.textPrimary(context),
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter student comment...',
                              hintStyle: TextStyle(
                                color: AppColors.textMuted(context),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_commentController.text.length}/500',
                            style: TextStyle(
                              color: AppColors.textMuted(context),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Next Steps / Recommendations'),
                    const SizedBox(height: 12),
                    AppCard(
                      child: Column(
                        children: [
                          ..._recommendations.map(
                            (rec) => Column(
                              children: [
                                _RecommendationItem(
                                  text: rec,
                                  onDelete: () => setState(
                                    () => _recommendations.remove(rec),
                                  ),
                                ),
                                if (rec != _recommendations.last)
                                  Divider(color: AppColors.border(context)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          SecondaryButton(
                            label: 'Add Recommendation',
                            icon: Icons.add,
                            onPressed: _showAddRecommendationDialog,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  label: 'Save & Next',
                  onPressed: state is TeacherLoading ? null : _onSave,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecommendationItem extends StatelessWidget {
  final String text;
  final VoidCallback onDelete;

  const _RecommendationItem({required this.text, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: AppColors.success(context),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(color: AppColors.textPrimary(context)),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.close,
              size: 18,
              color: AppColors.textMuted(context),
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

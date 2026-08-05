import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/report_comment.dart';

class ReportCommentsScreen extends StatefulWidget {
  const ReportCommentsScreen({super.key});

  @override
  State<ReportCommentsScreen> createState() => _ReportCommentsScreenState();
}

class _ReportCommentsScreenState extends State<ReportCommentsScreen> {
  String? _selectedClass;
  final String _currentTerm = 'Term 1'; // Mock data
  final String _currentYear = '2024'; // Mock data

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _selectedClass = authState.user.assignedClass;
      if (_selectedClass != null) {
        _fetchComments();
      }
    }
  }

  void _fetchComments() {
    if (_selectedClass != null) {
      context.read<TeacherBloc>().add(
        TeacherReportCommentsRequested(
          className: _selectedClass!,
          term: _currentTerm,
          year: _currentYear,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        title: Text(
          'Report Comments',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary(context)),
      ),
      body: Column(
        children: [
          _buildClassSelector(),
          Expanded(
            child: BlocConsumer<TeacherBloc, TeacherState>(
              listener: (context, state) {
                if (state is TeacherOperationSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.success(context),
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is TeacherLoading) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary(context),
                    ),
                  );
                }

                if (state is TeacherReportCommentsLoaded) {
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.students.length,
                    separatorBuilder: (context, index) => Divider(
                      color: AppColors.border(context).withValues(alpha: 0.5),
                    ),
                    itemBuilder: (context, index) {
                      final student = state.students[index];
                      final comment = state.comments.firstWhere(
                        (c) => c.studentId == student.id,
                        orElse: () => ReportComment(
                          id: '',
                          studentId: student.id,
                          className: _selectedClass ?? '',
                          term: _currentTerm,
                          year: _currentYear,
                          comment: '',
                          teacherId: '',
                          updatedAt: DateTime.now(),
                        ),
                      );
                      return _StudentCommentTile(
                        student: student,
                        initialComment: comment.comment,
                        onSave: (text) => _saveComment(student.id, text),
                      );
                    },
                  );
                }

                return EmptyState(
                  icon: Icons.comment_bank_outlined,
                  title: 'No reports to comment on',
                  message:
                      'Select a class to manage report comments for your students.',
                  ctaLabel: 'Select Class',
                  onCtaPressed: () => {}, // Handled by class selector
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelector() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AppCard(
        child: ListTile(
          title: Text(
            'Selected Class',
            style: TextStyle(
              color: AppColors.textPrimary(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            _selectedClass ?? 'None',
            style: TextStyle(color: AppColors.textSecondary(context)),
          ),
          trailing: Icon(
            Icons.arrow_drop_down,
            color: AppColors.textPrimary(context),
          ),
          onTap: () {
            // Logic to select class if teacher has multiple
          },
        ),
      ),
    );
  }

  void _saveComment(String studentId, String text) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<TeacherBloc>().add(
        TeacherReportCommentSaved(
          ReportComment(
            id: '', // Backend handles ID
            studentId: studentId,
            className: _selectedClass ?? '',
            term: _currentTerm,
            year: _currentYear,
            comment: text,
            teacherId: authState.user.id,
            updatedAt: DateTime.now(),
          ),
        ),
      );
    }
  }
}

class _StudentCommentTile extends StatefulWidget {
  final TeacherStudent student;
  final String initialComment;
  final Function(String) onSave;

  const _StudentCommentTile({
    required this.student,
    required this.initialComment,
    required this.onSave,
  });

  @override
  State<_StudentCommentTile> createState() => _StudentCommentTileState();
}

class _StudentCommentTileState extends State<_StudentCommentTile> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialComment);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.student.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary(context),
              ),
            ),
            IconButton(
              icon: Icon(
                _isEditing ? Icons.check : Icons.edit,
                size: 20,
                color: _isEditing
                    ? AppColors.success(context)
                    : AppColors.primary(context),
              ),
              onPressed: () {
                if (_isEditing) {
                  widget.onSave(_controller.text);
                }
                setState(() => _isEditing = !_isEditing);
              },
            ),
          ],
        ),
        if (_isEditing)
          TextField(
            controller: _controller,
            maxLines: 3,
            style: TextStyle(color: AppColors.textPrimary(context)),
            decoration: InputDecoration(
              hintText: 'Enter report comment...',
              hintStyle: TextStyle(color: AppColors.textMuted(context)),
              filled: true,
              fillColor: AppColors.surfaceElevated(context),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppColors.border(context)),
              ),
            ),
          )
        else
          Text(
            _controller.text.isEmpty ? 'No comment added' : _controller.text,
            style: TextStyle(
              color: _controller.text.isEmpty
                  ? AppColors.textMuted(context)
                  : AppColors.textSecondary(context),
              fontStyle: _controller.text.isEmpty
                  ? FontStyle.italic
                  : FontStyle.normal,
            ),
          ),
      ],
    );
  }
}

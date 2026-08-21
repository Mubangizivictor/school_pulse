import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/teacher/domain/entities/class_announcement.dart';
import 'package:school_pulse/features/teacher/domain/repositories/class_communication_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/teacher/presentation/bloc/class_announcements/class_announcements_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_students/class_students_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/tab_button.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_student_detail_ui.dart';

/// Per-student contact permission check plus the class announcements this
/// student has received. There is no per-student conversation API yet - a
/// chat thread here is keyed by conversation id, not by student - so "New
/// Message" checks the teacher may contact this parent and hands off to the
/// real Messages feature rather than faking a thread.
class TeacherStudentCommunicationsScreen extends StatefulWidget {
  final String studentId;
  const TeacherStudentCommunicationsScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<TeacherStudentCommunicationsScreen> createState() =>
      _TeacherStudentCommunicationsScreenState();
}

class _TeacherStudentCommunicationsScreenState
    extends State<TeacherStudentCommunicationsScreen> {
  bool _showingAnnouncements = false;

  @override
  void initState() {
    super.initState();
    final active = context.read<ClassTeacherContextBloc>().state.active;
    if (active != null) {
      context.read<ClassAnnouncementsBloc>().add(
        ClassAnnouncementsRequested(active),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const TeacherStudentDetailAppBar(title: 'Communications'),
      body: Column(
        children: [
          _buildTabs(isDark),
          Expanded(
            child: _showingAnnouncements
                ? _buildAnnouncements(isDark)
                : _buildMessagesTab(isDark),
          ),
          if (!_showingAnnouncements)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _startConversation(context),
                  icon: const Icon(Icons.send, color: Colors.white),
                  label: const Text(
                    'New Message',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.royalBlue,
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
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
  }

  Widget _buildMessagesTab(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Text(
          'Conversations with this student\'s parent live in Messages. '
          'Tap New Message to find them there.',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          ),
        ),
      ),
    );
  }

  Widget _buildAnnouncements(bool isDark) {
    return BlocBuilder<ClassAnnouncementsBloc, ClassAnnouncementsState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        final announcements = state.announcements
            .where((a) => a.status == ClassAnnouncementStatus.published)
            .toList();
        if (announcements.isEmpty) {
          return Center(
            child: Text(
              'No announcements sent to this class yet.',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.textMutedDark
                    : AppColors.textMutedLight,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.xl),
          itemCount: announcements.length,
          itemBuilder: (context, index) {
            final announcement = announcements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.l),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    announcement.title,
                    style: AppTypography.titleSmall.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    announcement.body,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textMutedLight,
                    ),
                  ),
                ],
              ),
            );
          },
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
            child: InkWell(
              onTap: () => setState(() => _showingAnnouncements = false),
              child: TabButton(
                label: 'Messages',
                isSelected: !_showingAnnouncements,
                isDark: isDark,
              ),
            ),
          ),
          Expanded(
            child: InkWell(
              onTap: () => setState(() => _showingAnnouncements = true),
              child: TabButton(
                label: 'Announcements',
                isSelected: _showingAnnouncements,
                isDark: isDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _startConversation(BuildContext context) async {
    final active = context.read<ClassTeacherContextBloc>().state.active;
    final student = context
        .read<ClassStudentsBloc>()
        .state
        .students
        .where((s) => s.studentId == widget.studentId)
        .firstOrNull;

    if (active == null || student == null) return;

    final repository = di.sl<ClassCommunicationRepository>();
    final allowed = await repository.assertCanMessageAbout(
      context: active,
      studentId: widget.studentId,
    );

    if (!context.mounted) return;

    allowed.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) {
        context.push('/staff/messages');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Find ${student.name}\'s parent in Messages to continue.',
            ),
          ),
        );
      },
    );
  }
}

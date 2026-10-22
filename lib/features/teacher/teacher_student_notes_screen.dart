import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_student_detail_ui.dart';

/// Private student notes have no backing entity, repository, or storage
/// location yet. This is an honest "not yet available" state, not
/// fabricated note data.
class TeacherStudentNotesScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentNotesScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const TeacherStudentDetailAppBar(title: 'Notes'),
      body: const TeacherStudentDetailEmptyState(
        icon: Icons.note_alt_outlined,
        title: 'Private notes are not available yet',
        message:
            'This feature is coming soon. You will be able to jot down '
            'private observations about this student here.',
      ),
    );
  }
}

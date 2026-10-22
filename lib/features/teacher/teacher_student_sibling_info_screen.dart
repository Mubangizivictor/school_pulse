import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_student_detail_ui.dart';

/// Sibling links have no backing field on the Student entity yet - there is
/// no way to associate one student with another as a sibling. This is an
/// honest "not yet available" state, not fabricated relationship data.
class TeacherStudentSiblingInfoScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentSiblingInfoScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const TeacherStudentDetailAppBar(title: 'Sibling Information'),
      body: const TeacherStudentDetailEmptyState(
        icon: Icons.people_outline,
        title: 'Sibling information is not available yet',
        message:
            'This feature is coming soon. For now, sibling relationships '
            'are recorded with the Admissions office directly.',
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/teacher/presentation/widgets/teacher_student_detail_ui.dart';

class TeacherStudentMoreOptionsScreen extends StatelessWidget {
  final String studentId;
  const TeacherStudentMoreOptionsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: const TeacherStudentDetailAppBar(title: 'More Options'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: [
          TeacherStudentDetailTile(
            icon: Icons.health_and_safety_outlined,
            label: 'Health Information',
            onTap: () => context.push('/staff/students/$studentId/health'),
          ),
          TeacherStudentDetailTile(
            icon: Icons.contact_phone_outlined,
            label: 'Contact Information',
            // The Personal Information section on the profile already shows
            // what a Class Teacher is entitled to see - full guardian contact
            // records live in the Admissions office record.
            onTap: () => context.pop(),
          ),
          TeacherStudentDetailTile(
            icon: Icons.description_outlined,
            label: 'Documents',
            onTap: () => context.push('/staff/students/$studentId/documents'),
          ),
          TeacherStudentDetailTile(
            icon: Icons.people_outline,
            label: 'Sibling Information',
            onTap: () => context.push('/staff/students/$studentId/siblings'),
          ),
          TeacherStudentDetailTile(
            icon: Icons.exit_to_app_outlined,
            label: 'Leave Applications',
            onTap: () =>
                context.push('/staff/students/$studentId/leave-applications'),
          ),
          TeacherStudentDetailTile(
            icon: Icons.note_alt_outlined,
            label: 'Notes',
            onTap: () => context.push('/staff/students/$studentId/notes'),
          ),
          TeacherStudentDetailTile(
            icon: Icons.chat_bubble_outline,
            label: 'Communications',
            onTap: () =>
                context.push('/staff/students/$studentId/communications'),
          ),
          TeacherStudentDetailTile(
            icon: Icons.history_outlined,
            label: 'Timeline',
            onTap: () => context.push('/staff/students/$studentId/behaviour'),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/design_system/components/pulse_card.dart';
import 'package:school_pulse/design_system/components/pulse_text_field.dart';
import 'package:school_pulse/features/teacher/domain/entities/staff_role_assignment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/class_teacher_context/class_teacher_context_state.dart';

class TeacherClassesListScreen extends StatefulWidget {
  const TeacherClassesListScreen({super.key});

  @override
  State<TeacherClassesListScreen> createState() =>
      _TeacherClassesListScreenState();
}

class _TeacherClassesListScreenState extends State<TeacherClassesListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClassTeacherContextBloc, ClassTeacherContextState>(
      builder: (context, state) {
        final classes = state.classAssignments
            .where(
              (a) =>
                  _query.isEmpty ||
                  (a.className ?? '').toLowerCase().contains(
                    _query.toLowerCase(),
                  ),
            )
            .toList();

        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text(
              'Classes',
              style: AppTypography.headlineSmall.copyWith(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              _buildMyClassesHeader(context, state.classAssignments.length),
              const SizedBox(height: AppSpacing.xl),
              PulseTextField(
                hint: 'Search classes...',
                prefixIcon: Icons.search,
                onChanged: (value) => setState(() => _query = value),
              ),
              const SizedBox(height: AppSpacing.xl),
              if (classes.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                  child: Text(
                    state.classAssignments.isEmpty
                        ? 'You are not currently the Class Teacher for any '
                              'class.'
                        : 'No class matches your search.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textMuted(context),
                    ),
                  ),
                )
              else
                for (final assignment in classes)
                  _buildClassCard(
                    context,
                    assignment: assignment,
                    isActive: state.active?.roleAssignmentId == assignment.id,
                  ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMyClassesHeader(BuildContext context, int count) {
    return PulseCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      backgroundColor: AppColors.surfaceElevated(context),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Classes',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: AppTypography.headlineMedium.copyWith(
                    color: AppColors.primary(context),
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  count == 1 ? 'Class Assigned' : 'Classes Assigned',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textMuted(context),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.l),
            decoration: BoxDecoration(
              color: AppColors.primary(context).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.school,
              color: AppColors.primary(context),
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required StaffRoleAssignment assignment,
    required bool isActive,
  }) {
    final label = [
      assignment.className,
      assignment.streamName,
    ].where((e) => e != null && e.isNotEmpty).join(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: PulseCard(
        onTap: () => context.push('/staff/classes/${assignment.classId}'),
        padding: const EdgeInsets.all(AppSpacing.l),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                color: AppColors.primary(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.m),
              ),
              child: Icon(
                Icons.groups,
                color: AppColors.primary(context),
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.l),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.isEmpty ? 'Class' : label,
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success(context).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Active',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.success(context),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.s),
            Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
          ],
        ),
      ),
    );
  }
}

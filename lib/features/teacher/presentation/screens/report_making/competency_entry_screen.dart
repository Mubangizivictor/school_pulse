import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/competency_rating.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/report_wizard/report_wizard_state.dart';

class CompetencyEntryScreen extends StatefulWidget {
  final String className;
  final String term;
  final String year;

  const CompetencyEntryScreen({
    super.key,
    this.className = 'P.1 North',
    this.term = 'Term 1',
    this.year = '2024',
  });

  @override
  State<CompetencyEntryScreen> createState() => _CompetencyEntryScreenState();
}

class _CompetencyEntryScreenState extends State<CompetencyEntryScreen> {
  final String competency = 'Communication Skills';

  @override
  void initState() {
    super.initState();
    final wizardState = context.read<ReportWizardBloc>().state;
    context.read<TeacherBloc>().add(
      TeacherCompetencyRatingsRequested(
        className: wizardState.selectedClassName ?? widget.className,
        term: wizardState.selectedTerm ?? widget.term,
        year: wizardState.selectedYear ?? widget.year,
        competency: competency,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Competency Development')),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
          if (state is TeacherOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is TeacherLoading) {
            return const Center(child: SchoolPulseLoader());
          }

          if (state is TeacherCompetencyRatingsLoaded) {
            return _buildContent(state.students, state.ratings);
          }

          return const Center(child: Text('No data found'));
        },
      ),
    );
  }

  Widget _buildContent(
    List<TeacherStudent> students,
    List<CompetencyRating> ratings,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.primary(context).withValues(alpha: 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                competency,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Level Key:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const _LevelBadge(level: 4, label: 'Exceeding'),
                  const SizedBox(width: 4),
                  const _LevelBadge(level: 3, label: 'Achieved'),
                  const SizedBox(width: 4),
                  const _LevelBadge(level: 2, label: 'Developing'),
                  const SizedBox(width: 4),
                  const _LevelBadge(level: 1, label: 'Emerging'),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: students.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final student = students[index];
              final rating = ratings
                  .where((r) => r.studentId == student.id)
                  .firstOrNull;
              final currentLevel = rating?.level ?? 0;

              return AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        student.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary(context),
                        ),
                      ),
                    ),
                    Row(
                      children: List.generate(4, (i) {
                        final level = i + 1;
                        final isSelected = currentLevel == level;
                        final levelColor = _getLevelColor(context, level);
                        return GestureDetector(
                          onTap: () => _saveRating(student, level, rating),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? levelColor
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: levelColor),
                            ),
                            child: Center(
                              child: Text(
                                '$level',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.white
                                      : levelColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: PrimaryButton(
            label: 'Save & Next',
            onPressed: () => context.push('/staff/reports/attendance-summary'),
          ),
        ),
      ],
    );
  }

  void _saveRating(
    TeacherStudent student,
    int level,
    CompetencyRating? existingRating,
  ) {
    final authState = context.read<AuthBloc>().state;
    final wizardState = context.read<ReportWizardBloc>().state;
    final teacherId = authState is AuthAuthenticated
        ? authState.user.id
        : 'teacher_1';

    final rating =
        (existingRating ??
                CompetencyRating(
                  id: '',
                  studentId: student.id,
                  className: wizardState.selectedClassName ?? widget.className,
                  term: wizardState.selectedTerm ?? widget.term,
                  year: wizardState.selectedYear ?? widget.year,
                  competency: competency,
                  level: level,
                  teacherId: teacherId,
                  updatedAt: DateTime.now(),
                ))
            .copyWith(level: level, updatedAt: DateTime.now());

    context.read<TeacherBloc>().add(TeacherCompetencyRatingSaved(rating));

    // Optimistically update the UI by re-requesting the data
    context.read<TeacherBloc>().add(
      TeacherCompetencyRatingsRequested(
        className: wizardState.selectedClassName ?? widget.className,
        term: wizardState.selectedTerm ?? widget.term,
        year: wizardState.selectedYear ?? widget.year,
        competency: competency,
      ),
    );
  }

  Color _getLevelColor(BuildContext context, int level) {
    switch (level) {
      case 4:
        return AppColors.information(context);
      case 3:
        return AppColors.success(context);
      case 2:
        return AppColors.warning(context);
      case 1:
        return AppColors.error;
      default:
        return AppColors.disabled(context);
    }
  }
}

class _LevelBadge extends StatelessWidget {
  final int level;
  final String label;

  const _LevelBadge({required this.level, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (level) {
      case 4:
        color = AppColors.information(context);
        break;
      case 3:
        color = AppColors.success(context);
        break;
      case 2:
        color = AppColors.warning(context);
        break;
      case 1:
        color = AppColors.error;
        break;
      default:
        color = AppColors.disabled(context);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

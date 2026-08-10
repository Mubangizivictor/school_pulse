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

class BehaviourConductScreen extends StatefulWidget {
  final String className;
  final String studentId;
  final String term;
  final String year;

  const BehaviourConductScreen({
    super.key,
    this.className = 'P.1 North',
    this.studentId =
        'student_1', // In a real app, passed from the student selection
    this.term = 'Term 1',
    this.year = '2024',
  });

  @override
  State<BehaviourConductScreen> createState() => _BehaviourConductScreenState();
}

class _BehaviourConductScreenState extends State<BehaviourConductScreen> {
  final List<String> behaviours = [
    'Respect for Others',
    'Responsibility',
    'Self-Discipline',
    'Cooperation',
    'Honesty & Integrity',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch ratings for the first behaviour to initialize the view
    // In a production app, we might fetch all behavioural ratings at once
    _fetchRatings();
  }

  void _fetchRatings() {
    context.read<TeacherBloc>().add(
      TeacherCompetencyRatingsRequested(
        className: widget.className,
        term: widget.term,
        year: widget.year,
        competency: 'Behaviour', // Using a generic tag for behavioural ratings
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Behaviour & Conduct')),
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

          List<CompetencyRating> currentRatings = [];
          if (state is TeacherCompetencyRatingsLoaded) {
            currentRatings = state.ratings
                .where((r) => r.studentId == widget.studentId)
                .toList();
          }

          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const SectionHeader(title: 'Rate each area (1 - 5 Stars)'),
                    const SizedBox(height: 12),
                    ...behaviours.map((label) {
                      final rating =
                          currentRatings
                              .where((r) => r.competency == label)
                              .firstOrNull
                              ?.level ??
                          0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textPrimary(context),
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                final starLevel = index + 1;
                                return GestureDetector(
                                  onTap: () => _saveBehaviourRating(
                                    label,
                                    starLevel,
                                    currentRatings
                                        .where((r) => r.competency == label)
                                        .firstOrNull,
                                  ),
                                  child: Icon(
                                    starLevel <= rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: AppColors.warning(context),
                                    size: 28,
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                    const SectionHeader(title: 'Overall Conduct'),
                    const SizedBox(height: 12),
                    AppCard(
                      color: AppColors.success(context).withValues(alpha: 0.1),
                      borderColor: AppColors.success(
                        context,
                      ).withValues(alpha: 0.3),
                      child: Center(
                        child: Text(
                          'Based on star ratings above',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.success(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: PrimaryButton(
                  label: 'Save & Next',
                  onPressed: () =>
                      context.push('/staff/reports/teacher-comment'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _saveBehaviourRating(
    String label,
    int level,
    CompetencyRating? existingRating,
  ) {
    final rating =
        (existingRating ??
                CompetencyRating(
                  id: '',
                  studentId: widget.studentId,
                  className: widget.className,
                  term: widget.term,
                  year: widget.year,
                  competency: label,
                  level: level,
                  teacherId: 'teacher_1',
                  updatedAt: DateTime.now(),
                ))
            .copyWith(level: level, updatedAt: DateTime.now());

    context.read<TeacherBloc>().add(TeacherCompetencyRatingSaved(rating));

    // For simplicity, we trigger a refresh.
    // In a real app, the BLoC state would be updated more gracefully.
    _fetchRatings();
  }
}

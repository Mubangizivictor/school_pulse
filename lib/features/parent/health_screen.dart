import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_bloc.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_event.dart';
import 'package:school_pulse/features/health/presentation/bloc/health_state.dart';
import 'package:school_pulse/features/health/domain/entities/health_visit.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/parent/widgets/student_app_bar.dart';

class HealthScreen extends StatefulWidget {
  const HealthScreen({super.key});

  @override
  State<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends State<HealthScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    if (studentState is SelectedStudentLoaded) {
      context.read<HealthBloc>().add(FetchHealthVisits(studentState.student.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: const StudentAppBar(title: 'Health & Wellness'),
      body: BlocListener<SelectedStudentBloc, SelectedStudentState>(
        listener: (context, state) {
          if (state is SelectedStudentLoaded) {
            context.read<HealthBloc>().add(FetchHealthVisits(state.student.id));
          }
        },
        child: BlocBuilder<HealthBloc, HealthState>(
          builder: (context, state) {
            if (state is HealthLoading) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Skeleton(height: 80),
                  const SizedBox(height: 24),
                  const Skeleton(height: 24, width: 150),
                  const SizedBox(height: 12),
                  ...List.generate(2, (index) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: Skeleton(height: 150),
                  )),
                ],
              );
            } else if (state is HealthError) {
              return Center(child: Text(state.message));
            } else if (state is HealthLoaded) {
              final visits = state.visits;
              final studentState = context.read<SelectedStudentBloc>().state;
              final bool hasAllergies = studentState is SelectedStudentLoaded && studentState.student.id == 's1';

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (hasAllergies)
                    FadeInSlide(
                      child: AppCard(
                        child: Row(
                          children: [
                            Icon(Icons.warning_amber_rounded, color: semanticColors.warning, size: 32),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Allergies & Conditions',
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                                  Text('Peanuts, Penicillin',
                                      style: TextStyle(color: semanticColors.error, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 100),
                    child: SectionHeader(title: 'Nurse Visits'),
                  ),
                  if (visits.isEmpty)
                    const FadeInSlide(
                      delay: Duration(milliseconds: 200),
                      child: EmptyState(
                        icon: Icons.health_and_safety_outlined,
                        title: 'No Health Visits',
                        message: 'No medical visits have been recorded for this student.',
                      ),
                    )
                  else
                    ...visits.asMap().entries.map((entry) {
                      final index = entry.key;
                      final visit = entry.value;
                      return FadeInSlide(
                        delay: Duration(milliseconds: 200 + (index * 100)),
                        child: _buildVisitCard(context, visit),
                      );
                    }),
                  const SizedBox(height: 16),
                  FadeInSlide(
                    delay: const Duration(milliseconds: 500),
                    child: SecondaryButton(
                      label: 'Contact School Nurse',
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => context.push('/parent/messages'),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildVisitCard(BuildContext context, HealthVisit visit) {
    return AppCard(
      onTap: () {}, // For scale animation
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.format(visit.date),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              StatusBadge(label: 'Completed', color: Theme.of(context).extension<SemanticColors>()!.success),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(context, 'Reason', visit.reason, Icons.info_outline),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Treatment', visit.treatment, Icons.healing_outlined),
          const SizedBox(height: 8),
          _buildInfoRow(context, 'Medication', visit.medication, Icons.medication_outlined),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ],
    );
  }
}

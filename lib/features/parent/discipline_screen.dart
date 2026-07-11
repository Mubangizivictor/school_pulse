import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/utils.dart';
import '../../design_system/app_components.dart';
import '../../design_system/app_theme.dart';
import '../student/presentation/bloc/selected_student_bloc.dart';
import '../student/presentation/bloc/selected_student_state.dart';
import '../discipline/presentation/bloc/discipline_bloc.dart';
import '../discipline/presentation/bloc/discipline_event.dart';
import '../discipline/presentation/bloc/discipline_state.dart';
import '../discipline/domain/entities/discipline_incident.dart';
import 'widgets/student_app_bar.dart';

class DisciplineScreen extends StatelessWidget {
  const DisciplineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: const StudentAppBar(title: 'Discipline & Guidance'),
      body: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
        builder: (context, studentState) {
          if (studentState is SelectedStudentLoaded) {
            context.read<DisciplineBloc>().add(LoadDisciplineIncidents(studentState.student.id));
            final firstName = studentState.student.name.split(' ').first;

            return BlocBuilder<DisciplineBloc, DisciplineState>(
              builder: (context, state) {
                if (state is DisciplineLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is DisciplineLoaded) {
                  final incidents = state.incidents;
                  if (incidents.isEmpty) {
                    return FadeInSlide(
                      child: EmptyState(
                        icon: Icons.sentiment_satisfied_alt_outlined,
                        title: 'No incidents recorded',
                        message: '$firstName has a clean record. Keep up the good behavior!',
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: incidents.length,
                    itemBuilder: (context, index) {
                      final incident = incidents[index];
                      return FadeInSlide(
                        delay: Duration(milliseconds: index * 100),
                        child: AppCard(
                          onTap: () {}, // For scale animation
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormatter.format(incident.date),
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  StatusBadge(
                                    label: incident.severity.name.toUpperCase(),
                                    color: _getSeverityColor(incident.severity, semanticColors),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _buildIncidentRow(context, 'Incident', incident.description, Icons.report_problem_outlined),
                              const SizedBox(height: 8),
                              _buildIncidentRow(context, 'Resolution', incident.resolution, Icons.check_circle_outline),
                              if (incident.counselingNotes.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                _buildIncidentRow(context, 'Counseling', incident.counselingNotes, Icons.psychology_outlined),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is DisciplineError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox.shrink();
              },
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildIncidentRow(BuildContext context, String label, String value, IconData icon) {
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

  Color _getSeverityColor(Severity severity, SemanticColors colors) {
    switch (severity) {
      case Severity.info: return colors.info;
      case Severity.success: return colors.success;
      case Severity.warning: return colors.warning;
      case Severity.error: return colors.error;
    }
  }
}

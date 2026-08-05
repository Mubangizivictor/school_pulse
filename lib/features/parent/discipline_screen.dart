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
import '../matron/domain/entities/boarding_entities.dart';
import 'widgets/student_app_bar.dart';

class DisciplineScreen extends StatefulWidget {
  const DisciplineScreen({super.key});

  @override
  State<DisciplineScreen> createState() => _DisciplineScreenState();
}

class _DisciplineScreenState extends State<DisciplineScreen> {
  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    final studentState = context.read<SelectedStudentBloc>().state;
    if (studentState is SelectedStudentLoaded) {
      context.read<DisciplineBloc>().add(
        LoadDisciplineIncidents(studentState.student.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: const StudentAppBar(title: 'Discipline & Guidance'),
      body: BlocListener<SelectedStudentBloc, SelectedStudentState>(
        listener: (context, state) {
          if (state is SelectedStudentLoaded) {
            context.read<DisciplineBloc>().add(
              LoadDisciplineIncidents(state.student.id),
            );
          }
        },
        child: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
          builder: (context, studentState) {
            if (studentState is SelectedStudentLoaded) {
              final firstName = studentState.student.name.split(' ').first;

              return BlocBuilder<DisciplineBloc, DisciplineState>(
                builder: (context, state) {
                  if (state is DisciplineLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is DisciplineLoaded) {
                    final incidents = state.incidents;
                    final boardingCases = state.boardingCases;

                    if (incidents.isEmpty && boardingCases.isEmpty) {
                      return FadeInSlide(
                        child: EmptyState(
                          icon: Icons.sentiment_satisfied_alt_outlined,
                          title: 'No incidents recorded',
                          message:
                              '$firstName has a clean record. Keep up the good behavior!',
                        ),
                      );
                    }
                    return ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        if (incidents.isNotEmpty) ...[
                          const SectionHeader(title: 'Academic & General'),
                          const SizedBox(height: 12),
                          ...incidents.asMap().entries.map((entry) {
                            final index = entry.key;
                            final incident = entry.value;
                            return FadeInSlide(
                              delay: Duration(milliseconds: index * 100),
                              child: _buildAcademicIncidentCard(
                                context,
                                incident,
                                semanticColors,
                              ),
                            );
                          }),
                          const SizedBox(height: 24),
                        ],
                        if (boardingCases.isNotEmpty) ...[
                          const SectionHeader(title: 'Boarding & Dormitory'),
                          const SizedBox(height: 12),
                          ...boardingCases.asMap().entries.map((entry) {
                            final index = entry.key;
                            final disciplineCase = entry.value;
                            return FadeInSlide(
                              delay: Duration(milliseconds: index * 100),
                              child: _buildBoardingIncidentCard(
                                context,
                                disciplineCase,
                                semanticColors,
                              ),
                            );
                          }),
                        ],
                      ],
                    );
                  } else if (state is DisciplineError) {
                    return EmptyState(
                      icon: Icons.cloud_off,
                      title: 'Could not load discipline records',
                      message: state.message,
                      ctaLabel: 'Retry',
                      onCtaPressed: _fetchData,
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildAcademicIncidentCard(
    BuildContext context,
    DisciplineIncident incident,
    SemanticColors semanticColors,
  ) {
    return AppCard(
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
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              StatusBadge(
                label: incident.severity.name.toUpperCase(),
                color: _getSeverityColor(incident.severity, semanticColors),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildIncidentRow(
            context,
            'Incident',
            incident.description,
            Icons.report_problem_outlined,
          ),
          const SizedBox(height: 8),
          _buildIncidentRow(
            context,
            'Resolution',
            incident.resolution,
            Icons.check_circle_outline,
          ),
          if (incident.counselingNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildIncidentRow(
              context,
              'Counseling',
              incident.counselingNotes,
              Icons.psychology_outlined,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBoardingIncidentCard(
    BuildContext context,
    DisciplineCase disciplineCase,
    SemanticColors semanticColors,
  ) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.format(disciplineCase.date),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              StatusBadge(
                label: disciplineCase.status.toUpperCase(),
                color: disciplineCase.status.toLowerCase() == 'resolved'
                    ? semanticColors.success
                    : semanticColors.warning,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildIncidentRow(
            context,
            'Category',
            disciplineCase.category,
            Icons.category_outlined,
          ),
          const SizedBox(height: 8),
          _buildIncidentRow(
            context,
            'Incident',
            disciplineCase.incident,
            Icons.report_problem_outlined,
          ),
          const SizedBox(height: 8),
          _buildIncidentRow(
            context,
            'Action',
            disciplineCase.actionTaken,
            Icons.gavel_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildIncidentRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
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
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(Severity severity, SemanticColors colors) {
    switch (severity) {
      case Severity.info:
        return colors.info;
      case Severity.success:
        return colors.success;
      case Severity.warning:
        return colors.warning;
      case Severity.error:
        return colors.error;
    }
  }
}

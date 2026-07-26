import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:school_pulse/features/discipline/domain/entities/discipline_incident.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/usecases/get_all_students.dart';
import 'bloc/discipline_bloc.dart';
import 'bloc/discipline_event.dart';
import 'bloc/discipline_state.dart';

class DisciplineDashboardScreen extends StatefulWidget {
  const DisciplineDashboardScreen({super.key});

  @override
  State<DisciplineDashboardScreen> createState() => _DisciplineDashboardScreenState();
}

class _DisciplineDashboardScreenState extends State<DisciplineDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<DisciplineBloc>().add(LoadRecentIncidents());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discipline & Guidance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showLogIncidentDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<DisciplineBloc, DisciplineState>(
        builder: (context, state) {
          if (state is DisciplineLoading) {
            return const _DisciplineDashboardSkeleton();
          }

          if (state is DisciplineError) {
            return Center(child: Text(state.message));
          }

          if (state is DisciplineLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<DisciplineBloc>().add(LoadRecentIncidents());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  FadeInSlide(
                    child: Text(
                      'Discipline Overview',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 24),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.1,
                    children: [
                      FadeInSlide(
                        delay: const Duration(milliseconds: 100),
                        child: DashboardStatCard(
                          title: 'Total Incidents',
                          value: state.incidents.length.toDouble(),
                          icon: Icons.gavel_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      FadeInSlide(
                        delay: const Duration(milliseconds: 200),
                        child: DashboardStatCard(
                          title: 'Pending Review',
                          value: state.incidents.where((i) => i.resolution.isEmpty).length.toDouble(),
                          icon: Icons.pending_actions_outlined,
                          color: semanticColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const FadeInSlide(
                    delay: Duration(milliseconds: 300),
                    child: SectionHeader(title: 'Recent Incidents'),
                  ),
                  if (state.incidents.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No recent incidents recorded.'),
                      ),
                    )
                  else
                    ...state.incidents.asMap().entries.map((entry) {
                      final index = entry.key;
                      final incident = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: FadeInSlide(
                          delay: Duration(milliseconds: 400 + (index * 50)),
                          child: Card(
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getSeverityColor(incident.severity, semanticColors).withValues(alpha: 0.1),
                                child: Icon(
                                  Icons.warning_amber_rounded,
                                  color: _getSeverityColor(incident.severity, semanticColors),
                                ),
                              ),
                              title: Text('Student ID: ${incident.studentId}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(incident.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('MMM d, yyyy').format(incident.date),
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              isThreeLine: true,
                              onTap: () => _showIncidentDetail(context, incident),
                            ),
                          ),
                        ),
                      );
                    }),
                  const SizedBox(height: 32),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showLogIncidentDialog(BuildContext context) {
    final bloc = context.read<DisciplineBloc>();
    final descriptionController = TextEditingController();
    Severity severity = Severity.warning;

    showDialog(
      context: context,
      builder: (dialogContext) => FutureBuilder<List<Student>>(
        future: di.sl<GetAllStudents>()().then((r) => r.getOrElse(() => const [])),
        builder: (dialogContext, snapshot) {
          final students = snapshot.data ?? const <Student>[];
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())));
          }
          if (students.isEmpty) {
            return AlertDialog(
              title: const Text('Log Incident'),
              content: const Text('No students found.'),
              actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
            );
          }
          String selectedStudentId = students.first.id;

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) => AlertDialog(
              title: const Text('Log Incident'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: selectedStudentId,
                    decoration: const InputDecoration(labelText: 'Student'),
                    items: students.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
                    onChanged: (value) => setDialogState(() => selectedStudentId = value ?? selectedStudentId),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Severity>(
                    initialValue: severity,
                    decoration: const InputDecoration(labelText: 'Severity'),
                    items: Severity.values
                        .map((s) => DropdownMenuItem(value: s, child: Text(s.name)))
                        .toList(),
                    onChanged: (value) => setDialogState(() => severity = value ?? severity),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Description', alignLabelWithHint: true),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
                FilledButton(
                  onPressed: () {
                    if (descriptionController.text.trim().isEmpty) return;
                    bloc.add(LogIncidentRequested(
                      studentId: selectedStudentId,
                      description: descriptionController.text.trim(),
                      severity: severity,
                    ));
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Log Incident'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showIncidentDetail(BuildContext context, DisciplineIncident incident) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Student ID: ${incident.studentId}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM d, yyyy').format(incident.date), style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 12),
            Text(incident.description),
            if (incident.resolution.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Resolution', style: Theme.of(context).textTheme.labelMedium),
              Text(incident.resolution),
            ],
            if (incident.counselingNotes.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('Counseling Notes', style: Theme.of(context).textTheme.labelMedium),
              Text(incident.counselingNotes),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close')),
        ],
      ),
    );
  }

  Color _getSeverityColor(dynamic severity, SemanticColors semanticColors) {
    // This assumes severity is the enum defined in discipline_incident.dart
    switch (severity.toString().split('.').last) {
      case 'info': return semanticColors.info;
      case 'success': return semanticColors.success;
      case 'warning': return semanticColors.warning;
      case 'error': return semanticColors.error;
      default: return Colors.grey;
    }
  }
}

class _DisciplineDashboardSkeleton extends StatelessWidget {
  const _DisciplineDashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Skeleton(width: 200, height: 28),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: List.generate(2, (index) => const Skeleton(borderRadius: 12)),
        ),
        const SizedBox(height: 24),
        const Skeleton(width: 120, height: 20),
        const SizedBox(height: 16),
        ...List.generate(
          5,
          (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 80, borderRadius: 12),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/matron/domain/entities/matron_entities.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_bloc.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_event.dart';
import 'package:school_pulse/features/matron/presentation/bloc/matron_state.dart';
import 'package:school_pulse/features/shared/boarding/boarding_list_widgets.dart';

const _kSeverities = ['Low', 'Medium', 'High'];
const _kCategories = [
  'Curfew Violation',
  'Disruptive Behaviour',
  'Property Damage',
  'Bullying',
  'Substance Use',
  'Other',
];

class DisciplineManagementScreen extends StatefulWidget {
  const DisciplineManagementScreen({super.key});

  @override
  State<DisciplineManagementScreen> createState() =>
      _DisciplineManagementScreenState();
}

class _DisciplineManagementScreenState
    extends State<DisciplineManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatronBloc>().add(const WatchDisciplineIncidents());
    context.read<MatronBloc>().add(WatchBoardingStudents());
  }

  String _currentUserName(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    return authState is AuthAuthenticated ? authState.user.name : 'Matron';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discipline Tracking')),
      body: BlocListener<MatronBloc, MatronState>(
        listenWhen: (_, current) =>
            current is MatronActionSuccess || current is MatronError,
        listener: (context, state) {
          if (state is MatronActionSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is MatronError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        child: BlocBuilder<MatronBloc, MatronState>(
          buildWhen: (previous, current) =>
              current is DisciplineIncidentsLoaded || current is MatronLoading,
          builder: (context, state) {
            if (state is MatronLoading) {
              return const Center(child: SchoolPulseLoader());
            }

            List<DisciplineIncident> incidents = [];
            if (state is DisciplineIncidentsLoaded) {
              incidents = state.incidents;
            }

            if (incidents.isEmpty) {
              return const EmptyState(
                icon: Icons.gavel_outlined,
                title: 'No Discipline Incidents',
                message:
                    'Recorded incidents will appear here for case tracking.',
              );
            }

            final open = incidents
                .where((i) => i.status != 'Resolved')
                .toList();
            final resolved = incidents
                .where((i) => i.status == 'Resolved')
                .toList();

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.l),
              children: [
                if (open.isNotEmpty) ...[
                  SectionHeader(title: 'Open Cases (${open.length})'),
                  const SizedBox(height: AppSpacing.s),
                  ...open.map(
                    (i) => _IncidentCard(
                      incident: i,
                      currentUserName: _currentUserName(context),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.l),
                ],
                if (resolved.isNotEmpty) ...[
                  SectionHeader(title: 'Recent Actions (${resolved.length})'),
                  const SizedBox(height: AppSpacing.s),
                  ...resolved.map(
                    (i) => _IncidentCard(
                      incident: i,
                      currentUserName: _currentUserName(context),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogIncidentDialog(context),
        label: const Text('Log Incident'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showLogIncidentDialog(BuildContext context) {
    final descController = TextEditingController();
    final actionController = TextEditingController();
    final locationController = TextEditingController();
    final witnessesController = TextEditingController();
    String selectedCategory = _kCategories.first;
    String selectedSeverity = 'Low';
    BoardingStudent? selectedStudent;
    var parentNotified = false;
    var isPrivate = true;
    final recordedBy = _currentUserName(context);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) {
          final matronState = context.watch<MatronBloc>().state;
          List<BoardingStudent> students = [];
          if (matronState is BoardingStudentsLoaded) {
            students = matronState.students;
          }

          return AlertDialog(
            title: const Text('New Discipline Incident'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<BoardingStudent>(
                    decoration: const InputDecoration(labelText: 'Student'),
                    initialValue: selectedStudent,
                    items: students
                        .map(
                          (s) =>
                              DropdownMenuItem(value: s, child: Text(s.name)),
                        )
                        .toList(),
                    onChanged: (val) => setState(() => selectedStudent = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    initialValue: selectedCategory,
                    items: _kCategories
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Severity'),
                    initialValue: selectedSeverity,
                    items: _kSeverities
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedSeverity = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: 'Location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: witnessesController,
                    decoration: const InputDecoration(
                      labelText: 'Witnesses (comma separated)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: actionController,
                    decoration: const InputDecoration(
                      labelText: 'Initial Action',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    onChanged: (_) => setState(() {}),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Notify parent'),
                    subtitle: const Text(
                      'A summary alert will be sent to the parent',
                    ),
                    value: parentNotified,
                    onChanged: (val) =>
                        setState(() => parentNotified = val ?? false),
                  ),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Keep record private'),
                    subtitle: const Text(
                      'Hidden from parent/student portal unless disclosed later',
                    ),
                    value: isPrivate,
                    onChanged: (val) => setState(() => isPrivate = val ?? true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed:
                    selectedStudent == null || descController.text.isEmpty
                    ? null
                    : () {
                        final incident = DisciplineIncident(
                          id: '',
                          studentId: selectedStudent!.id,
                          studentName: selectedStudent!.name,
                          description: descController.text.trim(),
                          category: selectedCategory,
                          actionTaken: actionController.text.trim(),
                          date: DateTime.now(),
                          status: 'Pending',
                          recordedBy: recordedBy,
                          location: locationController.text.trim().isEmpty
                              ? null
                              : locationController.text.trim(),
                          witnesses: witnessesController.text
                              .split(',')
                              .map((w) => w.trim())
                              .where((w) => w.isNotEmpty)
                              .toList(),
                          severity: selectedSeverity,
                          parentNotified: parentNotified,
                          isPrivate: isPrivate,
                        );
                        context.read<MatronBloc>().add(
                          LogDisciplineIncidentEvent(incident),
                        );
                        Navigator.pop(dialogContext);
                      },
                child: const Text('Log Incident'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _IncidentCard extends StatelessWidget {
  final DisciplineIncident incident;
  final String currentUserName;
  const _IncidentCard({required this.incident, required this.currentUserName});

  Color _statusColor(SemanticColors semanticColors) {
    switch (incident.status) {
      case 'Pending':
        return semanticColors.warning;
      case 'Resolved':
        return semanticColors.success;
      case 'Follow-up':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;
    return AppCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      padding: EdgeInsets.zero,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(semanticColors).withValues(alpha: 0.2),
          child: Icon(Icons.gavel, color: _statusColor(semanticColors)),
        ),
        title: Text(
          incident.studentName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${incident.category} - ${DateFormat('MMM d').format(incident.date)}',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            SeverityBadge(severity: incident.severity),
            const SizedBox(height: 4),
            StatusBadge(
              label: incident.status,
              color: _statusColor(semanticColors),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Description:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(incident.description),
                if (incident.location != null) ...[
                  const SizedBox(height: 8),
                  Text('Location: ${incident.location}'),
                ],
                if (incident.witnesses.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text('Witnesses: ${incident.witnesses.join(', ')}'),
                ],
                const SizedBox(height: 12),
                const Text(
                  'Action Taken:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  incident.actionTaken.isEmpty
                      ? 'None recorded yet'
                      : incident.actionTaken,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      incident.isPrivate
                          ? Icons.lock_outline
                          : Icons.lock_open_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      incident.isPrivate
                          ? 'Private (staff only)'
                          : 'Shared with parent',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (incident.status == 'Pending')
                      TextButton(
                        onPressed: () => context.read<MatronBloc>().add(
                          UpdateDisciplineStatusEvent(
                            incident.id,
                            'Resolved',
                            incident.actionTaken,
                          ),
                        ),
                        child: const Text('Mark Resolved'),
                      ),
                    TextButton(
                      onPressed: () =>
                          _showUpdateStatusDialog(context, incident),
                      child: const Text('Update Details'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateStatusDialog(
    BuildContext context,
    DisciplineIncident incident,
  ) {
    final actionController = TextEditingController(text: incident.actionTaken);
    String selectedStatus = incident.status;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Update Incident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              items: [
                'Pending',
                'Resolved',
                'Follow-up',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) => selectedStatus = val!,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: actionController,
              decoration: const InputDecoration(
                labelText: 'Action Taken',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<MatronBloc>().add(
                UpdateDisciplineStatusEvent(
                  incident.id,
                  selectedStatus,
                  actionController.text,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

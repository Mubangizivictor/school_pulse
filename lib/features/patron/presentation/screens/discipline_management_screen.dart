import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/patron/domain/entities/patron_entities.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_bloc.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_event.dart';
import 'package:school_pulse/features/patron/presentation/bloc/patron_state.dart';
import 'package:intl/intl.dart';

class DisciplineManagementScreen extends StatefulWidget {
  const DisciplineManagementScreen({super.key});

  @override
  State<DisciplineManagementScreen> createState() => _DisciplineManagementScreenState();
}

class _DisciplineManagementScreenState extends State<DisciplineManagementScreen> {
  @override
  void initState() {
    super.initState();
    context.read<PatronBloc>().add(const WatchDisciplineIncidents());
    context.read<PatronBloc>().add(WatchBoardingStudents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Discipline Tracking'),
      ),
      body: BlocBuilder<PatronBloc, PatronState>(
        builder: (context, state) {
          if (state is PatronLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<DisciplineIncident> incidents = [];
          if (state is DisciplineIncidentsLoaded) {
            incidents = state.incidents;
          }

          if (incidents.isEmpty) {
            return const Center(child: Text('No discipline incidents recorded.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: incidents.length,
            itemBuilder: (context, index) {
              final incident = incidents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(incident.status).withValues(alpha: 0.2),
                    child: Icon(Icons.gavel, color: _getStatusColor(incident.status)),
                  ),
                  title: Text(incident.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${incident.category} • ${DateFormat('MMM d').format(incident.date)}'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(incident.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      incident.status,
                      style: TextStyle(color: _getStatusColor(incident.status), fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Description:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(incident.description),
                          const SizedBox(height: 12),
                          const Text('Action Taken:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(incident.actionTaken),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (incident.status == 'Pending')
                                TextButton(
                                  onPressed: () => _updateIncidentStatus(incident, 'Resolved'),
                                  child: const Text('Mark Resolved'),
                                ),
                              TextButton(
                                onPressed: () => _showUpdateStatusDialog(incident),
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
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showLogIncidentDialog(context),
        label: const Text('Log Incident'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Resolved': return Colors.green;
      case 'Follow-up': return Colors.blue;
      default: return Colors.grey;
    }
  }

  void _updateIncidentStatus(DisciplineIncident incident, String status) {
    context.read<PatronBloc>().add(UpdateDisciplineStatusEvent(
      incident.id,
      status,
      incident.actionTaken,
    ));
  }

  void _showUpdateStatusDialog(DisciplineIncident incident) {
    final actionController = TextEditingController(text: incident.actionTaken);
    String selectedStatus = incident.status;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Incident'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: selectedStatus,
              items: ['Pending', 'Resolved', 'Follow-up']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (val) => selectedStatus = val!,
              decoration: const InputDecoration(labelText: 'Status'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: actionController,
              decoration: const InputDecoration(labelText: 'Action Taken', border: OutlineInputBorder()),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<PatronBloc>().add(UpdateDisciplineStatusEvent(
                incident.id,
                selectedStatus,
                actionController.text,
              ));
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showLogIncidentDialog(BuildContext context) {
    final descController = TextEditingController();
    final actionController = TextEditingController();
    String selectedCategory = 'Minor';
    BoardingStudent? selectedStudent;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final patronState = context.watch<PatronBloc>().state;
          List<BoardingStudent> students = [];
          if (patronState is BoardingStudentsLoaded) {
            students = patronState.students;
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
                    items: students.map((s) => DropdownMenuItem(value: s, child: Text(s.name))).toList(),
                    onChanged: (val) => setState(() => selectedStudent = val),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    initialValue: selectedCategory,
                    items: ['Minor', 'Major', 'Severe', 'Positive Reinforcement']
                        .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                        .toList(),
                    onChanged: (val) => setState(() => selectedCategory = val!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: actionController,
                    decoration: const InputDecoration(labelText: 'Initial Action', border: OutlineInputBorder()),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: selectedStudent == null || descController.text.isEmpty
                    ? null
                    : () {
                        final incident = DisciplineIncident(
                          id: '',
                          studentId: selectedStudent!.id,
                          studentName: selectedStudent!.name,
                          description: descController.text,
                          category: selectedCategory,
                          actionTaken: actionController.text,
                          date: DateTime.now(),
                          status: 'Pending',
                          recordedBy: 'Patron',
                        );
                        context.read<PatronBloc>().add(LogDisciplineIncidentEvent(incident));
                        Navigator.pop(context);
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

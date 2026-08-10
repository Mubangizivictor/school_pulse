import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../../../domain/entities/academic_intervention.dart';

class AcademicInterventionsScreen extends StatefulWidget {
  const AcademicInterventionsScreen({super.key});

  @override
  State<AcademicInterventionsScreen> createState() =>
      _AcademicInterventionsScreenState();
}

class _AcademicInterventionsScreenState
    extends State<AcademicInterventionsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(InterventionsRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Academic Interventions'),
          actions: [
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showCreateInterventionSheet(context),
              ),
            ),
          ],
        ),
        body: BlocConsumer<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              context.read<DeanBloc>().add(InterventionsRequested());
            }
          },
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: SchoolPulseLoader());
            } else if (state is InterventionsLoaded) {
              if (state.interventions.isEmpty) {
                return const Center(child: Text('No interventions active.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.interventions.length,
                itemBuilder: (context, index) {
                  final intervention = state.interventions[index];
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        intervention.studentName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(intervention.reason),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              _buildTypeBadge(intervention.type),
                              const SizedBox(width: 8),
                              _buildStatusBadge(intervention.status),
                            ],
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      isThreeLine: true,
                      onTap: () =>
                          _showUpdateStatusSheet(context, intervention),
                    ),
                  );
                },
              );
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initializing...'));
          },
        ),
      ),
    );
  }

  Widget _buildTypeBadge(InterventionType type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        type.name.toUpperCase(),
        style: const TextStyle(
          fontSize: 10,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(InterventionStatus status) {
    Color color;
    switch (status) {
      case InterventionStatus.pending:
        color = Colors.orange;
        break;
      case InterventionStatus.inProgress:
        color = Colors.blue;
        break;
      case InterventionStatus.completed:
        color = Colors.green;
        break;
      case InterventionStatus.cancelled:
        color = Colors.grey;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _showCreateInterventionSheet(BuildContext context) {
    final deanBloc = context.read<DeanBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CreateInterventionSheet(
        onCreated: (intervention) {
          deanBloc.add(CreateInterventionRequested(intervention));
        },
      ),
    );
  }

  void _showUpdateStatusSheet(
    BuildContext context,
    AcademicIntervention intervention,
  ) {
    final deanBloc = context.read<DeanBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => UpdateInterventionStatusSheet(
        intervention: intervention,
        onUpdated: (status, outcomes) {
          deanBloc.add(
            UpdateInterventionStatusRequested(
              intervention.id,
              status,
              outcomes,
            ),
          );
        },
      ),
    );
  }
}

class CreateInterventionSheet extends StatefulWidget {
  final Function(AcademicIntervention) onCreated;
  const CreateInterventionSheet({super.key, required this.onCreated});

  @override
  State<CreateInterventionSheet> createState() =>
      _CreateInterventionSheetState();
}

class _CreateInterventionSheetState extends State<CreateInterventionSheet> {
  final _formKey = GlobalKey<FormState>();
  String _studentName = '';
  String _reason = '';
  InterventionType _type = InterventionType.remedial;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'New Intervention Plan'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Student Name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onSaved: (v) => _studentName = v!,
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason for Intervention',
              ),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onSaved: (v) => _reason = v!,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<InterventionType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Intervention Type'),
              items: InterventionType.values
                  .map(
                    (t) => DropdownMenuItem(
                      value: t,
                      child: Text(t.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  _formKey.currentState?.save();
                  widget.onCreated(
                    AcademicIntervention(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      studentId: 'temp',
                      studentName: _studentName,
                      reason: _reason,
                      type: _type,
                      status: InterventionStatus.pending,
                      startDate: DateTime.now(),
                      assignedTo: const [],
                      outcomes: '',
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Create Plan'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class UpdateInterventionStatusSheet extends StatefulWidget {
  final AcademicIntervention intervention;
  final Function(InterventionStatus, String) onUpdated;
  const UpdateInterventionStatusSheet({
    super.key,
    required this.intervention,
    required this.onUpdated,
  });

  @override
  State<UpdateInterventionStatusSheet> createState() =>
      _UpdateInterventionStatusSheetState();
}

class _UpdateInterventionStatusSheetState
    extends State<UpdateInterventionStatusSheet> {
  late InterventionStatus _status;
  late TextEditingController _outcomesController;

  @override
  void initState() {
    super.initState();
    _status = widget.intervention.status;
    _outcomesController = TextEditingController(
      text: widget.intervention.outcomes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: 'Update: ${widget.intervention.studentName}'),
          const SizedBox(height: 16),
          DropdownButtonFormField<InterventionStatus>(
            initialValue: _status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: InterventionStatus.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.name.toUpperCase()),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _outcomesController,
            decoration: const InputDecoration(labelText: 'Outcomes / Progress'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onUpdated(_status, _outcomesController.text);
              Navigator.pop(context);
            },
            child: const Text('Update Status'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/domain/entities/class_observation.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:intl/intl.dart';

class ClassObservationsScreen extends StatelessWidget {
  const ClassObservationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(ClassObservationsRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Class Observations')),
        body: BlocConsumer<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              context.read<DeanBloc>().add(ClassObservationsRequested());
            }
          },
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ClassObservationsLoaded) {
              if (state.observations.isEmpty) {
                return const Center(
                  child: Text('No class observations recorded yet.'),
                );
              }
              return _buildObservationList(context, state.observations);
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Loading observations...'));
          },
        ),
        floatingActionButton: Builder(
          builder: (context) => FloatingActionButton.extended(
            onPressed: () => _showRecordObservationSheet(context),
            label: const Text('Record Observation'),
            icon: const Icon(Icons.add),
          ),
        ),
      ),
    );
  }

  Widget _buildObservationList(
    BuildContext context,
    List<ClassObservation> observations,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: observations.length,
      itemBuilder: (context, index) {
        final obs = observations[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text('${obs.teacherName} • ${obs.subjectName}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Class: ${obs.className}'),
                Text('Date: ${DateFormat('MMM dd, yyyy').format(obs.date)}'),
                const SizedBox(height: 4),
                Text(
                  'Strengths: ${obs.strengths}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (obs.followUpDate != null)
                  Text(
                    'Follow-up: ${DateFormat('MMM dd, yyyy').format(obs.followUpDate!)}',
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),
            isThreeLine: true,
            onTap: () => _showObservationDetails(context, obs),
          ),
        );
      },
    );
  }

  void _showObservationDetails(BuildContext context, ClassObservation obs) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${obs.teacherName} • ${obs.subjectName}'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Class: ${obs.className}'),
              Text('Date: ${DateFormat('MMM dd, yyyy').format(obs.date)}'),
              const SizedBox(height: 12),
              Text(
                'Strengths',
                style: Theme.of(dialogContext).textTheme.titleSmall,
              ),
              Text(obs.strengths),
              const SizedBox(height: 12),
              Text(
                'Areas for Improvement',
                style: Theme.of(dialogContext).textTheme.titleSmall,
              ),
              Text(obs.areasForImprovement),
              const SizedBox(height: 12),
              Text(
                'Recommendations',
                style: Theme.of(dialogContext).textTheme.titleSmall,
              ),
              Text(obs.recommendations),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRecordObservationSheet(BuildContext context) {
    final deanBloc = context.read<DeanBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _RecordObservationSheet(
        onSubmit: (observation) =>
            deanBloc.add(RecordObservationRequested(observation)),
      ),
    );
  }
}

class _RecordObservationSheet extends StatefulWidget {
  final void Function(ClassObservation) onSubmit;

  const _RecordObservationSheet({required this.onSubmit});

  @override
  State<_RecordObservationSheet> createState() =>
      _RecordObservationSheetState();
}

class _RecordObservationSheetState extends State<_RecordObservationSheet> {
  final _formKey = GlobalKey<FormState>();
  String _teacherName = '';
  String _subjectName = '';
  String _className = '';
  String _strengths = '';
  String _areasForImprovement = '';
  String _recommendations = '';

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SectionHeader(title: 'Record Observation'),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Teacher Name'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _teacherName = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Subject'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _subjectName = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Class'),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _className = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Strengths'),
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _strengths = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Areas for Improvement',
                ),
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _areasForImprovement = v!,
              ),
              const SizedBox(height: 12),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Recommendations'),
                maxLines: 2,
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
                onSaved: (v) => _recommendations = v!,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _formKey.currentState?.save();
                    widget.onSubmit(
                      ClassObservation(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        teacherId: 'temp',
                        teacherName: _teacherName,
                        subjectId: 'temp',
                        subjectName: _subjectName,
                        classId: 'temp',
                        className: _className,
                        observerId: 'temp',
                        date: DateTime.now(),
                        strengths: _strengths,
                        areasForImprovement: _areasForImprovement,
                        recommendations: _recommendations,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save Observation'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

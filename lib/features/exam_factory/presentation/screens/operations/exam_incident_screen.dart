import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import '../../../domain/entities/exam_factory_entities.dart';
import '../../bloc/exam_factory_cubit.dart';
import '../../widgets/exam_factory_shell.dart';

String incidentTypeLabel(ExamIncidentType type) => switch (type) {
  ExamIncidentType.lateArrival => 'Late arrival',
  ExamIncidentType.malpractice => 'Malpractice',
  ExamIncidentType.illness => 'Illness',
  ExamIncidentType.materialsIssue => 'Materials issue',
  ExamIncidentType.disturbance => 'Disturbance',
  ExamIncidentType.other => 'Other',
};

class ExamIncidentScreen extends StatefulWidget {
  final String sittingId;
  const ExamIncidentScreen({super.key, required this.sittingId});

  @override
  State<ExamIncidentScreen> createState() => _ExamIncidentScreenState();
}

class _ExamIncidentScreenState extends State<ExamIncidentScreen> {
  final _descriptionController = TextEditingController();
  ExamIncidentType _type = ExamIncidentType.lateArrival;
  bool _reporting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _report(ExamFactoryCubit cubit) async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Describe what happened.')));
      return;
    }
    setState(() => _reporting = true);
    try {
      await cubit.reportIncident(
        sittingId: widget.sittingId,
        type: _type,
        description: _descriptionController.text.trim(),
      );
      if (!mounted) return;
      _descriptionController.clear();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Incident reported.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(cubit.state.error ?? 'Could not report this incident.'),
        ),
      );
    } finally {
      if (mounted) setState(() => _reporting = false);
    }
  }

  Future<void> _resolve(ExamFactoryCubit cubit, ExamIncident incident) async {
    final controller = TextEditingController();
    final resolution = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve incident'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Resolution notes'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );
    if (resolution == null || resolution.isEmpty) return;
    try {
      await cubit.resolveIncident(incident.id, resolution: resolution);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cubit.state.error ?? 'Could not resolve this incident.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ExamFactoryCubit>();
    return ExamFactoryScaffold(
      title: 'Incident reporting',
      backFallback:
          '/staff/dean/exam-factory/exam-day?sittingId=${widget.sittingId}',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          100,
        ),
        children: [
          DropdownButtonFormField<ExamIncidentType>(
            initialValue: _type,
            decoration: const InputDecoration(labelText: 'Type'),
            items: ExamIncidentType.values
                .map(
                  (t) => DropdownMenuItem(
                    value: t,
                    child: Text(incidentTypeLabel(t)),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _type = v ?? _type),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descriptionController,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Description',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _reporting ? null : () => _report(cubit),
            icon: _reporting
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.report_gmailerrorred_outlined),
            label: Text(_reporting ? 'Reporting…' : 'Report incident'),
          ),
          const SizedBox(height: 24),
          Text('Incidents', style: AppTypography.titleSmall),
          const SizedBox(height: 8),
          StreamBuilder<List<ExamIncident>>(
            stream: cubit.watchIncidents(sittingId: widget.sittingId),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final incidents = snap.data ?? const <ExamIncident>[];
              if (incidents.isEmpty) {
                return const Text('No incidents reported for this sitting.');
              }
              return Column(
                children: incidents
                    .map(
                      (incident) => Card(
                        child: ListTile(
                          leading: Icon(
                            incident.status == ExamIncidentStatus.resolved
                                ? Icons.check_circle_outline
                                : Icons.warning_amber_rounded,
                            color:
                                incident.status == ExamIncidentStatus.resolved
                                ? AppColors.success(context)
                                : AppColors.warning(context),
                          ),
                          title: Text(incidentTypeLabel(incident.type)),
                          subtitle: Text(
                            incident.status == ExamIncidentStatus.resolved
                                ? 'Resolved: ${incident.resolution}'
                                : incident.description,
                          ),
                          trailing:
                              incident.status == ExamIncidentStatus.resolved
                              ? null
                              : TextButton(
                                  onPressed: () => _resolve(cubit, incident),
                                  child: const Text('Resolve'),
                                ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

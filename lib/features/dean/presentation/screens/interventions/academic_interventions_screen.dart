import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_typography.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/academic_intervention.dart';

class AcademicInterventionsScreen extends StatefulWidget {
  const AcademicInterventionsScreen({super.key});

  @override
  State<AcademicInterventionsScreen> createState() =>
      _AcademicInterventionsScreenState();
}

class _AcademicInterventionsScreenState
    extends State<AcademicInterventionsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(InterventionsRequested()),
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        appBar: AppBar(
          title: const Text('Interventions'),
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: BlocConsumer<DeanBloc, DeanState>(
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
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is InterventionsLoaded) {
                    if (state.interventions.isEmpty) {
                      return const EmptyState(
                        icon: Icons.psychology,
                        title: 'No interventions',
                        message: 'No interventions active.',
                      );
                    }
                    final active = state.interventions
                        .where(
                          (i) =>
                              i.status != InterventionStatus.completed &&
                              i.status != InterventionStatus.cancelled,
                        )
                        .toList();
                    final completed = state.interventions
                        .where(
                          (i) =>
                              i.status == InterventionStatus.completed ||
                              i.status == InterventionStatus.cancelled,
                        )
                        .toList();
                    return TabBarView(
                      controller: _tabController,
                      children: [
                        _buildInterventionList(
                          context,
                          active,
                          'No active interventions.',
                        ),
                        _buildInterventionList(
                          context,
                          completed,
                          'No completed interventions.',
                        ),
                      ],
                    );
                  } else if (state is DeanError) {
                    return Center(child: Text(state.message));
                  }
                  return const Center(child: Text('Initializing...'));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Builder(
                builder: (context) => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showCreateInterventionSheet(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Intervention'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterventionList(
    BuildContext context,
    List<AcademicIntervention> interventions,
    String emptyMessage,
  ) {
    if (interventions.isEmpty) {
      return EmptyState(
        icon: Icons.psychology_outlined,
        title: 'Nothing here',
        message: emptyMessage,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      itemCount: interventions.length,
      itemBuilder: (context, index) {
        final intervention = interventions[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: AppSpacing.l),
          onTap: () => _showUpdateStatusSheet(context, intervention),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AvatarInitials(name: intervention.studentName, size: 44),
              const SizedBox(width: AppSpacing.l),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      intervention.studentName,
                      style: AppTypography.titleSmall.copyWith(
                        color: AppColors.textPrimary(context),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(intervention.reason, style: AppTypography.bodySmall),
                    const SizedBox(height: AppSpacing.xs),
                    if (intervention.targetDate != null)
                      Text(
                        'Due: ${DateFormat('d MMM yyyy').format(intervention.targetDate!)}',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.textMuted(context),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.s),
                    Row(
                      children: [
                        _buildTypeBadge(context, intervention.type),
                        const SizedBox(width: AppSpacing.m),
                        _buildStatusBadge(context, intervention.status),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textMuted(context)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeBadge(BuildContext context, InterventionType type) {
    return StatusBadge(label: type.name, color: AppColors.primary(context));
  }

  Widget _buildStatusBadge(BuildContext context, InterventionStatus status) {
    Color color;
    switch (status) {
      case InterventionStatus.pending:
        color = AppColors.warning(context);
        break;
      case InterventionStatus.inProgress:
        color = AppColors.information(context);
        break;
      case InterventionStatus.completed:
        color = AppColors.success(context);
        break;
      case InterventionStatus.cancelled:
        color = AppColors.textMuted(context);
        break;
    }
    return StatusBadge(label: status.name, color: color);
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
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'New Intervention Plan'),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Student Name'),
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onSaved: (v) => _studentName = v!,
            ),
            const SizedBox(height: AppSpacing.xl),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Reason for Intervention',
              ),
              maxLines: 2,
              validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              onSaved: (v) => _reason = v!,
            ),
            const SizedBox(height: AppSpacing.xl),
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
            const SizedBox(height: AppSpacing.x3l),
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
            const SizedBox(height: AppSpacing.xl),
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
        left: AppSpacing.xl,
        right: AppSpacing.xl,
        top: AppSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionHeader(title: 'Update: ${widget.intervention.studentName}'),
          const SizedBox(height: AppSpacing.xl),
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
          const SizedBox(height: AppSpacing.xl),
          TextFormField(
            controller: _outcomesController,
            decoration: const InputDecoration(labelText: 'Outcomes / Progress'),
            maxLines: 3,
          ),
          const SizedBox(height: AppSpacing.x3l),
          ElevatedButton(
            onPressed: () {
              widget.onUpdated(_status, _outcomesController.text);
              Navigator.pop(context);
            },
            child: const Text('Update Status'),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/appointment.dart';
import '../../domain/entities/appointment_note.dart';
import '../../domain/entities/appointment_status.dart';
import '../../domain/repositories/appointment_repository.dart';
import '../bloc/appointment_action_bloc.dart';
import '../bloc/appointment_action_event.dart';
import '../bloc/appointment_action_state.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const AppointmentDetailScreen({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<AppointmentActionBloc>(),
      child: _AppointmentDetailView(appointment: appointment),
    );
  }
}

class _AppointmentDetailView extends StatelessWidget {
  final Appointment appointment;
  const _AppointmentDetailView({required this.appointment});

  (String, Color) _statusVisual(BuildContext context, AppointmentStatus status) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    return switch (status) {
      AppointmentStatus.pending => ('Pending', semantic.info),
      AppointmentStatus.approved => ('Approved', semantic.success),
      AppointmentStatus.rejected => ('Rejected', semantic.error),
      AppointmentStatus.rescheduleProposed => ('New Time Proposed', semantic.warning),
      AppointmentStatus.cancelled => ('Cancelled', Theme.of(context).colorScheme.outline),
      AppointmentStatus.completed => ('Completed', semantic.success),
      AppointmentStatus.noShow => ('No Show', semantic.error),
      AppointmentStatus.expired => ('Expired', Theme.of(context).colorScheme.outline),
    };
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();
    final user = authState.user;
    final isStaffViewer = user.role != UserRole.parent;
    final isRequester = user.id == appointment.requesterId;
    final dateFormat = DateFormat('EEE, MMM d • hh:mm a');

    return BlocConsumer<AppointmentActionBloc, AppointmentActionState>(
      listener: (context, state) {
        if (state is AppointmentActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          if (state.appointment == null) Navigator.pop(context, true);
        }
        if (state is AppointmentActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, actionState) {
        final (label, color) = _statusVisual(context, appointment.status);
        final busy = actionState is AppointmentActionInProgress;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          appBar: AppBar(title: const Text('Appointment Details')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(appointment.appointmentTypeName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                        ),
                        StatusBadge(label: label, color: color),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _InfoRow(icon: Icons.event, label: 'When', value: dateFormat.format(appointment.scheduledStart)),
                    _InfoRow(icon: Icons.timer_outlined, label: 'Duration', value: '${appointment.durationMinutes} min'),
                    _InfoRow(icon: Icons.person_outline, label: 'Requested by', value: appointment.requesterName),
                    if (appointment.studentName != null)
                      _InfoRow(icon: Icons.school_outlined, label: 'Student', value: appointment.studentName!),
                    _InfoRow(icon: Icons.badge_outlined, label: 'With', value: appointment.staffName),
                    _InfoRow(icon: Icons.apartment_outlined, label: 'Department', value: appointment.department),
                    const SizedBox(height: 8),
                    Text('Reason', style: Theme.of(context).textTheme.labelLarge),
                    const SizedBox(height: 4),
                    Text(appointment.reason),
                    if (appointment.responseNote != null) ...[
                      const SizedBox(height: 12),
                      Text('Staff note', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(appointment.responseNote!),
                    ],
                    if (appointment.status == AppointmentStatus.rescheduleProposed && appointment.proposedStart != null) ...[
                      const SizedBox(height: 12),
                      Text('Proposed new time', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 4),
                      Text(dateFormat.format(appointment.proposedStart!)),
                    ],
                    if (appointment.checkInTime != null) ...[
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.login,
                        label: 'Checked in',
                        value: DateFormat('hh:mm a').format(appointment.checkInTime!),
                      ),
                    ],
                    if (appointment.checkOutTime != null)
                      _InfoRow(
                        icon: Icons.logout,
                        label: 'Checked out',
                        value: DateFormat('hh:mm a').format(appointment.checkOutTime!),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (isStaffViewer)
                _StaffActions(appointment: appointment, staffId: user.id, busy: busy)
              else if (isRequester)
                _RequesterActions(appointment: appointment, requesterId: user.id, busy: busy),
              if (isStaffViewer) ...[
                const SizedBox(height: 24),
                _NotesSection(appointment: appointment, staffId: user.id, staffName: user.name),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text('$label: ', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}

class _StaffActions extends StatelessWidget {
  final Appointment appointment;
  final String staffId;
  final bool busy;
  const _StaffActions({required this.appointment, required this.staffId, required this.busy});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppointmentActionBloc>();

    if (appointment.status == AppointmentStatus.pending) {
      return Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: 'Approve',
              isLoading: busy,
              onPressed: () => bloc.add(RespondToAppointmentAction(
                appointment: appointment,
                status: AppointmentStatus.approved,
                respondedBy: staffId,
              )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SecondaryButton(
              label: 'Reject',
              onPressed: busy ? null : () => _showResponseDialog(context, bloc, AppointmentStatus.rejected),
            ),
          ),
        ],
      );
    }

    if (appointment.status == AppointmentStatus.approved) {
      if (appointment.checkInTime == null) {
        return PrimaryButton(
          label: 'Check In',
          isLoading: busy,
          icon: Icons.login,
          onPressed: () => bloc.add(CheckInAppointmentAction(appointment: appointment, checkedInBy: staffId)),
        );
      }
      if (appointment.checkOutTime == null) {
        return PrimaryButton(
          label: 'Check Out / Complete',
          isLoading: busy,
          icon: Icons.logout,
          onPressed: () => bloc.add(CheckOutAppointmentAction(appointment)),
        );
      }
    }

    return const SizedBox.shrink();
  }

  void _showResponseDialog(BuildContext context, AppointmentActionBloc bloc, AppointmentStatus status) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reason (optional)'),
        content: TextField(controller: controller, maxLines: 3),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              bloc.add(RespondToAppointmentAction(
                appointment: appointment,
                status: status,
                respondedBy: staffId,
                responseNote: controller.text.trim().isEmpty ? null : controller.text.trim(),
              ));
              Navigator.pop(dialogContext);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _RequesterActions extends StatelessWidget {
  final Appointment appointment;
  final String requesterId;
  final bool busy;
  const _RequesterActions({required this.appointment, required this.requesterId, required this.busy});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AppointmentActionBloc>();
    final cancellable = {
      AppointmentStatus.pending,
      AppointmentStatus.approved,
      AppointmentStatus.rescheduleProposed,
    }.contains(appointment.status);

    if (!cancellable) return const SizedBox.shrink();

    return Column(
      children: [
        if (appointment.status == AppointmentStatus.rescheduleProposed && appointment.proposedStart != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PrimaryButton(
              label: 'Accept New Time',
              isLoading: busy,
              onPressed: () => bloc.add(RespondToAppointmentAction(
                appointment: appointment,
                status: AppointmentStatus.approved,
                respondedBy: requesterId,
                proposedStart: appointment.proposedStart,
              )),
            ),
          ),
        SecondaryButton(
          label: 'Cancel Appointment',
          onPressed: busy
              ? null
              : () async {
                  final confirmed = await confirmActionDialog(
                    context,
                    title: 'Cancel Appointment?',
                    message: 'This will cancel your ${appointment.appointmentTypeName} request.',
                    isDestructive: true,
                  );
                  if (confirmed == true && context.mounted) {
                    bloc.add(CancelAppointmentAction(appointment: appointment, cancelledBy: requesterId));
                  }
                },
        ),
      ],
    );
  }
}

class _NotesSection extends StatefulWidget {
  final Appointment appointment;
  final String staffId;
  final String staffName;
  const _NotesSection({required this.appointment, required this.staffId, required this.staffName});

  @override
  State<_NotesSection> createState() => _NotesSectionState();
}

class _NotesSectionState extends State<_NotesSection> {
  final _summaryController = TextEditingController();
  final _actionItemsController = TextEditingController();
  bool _followUpRequired = false;

  @override
  void dispose() {
    _summaryController.dispose();
    _actionItemsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Confidential Meeting Notes'),
        Text(
          'Only visible to staff - never shown to the requesting parent.',
          style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        StreamBuilder<List<AppointmentNote>>(
          stream: di.sl<AppointmentRepository>().watchNotes(widget.appointment.id),
          builder: (context, snapshot) {
            final notes = snapshot.data ?? const [];
            if (notes.isEmpty) return const SizedBox.shrink();
            return Column(
              children: notes
                  .map((note) => AppCard(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(note.summary, style: const TextStyle(fontWeight: FontWeight.w600)),
                            if (note.actionItems != null && note.actionItems!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text('Action items: ${note.actionItems}'),
                            ],
                            if (note.followUpRequired)
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Text('Follow-up required', style: TextStyle(fontStyle: FontStyle.italic)),
                              ),
                            const SizedBox(height: 4),
                            Text(
                              '${note.authorName} • ${DateFormat('MMM d, hh:mm a').format(note.createdAt)}',
                              style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.outline),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            );
          },
        ),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _summaryController,
                decoration: const InputDecoration(labelText: 'Summary'),
                maxLines: 2,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _actionItemsController,
                decoration: const InputDecoration(labelText: 'Action items (optional)'),
                maxLines: 2,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Follow-up required'),
                value: _followUpRequired,
                onChanged: (v) => setState(() => _followUpRequired = v),
              ),
              const SizedBox(height: 8),
              PrimaryButton(
                label: 'Save Note',
                onPressed: () {
                  if (_summaryController.text.trim().isEmpty) return;
                  context.read<AppointmentActionBloc>().add(AddAppointmentNoteAction(AppointmentNote(
                    id: '',
                    appointmentId: widget.appointment.id,
                    authorId: widget.staffId,
                    authorName: widget.staffName,
                    summary: _summaryController.text.trim(),
                    actionItems: _actionItemsController.text.trim().isEmpty ? null : _actionItemsController.text.trim(),
                    followUpRequired: _followUpRequired,
                    createdAt: DateTime.now(),
                  )));
                  _summaryController.clear();
                  _actionItemsController.clear();
                  setState(() => _followUpRequired = false);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

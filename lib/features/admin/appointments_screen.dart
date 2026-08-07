import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/data/models/appointment.dart';
import 'package:school_pulse/features/admin/data/repositories/appointment_repository.dart'
    as admin_appointment;
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _repository = di.sl<admin_appointment.AppointmentRepository>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Appointments & Schedule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'New Appointment',
            onPressed: () => _showAddDialog(context),
          ),
        ],
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _repository.getAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Couldn\'t load appointments',
              message:
                  'Something went wrong on our end. Pull to refresh or check back shortly.',
            );
          }
          final appointments = snapshot.data ?? const [];
          if (appointments.isEmpty) {
            return EmptyState(
              icon: Icons.event_available_outlined,
              title: 'No appointments scheduled',
              message:
                  'Book a visitor meeting or staff appointment to see it here.',
              ctaLabel: 'New Appointment',
              onCtaPressed: () => _showAddDialog(context),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) => _AppointmentTile(
              appointment: appointments[index],
              onUpdateStatus: (status) => _repository.updateAppointmentStatus(
                appointments[index].id,
                status,
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddDialog(BuildContext context) {
    final nameController = TextEditingController();
    final purposeController = TextEditingController();
    DateTime scheduled = DateTime.now().add(const Duration(hours: 1));
    final hostId = (context.read<AuthBloc>().state is AuthAuthenticated)
        ? (context.read<AuthBloc>().state as AuthAuthenticated).user.id
        : '';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('New Appointment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Visitor / Guest Name',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: purposeController,
                decoration: const InputDecoration(labelText: 'Purpose'),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  final date = await showDatePicker(
                    context: dialogContext,
                    initialDate: scheduled,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date == null) return;
                  if (!dialogContext.mounted) return;
                  final time = await showTimePicker(
                    context: dialogContext,
                    initialTime: TimeOfDay.fromDateTime(scheduled),
                  );
                  if (time == null) return;
                  setDialogState(() {
                    scheduled = DateTime(
                      date.year,
                      date.month,
                      date.day,
                      time.hour,
                      time.minute,
                    );
                  });
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Scheduled Time',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy • hh:mm a').format(scheduled),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                await _repository.createAppointment(
                  Appointment(
                    id: '',
                    visitorName: nameController.text.trim(),
                    purpose: purposeController.text.trim().isEmpty
                        ? 'General visit'
                        : purposeController.text.trim(),
                    scheduledTime: scheduled,
                    status: 'pending',
                    hostStaffId: hostId,
                  ),
                );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final ValueChanged<String> onUpdateStatus;

  const _AppointmentTile({
    required this.appointment,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final (label, color) = switch (appointment.status) {
      'checked_in' => ('Checked In', semantic.success),
      'completed' => ('Completed', Theme.of(context).colorScheme.outline),
      'cancelled' => ('Cancelled', semantic.error),
      _ => ('Pending', semantic.info),
    };

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.visitorName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${appointment.purpose} • ${DateFormat('MMM dd, hh:mm a').format(appointment.scheduledTime)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(label: label, color: color),
          if (appointment.status == 'pending' ||
              appointment.status == 'checked_in')
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: onUpdateStatus,
              itemBuilder: (context) => [
                if (appointment.status == 'pending')
                  const PopupMenuItem(
                    value: 'checked_in',
                    child: Text('Check In'),
                  ),
                if (appointment.status == 'checked_in')
                  const PopupMenuItem(
                    value: 'completed',
                    child: Text('Mark Completed'),
                  ),
                const PopupMenuItem(value: 'cancelled', child: Text('Cancel')),
              ],
            ),
        ],
      ),
    );
  }
}

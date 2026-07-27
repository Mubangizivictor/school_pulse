import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/receptionist/presentation/bloc/receptionist_bloc.dart';
import 'package:school_pulse/features/receptionist/presentation/bloc/receptionist_event.dart';
import 'package:school_pulse/features/receptionist/presentation/bloc/receptionist_state.dart';

class ReceptionistDashboardScreen extends StatefulWidget {
  const ReceptionistDashboardScreen({super.key});

  @override
  State<ReceptionistDashboardScreen> createState() => _ReceptionistDashboardScreenState();
}

class _ReceptionistDashboardScreenState extends State<ReceptionistDashboardScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ReceptionistBloc>().add(ReceptionistDashboardRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receptionist Portal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task),
            onPressed: () => _showScheduleAppointmentDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<ReceptionistBloc, ReceptionistState>(
        builder: (context, state) {
          if (state is ReceptionistLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ReceptionistError) {
            return Center(child: Text(state.message));
          }
          if (state is ReceptionistLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<ReceptionistBloc>().add(ReceptionistDashboardRequested());
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Text(
                    'Daily Overview',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
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
                      DashboardStatCard(
                        title: 'Appointments',
                        value: state.appointments.length.toDouble(),
                        icon: Icons.calendar_today,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      DashboardStatCard(
                        title: 'Total Visitors',
                        value: state.totalVisitorsToday.toDouble(),
                        icon: Icons.people_outline,
                        color: Theme.of(context).extension<SemanticColors>()?.success ?? Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionHeader(title: 'Upcoming Appointments'),
                  if (state.appointments.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No appointments scheduled.'),
                      ),
                    )
                  else
                    ...state.appointments.map((appointment) => AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Text(appointment.visitorName),
                            subtitle: Text(appointment.purpose),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  DateFormat('hh:mm a').format(appointment.time),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  appointment.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: appointment.status == 'Scheduled' ? Colors.blue : Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showScheduleAppointmentDialog(BuildContext context) {
    final visitorNameController = TextEditingController();
    final purposeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Schedule Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: visitorNameController,
                  decoration: const InputDecoration(labelText: 'Visitor Name'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: purposeController,
                  decoration: const InputDecoration(labelText: 'Purpose of Visit'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: Text("Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}"),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) setDialogState(() => selectedDate = date);
                  },
                ),
                ListTile(
                  title: Text("Time: ${selectedTime.format(context)}"),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(context: context, initialTime: selectedTime);
                    if (time != null) setDialogState(() => selectedTime = time);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            FilledButton(
              onPressed: () {
                if (visitorNameController.text.isEmpty) return;
                final appointmentTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );
                context.read<ReceptionistBloc>().add(ScheduleAppointmentRequested(
                      visitorName: visitorNameController.text.trim(),
                      purpose: purposeController.text.trim(),
                      time: appointmentTime,
                    ));
                Navigator.pop(context);
              },
              child: const Text('Schedule'),
            ),
          ],
        ),
      ),
    );
  }
}

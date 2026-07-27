import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/notification/local_notification_service.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/calendar/domain/entities/school_event.dart';
import 'package:school_pulse/features/calendar/presentation/bloc/calendar_bloc.dart';
import 'package:school_pulse/features/calendar/presentation/bloc/calendar_event.dart';
import 'package:school_pulse/features/calendar/presentation/bloc/calendar_state.dart';

class SchoolCalendarScreen extends StatelessWidget {
  const SchoolCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final bool canAdd = authState is AuthAuthenticated &&
        UserRoleDisplay.adminConsoleRoles.contains(authState.user.role);

    return Scaffold(
      appBar: AppBar(
        title: const Text('School Calendar'),
        actions: [
          if (canAdd)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEventDialog(context),
            ),
        ],
      ),
      body: BlocConsumer<CalendarBloc, CalendarState>(
        listener: (context, state) {
          if (state is CalendarLoaded) {
            _syncAllNotifications(state.events);
          }
        },
        builder: (context, state) {
          if (state is CalendarLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CalendarError) {
            return Center(child: Text(state.message));
          }
          if (state is CalendarLoaded) {
            final events = state.events;
            if (events.isEmpty) {
              return const EmptyState(
                icon: Icons.event_outlined,
                title: 'No events yet',
                message: 'Check back later for school events.',
              );
            }
            return RefreshIndicator(
              onRefresh: () async {
                context.read<CalendarBloc>().add(LoadCalendarEvents());
              },
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final event = events[index];
                  return _EventCard(
                    event: event,
                    canDelete: canAdd,
                    onDelete: () => _confirmDelete(context, event),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _syncAllNotifications(List<SchoolEvent> events) {
    for (final event in events) {
      _scheduleNotifications(event);
    }
  }

  void _confirmDelete(BuildContext context, SchoolEvent event) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<CalendarBloc>().add(DeleteCalendarEvent(event.id));
              _cancelNotifications(event);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showAddEventDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final responsibleController = TextEditingController();
    DateTime selectedDate = DateTime.now().add(const Duration(hours: 1));
    SchoolEventType selectedType = SchoolEventType.general;
    List<UserRole> selectedRoles = [];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('Add School Event'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Event Title'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: responsibleController,
                  decoration: const InputDecoration(
                    labelText: 'Responsible Person',
                    hintText: 'e.g. Mr. Okello',
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SchoolEventType>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: 'Event Type'),
                  items: SchoolEventType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.name.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedType = val);
                  },
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Date & Time'),
                  subtitle: Text(DateFormat('MMM d, yyyy HH:mm').format(selectedDate)),
                  trailing: const Icon(Icons.calendar_today, size: 18),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: dialogContext,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      final time = await showTimePicker(
                        context: dialogContext,
                        initialTime: TimeOfDay.fromDateTime(selectedDate),
                      );
                      if (time != null) {
                        setDialogState(() {
                          selectedDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                
                final authState = context.read<AuthBloc>().state;
                final createdBy = authState is AuthAuthenticated ? authState.user.id : '';

                final eventId = FirebaseFirestore.instance.collection('school_events').doc().id;

                final event = SchoolEvent(
                  id: eventId,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  date: selectedDate,
                  createdBy: createdBy,
                  type: selectedType,
                  responsiblePerson: responsibleController.text.trim(),
                  targetRoles: selectedRoles,
                );

                context.read<CalendarBloc>().add(AddCalendarEvent(event));
                
                // Schedule Local Notifications/Alarms
                _scheduleNotifications(event);

                Navigator.pop(dialogContext);
              },
              child: const Text('Add Event'),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleNotifications(SchoolEvent event) {
    if (event.id.isEmpty) return;
    
    final now = DateTime.now();
    final eventId = event.id.hashCode;

    // Staff Meeting specific notifications
    if (event.type == SchoolEventType.staffMeeting) {
      // 1 day before
      final dayBefore = event.date.subtract(const Duration(days: 1));
      if (dayBefore.isAfter(now)) {
        LocalNotificationService.schedule(
          id: eventId + 1,
          title: 'Staff Meeting Tomorrow',
          body: 'Reminder: ${event.title} is scheduled for tomorrow at ${DateFormat('HH:mm').format(event.date)}',
          scheduledDate: dayBefore,
        );
      }

      // 1 hour before
      final hourBefore = event.date.subtract(const Duration(hours: 1));
      if (hourBefore.isAfter(now)) {
        LocalNotificationService.schedule(
          id: eventId + 2,
          title: 'Staff Meeting in 1 Hour',
          body: 'Reminder: ${event.title} starts at ${DateFormat('HH:mm').format(event.date)}',
          scheduledDate: hourBefore,
        );
      }
    } else {
      // General reminder 2 hours before
      final reminder = event.date.subtract(const Duration(hours: 2));
      if (reminder.isAfter(now)) {
        LocalNotificationService.schedule(
          id: eventId,
          title: 'Upcoming School Event',
          body: '${event.title} is starting at ${DateFormat('HH:mm').format(event.date)}',
          scheduledDate: reminder,
        );
      }
    }
  }

  void _cancelNotifications(SchoolEvent event) {
    if (event.id.isEmpty) return;
    final eventId = event.id.hashCode;
    if (event.type == SchoolEventType.staffMeeting) {
      LocalNotificationService.cancel(eventId + 1);
      LocalNotificationService.cancel(eventId + 2);
    } else {
      LocalNotificationService.cancel(eventId);
    }
  }
}

class _EventCard extends StatelessWidget {
  final SchoolEvent event;
  final bool canDelete;
  final VoidCallback? onDelete;

  const _EventCard({
    required this.event,
    this.canDelete = false,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    IconData icon;
    Color color;
    switch (event.type) {
      case SchoolEventType.staffMeeting:
        icon = Icons.groups;
        color = Colors.orange;
        break;
      case SchoolEventType.exam:
        icon = Icons.assignment;
        color = Colors.red;
        break;
      case SchoolEventType.holiday:
        icon = Icons.beach_access;
        color = Colors.green;
        break;
      default:
        icon = Icons.event;
        color = colorScheme.primary;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d, yyyy • HH:mm').format(event.date),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  onPressed: onDelete,
                  color: colorScheme.error,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(event.description, style: Theme.of(context).textTheme.bodyMedium),
          ],
          if (event.responsiblePerson != null && event.responsiblePerson!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person_outline, size: 14, color: colorScheme.outline),
                const SizedBox(width: 4),
                Text(
                  'Responsible: ${event.responsiblePerson}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

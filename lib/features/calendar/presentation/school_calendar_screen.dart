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
import 'package:school_pulse/features/calendar/presentation/event_detail_screen.dart';
import 'package:school_pulse/features/calendar/presentation/widgets/event_type_style.dart';

/// Broadcast groups an admin can aim an event at when creating/editing it -
/// mirrors the options in BroadcastSmsScreen so the same topics are reached.
const _audienceOptions = [
  'Parents',
  'All Staff',
  'Teachers Only',
  'Bursars & Admin',
  'Matrons (Girls)',
  'Patrons (Boys)',
];

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
                    canManage: canAdd,
                    onDelete: () => _confirmDelete(context, event),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailScreen(
                          event: event,
                          canManage: canAdd,
                          onEdit: () => _showAddEventDialog(context, existing: event),
                          onDelete: () => _confirmDelete(context, event),
                        ),
                      ),
                    ),
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

  void _confirmDelete(BuildContext context, SchoolEvent event) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Delete Event',
      message: 'Are you sure you want to delete "${event.title}"?',
      confirmLabel: 'Delete',
      isDestructive: true,
    );
    if (confirmed == true && context.mounted) {
      context.read<CalendarBloc>().add(DeleteCalendarEvent(event.id));
      _cancelNotifications(event);
    }
  }

  void _showAddEventDialog(BuildContext context, {SchoolEvent? existing}) {
    final isEditing = existing != null;
    final titleController = TextEditingController(text: existing?.title);
    final descriptionController = TextEditingController(text: existing?.description);
    DateTime selectedDate = existing?.date ?? DateTime.now().add(const Duration(hours: 1));
    SchoolEventType selectedType = existing?.type ?? SchoolEventType.general;
    final selectedGroups = Set<String>.of(existing?.targetGroups ?? defaultEventTargetGroups);

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Edit School Event' : 'Add School Event'),
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
                  minLines: 3,
                  maxLines: 6,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Add as much detail as staff/parents need…',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<SchoolEventType>(
                  initialValue: selectedType,
                  decoration: const InputDecoration(labelText: 'Event Type'),
                  items: SchoolEventType.values
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(type.icon, size: 16, color: type.color),
                                const SizedBox(width: 8),
                                Text(type.label),
                              ],
                            ),
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
                    if (date != null && dialogContext.mounted) {
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
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Notify',
                    style: Theme.of(dialogContext).textTheme.labelLarge,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _audienceOptions.map((group) {
                    final selected = selectedGroups.contains(group);
                    return FilterChip(
                      label: Text(group),
                      selected: selected,
                      onSelected: (val) => setDialogState(() {
                        if (val) {
                          selectedGroups.add(group);
                        } else {
                          selectedGroups.remove(group);
                        }
                      }),
                    );
                  }).toList(),
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

                final eventId = existing?.id ??
                    FirebaseFirestore.instance.collection('school_events').doc().id;

                final event = SchoolEvent(
                  id: eventId,
                  title: titleController.text.trim(),
                  description: descriptionController.text.trim(),
                  date: selectedDate,
                  createdBy: isEditing ? existing.createdBy : createdBy,
                  type: selectedType,
                  targetGroups: selectedGroups.isEmpty ? defaultEventTargetGroups : selectedGroups.toList(),
                );

                context.read<CalendarBloc>().add(AddCalendarEvent(event));

                // Re-arm the ringing reminders for the (possibly new) date/type.
                if (isEditing) _cancelNotifications(existing);
                _scheduleNotifications(event);

                Navigator.pop(dialogContext);
              },
              child: Text(isEditing ? 'Save Changes' : 'Add Event'),
            ),
          ],
        ),
      ),
    );
  }

  /// Arms two ringing local notifications for every event - a day before
  /// and an hour before (see [SchoolEventTypeStyle.reminderLeadTimes]).
  void _scheduleNotifications(SchoolEvent event) {
    if (event.id.isEmpty) return;

    final now = DateTime.now();
    final baseId = event.id.hashCode;
    final leadTimes = event.type.reminderLeadTimes;

    for (var i = 0; i < leadTimes.length; i++) {
      final leadTime = leadTimes[i];
      final fireAt = event.date.subtract(leadTime);
      if (!fireAt.isAfter(now)) continue;

      LocalNotificationService.schedule(
        id: baseId + i + 1,
        title: '${event.type.label}: ${event.title}',
        body: '${event.title} starts ${_describeLeadTime(leadTime)} at ${DateFormat('HH:mm').format(event.date)}',
        scheduledDate: fireAt,
      );
    }
  }

  String _describeLeadTime(Duration leadTime) {
    if (leadTime.inHours >= 24) return 'tomorrow';
    if (leadTime.inHours >= 1) return 'in ${leadTime.inHours} hour${leadTime.inHours == 1 ? '' : 's'}';
    return 'soon';
  }

  void _cancelNotifications(SchoolEvent event) {
    if (event.id.isEmpty) return;
    final baseId = event.id.hashCode;
    for (var i = 0; i < event.type.reminderLeadTimes.length; i++) {
      LocalNotificationService.cancel(baseId + i + 1);
    }
  }
}

class _EventCard extends StatelessWidget {
  final SchoolEvent event;
  final bool canManage;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const _EventCard({
    required this.event,
    this.canManage = false,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final type = event.type;

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(type.icon, color: type.color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label,
                      style: TextStyle(color: type.color, fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 0.3),
                    ),
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
              if (canManage)
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
            Text(
              event.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ],
      ),
    );
  }
}

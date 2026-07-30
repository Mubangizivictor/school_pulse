import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/calendar/domain/entities/school_event.dart';
import 'package:school_pulse/features/calendar/presentation/widgets/event_type_style.dart';

class EventDetailScreen extends StatelessWidget {
  final SchoolEvent event;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const EventDetailScreen({
    super.key,
    required this.event,
    this.canManage = false,
    this.onEdit,
    this.onDelete,
  });

  String _relativeTime() {
    final diff = event.date.difference(DateTime.now());
    if (diff.isNegative) return 'Already happened';
    if (diff.inMinutes < 60) return 'In ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'In ${diff.inHours} hr${diff.inHours == 1 ? '' : 's'}';
    return 'In ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final type = event.type;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Details'),
        actions: [
          if (canManage) ...[
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: 'Edit',
              onPressed: onEdit == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      onEdit!();
                    },
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              color: colorScheme.error,
              onPressed: onDelete == null
                  ? null
                  : () {
                      Navigator.pop(context);
                      onDelete!();
                    },
            ),
          ],
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: type.color, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label.toUpperCase(),
                      style: TextStyle(color: type.color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                    ),
                    const SizedBox(height: 4),
                    Text(event.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(icon: Icons.calendar_today_outlined, label: DateFormat('EEEE, MMM d, yyyy').format(event.date)),
                const SizedBox(height: 12),
                _DetailRow(icon: Icons.access_time_rounded, label: DateFormat('HH:mm').format(event.date)),
                const SizedBox(height: 12),
                _DetailRow(icon: Icons.timelapse_rounded, label: _relativeTime()),
              ],
            ),
          ),
          if (event.description.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Text(event.description, style: const TextStyle(fontSize: 15, height: 1.5)),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500))),
      ],
    );
  }
}

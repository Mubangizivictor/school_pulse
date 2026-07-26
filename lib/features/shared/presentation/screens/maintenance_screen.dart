import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/features/shared/domain/entities/school_asset.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final List<MaintenanceTicket> _tickets = [
    MaintenanceTicket(
      id: 'T1',
      assetId: '2',
      assetName: 'Generator 50kVA',
      description: 'Engine oil leak detected.',
      priority: 'High',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Maintenance Tickets'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.build)),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _tickets.length,
        itemBuilder: (context, index) {
          final ticket = _tickets[index];
          return AppCard(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ticket.assetName, style: const TextStyle(fontWeight: FontWeight.bold)),
                    _PriorityBadge(priority: ticket.priority),
                  ],
                ),
                const SizedBox(height: 8),
                Text(ticket.description),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Status: ${ticket.status}', style: const TextStyle(fontWeight: FontWeight.w500)),
                    Text(DateFormatter.relative(ticket.createdAt), style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PriorityBadge extends StatelessWidget {
  final String priority;
  const _PriorityBadge({required this.priority});

  @override
  Widget build(BuildContext context) {
    Color color = priority == 'High' ? Colors.red : (priority == 'Medium' ? Colors.orange : Colors.blue);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(priority.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

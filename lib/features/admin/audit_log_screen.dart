import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/data/models/audit_log.dart';
import 'package:school_pulse/features/admin/data/repositories/audit_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AuditLogScreen extends StatelessWidget {
  const AuditLogScreen({super.key});

  static const _iconMap = {
    'person_add': Icons.person_add,
    'vpn_key': Icons.vpn_key,
    'send': Icons.send,
    'gpp_maybe': Icons.gpp_maybe,
    'inventory_2': Icons.inventory_2,
  };

  @override
  Widget build(BuildContext context) {
    final repository = di.sl<AuditRepository>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(title: const Text('Audit Log')),
      body: StreamBuilder<List<AuditLog>>(
        stream: repository.watchRecentLogs(limit: 200),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SchoolPulseLoader());
          }
          if (snapshot.hasError) {
            return const EmptyState(
              icon: Icons.error_outline_rounded,
              title: 'Couldn\'t load the audit log',
              message:
                  'Something went wrong on our end. Pull to refresh or check back shortly.',
            );
          }
          final logs = snapshot.data ?? const [];
          if (logs.isEmpty) {
            return const EmptyState(
              icon: Icons.history_rounded,
              title: 'No activity yet',
              message: 'Staff and system actions will be recorded here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: logs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final log = logs[index];
              final color = _parseColor(log.colorHex);
              return AppCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _iconMap[log.iconName] ?? Icons.info,
                      size: 16,
                      color: color,
                    ),
                  ),
                  title: Text(
                    log.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  subtitle: Text(
                    log.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  trailing: Text(
                    _formatFull(log.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.blueGrey;
    }
  }

  String _formatFull(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
  }
}

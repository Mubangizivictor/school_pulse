import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/super_admin_bloc.dart';
import '../bloc/super_admin_event.dart';
import '../bloc/super_admin_state.dart';
import '../responsive.dart';
import '../widgets/super_admin_logout_button.dart';

class AuditLogsScreen extends StatelessWidget {
  const AuditLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Platform Audit Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<SuperAdminBloc>().add(const LoadAuditLogsEvent()),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter dialog
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              // Export logs
            },
          ),
          const SizedBox(width: 16),
          if (!isSuperAdminWide(context)) const SuperAdminLogoutButton(),
        ],
      ),
      body: BlocBuilder<SuperAdminBloc, SuperAdminState>(
        builder: (context, state) {
          if (state.status == SuperAdminStatus.loading && state.auditLogs.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final logs = state.auditLogs;

          if (logs.isEmpty) {
            return const Center(child: Text('No audit logs found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: logs.length,
            separatorBuilder: (_, _) => const Divider(),
            itemBuilder: (context, index) {
              final log = logs[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.surfaceContainerHigh,
                  child: Icon(Icons.history, color: theme.colorScheme.primary),
                ),
                title: Text(log.action, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text('By ${log.ownerId} • ${log.device}'),
                    if (log.reason != null)
                      Text('Reason: ${log.reason}', style: TextStyle(color: theme.colorScheme.error, fontSize: 12)),
                  ],
                ),
                trailing: Text(
                  DateFormat('MMM dd, HH:mm').format(log.timestamp),
                  style: theme.textTheme.bodySmall,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

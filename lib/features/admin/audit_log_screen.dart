import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

/// Read-only institution operational trace. Backend redacts values before
/// persistence; this screen never renders a raw event payload.
class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});
  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  String _module = 'all';
  String _search = '';
  bool _securityOnly = false;
  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthBloc, dynamic>(
      (b) => b.state is AuthAuthenticated
          ? (b.state as AuthAuthenticated).user
          : null,
    );
    if (user == null) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    final ref = FirebaseFirestore.instance
        .collection('institutions')
        .doc(user.schoolId)
        .collection('audit_events');
    return Scaffold(
      appBar: const AdminAppBar(title: 'Audit Center'),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: ref
            .orderBy('createdAt', descending: true)
            .limit(200)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _State(
              icon: Icons.error_outline,
              title: 'Couldn’t load audit history',
              message: 'Try again when you are online.',
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: SchoolPulseLoader());
          }
          final rows = snapshot.data!.docs.where((row) {
            final d = row.data();
            final haystack =
                '${d['actorNameSnapshot'] ?? ''} ${d['targetDisplaySnapshot'] ?? ''} ${d['targetId'] ?? ''} ${d['correlationId'] ?? ''} ${d['action'] ?? ''}'
                    .toLowerCase();
            return (_module == 'all' || d['moduleKey'] == _module) &&
                (!_securityOnly ||
                    d['moduleKey'] == 'security' ||
                    d['sensitivity'] == 'sensitive') &&
                (_search.isEmpty || haystack.contains(_search.toLowerCase()));
          }).toList();
          final counts = <String, int>{
            'Security': 0,
            'Exports': 0,
            'Support': 0,
            'Denied': 0,
          };
          for (final row in rows) {
            final d = row.data();
            if (d['moduleKey'] == 'security') {
              counts['Security'] = counts['Security']! + 1;
            }
            if (d['eventType'] == 'Export') {
              counts['Exports'] = counts['Exports']! + 1;
            }
            if (d['moduleKey'] == 'support') {
              counts['Support'] = counts['Support']! + 1;
            }
            if (d['status'] == 'denied') {
              counts['Denied'] = counts['Denied']! + 1;
            }
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Institution activity',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: counts.entries
                    .map((e) => Chip(label: Text('${e.value} ${e.key}')))
                    .toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (v) => setState(() => _search = v),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search user, target, correlation ID…',
                ),
              ),
              Wrap(
                spacing: 8,
                children: [
                  DropdownButton<String>(
                    value: _module,
                    items:
                        const [
                              'all',
                              'support',
                              'security',
                              'attendance',
                              'finance',
                              'structure',
                              'integrations',
                              'data_management',
                              'communication',
                            ]
                            .map(
                              (v) => DropdownMenuItem(
                                value: v,
                                child: Text(v == 'all' ? 'All modules' : v),
                              ),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => _module = v!),
                  ),
                  FilterChip(
                    label: const Text('Security'),
                    selected: _securityOnly,
                    onSelected: (v) => setState(() => _securityOnly = v),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (rows.isEmpty)
                const _State(
                  icon: Icons.history_toggle_off,
                  title: 'No matching activity',
                  message: 'Change the filters or try a broader date range.',
                )
              else
                ...rows.map((row) => _AuditRow(row: row)),
            ],
          );
        },
      ),
    );
  }
}

class _AuditRow extends StatelessWidget {
  const _AuditRow({required this.row});
  final QueryDocumentSnapshot<Map<String, dynamic>> row;
  @override
  Widget build(BuildContext context) {
    final d = row.data();
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: () => showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (_) => _Detail(d),
        ),
        leading: Icon(d['status'] == 'denied' ? Icons.block : Icons.history),
        title: Text(
          '${d['action'] ?? d['eventType'] ?? 'Activity'}'.replaceAll('_', ' '),
        ),
        subtitle: Text(
          '${d['actorNameSnapshot'] ?? d['actorId'] ?? 'System'} • ${d['moduleKey'] ?? 'system'}',
        ),
        trailing: Text(
          _when(d['createdAt']),
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ),
    );
  }
}

class _Detail extends StatelessWidget {
  const _Detail(this.d);
  final Map<String, dynamic> d;
  @override
  Widget build(BuildContext context) {
    Widget line(String label, dynamic value) => value == null
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                Text(
                  value is Map
                      ? value.entries
                            .map((e) => '${e.key}: ${e.value}')
                            .join('\n')
                      : value.toString(),
                ),
              ],
            ),
          );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            Text('Audit event', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            line('Action', d['action'] ?? d['eventType']),
            line('Actor', d['actorNameSnapshot'] ?? d['actorId']),
            line('Module', d['moduleKey']),
            line('Target', d['targetDisplaySnapshot'] ?? d['targetId']),
            line('Status', d['status']),
            line('Source', d['source']),
            line('Reason', d['reason']),
            line('Before', d['previousValueSummary']),
            line('After', d['newValueSummary']),
            line('Correlation ID', d['correlationId']),
            line('Support access session', d['supportAccessSessionId']),
            line('Device', d['deviceId']),
            line('Offline', d['offlineFlag']),
          ],
        ),
      ),
    );
  }
}

class _State extends StatelessWidget {
  const _State({
    required this.icon,
    required this.title,
    required this.message,
  });
  final IconData icon;
  final String title, message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Center(
      child: Column(
        children: [
          Icon(icon, size: 42),
          const SizedBox(height: 8),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

String _when(dynamic value) {
  if (value is! Timestamp) return 'Pending';
  final d = value.toDate();
  return '${d.day}/${d.month} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

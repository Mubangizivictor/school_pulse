import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/approval_repository.dart';
import '../../domain/entities/approval_models.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Lets an approver temporarily hand off their decision authority to another
/// active staff member (e.g. Headteacher away for a week -> Deputy Head).
/// createApprovalDelegation validates the delegate is an active member of
/// this institution and the date range is sane; decideApprovalRequest is
/// what actually checks a delegation is still valid before honouring it.
class ApprovalDelegationScreen extends StatefulWidget {
  const ApprovalDelegationScreen({super.key});
  @override
  State<ApprovalDelegationScreen> createState() =>
      _ApprovalDelegationScreenState();
}

class _ApprovalDelegationScreenState extends State<ApprovalDelegationScreen> {
  final _repository = ApprovalRepository();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to manage delegations.')),
      );
    }
    final schoolId = auth.user.schoolId;
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Delegations')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreate(context, schoolId),
        icon: const Icon(Icons.add),
        label: const Text('Delegate'),
      ),
      body: StreamBuilder<List<ApprovalDelegation>>(
        stream: _repository.watchDelegations(schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load delegations.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final delegations = snapshot.data!;
          if (delegations.isEmpty) {
            return const Center(
              child: Text('No delegations have been created yet.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: delegations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final d = delegations[i];
              final active = d.isActive;
              final expired = d.end.isBefore(DateTime.now());
              return Card(
                child: ListTile(
                  leading: Icon(
                    active
                        ? Icons.how_to_reg
                        : expired
                        ? Icons.event_busy
                        : Icons.schedule,
                    color: active ? Colors.black : Colors.black,
                  ),
                  title: Text('${d.delegatorId} → ${d.delegateId}'),
                  subtitle: Text(
                    '${DateFormat.yMMMd().format(d.start)} – ${DateFormat.yMMMd().format(d.end)}\n'
                    '${d.modules.isEmpty ? 'All modules' : d.modules.join(', ')}'
                    '${d.requestTypes.isEmpty ? '' : ' • ${d.requestTypes.join(', ')}'}'
                    '${d.reason.isEmpty ? '' : '\n${d.reason}'}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    active ? 'Active' : (expired ? 'Expired' : d.status),
                    style: TextStyle(
                      color: active ? Colors.black : Colors.black,
                      fontWeight: FontWeight.bold,
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

  Future<void> _openCreate(BuildContext context, String schoolId) async {
    final delegateId = TextEditingController();
    final modules = TextEditingController();
    final requestTypes = TextEditingController();
    final reason = TextEditingController();
    DateTime? start;
    DateTime? end;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: const Text('New delegation'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: delegateId,
                  decoration: const InputDecoration(
                    labelText: 'Delegate user ID',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: modules,
                  decoration: const InputDecoration(
                    labelText: 'Modules (comma-separated, optional)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: requestTypes,
                  decoration: const InputDecoration(
                    labelText: 'Request types (comma-separated, optional)',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: reason,
                  decoration: const InputDecoration(labelText: 'Reason'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now().subtract(
                              const Duration(days: 1),
                            ),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setDialogState(() => start = picked);
                          }
                        },
                        child: Text(
                          start == null
                              ? 'Start date'
                              : DateFormat.yMMMd().format(start!),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: dialogContext,
                            initialDate: (start ?? DateTime.now()).add(
                              const Duration(days: 1),
                            ),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );
                          if (picked != null) {
                            setDialogState(() => end = picked);
                          }
                        },
                        child: Text(
                          end == null
                              ? 'End date'
                              : DateFormat.yMMMd().format(end!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (delegateId.text.trim().isEmpty ||
                    start == null ||
                    end == null) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Delegate, start date and end date are required.',
                      ),
                    ),
                  );
                  return;
                }
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;
    try {
      await _repository.delegate(
        schoolId: schoolId,
        delegateId: delegateId.text.trim(),
        startsAt: start!,
        endsAt: end!,
        reason: reason.text.trim(),
        modules: modules.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
        requestTypes: requestTypes.text
            .split(',')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Delegation created.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not create delegation: $e')),
        );
      }
    }
  }
}

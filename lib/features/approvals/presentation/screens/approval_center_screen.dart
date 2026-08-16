import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/approval_repository.dart';
import '../../domain/entities/approval_models.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

class ApprovalCenterScreen extends StatefulWidget {
  /// When set, scopes this screen to a single [ApprovalRequest.moduleKey]
  /// (e.g. `'academics'`) so a domain-specific entry point (Dean report-card
  /// approvals, exam moderation) can reuse the one real inbox/decide flow
  /// instead of maintaining its own mock screen against the same data.
  final String? moduleKeyFilter;
  final String? title;
  const ApprovalCenterScreen({super.key, this.moduleKeyFilter, this.title});
  @override
  State<ApprovalCenterScreen> createState() => _ApprovalCenterScreenState();
}

class _ApprovalCenterScreenState extends State<ApprovalCenterScreen> {
  final _repository = ApprovalRepository();
  String _query = '';
  ApprovalStatus? _status;
  ApprovalPriority? _priority;
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated)
      return const Scaffold(
        body: Center(child: Text('Sign in to view approvals.')),
      );
    return Scaffold(
      appBar: AppBar(title: Text(widget.title ?? 'Approval Center')),
      body: StreamBuilder<List<ApprovalRequest>>(
        stream: _repository.watchInbox(auth.user.schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError)
            return _Error(
              message: 'Could not load approvals.',
              retry: () => setState(() {}),
            );
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final requests = snapshot.data!;
          final visible = requests
              .where(
                (r) =>
                    (widget.moduleKeyFilter == null ||
                        r.moduleKey == widget.moduleKeyFilter) &&
                    (_status == null || r.currentStatus == _status) &&
                    (_priority == null || r.priority == _priority) &&
                    (_query.isEmpty ||
                        '${r.approvalRequestId} ${r.title} ${r.requestedBy} ${r.sourceRecordId}'
                            .toLowerCase()
                            .contains(_query.toLowerCase())),
              )
              .toList();
          return Column(
            children: [
              _Summary(requests: requests),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search request, person or source record',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    FilterChip(
                      label: const Text('All'),
                      selected: _status == null && _priority == null,
                      onSelected: (_) => setState(() {
                        _status = null;
                        _priority = null;
                      }),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Pending'),
                      selected: _status == ApprovalStatus.pending,
                      onSelected: (v) => setState(
                        () => _status = v ? ApprovalStatus.pending : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Urgent'),
                      selected:
                          _priority == ApprovalPriority.urgent ||
                          _priority == ApprovalPriority.critical,
                      onSelected: (v) => setState(
                        () => _priority = v ? ApprovalPriority.urgent : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilterChip(
                      label: const Text('Execution failed'),
                      selected: _status == ApprovalStatus.executionFailed,
                      onSelected: (v) => setState(
                        () =>
                            _status = v ? ApprovalStatus.executionFailed : null,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const Center(
                        child: Text('No approvals match these filters.'),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: visible.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (_, i) => _RequestCard(
                          request: visible[i],
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ApprovalDetailScreen(
                                repository: _repository,
                                schoolId: auth.user.schoolId,
                                request: visible[i],
                              ),
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final List<ApprovalRequest> requests;
  const _Summary({required this.requests});
  @override
  Widget build(BuildContext context) {
    final pending = requests
        .where((r) => r.currentStatus == ApprovalStatus.pending)
        .length;
    final urgent = requests
        .where(
          (r) =>
              r.priority == ApprovalPriority.urgent ||
              r.priority == ApprovalPriority.critical,
        )
        .length;
    final overdue = requests
        .where((r) => r.dueAt?.isBefore(DateTime.now()) ?? false)
        .length;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _Metric('Pending', pending, Colors.orange),
          _Metric('Urgent', urgent, Colors.red),
          _Metric('Overdue', overdue, Colors.deepPurple),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _Metric(this.label, this.count, this.color);
  @override
  Widget build(BuildContext context) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: Theme.of(context).textTheme.labelSmall),
          ],
        ),
      ),
    ),
  );
}

class _RequestCard extends StatelessWidget {
  final ApprovalRequest request;
  final VoidCallback onTap;
  const _RequestCard({required this.request, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      onTap: onTap,
      title: Text(request.title),
      subtitle: Text(
        '${request.moduleKey} • ${request.requestedBy}\nStage: ${request.currentStage.isEmpty ? 'Awaiting resolution' : request.currentStage}',
      ),
      isThreeLine: true,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _Chip(
            text: request.priority.name,
            color: request.priority.index >= ApprovalPriority.urgent.index
                ? Colors.red
                : Colors.blueGrey,
          ),
          const SizedBox(height: 4),
          Text(
            request.currentStatus.name,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    ),
  );
}

class _Chip extends StatelessWidget {
  final String text;
  final Color color;
  const _Chip({required this.text, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .12),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      text.toUpperCase(),
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
    ),
  );
}

class _Error extends StatelessWidget {
  final String message;
  final VoidCallback retry;
  const _Error({required this.message, required this.retry});
  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(message),
        TextButton(onPressed: retry, child: const Text('Retry')),
      ],
    ),
  );
}

class ApprovalDetailScreen extends StatefulWidget {
  final ApprovalRepository repository;
  final String schoolId;
  final ApprovalRequest request;
  const ApprovalDetailScreen({
    super.key,
    required this.repository,
    required this.schoolId,
    required this.request,
  });
  @override
  State<ApprovalDetailScreen> createState() => _ApprovalDetailScreenState();
}

class _ApprovalDetailScreenState extends State<ApprovalDetailScreen> {
  bool _busy = false;
  Future<void> _act(
    ApprovalDecision decision, {
    bool requiresReason = false,
  }) async {
    final c = TextEditingController();
    final accepted = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(decision.name),
        content: TextField(
          controller: c,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: requiresReason ? 'Reason (required)' : 'Comment',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(ctx, !requiresReason || c.text.trim().isNotEmpty),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (accepted != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await widget.repository.decide(
        schoolId: widget.schoolId,
        requestId: widget.request.approvalRequestId,
        decision: decision,
        comment: c.text.trim(),
        expectedVersion: widget.request.version,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Decision recorded.')));
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Decision not recorded: $e')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Scaffold(
      appBar: AppBar(title: const Text('Approval request')),
      bottomNavigationBar: r.currentStatus == ApprovalStatus.pending
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _act(
                                ApprovalDecision.rejected,
                                requiresReason: true,
                              ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _busy
                            ? null
                            : () => _act(
                                ApprovalDecision.returned,
                                requiresReason: true,
                              ),
                        child: const Text('Return'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: FilledButton(
                        onPressed: _busy
                            ? null
                            : () => _act(ApprovalDecision.approved),
                        child: const Text('Approve'),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(r.title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _Chip(text: r.currentStatus.name, color: Colors.blue),
              _Chip(text: r.sensitivity.name, color: Colors.purple),
            ],
          ),
          const Divider(height: 32),
          _Row('Module', r.moduleKey),
          _Row('Type', r.requestType),
          _Row('Requester', '${r.requestedBy} • ${r.requesterRole}'),
          _Row('Stage', r.currentStage),
          _Row('Submitted', DateFormat.yMMMd().add_jm().format(r.submittedAt)),
          if (r.dueAt != null)
            _Row('Due', DateFormat.yMMMd().add_jm().format(r.dueAt!)),
          if (r.amount != null) _Row('Amount', r.amount!.toStringAsFixed(2)),
          if (r.reason != null) _Row('Reason', r.reason!),
          _Row('Source record', r.sourceRecordId),
          const SizedBox(height: 12),
          Text(r.summary),
          if (r.proposedValue != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Proposed changes',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(r.proposedValue.toString()),
          ],
          const SizedBox(height: 20),
          const Text(
            'Official workflow history',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          StreamBuilder<List<ApprovalAction>>(
            stream: widget.repository.watchActions(
              widget.schoolId,
              r.approvalRequestId,
            ),
            builder: (_, s) => !s.hasData
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: s.data!
                        .map(
                          (a) => ListTile(
                            leading: const Icon(Icons.history),
                            title: Text(a.action),
                            subtitle: Text(
                              '${a.actorId} • ${a.comment}\n${DateFormat.yMMMd().add_jm().format(a.timestamp)}',
                            ),
                          ),
                        )
                        .toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  const _Row(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(child: Text(value)),
      ],
    ),
  );
}

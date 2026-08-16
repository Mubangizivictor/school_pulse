import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/approval_repository.dart';
import '../../domain/entities/approval_models.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Lets an approvals admin define/edit the per-module, per-request-type
/// workflow (stage chain, delegation/self-approval/escalation rules) that
/// submitApprovalRequest and decideApprovalRequest key off of. There is no
/// client-side write path to schools/{id}/approval_policies (Firestore rules
/// deny it outright) - every save goes through saveApprovalPolicy, which
/// re-validates the stage list server-side.
class ApprovalPolicyManagerScreen extends StatefulWidget {
  const ApprovalPolicyManagerScreen({super.key});
  @override
  State<ApprovalPolicyManagerScreen> createState() =>
      _ApprovalPolicyManagerScreenState();
}

class _ApprovalPolicyManagerScreenState
    extends State<ApprovalPolicyManagerScreen> {
  final _repository = ApprovalRepository();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to manage approval policies.')),
      );
    }
    final schoolId = auth.user.schoolId;
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Policies')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(context, schoolId, null),
        icon: const Icon(Icons.add),
        label: const Text('New policy'),
      ),
      body: StreamBuilder<List<ApprovalPolicy>>(
        stream: _repository.watchPolicies(schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Could not load policies.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final policies = snapshot.data!;
          if (policies.isEmpty) {
            return const Center(
              child: Text(
                'No approval policies yet.\nCreate one so source modules can submit requests.',
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: policies.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final p = policies[i];
              return Card(
                child: ListTile(
                  title: Text(p.name),
                  subtitle: Text(
                    '${p.moduleKey} • ${p.requestType} • ${p.stages.length} stage${p.stages.length == 1 ? '' : 's'}\n'
                    '${p.sequential ? 'Sequential' : 'Parallel'} • v${p.version}'
                    '${p.status == 'archived' ? ' • Archived' : ''}',
                  ),
                  isThreeLine: true,
                  trailing: Icon(
                    p.status == 'archived'
                        ? Icons.archive_outlined
                        : Icons.chevron_right,
                  ),
                  onTap: () => _openEditor(context, schoolId, p),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    String schoolId,
    ApprovalPolicy? existing,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _PolicyEditorScreen(
          repository: _repository,
          schoolId: schoolId,
          existing: existing,
        ),
      ),
    );
  }
}

class _PolicyEditorScreen extends StatefulWidget {
  final ApprovalRepository repository;
  final String schoolId;
  final ApprovalPolicy? existing;
  const _PolicyEditorScreen({
    required this.repository,
    required this.schoolId,
    required this.existing,
  });
  @override
  State<_PolicyEditorScreen> createState() => _PolicyEditorScreenState();
}

class _PolicyEditorScreenState extends State<_PolicyEditorScreen> {
  late final _name = TextEditingController(text: widget.existing?.name);
  late final _moduleKey = TextEditingController(
    text: widget.existing?.moduleKey,
  );
  late final _requestType = TextEditingController(
    text: widget.existing?.requestType,
  );
  late final _dueMinutes = TextEditingController(
    text: widget.existing?.dueTime?.inMinutes.toString(),
  );
  late bool _sequential = widget.existing?.sequential ?? true;
  late bool _delegationAllowed = widget.existing?.delegationAllowed ?? false;
  late bool _selfApprovalAllowed =
      widget.existing?.selfApprovalAllowed ?? false;
  late bool _escalationAllowed = widget.existing?.escalationAllowed ?? true;
  late bool _archived = widget.existing?.status == 'archived';
  late List<_StageDraft> _stages =
      widget.existing?.stages.map((s) => _StageDraft.fromStage(s)).toList() ??
      [_StageDraft(order: 0)];
  bool _saving = false;

  Future<void> _save() async {
    if (_name.text.trim().isEmpty ||
        _moduleKey.text.trim().isEmpty ||
        _requestType.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, module and type are required.')),
      );
      return;
    }
    if (_stages.any((s) => s.stageId.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Every stage needs a stage ID.')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      await widget.repository.savePolicy(
        schoolId: widget.schoolId,
        approvalPolicyId: widget.existing?.approvalPolicyId,
        name: _name.text.trim(),
        moduleKey: _moduleKey.text.trim(),
        requestType: _requestType.text.trim(),
        stages: _stages
            .asMap()
            .entries
            .map((e) => e.value.toStage(e.key))
            .toList(),
        sequential: _sequential,
        delegationAllowed: _delegationAllowed,
        selfApprovalAllowed: _selfApprovalAllowed,
        escalationAllowed: _escalationAllowed,
        status: _archived ? 'archived' : 'active',
        dueTime: int.tryParse(_dueMinutes.text.trim()) == null
            ? null
            : Duration(minutes: int.parse(_dueMinutes.text.trim())),
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save policy: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'New policy' : 'Edit policy'),
        actions: [
          IconButton(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            tooltip: 'Save',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Policy name'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _moduleKey,
            decoration: const InputDecoration(
              labelText: 'Module key',
              helperText: "e.g. 'finance', 'academics', 'procurement'",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _requestType,
            decoration: const InputDecoration(
              labelText: 'Request type',
              helperText: "e.g. 'expenditure', 'report_card_publication'",
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _dueMinutes,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Default due time (minutes, optional)',
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Sequential stages'),
            subtitle: const Text('Off = stages may run in parallel'),
            value: _sequential,
            onChanged: (v) => setState(() => _sequential = v),
          ),
          SwitchListTile(
            title: const Text('Allow delegation'),
            value: _delegationAllowed,
            onChanged: (v) => setState(() => _delegationAllowed = v),
          ),
          SwitchListTile(
            title: const Text('Allow self-approval'),
            subtitle: const Text(
              'Off by default; keep off for high-risk workflows',
            ),
            value: _selfApprovalAllowed,
            onChanged: (v) => setState(() => _selfApprovalAllowed = v),
          ),
          SwitchListTile(
            title: const Text('Allow escalation'),
            value: _escalationAllowed,
            onChanged: (v) => setState(() => _escalationAllowed = v),
          ),
          if (widget.existing != null)
            SwitchListTile(
              title: const Text('Archived'),
              subtitle: const Text('Archived policies block new submissions'),
              value: _archived,
              onChanged: (v) => setState(() => _archived = v),
            ),
          const Divider(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Stages (in order)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextButton.icon(
                onPressed: () => setState(
                  () => _stages.add(_StageDraft(order: _stages.length)),
                ),
                icon: const Icon(Icons.add),
                label: const Text('Add stage'),
              ),
            ],
          ),
          for (int i = 0; i < _stages.length; i++)
            _StageCard(
              key: ValueKey(_stages[i]),
              draft: _stages[i],
              canRemove: _stages.length > 1,
              onRemove: () => setState(() => _stages.removeAt(i)),
              onMoveUp: i == 0
                  ? null
                  : () => setState(() {
                      final s = _stages.removeAt(i);
                      _stages.insert(i - 1, s);
                    }),
              onMoveDown: i == _stages.length - 1
                  ? null
                  : () => setState(() {
                      final s = _stages.removeAt(i);
                      _stages.insert(i + 1, s);
                    }),
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _StageDraft {
  final stageId = TextEditingController();
  final name = TextEditingController();
  final requiredPermission = TextEditingController(text: 'approvals.approve');
  final minimumApprovals = TextEditingController(text: '1');
  final escalationTimeoutMinutes = TextEditingController();
  bool parallel = false;
  bool allowReturn = true;
  bool allowReject = true;
  int order;
  _StageDraft({required this.order});
  factory _StageDraft.fromStage(ApprovalStage s) {
    final d = _StageDraft(order: s.order)
      ..stageId.text = s.stageId
      ..name.text = s.name
      ..requiredPermission.text = s.requiredPermission
      ..minimumApprovals.text = s.minimumApprovals.toString()
      ..parallel = s.parallel
      ..allowReturn = s.allowReturn
      ..allowReject = s.allowReject;
    if (s.escalationTimeout != null) {
      d.escalationTimeoutMinutes.text = s.escalationTimeout!.inMinutes
          .toString();
    }
    return d;
  }
  ApprovalStage toStage(int order) => ApprovalStage(
    stageId: stageId.text.trim(),
    order: order,
    name: name.text.trim().isEmpty ? stageId.text.trim() : name.text.trim(),
    requiredPermission: requiredPermission.text.trim().isEmpty
        ? 'approvals.approve'
        : requiredPermission.text.trim(),
    minimumApprovals: int.tryParse(minimumApprovals.text.trim()) ?? 1,
    parallel: parallel,
    allowReturn: allowReturn,
    allowReject: allowReject,
    escalationTimeout:
        int.tryParse(escalationTimeoutMinutes.text.trim()) == null
        ? null
        : Duration(minutes: int.parse(escalationTimeoutMinutes.text.trim())),
  );
}

class _StageCard extends StatefulWidget {
  final _StageDraft draft;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;
  const _StageCard({
    super.key,
    required this.draft,
    required this.canRemove,
    required this.onRemove,
    required this.onMoveUp,
    required this.onMoveDown,
  });
  @override
  State<_StageCard> createState() => _StageCardState();
}

class _StageCardState extends State<_StageCard> {
  @override
  Widget build(BuildContext context) {
    final d = widget.draft;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: d.stageId,
                    decoration: const InputDecoration(
                      labelText: 'Stage ID',
                      helperText: "e.g. 'bursar', 'headteacher'",
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: d.name,
                    decoration: const InputDecoration(
                      labelText: 'Display name',
                      isDense: true,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: widget.onMoveUp,
                  icon: const Icon(Icons.arrow_upward),
                ),
                IconButton(
                  onPressed: widget.onMoveDown,
                  icon: const Icon(Icons.arrow_downward),
                ),
                if (widget.canRemove)
                  IconButton(
                    onPressed: widget.onRemove,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: d.requiredPermission,
                    decoration: const InputDecoration(
                      labelText: 'Required permission',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 100,
                  child: TextField(
                    controller: d.minimumApprovals,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min. approvals',
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 130,
                  child: TextField(
                    controller: d.escalationTimeoutMinutes,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Escalate after (min)',
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
            Wrap(
              spacing: 12,
              children: [
                FilterChip(
                  label: const Text('Parallel'),
                  selected: d.parallel,
                  onSelected: (v) => setState(() => d.parallel = v),
                ),
                FilterChip(
                  label: const Text('Allow return'),
                  selected: d.allowReturn,
                  onSelected: (v) => setState(() => d.allowReturn = v),
                ),
                FilterChip(
                  label: const Text('Allow reject'),
                  selected: d.allowReject,
                  onSelected: (v) => setState(() => d.allowReject = v),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

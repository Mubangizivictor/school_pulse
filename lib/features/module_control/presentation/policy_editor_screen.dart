import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/module_control_repository.dart';
import '../domain/institution_policy.dart';
import '../domain/policy_field_schema.dart';
import 'policy_center_screen.dart';

/// Generic editor for any [InstitutionPolicyType]. Fields come from
/// [PolicyFieldSchema] so a new policy type only needs a schema entry, not a
/// bespoke screen. Every save creates a new version (draft, scheduled, or
/// immediately active) — history is append-only and rollback creates a new
/// version rather than mutating the past.
class PolicyEditorScreen extends StatefulWidget {
  final InstitutionPolicyType policyType;
  final String schoolId, actorId;
  const PolicyEditorScreen({
    super.key,
    required this.policyType,
    required this.schoolId,
    required this.actorId,
  });

  @override
  State<PolicyEditorScreen> createState() => _PolicyEditorScreenState();
}

class _PolicyEditorScreenState extends State<PolicyEditorScreen> {
  final _repository = ModuleControlRepository();
  late Map<String, dynamic> _draft;
  DateTime? _scheduledFor;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = Map<String, dynamic>.from(
      PolicyFieldSchema.defaults(widget.policyType),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fields = PolicyFieldSchema.forType(widget.policyType);
    return Scaffold(
      appBar: AppBar(
        title: Text(policyTypeLabel(widget.policyType)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'History',
            onPressed: () => _showHistory(context),
          ),
        ],
      ),
      body: StreamBuilder<List<InstitutionPolicy>>(
        stream: _repository.watchPolicies(widget.schoolId),
        builder: (context, snapshot) {
          final existing =
              (snapshot.data ?? const <InstitutionPolicy>[])
                  .where(
                    (p) =>
                        p.type == widget.policyType &&
                        p.scope.type == PolicyScopeType.institution,
                  )
                  .toList()
                ..sort((a, b) => b.version.compareTo(a.version));
          final current = existing.isEmpty ? null : existing.first;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (current != null)
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          current.status == PolicyStatus.active
                              ? Icons.check_circle
                              : Icons.schedule,
                          color: current.status == PolicyStatus.active
                              ? Colors.black
                              : Colors.black,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current: v${current.version} · ${current.status.name}'
                            '${current.status == PolicyStatus.scheduled ? ' from ${current.effectiveFrom.toLocal()}' : ''}',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              ...fields.map((field) => _buildField(field)),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('Schedule activation'),
                subtitle: Text(
                  _scheduledFor == null
                      ? 'Applies immediately on save'
                      : 'Activates ${_scheduledFor!.toLocal()}',
                ),
                trailing: TextButton(
                  onPressed: _pickScheduleDate,
                  child: Text(_scheduledFor == null ? 'Schedule' : 'Change'),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Saving…' : 'Save & activate policy'),
                onPressed: _saving
                    ? null
                    : () => _confirmAndSave(context, existing),
              ),
              if (current != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  icon: const Icon(Icons.undo),
                  label: const Text('Roll back to previous version'),
                  onPressed: existing.length < 2
                      ? null
                      : () => _rollback(context, existing),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildField(PolicyFieldSpec field) {
    final value = _draft[field.key] ?? field.defaultValue;
    switch (field.kind) {
      case PolicyFieldKind.boolean:
        return SwitchListTile(
          title: Text(field.label),
          subtitle: field.helperText == null ? null : Text(field.helperText!),
          value: value == true,
          onChanged: (v) => setState(() => _draft[field.key] = v),
        );
      case PolicyFieldKind.number:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextFormField(
            initialValue: '$value',
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (v) =>
                _draft[field.key] = int.tryParse(v) ?? _draft[field.key],
          ),
        );
      case PolicyFieldKind.text:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: TextFormField(
            initialValue: '$value',
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) => _draft[field.key] = v,
          ),
        );
      case PolicyFieldKind.singleChoice:
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: DropdownButtonFormField<String>(
            initialValue: '$value',
            decoration: InputDecoration(
              labelText: field.label,
              border: const OutlineInputBorder(),
            ),
            items: field.options
                .map(
                  (o) => DropdownMenuItem(value: o.value, child: Text(o.label)),
                )
                .toList(),
            onChanged: (v) => setState(() => _draft[field.key] = v),
          ),
        );
    }
  }

  Future<void> _pickScheduleDate() async {
    final date = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: DateTime.now().add(const Duration(days: 1)),
    );
    if (date != null) setState(() => _scheduledFor = date);
  }

  Future<void> _confirmAndSave(
    BuildContext context,
    List<InstitutionPolicy> existing,
  ) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          _scheduledFor == null
              ? 'Activate ${policyTypeLabel(widget.policyType)} policy?'
              : 'Schedule ${policyTypeLabel(widget.policyType)} policy?',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This applies institution-wide unless a more specific '
              'campus/division policy overrides it. All current staff, '
              'parent and student sessions will read the new value on '
              'next refresh — no logout required.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Reason (required)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) Navigator.pop(dialogContext, reason);
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
    if (reason == null || !mounted) return;
    setState(() => _saving = true);
    final current = existing.isEmpty ? null : existing.first;
    final now = DateTime.now();
    final policy = InstitutionPolicy(
      id: current?.id ?? const Uuid().v4(),
      institutionId: widget.schoolId,
      name: '${policyTypeLabel(widget.policyType)} Policy',
      createdBy: current?.createdBy ?? widget.actorId,
      updatedBy: widget.actorId,
      changeReason: reason,
      type: widget.policyType,
      scope: const PolicyScope(),
      configuration: _draft,
      status: _scheduledFor == null
          ? PolicyStatus.active
          : PolicyStatus.scheduled,
      version: current?.version ?? 0,
      effectiveFrom: _scheduledFor ?? now,
      createdAt: current?.createdAt ?? now,
      updatedAt: now,
    );
    try {
      await _repository.savePolicy(policy, previousVersion: current);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _scheduledFor == null
                  ? 'Policy activated.'
                  : 'Policy scheduled for ${_scheduledFor!.toLocal()}.',
            ),
          ),
        );
        setState(() => _scheduledFor = null);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _rollback(
    BuildContext context,
    List<InstitutionPolicy> existing,
  ) async {
    final previous = existing[1];
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Roll back to previous version?'),
        content: Text(
          'This creates a new version (v${existing.first.version + 1}) '
          'restoring the configuration from v${previous.version}. History '
          'is preserved, not overwritten.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Roll back'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final now = DateTime.now();
    final current = existing.first;
    await _repository.savePolicy(
      InstitutionPolicy(
        id: current.id,
        institutionId: widget.schoolId,
        name: current.name,
        createdBy: current.createdBy,
        updatedBy: widget.actorId,
        changeReason: 'Rollback to v${previous.version}',
        type: widget.policyType,
        scope: current.scope,
        configuration: previous.configuration,
        status: PolicyStatus.active,
        version: current.version,
        effectiveFrom: now,
        createdAt: current.createdAt,
        updatedAt: now,
      ),
      previousVersion: current,
    );
    if (mounted) {
      setState(
        () => _draft = Map<String, dynamic>.from(previous.configuration),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rolled back.')));
    }
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (context, controller) => StreamBuilder<List<InstitutionPolicy>>(
          stream: _repository.watchPolicies(widget.schoolId),
          builder: (context, snapshot) {
            final versions =
                (snapshot.data ?? const <InstitutionPolicy>[])
                    .where((p) => p.type == widget.policyType)
                    .toList()
                  ..sort((a, b) => b.version.compareTo(a.version));
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Change history',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                ...versions.map(
                  (p) => ListTile(
                    leading: CircleAvatar(child: Text('v${p.version}')),
                    title: Text('${p.status.name} · ${p.scope.type.name}'),
                    subtitle: Text(
                      '${p.changeReason}\nby ${p.updatedBy} · ${p.updatedAt.toLocal()}',
                    ),
                    isThreeLine: true,
                  ),
                ),
                if (versions.isEmpty) const Text('No changes recorded yet.'),
              ],
            );
          },
        ),
      ),
    );
  }
}

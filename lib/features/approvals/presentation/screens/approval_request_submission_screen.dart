import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../data/repositories/approval_repository.dart';
import '../../domain/entities/approval_models.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';

/// Generic submission form any source module can push a staff member to
/// (deep-link or embed) to raise an [ApprovalRequest] against an active
/// [ApprovalPolicy]. Source modules that already know their moduleKey,
/// requestType, sourceRecordId etc. can skip this screen entirely and call
/// [ApprovalRepository.submit] directly - this exists for the case where a
/// person, not code, is initiating the request (e.g. a one-off exception).
class ApprovalRequestSubmissionScreen extends StatefulWidget {
  /// Pre-fills and locks the module/request-type/source-record fields when
  /// launched from a specific source-module context.
  final String? moduleKey;
  final String? requestType;
  final String? sourceRecordType;
  final String? sourceRecordId;
  final String? sourceRecordVersion;
  final String? sourceRoute;
  final String? suggestedTitle;

  const ApprovalRequestSubmissionScreen({
    super.key,
    this.moduleKey,
    this.requestType,
    this.sourceRecordType,
    this.sourceRecordId,
    this.sourceRecordVersion,
    this.sourceRoute,
    this.suggestedTitle,
  });

  @override
  State<ApprovalRequestSubmissionScreen> createState() =>
      _ApprovalRequestSubmissionScreenState();
}

class _ApprovalRequestSubmissionScreenState
    extends State<ApprovalRequestSubmissionScreen> {
  final _repository = ApprovalRepository();
  late final _title = TextEditingController(text: widget.suggestedTitle);
  final _summary = TextEditingController();
  final _reason = TextEditingController();
  final _amount = TextEditingController();
  late final _moduleKey = TextEditingController(text: widget.moduleKey);
  late final _requestType = TextEditingController(text: widget.requestType);
  late final _sourceRecordType = TextEditingController(
    text: widget.sourceRecordType,
  );
  late final _sourceRecordId = TextEditingController(
    text: widget.sourceRecordId,
  );
  ApprovalPriority _priority = ApprovalPriority.normal;
  ApprovalSensitivity _sensitivity = ApprovalSensitivity.normal;
  ApprovalPolicy? _selectedPolicy;
  bool _submitting = false;

  bool get _locked => widget.moduleKey != null && widget.requestType != null;

  Future<void> _submit(String schoolId) async {
    if (_title.text.trim().isEmpty ||
        _moduleKey.text.trim().isEmpty ||
        _requestType.text.trim().isEmpty ||
        _sourceRecordType.text.trim().isEmpty ||
        _sourceRecordId.text.trim().isEmpty ||
        _selectedPolicy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Title, module, request type, source record and policy are required.',
          ),
        ),
      );
      return;
    }
    setState(() => _submitting = true);
    try {
      await _repository.submit(
        schoolId: schoolId,
        moduleKey: _moduleKey.text.trim(),
        requestType: _requestType.text.trim(),
        sourceRecordType: _sourceRecordType.text.trim(),
        sourceRecordId: _sourceRecordId.text.trim(),
        title: _title.text.trim(),
        summary: _summary.text.trim(),
        reason: _reason.text.trim().isEmpty ? null : _reason.text.trim(),
        approvalPolicyId: _selectedPolicy!.approvalPolicyId,
        sourceRecordVersion: widget.sourceRecordVersion ?? '1',
        sourceRoute: widget.sourceRoute ?? '',
        priority: _priority,
        sensitivity: _sensitivity,
        amount: double.tryParse(_amount.text.trim()),
      );
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Approval request submitted.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not submit request: $e')));
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Sign in to submit an approval request.')),
      );
    }
    final schoolId = auth.user.schoolId;
    return Scaffold(
      appBar: AppBar(title: const Text('Submit approval request')),
      body: StreamBuilder<List<ApprovalPolicy>>(
        stream: _repository.watchPolicies(schoolId),
        builder: (context, snapshot) {
          final allPolicies = snapshot.data ?? const <ApprovalPolicy>[];
          final activePolicies = allPolicies
              .where((p) => p.status != 'archived')
              .where(
                (p) =>
                    !_locked ||
                    (p.moduleKey == widget.moduleKey &&
                        p.requestType == widget.requestType),
              )
              .toList();
          if (_selectedPolicy != null &&
              !activePolicies.any(
                (p) => p.approvalPolicyId == _selectedPolicy!.approvalPolicyId,
              )) {
            _selectedPolicy = null;
          }
          _selectedPolicy ??= activePolicies.isEmpty
              ? null
              : activePolicies.first;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const SectionHeader(title: 'Request Details'),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _title,
                      decoration: const InputDecoration(labelText: 'Title'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _summary,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Summary'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _reason,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Reason (optional)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amount,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Amount (optional)',
                      ),
                    ),
                  ],
                ),
              ),
              if (!_locked) ...[
                const SizedBox(height: 20),
                const SectionHeader(title: 'Source Record'),
                const SizedBox(height: 4),
                Text(
                  'Identifies which record and workflow this request applies to. '
                  'Requests raised from another screen fill these in automatically.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                const SizedBox(height: 8),
                AppCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: _moduleKey,
                        decoration: const InputDecoration(
                          labelText: 'Module key',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _requestType,
                        decoration: const InputDecoration(
                          labelText: 'Request type',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _sourceRecordType,
                        decoration: const InputDecoration(
                          labelText: 'Source record type',
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _sourceRecordId,
                        decoration: const InputDecoration(
                          labelText: 'Source record ID',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const SectionHeader(title: 'Routing'),
              const SizedBox(height: 8),
              AppCard(
                child: Column(
                  children: [
                    DropdownButtonFormField<ApprovalPriority>(
                      initialValue: _priority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: ApprovalPriority.values
                          .map(
                            (p) =>
                                DropdownMenuItem(value: p, child: Text(p.name)),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => _priority = v ?? ApprovalPriority.normal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<ApprovalSensitivity>(
                      initialValue: _sensitivity,
                      decoration: const InputDecoration(
                        labelText: 'Sensitivity',
                      ),
                      items: ApprovalSensitivity.values
                          .map(
                            (s) =>
                                DropdownMenuItem(value: s, child: Text(s.name)),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => _sensitivity = v ?? ApprovalSensitivity.normal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (activePolicies.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Theme.of(context).hintColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'No active approval policy exists for this module/request type yet. '
                                'An approvals admin must create one before this can be submitted.',
                                style: TextStyle(
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      DropdownButtonFormField<ApprovalPolicy>(
                        initialValue: _selectedPolicy,
                        decoration: const InputDecoration(
                          labelText: 'Approval policy',
                        ),
                        items: activePolicies
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  '${p.name} (${p.moduleKey}/${p.requestType})',
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => _selectedPolicy = v),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _submitting || activePolicies.isEmpty
                    ? null
                    : () => _submit(schoolId),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit for approval'),
              ),
            ],
          );
        },
      ),
    );
  }
}

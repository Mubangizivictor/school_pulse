import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/features/approvals/data/repositories/approval_repository.dart';
import 'package:school_pulse/features/approvals/domain/entities/approval_models.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/presentation/screens/bursar_approvals_screen.dart'
    show
        approvalIsActionable,
        approvalIsHighRisk,
        approvalIsOpen,
        approvalTypeLabel,
        decideApproval,
        isFinanceApproval;
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_web_kit.dart';

/// Approvals — desktop split-pane over the finance slice of
/// `approval_requests`. Pending / History queue table on the left, the
/// selected request's inspector (route, evidence docs, actions) on the
/// right. Shares the exact decision surface + actionability rule with the
/// mobile Approvals tab (`decideApproval`, `approvalIsActionable`).
class BursarWebApprovalsScreen extends StatefulWidget {
  const BursarWebApprovalsScreen({super.key});

  @override
  State<BursarWebApprovalsScreen> createState() =>
      _BursarWebApprovalsScreenState();
}

class _BursarWebApprovalsScreenState extends State<BursarWebApprovalsScreen> {
  final _repository = ApprovalRepository();
  int _tab = 0; // 0 pending, 1 history
  String? _selectedId;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final uid = auth.user.id;
    final schoolId = auth.user.schoolId;

    return StreamBuilder<List<ApprovalRequest>>(
      stream: _repository.watchInbox(schoolId),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return FinanceStates.error(
            context,
            'Could not sync approvals.',
            onRetry: () => setState(() {}),
          );
        }
        final ready = snapshot.hasData;
        final all = (snapshot.data ?? const <ApprovalRequest>[])
            .where(isFinanceApproval)
            .toList();
        final pending = all.where((r) => approvalIsActionable(r, uid)).toList();
        final history = all
            .where(
              (r) =>
                  !approvalIsOpen(r) &&
                  (r.requestedBy == uid || r.requiredApprovers.contains(uid)),
            )
            .toList();
        final rows = _tab == 0 ? pending : history;
        final selected = all
            .where((r) => r.approvalRequestId == _selectedId)
            .firstOrNull;

        return FinanceWorkspace(
          title: 'Approvals',
          updatedLabel: '${pending.length} pending',
          padding: const EdgeInsets.fromLTRB(32, 24, 0, 0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 180,
            child: FinanceSplitPane(
              detailWidth: 440,
              detail: selected == null
                  ? null
                  : _Inspector(
                      key: ValueKey(selected.approvalRequestId),
                      request: selected,
                      actionable:
                          _tab == 0 && approvalIsActionable(selected, uid),
                      onDecision: (d) => decideApproval(
                        context,
                        _repository,
                        schoolId,
                        selected,
                        d,
                      ),
                      onClose: () => setState(() => _selectedId = null),
                    ),
              list: Padding(
                padding: const EdgeInsets.only(right: 24, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<int>(
                      showSelectedIcon: false,
                      segments: [
                        ButtonSegment(
                          value: 0,
                          label: Text('Pending (${pending.length})'),
                        ),
                        const ButtonSegment(value: 1, label: Text('History')),
                      ],
                      selected: {_tab},
                      onSelectionChanged: (s) => setState(() {
                        _tab = s.first;
                        _selectedId = null;
                      }),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceElevated(context),
                          borderRadius: AppRadius.large,
                          border: Border.all(color: AppColors.border(context)),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: !ready
                            ? FinanceStates.loading()
                            : SingleChildScrollView(
                                padding: const EdgeInsets.all(16),
                                child: FinanceDataTable<ApprovalRequest>(
                                  rows: rows,
                                  total: rows.length,
                                  emptyMessage: _tab == 0
                                      ? 'Nothing awaiting your approval.'
                                      : 'No approval history yet.',
                                  isSelected: (r) =>
                                      r.approvalRequestId == _selectedId,
                                  onRowTap: (r) => setState(
                                    () => _selectedId = r.approvalRequestId,
                                  ),
                                  columns: [
                                    FinanceColumn.text(
                                      'Date',
                                      (r) =>
                                          DateFormatter.format(r.submittedAt),
                                      flex: 2,
                                    ),
                                    FinanceColumn.text(
                                      'Title',
                                      (r) => r.title,
                                      flex: 4,
                                      bold: true,
                                    ),
                                    FinanceColumn.text(
                                      'Type',
                                      (r) => approvalTypeLabel(r.requestType),
                                      flex: 2,
                                    ),
                                    FinanceColumn(
                                      label: 'Amount (UGX)',
                                      flex: 2,
                                      align: TextAlign.right,
                                      cell: (r) => Text(
                                        r.amount == null
                                            ? '—'
                                            : CurrencyFormatter.ugx(r.amount!),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary(context),
                                        ),
                                      ),
                                    ),
                                    FinanceColumn(
                                      label: 'Status',
                                      flex: 2,
                                      cell: (r) =>
                                          approvalIsHighRisk(r) &&
                                              approvalIsOpen(r)
                                          ? const FinanceStatusChip(
                                              label: 'High risk',
                                              tone: FinanceStatusTone.negative,
                                            )
                                          : FinanceStatusChip.forStatus(
                                              r.currentStatus.name,
                                            ),
                                    ),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Inspector extends StatelessWidget {
  final ApprovalRequest request;
  final bool actionable;
  final void Function(ApprovalDecision) onDecision;
  final VoidCallback onClose;

  const _Inspector({
    super.key,
    required this.request,
    required this.actionable,
    required this.onDecision,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final r = request;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  r.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary(context),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              children: [
                KeyValueRow('Reference', r.approvalRequestId),
                KeyValueRow('Type', approvalTypeLabel(r.requestType)),
                KeyValueRow('Requested by', r.requesterRole),
                KeyValueRow('Submitted', DateFormatter.format(r.submittedAt)),
                if (r.amount != null)
                  KeyValueRow(
                    'Amount',
                    CurrencyFormatter.ugx(r.amount!),
                    bold: true,
                  ),
                KeyValueRow('Current step', r.currentStage),
                KeyValueRow('Status', r.currentStatus.name),
                if (r.summary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    r.summary,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                ],
                if (r.reason != null && r.reason!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  KeyValueRow('Reason', r.reason!),
                ],
                if (r.attachments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Evidence documents (${r.attachments.length})',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary(context),
                    ),
                  ),
                  const SizedBox(height: 6),
                  for (final a in r.attachments)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 15,
                            color: AppColors.textMuted(context),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              a.split('/').last,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          if (actionable) ...[
            const Divider(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger(context),
                      side: BorderSide(color: AppColors.danger(context)),
                    ),
                    onPressed: () => onDecision(ApprovalDecision.rejected),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onDecision(ApprovalDecision.returned),
                    child: const Text('Return'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: AppColors.background(context),
                    ),
                    onPressed: () => onDecision(ApprovalDecision.approved),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/approvals/data/repositories/approval_repository.dart';
import 'package:school_pulse/features/approvals/domain/entities/approval_models.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Finance's projection of the one institution-wide approval workflow
/// (`schools/{id}/approval_requests`). The server assigns every current-stage
/// approver; this screen never infers approval authority from a client role
/// alone. Both the mobile tab and the desktop console
/// (`BursarWebApprovalsScreen`) use the shared helpers below so the decision
/// surface, actionability rule and "reason required" behaviour are identical
/// everywhere.

/// Finance-relevant `moduleKey` / `requestType` values for the inbox filter.
bool isFinanceApproval(ApprovalRequest r) {
  final m = r.moduleKey.toLowerCase();
  final t = r.requestType.toLowerCase();
  return m == 'finance' ||
      m == 'expenditure' ||
      t.contains('payment') ||
      t.contains('expenditure') ||
      t.contains('requisition') ||
      t.contains('refund') ||
      t.contains('journal');
}

const _openStatuses = {
  ApprovalStatus.pending,
  ApprovalStatus.partiallyApproved,
  ApprovalStatus.inReview,
  ApprovalStatus.awaitingInformation,
};

bool approvalIsOpen(ApprovalRequest r) =>
    _openStatuses.contains(r.currentStatus);

/// A request the signed-in user can act on right now: open, they are a
/// current-stage approver, and it has not passed its due date.
bool approvalIsActionable(ApprovalRequest r, String uid) =>
    approvalIsOpen(r) &&
    r.requiredApprovers.contains(uid) &&
    r.dueAt?.isBefore(DateTime.now()) != true;

/// Whether [r] is over the "high risk" threshold for extra scrutiny (a large
/// spend, an urgent priority, or a passed due date).
bool approvalIsHighRisk(ApprovalRequest r) =>
    (r.amount ?? 0) >= 3000000 ||
    r.priority.index >= ApprovalPriority.high.index ||
    r.dueAt?.isBefore(DateTime.now()) == true;

String approvalTypeLabel(String requestType) => requestType
    .replaceAll('_', ' ')
    .split(' ')
    .where((w) => w.isNotEmpty)
    .map((w) => w[0].toUpperCase() + w.substring(1))
    .join(' ');

/// Confirm-then-decide on [request]. Shared by mobile + desktop. Rejecting
/// and returning both require a reason; the callable enforces version
/// concurrency (`expectedVersion`).
Future<void> decideApproval(
  BuildContext context,
  ApprovalRepository repository,
  String schoolId,
  ApprovalRequest request,
  ApprovalDecision decision,
) async {
  final requireReason =
      decision == ApprovalDecision.rejected ||
      decision == ApprovalDecision.returned;
  final controller = TextEditingController();
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(switch (decision) {
        ApprovalDecision.approved => 'Approve request',
        ApprovalDecision.rejected => 'Reject request',
        ApprovalDecision.returned => 'Return for changes',
        _ => 'Update request',
      }),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(request.title),
          if (request.amount != null) ...[
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.ugx(request.amount!),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: requireReason ? 'Reason' : 'Comment (optional)',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Confirm'),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return;
  final reason = controller.text.trim();
  if (requireReason && reason.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('A reason is required to reject or return a request.'),
      ),
    );
    return;
  }
  final messenger = ScaffoldMessenger.of(context);
  try {
    await repository.decide(
      schoolId: schoolId,
      requestId: request.approvalRequestId,
      decision: decision,
      comment: reason,
      expectedVersion: request.version,
    );
    messenger.showSnackBar(const SnackBar(content: Text('Decision recorded.')));
  } catch (_) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text(
          'This approval changed or could not be saved. Refresh and try again.',
        ),
      ),
    );
  }
}

/// Approvals tab (mobile bottom-nav slot 2). Pending / History over the
/// finance slice of `approval_requests`.
class BursarApprovalsScreen extends StatefulWidget {
  const BursarApprovalsScreen({super.key});

  @override
  State<BursarApprovalsScreen> createState() => _BursarApprovalsScreenState();
}

class _BursarApprovalsScreenState extends State<BursarApprovalsScreen>
    with SingleTickerProviderStateMixin {
  final _repository = ApprovalRepository();
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final uid = auth.user.id;

    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: AppColors.background(context),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: AppSpacing.l,
        title: Text(
          'Approvals',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary(context),
          ),
        ),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.primary(context),
          labelColor: AppColors.textPrimary(context),
          unselectedLabelColor: AppColors.textMuted(context),
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'History'),
          ],
        ),
      ),
      body: StreamBuilder<List<ApprovalRequest>>(
        stream: _repository.watchInbox(auth.user.schoolId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return FinanceStates.error(
              context,
              'Could not sync approvals. Cached items remain available when '
              'offline.',
              onRetry: () => setState(() {}),
            );
          }
          if (!snapshot.hasData) return FinanceStates.loading();
          final all = snapshot.data!.where(isFinanceApproval).toList();
          final pending = all
              .where((r) => approvalIsActionable(r, uid))
              .toList();
          final history = all
              .where(
                (r) =>
                    !approvalIsOpen(r) &&
                    (r.requestedBy == uid || r.requiredApprovers.contains(uid)),
              )
              .toList();

          return TabBarView(
            controller: _tabs,
            children: [
              _ApprovalList(
                items: pending,
                emptyTitle: 'No approvals waiting for you',
                emptyMessage:
                    'New finance requests assigned to your current approval '
                    'step will appear here.',
                onRefresh: () => setState(() {}),
                onTap: (r) => _openSheet(r, auth.user.schoolId, true),
              ),
              _ApprovalList(
                items: history,
                emptyTitle: 'No approval history yet',
                emptyMessage:
                    'Completed, rejected, returned, cancelled and expired '
                    'actions will appear here.',
                onRefresh: () => setState(() {}),
                onTap: (r) => _openSheet(r, auth.user.schoolId, false),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openSheet(
    ApprovalRequest request,
    String schoolId,
    bool actionable,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surfaceElevated(context),
    builder: (context) => _ApprovalDetailSheet(
      repository: _repository,
      schoolId: schoolId,
      request: request,
      actionable: actionable,
    ),
  );
}

class _ApprovalList extends StatelessWidget {
  final List<ApprovalRequest> items;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback onRefresh;
  final ValueChanged<ApprovalRequest> onTap;

  const _ApprovalList({
    required this.items,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRefresh,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return FinanceStates.empty(
        context,
        icon: Icons.verified_outlined,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.l),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.m),
        itemBuilder: (_, i) =>
            _ApprovalCard(request: items[i], onTap: () => onTap(items[i])),
      ),
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final ApprovalRequest request;
  final VoidCallback onTap;

  const _ApprovalCard({required this.request, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final highRisk = approvalIsHighRisk(request);
    return FinanceCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${approvalTypeLabel(request.requestType)} • '
                  '${DateFormatter.format(request.submittedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
              if (highRisk)
                const FinanceStatusChip(
                  label: 'High risk',
                  tone: FinanceStatusTone.negative,
                )
              else
                FinanceStatusChip.forStatus(request.currentStatus.name),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            request.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          if (request.summary.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              request.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          Row(
            children: [
              Text(
                request.amount == null
                    ? 'Amount not applicable'
                    : CurrencyFormatter.ugx(request.amount!),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary(context),
                ),
              ),
              const Spacer(),
              Text(
                'Step: ${request.currentStage}',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApprovalDetailSheet extends StatefulWidget {
  final ApprovalRepository repository;
  final String schoolId;
  final ApprovalRequest request;
  final bool actionable;

  const _ApprovalDetailSheet({
    required this.repository,
    required this.schoolId,
    required this.request,
    required this.actionable,
  });

  @override
  State<_ApprovalDetailSheet> createState() => _ApprovalDetailSheetState();
}

class _ApprovalDetailSheetState extends State<_ApprovalDetailSheet> {
  bool _working = false;

  Future<void> _decide(ApprovalDecision decision) async {
    setState(() => _working = true);
    await decideApproval(
      context,
      widget.repository,
      widget.schoolId,
      widget.request,
      decision,
    );
    if (mounted) {
      setState(() => _working = false);
      Navigator.of(context).maybePop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.request;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.l,
        AppSpacing.l,
        AppSpacing.l,
        MediaQuery.of(context).viewInsets.bottom + AppSpacing.l,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            r.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary(context),
            ),
          ),
          const SizedBox(height: AppSpacing.m),
          KeyValueRow('Reference', r.approvalRequestId),
          KeyValueRow('Type', approvalTypeLabel(r.requestType)),
          KeyValueRow('Requested by', r.requesterRole),
          KeyValueRow('Submitted', DateFormatter.format(r.submittedAt)),
          if (r.amount != null)
            KeyValueRow('Amount', CurrencyFormatter.ugx(r.amount!), bold: true),
          KeyValueRow('Current step', r.currentStage),
          if (r.reason != null && r.reason!.isNotEmpty)
            KeyValueRow('Reason', r.reason!),
          if (r.attachments.isNotEmpty)
            KeyValueRow('Attachments', '${r.attachments.length} file(s)'),
          if (widget.actionable) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger(context),
                      side: BorderSide(color: AppColors.danger(context)),
                    ),
                    onPressed: _working
                        ? null
                        : () => _decide(ApprovalDecision.rejected),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _working
                        ? null
                        : () => _decide(ApprovalDecision.returned),
                    child: const Text('Return'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: AppColors.background(context),
                    ),
                    onPressed: _working
                        ? null
                        : () => _decide(ApprovalDecision.approved),
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

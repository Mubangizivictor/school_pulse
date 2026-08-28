import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/core/utils.dart'
    show CurrencyFormatter, DateFormatter;
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/finance/domain/entities/expenditure.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_event.dart';
import 'package:school_pulse/features/finance/presentation/bloc/finance_state.dart';
import 'package:school_pulse/features/finance/presentation/widgets/finance_kit.dart';

/// Roles allowed to approve/reject/return an expenditure request. Mirrors
/// the existing [ExpenditureScreen] approver set and firestore.rules'
/// intent: bursars *prepare* spend; these roles *decide* on it.
const _approverRoles = {
  UserRole.schoolAdmin,
  UserRole.headTeacher,
  UserRole.director,
  UserRole.bursar,
};

/// Approvals tab (bottom-nav slot 2). Pending / History over
/// `schools/{schoolId}/expenditures`, driven by [FinanceBloc]. Matches the
/// reference "Approvals" screenshot: a Pending(N) / History segmented
/// header, request cards with amount + requester + high-risk badge, and
/// Reject / Approve inline actions.
class BursarApprovalsScreen extends StatefulWidget {
  const BursarApprovalsScreen({super.key});

  @override
  State<BursarApprovalsScreen> createState() => _BursarApprovalsScreenState();
}

class _BursarApprovalsScreenState extends State<BursarApprovalsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  void _load() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthAuthenticated) {
      context.read<FinanceBloc>().add(
        LoadExpenditureRequests(auth.user.schoolId),
      );
    }
  }

  bool get _canApprove {
    final auth = context.read<AuthBloc>().state;
    return auth is AuthAuthenticated &&
        auth.user.roles.any(_approverRoles.contains);
  }

  @override
  Widget build(BuildContext context) {
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
      body: SafeArea(
        top: false,
        child: BlocConsumer<FinanceBloc, FinanceState>(
          listener: (context, state) {
            if (state is FinanceActionSuccess) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
              _load();
            }
          },
          builder: (context, state) {
            if (state is FinanceLoading || state is FinanceInitial) {
              return FinanceStates.loading();
            }
            if (state is FinanceError) {
              return FinanceStates.error(
                context,
                state.message,
                onRetry: _load,
              );
            }
            if (state is! ExpendituresLoaded) return const SizedBox.shrink();

            final pending = state.requests
                .where((r) => r.status == ExpenditureStatus.pending)
                .toList();
            final history = state.requests
                .where((r) => r.status != ExpenditureStatus.pending)
                .toList();

            return TabBarView(
              controller: _tabs,
              children: [
                _RequestList(
                  requests: pending,
                  emptyTitle: 'Nothing awaiting approval',
                  emptyMessage:
                      'New payment and requisition requests land here.',
                  onRefresh: _load,
                  canApprove: _canApprove,
                  onDecision: _decide,
                ),
                _RequestList(
                  requests: history,
                  emptyTitle: 'No decisions yet',
                  emptyMessage:
                      'Approved, rejected and released requests appear here.',
                  onRefresh: _load,
                  canApprove: false,
                  onDecision: _decide,
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _decide(
    ExpenditureRequest request,
    ExpenditureStatus decision,
  ) async {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || !_canApprove) return;

    final commentController = TextEditingController();
    final requireComment = decision != ExpenditureStatus.approved;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          decision == ExpenditureStatus.approved
              ? 'Approve request'
              : decision == ExpenditureStatus.rejected
              ? 'Reject request'
              : 'Request changes',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(request.description),
            const SizedBox(height: 4),
            Text(
              CurrencyFormatter.ugx(request.amount),
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: commentController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: requireComment ? 'Reason' : 'Comment (optional)',
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
    if (confirmed != true || !mounted) return;
    final comment = commentController.text.trim();
    if (requireComment && comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A reason is required to reject or return a request.'),
        ),
      );
      return;
    }
    context.read<FinanceBloc>().add(
      UpdateExpenditureApproval(
        schoolId: auth.user.schoolId,
        requestId: request.id,
        status: decision,
        approverId: auth.user.id,
        approverName: auth.user.name,
        approverRole: auth.user.role.name,
        comment: comment.isEmpty ? null : comment,
      ),
    );
  }
}

class _RequestList extends StatelessWidget {
  final List<ExpenditureRequest> requests;
  final String emptyTitle;
  final String emptyMessage;
  final VoidCallback onRefresh;
  final bool canApprove;
  final void Function(ExpenditureRequest, ExpenditureStatus) onDecision;

  const _RequestList({
    required this.requests,
    required this.emptyTitle,
    required this.emptyMessage,
    required this.onRefresh,
    required this.canApprove,
    required this.onDecision,
  });

  @override
  Widget build(BuildContext context) {
    if (requests.isEmpty) {
      return FinanceStates.empty(
        context,
        icon: Icons.verified_outlined,
        title: emptyTitle,
        message: emptyMessage,
      );
    }
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.l,
          AppSpacing.x3l,
        ),
        itemCount: requests.length,
        itemBuilder: (context, i) => _RequestCard(
          request: requests[i],
          canApprove: canApprove,
          onDecision: onDecision,
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ExpenditureRequest request;
  final bool canApprove;
  final void Function(ExpenditureRequest, ExpenditureStatus) onDecision;

  const _RequestCard({
    required this.request,
    required this.canApprove,
    required this.onDecision,
  });

  /// A large spend flagged for extra scrutiny - the reference screenshot's
  /// red "High risk" chip. Threshold-based only; no server signal exists yet.
  bool get _highRisk => request.amount >= 3000000;

  @override
  Widget build(BuildContext context) {
    return FinanceCard(
      margin: const EdgeInsets.only(bottom: AppSpacing.m),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${_typeLabel(request)} • ${DateFormatter.format(request.createdAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                  ),
                ),
              ),
              if (_highRisk)
                const FinanceStatusChip(
                  label: 'High risk',
                  tone: FinanceStatusTone.negative,
                )
              else
                FinanceStatusChip.forStatus(request.status.name),
            ],
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            request.description,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary(context),
            ),
          ),
          if (request.supplierName != null) ...[
            const SizedBox(height: 2),
            Text(
              request.supplierName!,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.m),
          KeyValueRow(
            'Amount',
            CurrencyFormatter.ugx(request.amount),
            bold: true,
          ),
          KeyValueRow('Requested by', request.requesterName, dense: true),
          if (request.budgetCategoryId.isNotEmpty)
            KeyValueRow('Budget vote', request.budgetCategoryId, dense: true),
          if (request.attachmentUrls.isNotEmpty)
            KeyValueRow(
              'Attachments',
              '${request.attachmentUrls.length} file(s)',
              dense: true,
            ),
          if (request.approvalHistory.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.s),
            Text(
              'Route: ${request.approvalHistory.map((s) => s.approverRole).join(' → ')}',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
          if (canApprove && request.status == ExpenditureStatus.pending) ...[
            const SizedBox(height: AppSpacing.l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger(context),
                      side: BorderSide(color: AppColors.danger(context)),
                    ),
                    onPressed: () =>
                        onDecision(request, ExpenditureStatus.rejected),
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        onDecision(request, ExpenditureStatus.reviewed),
                    child: const Text('Changes'),
                  ),
                ),
                const SizedBox(width: AppSpacing.m),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: AppColors.background(context),
                    ),
                    onPressed: () =>
                        onDecision(request, ExpenditureStatus.approved),
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

  String _typeLabel(ExpenditureRequest r) =>
      r.supplierName != null ? 'Supplier payment' : 'Requisition';
}

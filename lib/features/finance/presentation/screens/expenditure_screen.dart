import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/core/utils.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../../domain/entities/expenditure.dart';

/// Roles allowed to approve/reject expenditure requests, mirroring
/// firestore.rules' comment on schools/{schoolId}/expenditures: update
/// (which covers approval decisions) is available to finance staff broadly,
/// but headTeacher/director act as approvers alongside bursar/schoolAdmin -
/// not the requester's own (typically lower-privilege) role.
const _approverRoles = [
  UserRole.schoolAdmin,
  UserRole.headTeacher,
  UserRole.director,
  UserRole.bursar,
];

class ExpenditureScreen extends StatefulWidget {
  const ExpenditureScreen({super.key});

  @override
  State<ExpenditureScreen> createState() => _ExpenditureScreenState();
}

class _ExpenditureScreenState extends State<ExpenditureScreen> {
  @override
  void initState() {
    super.initState();
    _loadExpenditures();
  }

  void _loadExpenditures() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<FinanceBloc>().add(
        LoadExpenditureRequests(authState.user.schoolId),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FinanceBloc, FinanceState>(
      listener: (context, state) {
        if (state is FinanceActionSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          _loadExpenditures();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Expenditure Management'),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showRequestForm(context),
            ),
          ],
        ),
        body: BlocBuilder<FinanceBloc, FinanceState>(
          builder: (context, state) {
            if (state is FinanceLoading) {
              return const Center(child: SchoolPulseLoader());
            }

            if (state is ExpendituresLoaded) {
              if (state.requests.isEmpty) {
                return const EmptyState(
                  icon: Icons.outbond_outlined,
                  title: 'No expenditure requests',
                  message: 'Requests for funds will appear here',
                );
              }

              return RefreshIndicator(
                onRefresh: () async => _loadExpenditures(),
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.requests.length,
                  itemBuilder: (context, index) {
                    final request = state.requests[index];
                    return _buildExpenditureItem(context, request);
                  },
                ),
              );
            }

            if (state is FinanceError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildExpenditureItem(
    BuildContext context,
    ExpenditureRequest request,
  ) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    Color statusColor;
    switch (request.status) {
      case ExpenditureStatus.approved:
        statusColor = semanticColors.success;
        break;
      case ExpenditureStatus.rejected:
        statusColor = semanticColors.error;
        break;
      case ExpenditureStatus.pending:
        statusColor = Colors.black;
        break;
      case ExpenditureStatus.released:
        statusColor = semanticColors.info;
        break;
      case ExpenditureStatus.reviewed:
        statusColor = Colors.black;
        break;
    }

    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      onTap: () => _showRequestDetails(context, request),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(label: request.status.name, color: statusColor),
              Text(
                CurrencyFormatter.ugx(request.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            request.description,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Requested by: ${request.requesterName}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormatter.format(request.createdAt),
                style: Theme.of(context).textTheme.labelSmall,
              ),
              if (request.status == ExpenditureStatus.pending &&
                  _canApprove(context))
                TextButton(
                  onPressed: () => _showApprovalDialog(context, request),
                  child: const Text('Action'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  bool _canApprove(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return false;
    return authState.user.roles.any(_approverRoles.contains);
  }

  void _showRequestForm(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final descController = TextEditingController();
    final amountController = TextEditingController();
    final categoryController = TextEditingController();
    final supplierController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New Expenditure Request'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextFormField(
                  controller: categoryController,
                  decoration: const InputDecoration(
                    labelText: 'Budget Category',
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount (UGX)'),
                  validator: (v) {
                    final parsed = double.tryParse(v ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter a valid amount';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: supplierController,
                  decoration: const InputDecoration(
                    labelText: 'Supplier (optional)',
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              final amount = double.tryParse(amountController.text) ?? 0;
              context.read<FinanceBloc>().add(
                SubmitExpenditureRequest(
                  ExpenditureRequest(
                    id: '',
                    schoolId: authState.user.schoolId,
                    requesterId: authState.user.id,
                    requesterName: authState.user.name,
                    description: descController.text.trim(),
                    amount: amount,
                    budgetCategoryId: categoryController.text.trim(),
                    supplierName: supplierController.text.trim().isEmpty
                        ? null
                        : supplierController.text.trim(),
                    status: ExpenditureStatus.pending,
                    createdAt: DateTime.now(),
                  ),
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  void _showRequestDetails(BuildContext context, ExpenditureRequest request) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Expenditure Request'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              _detailRow('Status', request.status.name),
              _detailRow('Amount', CurrencyFormatter.ugx(request.amount)),
              _detailRow('Category', request.budgetCategoryId),
              _detailRow('Description', request.description),
              _detailRow('Requested by', request.requesterName),
              _detailRow(
                'Requested on',
                DateFormatter.format(request.createdAt),
              ),
              if (request.supplierName != null)
                _detailRow('Supplier', request.supplierName!),
              if (request.approvalHistory.isNotEmpty) ...[
                const Divider(height: 24),
                const Text(
                  'Approval History',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...request.approvalHistory.map(
                  (step) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${step.approverName} (${step.approverRole}) - ${step.status}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        if (step.comment != null && step.comment!.isNotEmpty)
                          Text(step.comment!),
                        Text(
                          DateFormatter.format(step.updatedAt),
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          if (request.status == ExpenditureStatus.pending &&
              _canApprove(context))
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _showApprovalDialog(context, request);
              },
              child: const Text('Take Action'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }

  void _showApprovalDialog(BuildContext context, ExpenditureRequest request) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    if (!_canApprove(context)) return;

    final commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Review Expenditure Request'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(request.description),
              const SizedBox(height: 4),
              Text(
                CurrencyFormatter.ugx(request.amount),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  labelText: 'Comment (optional)',
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FinanceBloc>().add(
                UpdateExpenditureApproval(
                  schoolId: authState.user.schoolId,
                  requestId: request.id,
                  status: ExpenditureStatus.rejected,
                  approverId: authState.user.id,
                  approverName: authState.user.name,
                  approverRole: authState.user.role.name,
                  comment: commentController.text.trim().isEmpty
                      ? null
                      : commentController.text.trim(),
                ),
              );
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reject'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<FinanceBloc>().add(
                UpdateExpenditureApproval(
                  schoolId: authState.user.schoolId,
                  requestId: request.id,
                  status: ExpenditureStatus.approved,
                  approverId: authState.user.id,
                  approverName: authState.user.name,
                  approverRole: authState.user.role.name,
                  comment: commentController.text.trim().isEmpty
                      ? null
                      : commentController.text.trim(),
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }
}

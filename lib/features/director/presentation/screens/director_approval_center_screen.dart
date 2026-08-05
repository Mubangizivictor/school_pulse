import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/director/domain/entities/director_approval.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_bloc.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_event.dart';
import 'package:school_pulse/features/director/presentation/bloc/director_state.dart';

class DirectorApprovalCenterScreen extends StatelessWidget {
  const DirectorApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Center')),
      body: BlocBuilder<DirectorBloc, DirectorState>(
        builder: (context, state) {
          if (state is DirectorApprovalsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DirectorApprovalsLoaded) {
            return _buildApprovalList(context, state.approvals);
          } else if (state is DirectorApprovalsError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          // Trigger load if not loaded
          context.read<DirectorBloc>().add(DirectorApprovalsRequested());
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildApprovalList(
    BuildContext context,
    List<DirectorApproval> approvals,
  ) {
    if (approvals.isEmpty) {
      return const Center(child: Text('No pending approvals'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: approvals.length,
      itemBuilder: (context, index) {
        final approval = approvals[index];
        return _ApprovalCard(approval: approval);
      },
    );
  }
}

class _ApprovalCard extends StatelessWidget {
  final DirectorApproval approval;

  const _ApprovalCard({required this.approval});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(
                    approval.status,
                  ).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  approval.status.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(approval.status),
                  ),
                ),
              ),
              Text(
                '${approval.amount.toStringAsFixed(2)} UGX',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            approval.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Requested by ${approval.requesterName} • ${approval.department}',
            style: TextStyle(color: Theme.of(context).hintColor, fontSize: 12),
          ),
          const SizedBox(height: 12),
          Text(approval.description, style: const TextStyle(fontSize: 14)),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _showActionDialog(context, approval, 'reject'),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                  child: const Text('Reject'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      _showActionDialog(context, approval, 'clarify'),
                  child: const Text('Clarify'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () =>
                      _showActionDialog(context, approval, 'approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Approve'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return Colors.orange;
      case ApprovalStatus.approved:
        return Colors.green;
      case ApprovalStatus.rejected:
        return Colors.red;
      case ApprovalStatus.clarificationRequested:
        return Colors.blue;
    }
  }

  void _showActionDialog(
    BuildContext context,
    DirectorApproval approval,
    String action,
  ) {
    final commentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action[0].toUpperCase()}${action.substring(1)} Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to $action this request for ${approval.amount} UGX?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                hintText: 'Add a comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<DirectorBloc>().add(
                DirectorApprovalActionRequested(
                  approvalId: approval.id,
                  action: action,
                  comment: commentController.text,
                ),
              );
              Navigator.pop(context);
            },
            child: Text(action.toUpperCase()),
          ),
        ],
      ),
    );
  }
}

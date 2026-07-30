import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import '../../../domain/entities/report_card_approval.dart';

class ReportApprovalScreen extends StatelessWidget {
  const ReportApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(PendingReportApprovalsRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Report Card Approvals'),
          actions: [
            BlocBuilder<DeanBloc, DeanState>(
              builder: (context, state) {
                if (state is PendingReportApprovalsLoaded && state.approvals.isNotEmpty) {
                  return IconButton(
                    icon: const Icon(Icons.check_circle_outline),
                    onPressed: () {
                      final ids = state.approvals.map((a) => a.id).toList();
                      context.read<DeanBloc>().add(ApproveReportCardsRequested(ids));
                    },
                    tooltip: 'Approve All',
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
        body: BlocListener<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.read<DeanBloc>().add(PendingReportApprovalsRequested());
            }
          },
          child: BlocBuilder<DeanBloc, DeanState>(
            builder: (context, state) {
              if (state is DeanLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is PendingReportApprovalsLoaded) {
                if (state.approvals.isEmpty) {
                  return const Center(child: Text('No report cards pending approval.'));
                }
                return _buildReportList(context, state.approvals);
              } else if (state is DeanError) {
                return Center(child: Text(state.message));
              }
              return const Center(child: Text('Initialize approvals...'));
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReportList(BuildContext context, List<ReportCardApproval> reports) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            title: Text(report.studentName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${report.className} • Avg: ${report.averageScore.toStringAsFixed(1)}%'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => _showRejectDialog(context, report.id),
                ),
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    context.read<DeanBloc>().add(ApproveReportCardsRequested([report.id]));
                  },
                ),
              ],
            ),
            onTap: () {
              // Preview report card
            },
          ),
        );
      },
    );
  }

  void _showRejectDialog(BuildContext context, String reportId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Report Card'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason for rejection'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<DeanBloc>().add(RejectReportCardsRequested([reportId], reasonController.text));
              Navigator.pop(dialogContext);
            },
            child: const Text('Reject', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

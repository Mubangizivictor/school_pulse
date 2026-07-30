import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/dean/domain/entities/report_card_approval.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

class HeadTeacherApprovalScreen extends StatefulWidget {
  const HeadTeacherApprovalScreen({super.key});

  @override
  State<HeadTeacherApprovalScreen> createState() => _HeadTeacherApprovalScreenState();
}

class _HeadTeacherApprovalScreenState extends State<HeadTeacherApprovalScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(PendingReportApprovalsRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Final Report Approvals'),
        ),
        body: BlocListener<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              context.read<DeanBloc>().add(PendingReportApprovalsRequested());
            } else if (state is DeanError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: _buildReportList(),
        ),
      ),
    );
  }

  Widget _buildReportList() {
    return BlocBuilder<DeanBloc, DeanState>(
      builder: (context, state) {
        if (state is DeanLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is PendingReportApprovalsLoaded) {
          if (state.approvals.isEmpty) {
            return const Center(child: Text('No reports awaiting final signature'));
          }
          return ListView.builder(
            itemCount: state.approvals.length,
            itemBuilder: (context, index) {
              final report = state.approvals[index];
              return _HeadTeacherReportCardTile(report: report);
            },
          );
        }
        return const Center(child: Text('Error loading reports'));
      },
    );
  }
}

class _HeadTeacherReportCardTile extends StatelessWidget {
  final ReportCardApproval report;

  const _HeadTeacherReportCardTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final canSign = !report.isApproved;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(report.studentName),
        subtitle: Text('${report.className} • Avg: ${report.averageScore.toStringAsFixed(1)}%'),
        trailing: canSign
            ? ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  context.read<DeanBloc>().add(ApproveReportCardsRequested([report.id]));
                },
                child: const Text('Final Sign'),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text('Signed', style: TextStyle(color: Colors.green, fontSize: 12)),
              ),
      ),
    );
  }
}

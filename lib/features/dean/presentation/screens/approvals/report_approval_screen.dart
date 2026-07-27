import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/academic/domain/entities/report_card.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

class ReportApprovalScreen extends StatefulWidget {
  const ReportApprovalScreen({super.key});

  @override
  State<ReportApprovalScreen> createState() => _ReportApprovalScreenState();
}

class _ReportApprovalScreenState extends State<ReportApprovalScreen> {
  String? selectedClass;
  ReportCardStatus? selectedStatus = ReportCardStatus.pending;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()
        ..add(DeanReportCardsRequested(status: selectedStatus)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Academic Report Approvals'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),
        body: BlocListener<DeanBloc, DeanState>(
          listener: (context, state) {
            if (state is DeanOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            } else if (state is DeanError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          child: Column(
            children: [
              _buildFilterChips(),
              Expanded(child: _buildReportList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Pending'),
            selected: selectedStatus == ReportCardStatus.pending,
            onSelected: (selected) {
              setState(() => selectedStatus = selected ? ReportCardStatus.pending : null);
              context.read<DeanBloc>().add(DeanReportCardsRequested(status: selectedStatus));
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Dean Signed'),
            selected: selectedStatus == ReportCardStatus.deanSigned,
            onSelected: (selected) {
              setState(() => selectedStatus = selected ? ReportCardStatus.deanSigned : null);
              context.read<DeanBloc>().add(DeanReportCardsRequested(status: selectedStatus));
            },
          ),
          const SizedBox(width: 8),
          FilterChip(
            label: const Text('Fully Signed'),
            selected: selectedStatus == ReportCardStatus.fullySigned,
            onSelected: (selected) {
              setState(() => selectedStatus = selected ? ReportCardStatus.fullySigned : null);
              context.read<DeanBloc>().add(DeanReportCardsRequested(status: selectedStatus));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReportList() {
    return BlocBuilder<DeanBloc, DeanState>(
      builder: (context, state) {
        if (state is DeanLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is DeanReportCardsLoaded) {
          if (state.reportCards.isEmpty) {
            return const Center(child: Text('No reports matching current filters'));
          }
          return ListView.builder(
            itemCount: state.reportCards.length,
            itemBuilder: (context, index) {
              final report = state.reportCards[index];
              return _ReportCardTile(report: report);
            },
          );
        }
        return const Center(child: Text('Load reports to begin'));
      },
    );
  }

  void _refresh(BuildContext context) {
    context.read<DeanBloc>().add(DeanReportCardsRequested(
      className: selectedClass,
      status: selectedStatus,
    ));
  }

  void _showFilterDialog(BuildContext context) {
    // TODO: Implement class filter dialog
  }
}

class _ReportCardTile extends StatelessWidget {
  final ReportCard report;

  const _ReportCardTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final canSign = report.status == ReportCardStatus.pending;
    final deanId = (context.read<AuthBloc>().state as AuthAuthenticated).user.id;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(report.studentName),
        subtitle: Text('${report.className} • Avg: ${report.averageScore.toStringAsFixed(1)}%'),
        trailing: canSign
            ? ElevatedButton(
                onPressed: () {
                  context.read<DeanBloc>().add(DeanSignReportCardRequested(
                        reportCardId: report.id,
                        signerId: deanId,
                      ));
                },
                child: const Text('Sign Off'),
              )
            : _buildStatusBadge(report.status),
      ),
    );
  }

  Widget _buildStatusBadge(ReportCardStatus status) {
    Color color;
    String label;
    switch (status) {
      case ReportCardStatus.pending:
        color = Colors.orange;
        label = 'Pending';
      case ReportCardStatus.deanSigned:
        color = Colors.blue;
        label = 'Dean Signed';
      case ReportCardStatus.fullySigned:
        color = Colors.green;
        label = 'Fully Signed';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/academic/domain/entities/report_card.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
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
  ReportCardStatus? selectedStatus = ReportCardStatus.deanSigned;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()
        ..add(DeanReportCardsRequested(status: selectedStatus)),
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
            label: const Text('Dean Signed (Pending Final)'),
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
            return const Center(child: Text('No reports awaiting final signature'));
          }
          return ListView.builder(
            itemCount: state.reportCards.length,
            itemBuilder: (context, index) {
              final report = state.reportCards[index];
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
  final ReportCard report;

  const _HeadTeacherReportCardTile({required this.report});

  @override
  Widget build(BuildContext context) {
    final canSign = report.status == ReportCardStatus.deanSigned;
    final headTeacherId = (context.read<AuthBloc>().state as AuthAuthenticated).user.id;

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
                  context.read<DeanBloc>().add(DeanSignReportCardRequested(
                        reportCardId: report.id,
                        signerId: headTeacherId,
                        isHeadTeacher: true,
                      ));
                },
                child: const Text('Final Sign'),
              )
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.green),
                ),
                child: const Text('Signed', style: TextStyle(color: Colors.green, fontSize: 12)),
              ),
      ),
    );
  }
}

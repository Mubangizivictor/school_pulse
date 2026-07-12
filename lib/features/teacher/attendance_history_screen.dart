import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';

class TeacherAttendanceHistoryScreen extends StatefulWidget {
  const TeacherAttendanceHistoryScreen({super.key});

  @override
  State<TeacherAttendanceHistoryScreen> createState() => _TeacherAttendanceHistoryScreenState();
}

class _TeacherAttendanceHistoryScreenState extends State<TeacherAttendanceHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(TeacherAttendanceHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TeacherError) {
            return Center(child: Text(state.message));
          }

          if (state is TeacherAttendanceHistoryLoaded) {
            if (state.history.isEmpty) {
              return const Center(child: Text('No attendance history found.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.history.length,
              itemBuilder: (context, index) {
                final record = state.history[index];
                final isSubmitted = record.status == 'Submitted';
                
                return _HistoryCard(
                  className: record.className,
                  date: record.date,
                  presentCount: record.presentCount,
                  totalCount: record.totalCount,
                  status: record.status,
                  color: isSubmitted ? semanticColors.success : semanticColors.error,
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String className;
  final DateTime date;
  final int presentCount;
  final int totalCount;
  final String status;
  final Color color;

  const _HistoryCard({
    required this.className,
    required this.date,
    required this.presentCount,
    required this.totalCount,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              status == 'Submitted' ? Icons.check_circle_outline : Icons.error_outline,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(className, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  DateFormat('EEEE, MMM d, yyyy').format(date),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                status == 'Submitted' ? '$presentCount/$totalCount' : 'MISSING',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: status == 'Submitted' ? null : color,
                ),
              ),
              Text(
                status,
                style: TextStyle(fontSize: 12, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

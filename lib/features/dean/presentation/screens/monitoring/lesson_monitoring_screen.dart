import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/features/dean/domain/entities/lesson_tracking.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:intl/intl.dart';

class LessonMonitoringScreen extends StatelessWidget {
  const LessonMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(const LessonRecordsRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lesson Monitoring'),
          actions: [
            IconButton(
              icon: const Icon(Icons.filter_list),
              onPressed: () => _showFilterDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is LessonRecordsLoaded) {
              if (state.records.isEmpty) {
                return const Center(child: Text('No lesson records found.'));
              }
              return _buildLessonList(state.records);
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initialize monitoring...'));
          },
        ),
      ),
    );
  }

  Widget _buildLessonList(List<LessonRecord> records) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        return AppCard(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: _getStatusIcon(record.status),
            title: Text(
              '${record.subjectName} - ${record.className}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Teacher: ${record.teacherName}'),
                Text(
                  'Date: ${DateFormat('MMM dd, yyyy HH:mm').format(record.scheduledAt)}',
                ),
                if (record.topicCovered != null)
                  Text(
                    'Topic: ${record.topicCovered}',
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
              ],
            ),
            trailing: _getStatusChip(record.status),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  Widget _getStatusIcon(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return const Icon(Icons.check_circle, color: Colors.green);
      case LessonStatus.missed:
        return const Icon(Icons.error, color: Colors.red);
      case LessonStatus.planned:
        return const Icon(Icons.schedule, color: Colors.blue);
      case LessonStatus.rescheduled:
        return const Icon(Icons.swap_horiz, color: Colors.orange);
      case LessonStatus.substituted:
        return const Icon(Icons.person_outline, color: Colors.purple);
    }
  }

  Widget _getStatusChip(LessonStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getStatusColor(status)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(status),
        ),
      ),
    );
  }

  Color _getStatusColor(LessonStatus status) {
    switch (status) {
      case LessonStatus.completed:
        return Colors.green;
      case LessonStatus.missed:
        return Colors.red;
      case LessonStatus.planned:
        return Colors.blue;
      case LessonStatus.rescheduled:
        return Colors.orange;
      case LessonStatus.substituted:
        return Colors.purple;
    }
  }

  void _showFilterDialog(BuildContext context) {
    // Placeholder for filter logic
    showModalBottomSheet(
      context: context,
      builder: (context) => const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter Lessons',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            // Add date range, teacher, class pickers here
            Text('Filtering options coming soon...'),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

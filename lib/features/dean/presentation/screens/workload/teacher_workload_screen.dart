import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';

class TeacherWorkloadScreen extends StatelessWidget {
  const TeacherWorkloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(TeacherWorkloadsRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Teacher Workload Monitoring')),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is TeacherWorkloadsLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.workloads.length,
                itemBuilder: (context, index) {
                  final workload = state.workloads[index];
                  final completionText = workload.weeklyLessonsCount > 0
                      ? '${(workload.lessonsDelivered / workload.weeklyLessonsCount * 100).toStringAsFixed(0)}%'
                      : 'N/A';

                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                workload.teacherName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Load: ${workload.weeklyLessonsCount} hrs/wk',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: workload.weeklyLessonsCount > 0
                                ? workload.lessonsDelivered /
                                      workload.weeklyLessonsCount
                                : 0,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.green,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Lesson Completion: $completionText',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Missed: ${workload.lessonsMissed}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: workload.lessonsMissed > 0
                                      ? Colors.red
                                      : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _WorkloadMetric(
                                label: 'Assessments',
                                value: '${workload.assessmentsCreated}',
                              ),
                              _WorkloadMetric(
                                label: 'Pending Marks',
                                value: '${workload.marksPending}',
                                color: Colors.orange,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return const Center(child: Text('No workload data available.'));
          },
        ),
      ),
    );
  }
}

class _WorkloadMetric extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;

  const _WorkloadMetric({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

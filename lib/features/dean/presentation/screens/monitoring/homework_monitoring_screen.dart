import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:intl/intl.dart';

class HomeworkMonitoringScreen extends StatelessWidget {
  const HomeworkMonitoringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<DeanBloc>()..add(const HomeworkRecordsRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Homework Monitoring')),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is DeanLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is HomeworkRecordsLoaded) {
              if (state.records.isEmpty) {
                return const Center(child: Text('No homework records found.'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.records.length,
                itemBuilder: (context, index) {
                  final record = state.records[index];
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      title: Text(
                        record.title,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${record.subjectName} • ${record.className}'),
                          Text('Teacher: ${record.teacherName}'),
                          Text(
                            'Due: ${DateFormat('MMM dd, yyyy').format(record.dueDate)}',
                          ),
                        ],
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${record.submissionRate.toInt()}%',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary(context),
                            ),
                          ),
                          const Text(
                            'Submissions',
                            style: TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            } else if (state is DeanError) {
              return Center(child: Text(state.message));
            }
            return const Center(child: Text('Initializing...'));
          },
        ),
      ),
    );
  }
}

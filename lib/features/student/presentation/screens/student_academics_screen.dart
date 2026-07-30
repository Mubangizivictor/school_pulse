import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/academic/presentation/bloc/academic_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';

class StudentAcademicsScreen extends StatelessWidget {
  const StudentAcademicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Academics')),
      body: BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
        builder: (context, state) {
          if (state is! SelectedStudentLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return BlocBuilder<AcademicBloc, AcademicState>(
            builder: (context, academicState) {
              if (academicState is AcademicLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (academicState is AcademicLoaded) {
                if (academicState.academicRecords.isEmpty) {
                  return const EmptyState(
                    title: 'No academic records',
                    message: 'Your results will appear here once published.',
                    icon: Icons.school_outlined,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: academicState.academicRecords.length,
                  itemBuilder: (context, index) {
                    final record = academicState.academicRecords[index];
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(record.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('${record.term} ${record.year}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${record.score.round()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(record.grade, style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }

              return const Center(child: Text('Something went wrong'));
            },
          );
        },
      ),
    );
  }
}

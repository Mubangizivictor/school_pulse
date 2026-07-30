import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/student.dart';
import '../bloc/student_homework_bloc.dart';
import '../bloc/student_homework_event.dart';
import '../bloc/student_homework_state.dart';
import '../../../../injection_container.dart';
import '../../domain/repositories/student_repository.dart';

class StudentHomeworkScreen extends StatelessWidget {
  const StudentHomeworkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final user = authState is AuthAuthenticated ? authState.user : null;
    final studentId = user?.studentId;

    if (studentId == null) {
      return const Scaffold(
        body: Center(child: Text('Student information not found.')),
      );
    }

    return FutureBuilder<Student>(
      future: sl<StudentRepository>().getStudentById(studentId).then((result) => result.getOrElse(() => throw Exception('Student not found'))),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Error loading student profile.')),
          );
        }

        final student = snapshot.data!;

        return BlocProvider(
          create: (context) => sl<StudentHomeworkBloc>()..add(LoadStudentHomework(student.classId)),
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Homework & Assignments'),
            ),
            body: BlocBuilder<StudentHomeworkBloc, StudentHomeworkState>(
              builder: (context, state) {
                if (state is StudentHomeworkLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StudentHomeworkLoaded) {
                  if (state.homeworkList.isEmpty) {
                    return const Center(
                      child: Text('No homework assigned for your class.'),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.homeworkList.length,
                    itemBuilder: (context, index) {
                      final homework = state.homeworkList[index];
                      final isPastDue = homework.dueDate.isBefore(DateTime.now());

                      return Card(
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      homework.title,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: homework.subject.toLowerCase() == 'math' 
                                          ? Colors.blue.withValues(alpha: 0.1) 
                                          : Colors.green.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      homework.subject,
                                      style: TextStyle(
                                        color: homework.subject.toLowerCase() == 'math' 
                                            ? Colors.blue 
                                            : Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(homework.description),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: isPastDue ? Colors.red : Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Due: ${DateFormat('MMM dd, yyyy').format(homework.dueDate)}',
                                        style: TextStyle(
                                          color: isPastDue ? Colors.red : Colors.grey[700],
                                          fontWeight: isPastDue ? FontWeight.bold : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (homework.attachments != null && homework.attachments!.isNotEmpty)
                                    TextButton.icon(
                                      onPressed: () {
                                        // TODO: Implement attachment download/view
                                      },
                                      icon: const Icon(Icons.attach_file),
                                      label: Text('${homework.attachments!.length} Attachments'),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                } else if (state is StudentHomeworkError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}

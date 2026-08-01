import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/app_components.dart';
import '../../../../design_system/theme/app_colors.dart';
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
            backgroundColor: AppColors.background(context),
            appBar: AppBar(
              title: const Text('Homework & Assignments'),
              backgroundColor: Colors.transparent,
            ),
            body: BlocBuilder<StudentHomeworkBloc, StudentHomeworkState>(
              builder: (context, state) {
                if (state is StudentHomeworkLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is StudentHomeworkLoaded) {
                  if (state.homeworkList.isEmpty) {
                    return EmptyState(
                      icon: Icons.assignment_outlined,
                      title: 'No Homework',
                      message: 'No homework assigned for your class.',
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.homeworkList.length,
                    itemBuilder: (context, index) {
                      final homework = state.homeworkList[index];
                      final isPastDue = homework.dueDate.isBefore(DateTime.now());

                      return AppCard(
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
                                      style: TextStyle(
                                        color: AppColors.textPrimary(context),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primarySoft(context),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      homework.subject,
                                      style: TextStyle(
                                        color: AppColors.primary(context),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                homework.description,
                                style: TextStyle(color: AppColors.textSecondary(context)),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: isPastDue ? AppColors.danger(context) : AppColors.textMuted(context),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Due: ${DateFormat('MMM dd, yyyy').format(homework.dueDate)}',
                                        style: TextStyle(
                                          color: isPastDue ? AppColors.danger(context) : AppColors.textSecondary(context),
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
                                      icon: Icon(Icons.attach_file, color: AppColors.primary(context)),
                                      label: Text(
                                        '${homework.attachments!.length} Attachments',
                                        style: TextStyle(color: AppColors.primary(context)),
                                      ),
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
                  return Center(child: Text('Error: ${state.message}', style: TextStyle(color: AppColors.danger(context))));
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

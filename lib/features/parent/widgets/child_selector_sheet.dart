import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';

class ChildSelectorSheet extends StatelessWidget {
  const ChildSelectorSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocBuilder(
      builders: [
        BlocBuilder<StudentsBloc, StudentsState>(
          builder: (context, studentsState) {
            final parentStudents = studentsState is StudentsLoaded
                ? studentsState.students
                : const [];

            return BlocBuilder<SelectedStudentBloc, SelectedStudentState>(
              builder: (context, studentState) {
                String? selectedStudentId;
                if (studentState is SelectedStudentLoaded) {
                  selectedStudentId = studentState.student.id;
                }

                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Text(
                              'Select Student',
                              style: Theme.of(context).textTheme.titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Flexible(
                        child: ListView.separated(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: parentStudents.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 8),
                          itemBuilder: (context, index) {
                            final student = parentStudents[index];
                            final isSelected = student.id == selectedStudentId;

                            return AppCard(
                              onTap: () {
                                context.read<SelectedStudentBloc>().add(
                                  SelectStudent(student),
                                );
                                Navigator.pop(context);
                              },
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              child: Row(
                                children: [
                                  AvatarInitials(
                                    name: student.name,
                                    size: 40,
                                    ringColor: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.name,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? Theme.of(
                                                    context,
                                                  ).colorScheme.primary
                                                : null,
                                          ),
                                        ),
                                        Text(
                                          student.className,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ChildSelectorSheet(),
    );
  }
}

// Helper widget for nested BlocBuilders if needed, though simple nesting works too.
class MultiBlocBuilder extends StatelessWidget {
  final List<Widget> builders;
  const MultiBlocBuilder({super.key, required this.builders});

  @override
  Widget build(BuildContext context) {
    return builders.first;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
import 'package:school_pulse/features/dean/presentation/widgets/glass_icon_button.dart';
import 'package:school_pulse/injection_container.dart';
import 'package:school_pulse/features/dean/presentation/screens/curriculum/subject_list_screen.dart';

class CurriculumManagementScreen extends StatelessWidget {
  const CurriculumManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<DeanBloc>()..add(CurriculaRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Curriculum Management'),
          actions: [
            GlassIconButton(
              icon: Icons.add,
              tooltip: 'Add Curriculum',
              onPressed: () => _showAddCurriculumSheet(context),
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: BlocBuilder<DeanBloc, DeanState>(
          builder: (context, state) {
            if (state is CurriculaLoaded) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.curricula.length,
                itemBuilder: (context, index) {
                  final curriculum = state.curricula[index];
                  return AppCard(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(
                            curriculum.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(curriculum.description),
                          trailing: const Icon(Icons.edit_outlined),
                        ),
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Levels:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 8,
                                children: curriculum.applicableLevels
                                    .map(
                                      (l) => Chip(
                                        label: Text(
                                          l,
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: AppColors.primary(context),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        backgroundColor: AppColors.primary(
                                          context,
                                        ).withValues(alpha: 0.1),
                                        side: BorderSide(
                                          color: AppColors.primary(
                                            context,
                                          ).withValues(alpha: 0.3),
                                        ),
                                        visualDensity: VisualDensity.compact,
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Assessment Weighting:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              ...curriculum.calendarConfig.defaultWeighting.map(
                                (w) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        w.type,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                      Text(
                                        '${w.weight}%',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Subjects (${curriculum.subjects.length})',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              SubjectListScreen(
                                                curriculum: curriculum,
                                              ),
                                        ),
                                      );
                                    },
                                    child: const Text('View All'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  void _showAddCurriculumSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionHeader(title: 'New Curriculum'),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Curriculum Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '"${nameController.text}" will be added once curriculum creation is available.',
                    ),
                  ),
                );
              },
              child: const Text('Create'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

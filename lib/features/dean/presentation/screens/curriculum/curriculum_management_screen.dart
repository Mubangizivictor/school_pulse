import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_bloc.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_event.dart';
import 'package:school_pulse/features/dean/presentation/bloc/dean_state.dart';
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
          actions: [IconButton(icon: const Icon(Icons.add), onPressed: () {})],
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
                                          style: const TextStyle(fontSize: 10),
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
}

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../design_system/app_components.dart';
import '../bloc/assessment_bloc.dart';
import '../bloc/assessment_event.dart';
import '../bloc/assessment_state.dart';
import '../../domain/entities/assessment_type.dart';

class MarksEntryScreen extends StatefulWidget {
  final String schoolId;
  const MarksEntryScreen({super.key, required this.schoolId});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  String? _selectedClass;
  String? _selectedSubject;
  AssessmentType? _selectedAssessmentType;

  @override
  void initState() {
    super.initState();
    context.read<AssessmentBloc>().add(LoadAssessmentConfig(widget.schoolId));
  }

  void _loadMarks() {
    if (_selectedClass != null &&
        _selectedSubject != null &&
        _selectedAssessmentType != null) {
      context.read<AssessmentBloc>().add(
        LoadMarksForEntry(
          schoolId: widget.schoolId,
          assessmentTypeId: _selectedAssessmentType!.id,
          subjectId: _selectedSubject!,
          classId: _selectedClass!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Marks Entry Engine'),
        actions: [
          BlocBuilder<AssessmentBloc, AssessmentState>(
            builder: (context, state) {
              return Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.save),
                    onPressed: state.status == AssessmentStatus.saving
                        ? null
                        : () => context.read<AssessmentBloc>().add(
                            SaveMarksEvent(widget.schoolId),
                          ),
                  ),
                  if (state.marks.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        // Logic to submit all marks currently in the list
                        context.read<AssessmentBloc>().add(
                          SubmitMarksEvent(
                            widget.schoolId,
                            state.marks.map((m) => m.id).toList(),
                          ),
                        );
                      },
                      child: const Text(
                        'SUBMIT',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: BlocConsumer<AssessmentBloc, AssessmentState>(
              listener: (context, state) {
                if (state.status == AssessmentStatus.success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Marks saved successfully!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (state.status == AssessmentStatus.failure) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.errorMessage ?? 'An error occurred'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state.status == AssessmentStatus.loading) {
                  return const Center(child: SchoolPulseLoader());
                }
                if (state.marks.isEmpty) {
                  return const EmptyState(
                    icon: Icons.person_search,
                    title: 'No Students Found',
                    message:
                        'Select Class, Subject, and Assessment to enter marks.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.marks.length,
                  itemBuilder: (context, index) {
                    final mark = state.marks[index];
                    return AppCard(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text('Student ID: ${mark.studentId}'),
                        trailing: SizedBox(
                          width: 100,
                          child: TextField(
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d*\.?\d*'),
                              ),
                            ],
                            decoration: InputDecoration(
                              hintText:
                                  'Max ${_selectedAssessmentType?.maxMark ?? 100}',
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              context.read<AssessmentBloc>().add(
                                UpdateMarkLocal(
                                  studentId: mark.studentId,
                                  score: double.tryParse(value),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return BlocBuilder<AssessmentBloc, AssessmentState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Class'),
                      items: const [
                        DropdownMenuItem(value: 'S1', child: Text('Senior 1')),
                        DropdownMenuItem(value: 'S2', child: Text('Senior 2')),
                      ],
                      onChanged: (v) {
                        setState(() => _selectedClass = v);
                        _loadMarks();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Subject'),
                      items: const [
                        DropdownMenuItem(
                          value: 'MAT',
                          child: Text('Mathematics'),
                        ),
                        DropdownMenuItem(value: 'ENG', child: Text('English')),
                      ],
                      onChanged: (v) {
                        setState(() => _selectedSubject = v);
                        _loadMarks();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<AssessmentType>(
                decoration: const InputDecoration(labelText: 'Assessment Type'),
                items: state.assessmentTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text('${t.name} (${t.weight}%)'),
                      ),
                    )
                    .toList(),
                onChanged: (v) {
                  setState(() => _selectedAssessmentType = v);
                  _loadMarks();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

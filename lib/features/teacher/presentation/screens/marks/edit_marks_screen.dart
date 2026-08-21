import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/domain/entities/subject_assessment.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/marks/marks_bloc.dart';

class EditMarksScreen extends StatefulWidget {
  final String studentId;
  const EditMarksScreen({super.key, required this.studentId});

  @override
  State<EditMarksScreen> createState() => _EditMarksScreenState();
}

class _EditMarksScreenState extends State<EditMarksScreen> {
  late final TextEditingController _markController;
  final _reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final entry = context.read<MarksBloc>().state.entries[widget.studentId];
    _markController = TextEditingController(
      text: entry?.score?.toStringAsFixed(0) ?? '',
    );
  }

  @override
  void dispose() {
    _markController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<MarksBloc, MarksState>(
      listenWhen: (previous, current) =>
          previous.successMessage != current.successMessage &&
          current.successMessage != null,
      listener: (context, state) => context.pop(),
      builder: (context, state) {
        final student = state.students
            .where((s) => s.studentId == widget.studentId)
            .firstOrNull;
        final component = state.selectedComponent;
        final assessment = state.selectedAssessment;

        if (student == null || component == null || assessment == null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(title: const Text('Edit Mark')),
            body: const Center(child: Text('This mark is no longer available.')),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.onSurface,
              ),
              onPressed: () => context.pop(),
            ),
            title: Text(
              'Edit Mark',
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${assessment.title.isEmpty ? assessment.assessmentTypeName : assessment.title} • ${component.name}',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: (student.photoUrl?.isNotEmpty ?? false)
                          ? NetworkImage(student.photoUrl!)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          student.admissionNumber,
                          style: TextStyle(
                            color: theme.hintColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Text(
                  'Mark (out of ${component.maximumMark.toStringAsFixed(0)})',
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: TextField(
                    controller: _markController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Reason for change *',
                  style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 120,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.dividerColor),
                  ),
                  child: TextField(
                    controller: _reasonController,
                    style: TextStyle(color: theme.colorScheme.onSurface),
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Why is this mark being corrected?',
                      hintStyle: TextStyle(
                        color: theme.hintColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: AppColors.danger(context)),
                    ),
                  ),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: theme.dividerColor),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: theme.colorScheme.onSurface),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.isSaving
                            ? null
                            : () {
                                final score = double.tryParse(
                                  _markController.text,
                                );
                                final reason = _reasonController.text.trim();
                                if (score == null || reason.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Enter a mark and a reason.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                context.read<MarksBloc>().add(
                                  MarksEntryEdited(
                                    StudentMarkEntry(
                                      studentId: student.studentId,
                                      componentId: component.id,
                                      score: score,
                                      status: MarkEntryStatus.scored,
                                    ),
                                    reason,
                                  ),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Changes',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
  }
}

import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';

class EnterScoresScreen extends StatefulWidget {
  final String className;
  final String subject;
  final String assessment;
  final String term;
  final String year;

  const EnterScoresScreen({
    super.key,
    this.className = 'Primary 4 - Emerald',
    this.subject = 'Mathematics',
    this.assessment = 'End of Term',
    this.term = 'Term 2',
    this.year = '2024/2025',
  });

  @override
  State<EnterScoresScreen> createState() => _EnterScoresScreenState();
}

class _EnterScoresScreenState extends State<EnterScoresScreen> {
  final Map<String, TextEditingController> _caControllers = {};
  final Map<String, TextEditingController> _eaControllers = {};

  @override
  void initState() {
    super.initState();
    context.read<TeacherBloc>().add(
      TeacherMarksEntryRequested(
        className: widget.className,
        subject: widget.subject,
        assessment: widget.assessment,
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _caControllers.values) {
      controller.dispose();
    }
    for (var controller in _eaControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onSave() {
    final marks = <String, double>{};
    for (var entry in _caControllers.entries) {
      final ca = double.tryParse(entry.value.text) ?? 0;
      final ea = double.tryParse(_eaControllers[entry.key]?.text ?? '0') ?? 0;
      marks[entry.key] = ca + ea;
    }

    context.read<TeacherBloc>().add(
      TeacherMarksSubmitted(
        className: widget.className,
        subject: widget.subject,
        assessment: widget.assessment,
        term: widget.term,
        year: widget.year,
        marks: marks,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TeacherBloc, TeacherState>(
      listener: (context, state) {
        if (state is TeacherMarksSubmitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully saved marks for ${state.savedCount} students',
              ),
              backgroundColor: AppColors.success(context),
            ),
          );
          Navigator.pop(context);
        } else if (state is TeacherError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.errorRed,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background(context),
          appBar: AppBar(
            title: const Text('Enter Scores'),
            backgroundColor: AppColors.surfaceElevated(context),
            foregroundColor: AppColors.textPrimary(context),
            elevation: 0,
            actions: [
              TextButton(
                onPressed: () => context.push('/staff/reports/ca-ea-breakdown'),
                child: Text(
                  'CA/EA Breakdown',
                  style: TextStyle(color: AppColors.primary(context)),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(
                color: AppColors.border(context).withValues(alpha: 0.5),
                height: 1,
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                color: AppColors.primary(context).withValues(alpha: 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.subject,
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      'Total: 100 Points',
                      style: TextStyle(color: AppColors.textSecondary(context)),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Text(
                        'Student',
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'CA (40)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'EA (60)',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Total',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: AppColors.border(context).withValues(alpha: 0.5),
              ),
              Expanded(child: _buildContent(state)),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Previous',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButton(
                        label: 'Save & Next',
                        onPressed: state is TeacherLoading ? null : _onSave,
                      ),
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

  Widget _buildContent(TeacherState state) {
    if (state is TeacherLoading) {
      return Center(
        child: const SchoolPulseLoader(),
      );
    }

    if (state is TeacherMarksEntryLoaded) {
      return ListView.separated(
        itemCount: state.students.length,
        separatorBuilder: (_, _) => Divider(
          height: 1,
          color: AppColors.border(context).withValues(alpha: 0.5),
        ),
        itemBuilder: (context, index) {
          final student = state.students[index];
          final caController = _caControllers.putIfAbsent(
            student.id,
            () => TextEditingController(text: '0'),
          );
          final eaController = _eaControllers.putIfAbsent(
            student.id,
            () => TextEditingController(text: '0'),
          );

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    student.name,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: TextFormField(
                      controller: caController,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textPrimary(context)),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        fillColor: AppColors.surfaceElevated(context),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.border(context),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: TextFormField(
                      controller: eaController,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textPrimary(context)),
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(vertical: 8),
                        fillColor: AppColors.surfaceElevated(context),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: AppColors.border(context),
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${(double.tryParse(caController.text) ?? 0) + (double.tryParse(eaController.text) ?? 0)}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    if (state is TeacherError) {
      return Center(
        child: Text(
          state.message,
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
      );
    }

    return Center(
      child: Text(
        'No students found for this class.',
        style: TextStyle(color: AppColors.textSecondary(context)),
      ),
    );
  }
}

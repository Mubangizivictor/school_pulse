import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/theme_provider.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';

class MarksEntryScreen extends StatefulWidget {
  const MarksEntryScreen({super.key});

  @override
  State<MarksEntryScreen> createState() => _MarksEntryScreenState();
}

class _MarksEntryScreenState extends State<MarksEntryScreen> {
  String? _selectedClass;
  String? _selectedSubject;
  String _selectedAssessment = 'Mid-term Exam';
  bool _hasClasses = true;
  List<TeacherStudent> _students = [];
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      if (user.subjects != null && user.subjects!.isNotEmpty) {
        _selectedClass = user.subjects!.first.className;
        _selectedSubject = user.subjects!.first.subjectName;
      } else if (user.assignedClass != null) {
        _selectedClass = user.assignedClass;
        _selectedSubject = 'General';
      }

      if (_selectedClass != null && _selectedSubject != null) {
        _requestMarks();
      } else {
        _hasClasses = false;
      }
    } else {
      _hasClasses = false;
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _requestMarks() {
    if (_selectedClass == null || _selectedSubject == null) return;
    context.read<TeacherBloc>().add(
      TeacherMarksEntryRequested(
        className: _selectedClass!,
        subject: _selectedSubject!,
        assessment: _selectedAssessment,
      ),
    );
  }

  TextEditingController _controllerFor(String studentId) {
    return _controllers.putIfAbsent(studentId, TextEditingController.new);
  }

  void _submitMarks() {
    final marks = <String, double>{};
    for (final student in _students) {
      final text = _controllers[student.id]?.text.trim() ?? '';
      if (text.isEmpty) continue;
      final score = double.tryParse(text);
      if (score == null || score < 0 || score > 100) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Invalid mark "$text" for ${student.name}. '
              'Marks must be between 0 and 100.',
            ),
          ),
        );
        return;
      }
      marks[student.id] = score;
    }

    if (marks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one mark before saving.')),
      );
      return;
    }

    final config = context.read<ThemeProvider>().config;
    final term = config?.currentTerm ?? 'Term 1';
    final year = config?.academicYear ?? DateTime.now().year.toString();

    context.read<TeacherBloc>().add(
      TeacherMarksSubmitted(
        className: _selectedClass!,
        subject: _selectedSubject!,
        assessment: _selectedAssessment,
        term: term,
        year: year,
        marks: marks,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background(context),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Enter Marks',
          style: TextStyle(color: AppColors.textPrimary(context)),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary(context)),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherMarksEntryLoaded) {
            setState(() => _students = state.students);
          }
          if (state is TeacherMarksSubmitSuccess) {
            for (final controller in _controllers.values) {
              controller.clear();
            }
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Saved marks for ${state.savedCount} student${state.savedCount == 1 ? '' : 's'}',
                ),
                backgroundColor: AppColors.success(context),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (!_hasClasses) {
            return const EmptyState(
              icon: Icons.class_outlined,
              title: 'No classes assigned',
              message:
                  'Your account has no class or subject assignments. Ask your '
                  'school admin to assign you a class before entering marks.',
            );
          }

          if (state is TeacherLoading && _students.isEmpty) {
            return const _MarksEntrySkeleton();
          }

          if (state is TeacherError && _students.isEmpty) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load students',
              message: state.message,
              ctaLabel: 'Retry',
              onCtaPressed: _requestMarks,
            );
          }

          if (_students.isNotEmpty) {
            final isLoading = state is TeacherLoading;

            return Column(
              children: [
                _buildSelectors(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _students.length,
                    itemBuilder: (context, index) {
                      final student = _students[index];
                      return FadeInSlide(
                        delay: Duration(milliseconds: index * 50),
                        child: AppCard(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              AvatarInitials(name: student.name, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  student.name,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary(context),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  controller: _controllerFor(student.id),
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textPrimary(context),
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(3),
                                  ],
                                  decoration: InputDecoration(
                                    hintText: '0-100',
                                    hintStyle: TextStyle(
                                      color: AppColors.textMuted(context),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.border(context),
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.border(context),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide(
                                        color: AppColors.primary(context),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                _buildSubmitBar(isLoading),
              ],
            );
          }

          return const _MarksEntrySkeleton();
        },
      ),
    );
  }

  Widget _buildSelectors() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final user = authState.user;
    final classes = <String>{};
    if (user.assignedClass != null) classes.add(user.assignedClass!);
    if (user.subjects != null) {
      classes.addAll(user.subjects!.map((s) => s.className));
    }

    final subjects = <String>{};
    if (user.subjects != null) {
      subjects.addAll(
        user.subjects!
            .where((s) => s.className == _selectedClass)
            .map((s) => s.subjectName),
      );
    }
    if (subjects.isEmpty) subjects.add('General');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border(context).withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Column(
        children: [
          _DropdownRow(
            label: 'Class',
            value: _selectedClass ?? '',
            items: classes.toList(),
            onChanged: (v) {
              setState(() {
                _selectedClass = v!;
                _students = [];
                // Update subjects for the new class
                final classSubjects =
                    user.subjects
                        ?.where((s) => s.className == v)
                        .map((s) => s.subjectName)
                        .toList() ??
                    [];
                _selectedSubject = classSubjects.isNotEmpty
                    ? classSubjects.first
                    : 'General';
              });
              _requestMarks();
            },
          ),
          const SizedBox(height: 12),
          _DropdownRow(
            label: 'Subject',
            value: _selectedSubject ?? '',
            items: subjects.toList(),
            onChanged: (v) {
              setState(() => _selectedSubject = v!);
              _requestMarks();
            },
          ),
          const SizedBox(height: 12),
          _DropdownRow(
            label: 'Type',
            value: _selectedAssessment,
            items: const [
              'Mid-term Exam',
              'Beginning of Term',
              'End of Term',
              'Quiz',
            ],
            onChanged: (v) {
              setState(() => _selectedAssessment = v!);
              _requestMarks();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow(context),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: PrimaryButton(
        label: 'Save Marks',
        isLoading: isLoading,
        onPressed: isLoading ? null : _submitMarks,
      ),
    );
  }
}

class _MarksEntrySkeleton extends StatelessWidget {
  const _MarksEntrySkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Skeleton(height: 50, borderRadius: 8),
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 8,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 64, borderRadius: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _DropdownRow extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownRow({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary(context),
            ),
          ),
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                dropdownColor: AppColors.surfaceElevated(context),
                style: TextStyle(color: AppColors.textPrimary(context)),
                items: items
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(
                            color: AppColors.textPrimary(context),
                          ),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

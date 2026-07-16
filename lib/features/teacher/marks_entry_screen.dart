import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
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
      }
    }
  }

  void _requestMarks() {
    if (_selectedClass == null || _selectedSubject == null) return;
    context.read<TeacherBloc>().add(TeacherMarksEntryRequested(
          className: _selectedClass!,
          subject: _selectedSubject!,
          assessment: _selectedAssessment,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter Marks'),
      ),
      body: BlocBuilder<TeacherBloc, TeacherState>(
        builder: (context, state) {
          if (state is TeacherLoading) {
            return const _MarksEntrySkeleton();
          }

          if (state is TeacherError) {
            return Center(child: Text(state.message));
          }

          if (state is TeacherMarksEntryLoaded) {
            final students = state.students;

            return Column(
              children: [
                _buildSelectors(),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return FadeInSlide(
                        delay: Duration(milliseconds: index * 50),
                        child: AppCard(
                          onTap: () {}, // Enable scale animation
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              AvatarInitials(name: student.name, size: 40),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  student.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 16),
                              SizedBox(
                                width: 80,
                                child: TextField(
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    hintText: '0-100',
                                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                _buildSubmitBar(),
              ],
            );
          }

          return const SizedBox.shrink();
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
      subjects.addAll(user.subjects!
          .where((s) => s.className == _selectedClass)
          .map((s) => s.subjectName));
    }
    if (subjects.isEmpty) subjects.add('General');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
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
                // Update subjects for the new class
                final classSubjects = user.subjects?.where((s) => s.className == v).map((s) => s.subjectName).toList() ?? [];
                _selectedSubject = classSubjects.isNotEmpty ? classSubjects.first : 'General';
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
            items: const ['Mid-term Exam', 'Beginning of Term', 'End of Term', 'Quiz'],
            onChanged: (v) {
              setState(() => _selectedAssessment = v!);
              _requestMarks();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: PrimaryButton(
        label: 'Save Marks',
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Marks saved as draft')),
          );
        },
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
            children: List.generate(3, (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Skeleton(height: 50, borderRadius: 8),
            )),
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
        SizedBox(width: 80, child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

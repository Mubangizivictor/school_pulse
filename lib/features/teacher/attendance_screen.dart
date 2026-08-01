import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/core/enums/student_status.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_bloc.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_event.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';

class TeacherAttendanceScreen extends StatefulWidget {
  const TeacherAttendanceScreen({super.key});

  @override
  State<TeacherAttendanceScreen> createState() => _TeacherAttendanceScreenState();
}

class _TeacherAttendanceScreenState extends State<TeacherAttendanceScreen> {
  String _selectedClass = 'Primary 4';
  String _searchQuery = '';
  bool _hasClasses = true;
  final Map<String, StudentStatus> _attendance = {};
  List<TeacherStudent> _students = [];

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final user = authState.user;
      final classes = <String>[];
      if (user.assignedClass != null) {
        classes.add(user.assignedClass!);
      }
      if (user.subjects != null) {
        classes.addAll(user.subjects!.map((s) => s.className));
      }

      final distinctClasses = classes.toSet().toList();
      if (distinctClasses.isNotEmpty) {
        _selectedClass = distinctClasses.first;
        context.read<TeacherBloc>().add(TeacherAttendanceRequested(_selectedClass));
      } else {
        _hasClasses = false;
      }
    } else {
      _hasClasses = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Take Attendance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => context.go('/staff/attendance/history'),
          ),
        ],
      ),
      body: BlocConsumer<TeacherBloc, TeacherState>(
        listener: (context, state) {
          if (state is TeacherAttendanceLoaded) {
            setState(() {
              _students = state.students;
              for (var student in state.students) {
                _attendance.putIfAbsent(student.id, () => StudentStatus.present);
              }
            });
          }
          if (state is TeacherInitial && _students.isNotEmpty) {
            // This happens after submission in the current Bloc implementation
            setState(() {
              _attendance.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance submitted successfully'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is TeacherLoading;

          if (!_hasClasses) {
            return const EmptyState(
              icon: Icons.class_outlined,
              title: 'No classes assigned',
              message:
                  'Your account has no class or subject assignments, so there '
                  'is no register to take. Ask your school admin to assign '
                  'you a class.',
            );
          }

          if (isLoading && _students.isEmpty) {
            return const _AttendanceSkeleton();
          }

          if (state is TeacherError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<TeacherBloc>().add(TeacherAttendanceRequested(_selectedClass)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_students.isNotEmpty) {
            final filteredStudents = _students.where((s) => 
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) || 
              s.studentId.toLowerCase().contains(_searchQuery.toLowerCase())
            ).toList();

            return Column(
              children: [
                _buildClassSelector(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
                  child: AppSearchField(
                    hintText: 'Search students...',
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l, vertical: AppSpacing.s),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${filteredStudents.length} Students',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: isLoading ? null : () {
                          setState(() {
                            for (var s in filteredStudents) {
                              _attendance[s.id] = StudentStatus.present;
                            }
                          });
                        },
                        icon: const Icon(Icons.done_all, size: 18),
                        label: const Text('Mark all present'),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filteredStudents.isEmpty 
                    ? const EmptyState(
                        icon: Icons.search_off, 
                        title: 'No results', 
                        message: 'No students found matching your search query.',
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                        itemCount: filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = filteredStudents[index];
                          final status = _attendance[student.id] ?? StudentStatus.present;

                          return FadeInSlide(
                            delay: Duration(milliseconds: index * 30),
                            child: AppCard(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              child: Row(
                                children: [
                                  AvatarInitials(name: student.name, size: 40),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        Text(student.studentId, style: Theme.of(context).textTheme.labelSmall),
                                      ],
                                    ),
                                  ),
                                  _buildStatusToggle(student.id, status, semanticColors, isLoading),
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

          return const _AttendanceSkeleton();
        },
      ),
    );
  }

  Widget _buildClassSelector() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final user = authState.user;
    final classes = <String>{};
    if (user.assignedClass != null) classes.add(user.assignedClass!);
    if (user.subjects != null) {
      classes.addAll(user.subjects!.map((s) => s.className));
    }

    if (classes.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          const Icon(Icons.class_outlined, size: 20),
          const SizedBox(width: 12),
          const Text('Class:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(width: 12),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SegmentedButton<String>(
                segments: classes.map((c) {
                  return ButtonSegment(
                    value: c,
                    label: Text(c.replaceAll('Primary ', 'P.')),
                  );
                }).toList(),
                selected: {_selectedClass},
                onSelectionChanged: (newSelection) {
                  if (newSelection.first != _selectedClass) {
                    setState(() {
                      _selectedClass = newSelection.first;
                      _students = []; // Clear current list to show skeleton
                      _attendance.clear();
                      context.read<TeacherBloc>().add(TeacherAttendanceRequested(_selectedClass));
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusToggle(String studentId, StudentStatus currentStatus, SemanticColors colors, bool isLoading) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StatusButton(
          icon: Icons.check,
          color: colors.success,
          isSelected: currentStatus == StudentStatus.present,
          onTap: isLoading ? () {} : () => setState(() => _attendance[studentId] = StudentStatus.present),
        ),
        const SizedBox(width: 4),
        _StatusButton(
          icon: Icons.access_time,
          color: colors.warning,
          isSelected: currentStatus == StudentStatus.late,
          onTap: isLoading ? () {} : () => setState(() => _attendance[studentId] = StudentStatus.late),
        ),
        const SizedBox(width: 4),
        _StatusButton(
          icon: Icons.close,
          color: colors.error,
          isSelected: currentStatus == StudentStatus.absent,
          onTap: isLoading ? () {} : () => setState(() => _attendance[studentId] = StudentStatus.absent),
        ),
      ],
    );
  }

  Widget _buildSubmitBar(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
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
      child: SafeArea(
        top: false,
        child: PrimaryButton(
          label: 'Submit Attendance',
          isLoading: isLoading,
          onPressed: () {
            if (_attendance.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('No students to submit attendance for')),
              );
              return;
            }

            context.read<TeacherBloc>().add(
                  TeacherAttendanceSubmitted(
                    className: _selectedClass,
                    attendance: _attendance.map((key, value) => MapEntry(key, value.name)),
                  ),
                );
          },
        ),
      ),
    );
  }
}

class _AttendanceSkeleton extends StatelessWidget {
  const _AttendanceSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Skeleton(height: 70),
        Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Skeleton(width: 100, height: 20),
              const Skeleton(width: 120, height: 20),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
            itemCount: 10,
            itemBuilder: (context, index) => const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Skeleton(height: 60, borderRadius: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _StatusButton({
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isSelected ? Colors.white : color,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';

/// School-wide student directory for tenant administrators.
///
/// This deliberately does not consume ClassTeacherContextBloc: an administrator
/// is entitled to the institution roster by school scope and must not need a
/// fake class-teacher assignment just to manage enrolled students.
class AdminStudentDirectoryScreen extends StatefulWidget {
  const AdminStudentDirectoryScreen({super.key});

  @override
  State<AdminStudentDirectoryScreen> createState() =>
      _AdminStudentDirectoryScreenState();
}

class _AdminStudentDirectoryScreenState
    extends State<AdminStudentDirectoryScreen> {
  final _search = TextEditingController();
  StudentStatus? _status;
  String _query = '';
  String? _schoolId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    if (!mounted) return;
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthAuthenticated || auth.user.schoolId.isEmpty) return;
    _schoolId = auth.user.schoolId;
    context.read<StudentsBloc>().add(LoadSchoolStudents(auth.user.schoolId));
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
        actions: [
          IconButton(
            tooltip: 'Admissions',
            icon: const Icon(Icons.how_to_reg_outlined),
            onPressed: () => context.push('/staff/admin/admissions'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final schoolId = _schoolId;
          if (schoolId == null || schoolId.isEmpty) return;
          context.push('/staff/admin/admissions/new', extra: schoolId);
        },
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Enroll student'),
      ),
      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is StudentsError) {
            return _MessageState(
              icon: Icons.cloud_off_outlined,
              title: 'Could not load students',
              message: state.message,
              actionLabel: 'Retry',
              onAction: _load,
            );
          }
          final students = state is StudentsLoaded
              ? _visible(state.students)
              : const <Student>[];
          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
              children: [
                TextField(
                  controller: _search,
                  onChanged: (value) => setState(() => _query = value.trim()),
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search_rounded),
                    hintText: 'Search name, admission no. or student code',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All'),
                        selected: _status == null,
                        onSelected: (_) => setState(() => _status = null),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Active'),
                        selected: _status == StudentStatus.active,
                        onSelected: (_) =>
                            setState(() => _status = StudentStatus.active),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Admitted'),
                        selected: _status == StudentStatus.admitted,
                        onSelected: (_) =>
                            setState(() => _status = StudentStatus.admitted),
                      ),
                      const SizedBox(width: 8),
                      ChoiceChip(
                        label: const Text('Suspended'),
                        selected: _status == StudentStatus.suspended,
                        onSelected: (_) =>
                            setState(() => _status = StudentStatus.suspended),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                if (state is! StudentsLoaded)
                  const _MessageState(
                    icon: Icons.people_outline_rounded,
                    title: 'Loading school roster',
                    message: 'Student records will appear here.',
                  )
                else if (students.isEmpty)
                  _MessageState(
                    icon: Icons.people_outline_rounded,
                    title: state.students.isEmpty
                        ? 'No students enrolled yet'
                        : 'No matching students',
                    message: state.students.isEmpty
                        ? 'Use Enroll student to start the admission workflow.'
                        : 'Change the search or status filter.',
                    actionLabel: state.students.isEmpty
                        ? 'Open admissions'
                        : null,
                    onAction: state.students.isEmpty
                        ? () => context.push('/staff/admin/admissions')
                        : null,
                  )
                else
                  BlocBuilder<StructureBloc, StructureState>(
                    builder: (context, structure) => Column(
                      children: students
                          .map(
                            (student) => _StudentCard(
                              student: student,
                              className: _className(structure, student.classId),
                              streamName: _streamName(
                                structure,
                                student.streamId,
                              ),
                              onTap: () =>
                                  context.push('/staff/students/${student.id}'),
                              onIdentityCards: () => context.push(
                                '/staff/admin/student-id-card',
                                extra: student,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Student> _visible(List<Student> source) {
    final q = _query.toLowerCase();
    final visible = source.where((student) {
      if (_status != null && student.status != _status) return false;
      if (q.isEmpty) return true;
      return student.name.toLowerCase().contains(q) ||
          student.admissionNumber.toLowerCase().contains(q) ||
          student.studentCode.toLowerCase().contains(q);
    }).toList();
    visible.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
    return visible;
  }

  String _className(StructureState state, String classId) {
    for (final schoolClass in state.classes) {
      if (schoolClass.id == classId) return schoolClass.name;
    }
    return classId.isEmpty ? 'Unassigned class' : classId;
  }

  String? _streamName(StructureState state, String? streamId) {
    if (streamId == null || streamId.isEmpty) return null;
    for (final stream in state.streams) {
      if (stream.id == streamId) return stream.name;
    }
    return streamId;
  }
}

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.className,
    required this.streamName,
    required this.onTap,
    required this.onIdentityCards,
  });

  final Student student;
  final String className;
  final String? streamName;
  final VoidCallback onTap;
  final VoidCallback onIdentityCards;

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[
      className,
      if (streamName != null) streamName!,
      student.admissionNumber.isNotEmpty
          ? 'Adm. ${student.admissionNumber}'
          : student.studentCode,
    ].where((value) => value.isNotEmpty).join(' • ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            ListTile(
              onTap: onTap,
              leading: CircleAvatar(
                backgroundImage: student.photoUrl?.isNotEmpty == true
                    ? NetworkImage(student.photoUrl!)
                    : null,
                child: student.photoUrl?.isNotEmpty == true
                    ? null
                    : Text(_initials(student.name)),
              ),
              title: Text(
                student.name,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(subtitle),
              trailing: Text(
                _statusLabel(student.status),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: student.status == StudentStatus.active
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(72, 0, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      student.studentCode.isEmpty
                          ? 'Identity not issued yet'
                          : 'Student ID: ${student.studentCode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.tonalIcon(
                    onPressed: onIdentityCards,
                    icon: const Icon(Icons.contactless_rounded, size: 18),
                    label: const Text('Identity & Cards'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty);
    return words.take(2).map((e) => e[0].toUpperCase()).join();
  }

  static String _statusLabel(StudentStatus status) {
    final value = status.name;
    return value.isEmpty
        ? ''
        : '${value[0].toUpperCase()}${value.substring(1)}';
  }
}

class _MessageState extends StatelessWidget {
  const _MessageState({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 56),
      child: Column(
        children: [
          Icon(icon, size: 52, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 14),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 16),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

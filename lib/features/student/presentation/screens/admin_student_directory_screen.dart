import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_bloc.dart';
import 'package:school_pulse/features/structure/presentation/bloc/structure_state.dart';
import 'package:school_pulse/features/student/data/datasources/student_profile_data_source.dart';
import 'package:school_pulse/features/student/domain/entities/student.dart';
import 'package:school_pulse/features/student/domain/entities/student_enums.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_event.dart';
import 'package:school_pulse/features/student/presentation/bloc/students_state.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Compact, tenant-scoped directory. School context comes only from AuthBloc.
class AdminStudentDirectoryScreen extends StatelessWidget {
  const AdminStudentDirectoryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final schoolId = auth is AuthAuthenticated ? auth.user.schoolId : '';
    return BlocProvider(
      create: (_) => di.sl<StudentsBloc>()..add(LoadSchoolStudents(schoolId)),
      child: _Directory(schoolId),
    );
  }
}

class _Directory extends StatefulWidget {
  final String schoolId;
  const _Directory(this.schoolId);
  @override
  State<_Directory> createState() => _DirectoryState();
}

class _DirectoryState extends State<_Directory> {
  final _search = TextEditingController();
  final _profiles = StudentProfileDataSource();
  String _query = '';
  String? _year, _classId, _stream;
  StudentStatus? _status;
  StudentBoardingType? _boarding;
  Set<String> _guardianHits = const {};
  bool _guardianLoading = false;
  int _page = 0;
  Timer? _debounce;
  static const _pageSize = 40;
  @override
  void dispose() {
    _debounce?.cancel();
    _search.dispose();
    super.dispose();
  }

  void _load() =>
      context.read<StudentsBloc>().add(LoadSchoolStudents(widget.schoolId));
  void _onSearch(String value) {
    setState(() {
      _query = value.trim();
      _page = 0;
    });
    _debounce?.cancel();
    if (value.replaceAll(RegExp(r'[^0-9+]'), '').length < 4) {
      setState(() => _guardianHits = const {});
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 350), () async {
      setState(() => _guardianLoading = true);
      try {
        final hits = await _profiles.findStudentIdsByGuardianPhone(
          schoolId: widget.schoolId,
          phone: value,
        );
        if (mounted && _query == value.trim())
          setState(() => _guardianHits = hits);
      } catch (_) {}
      if (mounted) setState(() => _guardianLoading = false);
    });
  }

  void _clear() {
    _search.clear();
    setState(() {
      _query = '';
      _year = _classId = _stream = null;
      _status = null;
      _boarding = null;
      _guardianHits = const {};
      _page = 0;
    });
  }

  List<Student> _filtered(List<Student> students) {
    final q = _query.toLowerCase();
    final result = students.where((s) {
      final readable = s.admissionNumber.isNotEmpty
          ? s.admissionNumber
          : s.studentCode;
      return (q.isEmpty ||
              s.name.toLowerCase().contains(q) ||
              readable.toLowerCase().contains(q) ||
              _guardianHits.contains(s.id)) &&
          (_year == null || s.academicYearId == _year) &&
          (_classId == null || s.classId == _classId) &&
          (_stream == null || s.streamId == _stream) &&
          (_status == null || s.status == _status) &&
          (_boarding == null || s.boardingType == _boarding);
    }).toList();
    result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return result;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Students'),
      actions: [
        IconButton(
          tooltip: 'Enrol learner',
          icon: const Icon(Icons.add),
          onPressed: _enrol,
        ),
      ],
    ),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: _enrol,
      icon: const Icon(Icons.person_add_alt_1),
      label: const Text('Enrol learner'),
    ),
    body: BlocBuilder<StudentsBloc, StudentsState>(
      builder: (context, state) {
        if (state is StudentsLoading)
          return const Center(child: CircularProgressIndicator());
        if (state is StudentsError)
          return _StateMessage(
            'Could not load learners',
            state.message,
            'Retry',
            _load,
          );
        final all = state is StudentsLoaded
            ? state.students
            : const <Student>[];
        return BlocBuilder<StructureBloc, StructureState>(
          builder: (context, structure) {
            final list = _filtered(all);
            final shown = list.take((_page + 1) * _pageSize).toList();
            return RefreshIndicator(
              onRefresh: () async => _load(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 92),
                children: [
                  _searchBox(),
                  const SizedBox(height: 10),
                  _filters(structure),
                  const SizedBox(height: 14),
                  Text('${list.length} learner${list.length == 1 ? '' : 's'}'),
                  const SizedBox(height: 10),
                  if (list.isEmpty)
                    _StateMessage(
                      'No learners found',
                      'Try a different search or clear the filters.',
                      'Clear filters',
                      _clear,
                    )
                  else
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < shown.length; i++) ...[
                            _row(shown[i], structure),
                            if (i < shown.length - 1) const Divider(height: 1),
                          ],
                          if (shown.length < list.length)
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: OutlinedButton(
                                onPressed: () => setState(() => _page++),
                                child: Text(
                                  'Show more (${list.length - shown.length})',
                                ),
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
      },
    ),
  );
  Widget _searchBox() => TextField(
    controller: _search,
    onChanged: _onSearch,
    textInputAction: TextInputAction.search,
    decoration: InputDecoration(
      prefixIcon: const Icon(Icons.search),
      suffixIcon: _guardianLoading
          ? const Padding(
              padding: EdgeInsets.all(12),
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
      hintText: 'Search learners',
      border: const OutlineInputBorder(),
    ),
  );
  Widget _filters(StructureState s) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth > 540
          ? 170.0
          : (constraints.maxWidth - 8) / 2;
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _select(
            'Academic year',
            _year,
            [
              const DropdownMenuItem(value: null, child: Text('All years')),
              ...s.academicYears.map(
                (x) => DropdownMenuItem(value: x.id, child: Text(x.name)),
              ),
            ],
            (x) => setState(() => _year = x),
            width,
          ),
          _select(
            'Class',
            _classId,
            [
              const DropdownMenuItem(value: null, child: Text('All classes')),
              ...s.classes.map(
                (x) => DropdownMenuItem(value: x.id, child: Text(x.name)),
              ),
            ],
            (x) => setState(() => _classId = x),
            width,
          ),
          _select(
            'Stream',
            _stream,
            [
              const DropdownMenuItem(value: null, child: Text('All streams')),
              ...s.streams
                  .where((x) => _classId == null || x.classId == _classId)
                  .map(
                    (x) => DropdownMenuItem(value: x.id, child: Text(x.name)),
                  ),
            ],
            (x) => setState(() => _stream = x),
            width,
          ),
          _select(
            'Status',
            _status,
            [
              const DropdownMenuItem(value: null, child: Text('All statuses')),
              ...StudentStatus.values.map(
                (x) => DropdownMenuItem(value: x, child: Text(_statusName(x))),
              ),
            ],
            (x) => setState(() => _status = x),
            width,
          ),
          _select(
            'Day / boarding',
            _boarding,
            [
              const DropdownMenuItem(
                value: null,
                child: Text('Day / boarding'),
              ),
              ...StudentBoardingType.values.map(
                (x) => DropdownMenuItem(
                  value: x,
                  child: Text(x.name == 'boarding' ? 'Boarding' : 'Day'),
                ),
              ),
            ],
            (x) => setState(() => _boarding = x),
            width,
          ),
        ],
      );
    },
  );
  Widget _select<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T?>> items,
    ValueChanged<T?> changed,
    double width,
  ) => SizedBox(
    width: width,
    child: Semantics(
      label: label,
      child: DropdownButtonFormField<T?>(
        value: value,
        isExpanded: true,
        isDense: true,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: const OutlineInputBorder(),
        ),
        items: items,
        onChanged: (x) {
          changed(x);
          setState(() => _page = 0);
        },
      ),
    ),
  );
  Widget _row(Student s, StructureState state) {
    final c =
        state.classes.where((x) => x.id == s.classId).firstOrNull?.name ??
        'Unassigned';
    final stream = state.streams
        .where((x) => x.id == s.streamId)
        .firstOrNull
        ?.name;
    final number = _studentNumber(s);
    return ListTile(
      onTap: () => context.push('/staff/admin/students/${s.id}'),
      dense: true,
      minVerticalPadding: 11,
      leading: CircleAvatar(
        backgroundImage: s.photoUrl?.isNotEmpty == true
            ? NetworkImage(s.photoUrl!)
            : null,
        child: s.photoUrl?.isNotEmpty == true ? null : Text(_initials(s.name)),
      ),
      title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('$number\n$c${stream == null ? '' : ' · $stream'}'),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Pill(_statusName(s.status)),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }

  void _enrol() {
    if (widget.schoolId.isNotEmpty)
      context.push('/staff/admin/admissions/register', extra: widget.schoolId);
  }
}

class _Pill extends StatelessWidget {
  final String label;
  const _Pill(this.label);
  @override
  Widget build(BuildContext c) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      border: Border.all(color: Theme.of(c).colorScheme.outline),
      borderRadius: BorderRadius.circular(7),
    ),
    child: Text(
      label,
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    ),
  );
}

class _StateMessage extends StatelessWidget {
  final String title, message, action;
  final VoidCallback onAction;
  const _StateMessage(this.title, this.message, this.action, this.onAction);
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 52),
    child: Column(
      children: [
        const Icon(Icons.people_outline, size: 46),
        const SizedBox(height: 12),
        Text(title, style: Theme.of(c).textTheme.titleMedium),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 14),
        OutlinedButton(onPressed: onAction, child: Text(action)),
      ],
    ),
  );
}

String _initials(String value) {
  final p = value
      .trim()
      .split(RegExp(r'\s+'))
      .where((x) => x.isNotEmpty)
      .toList();
  return p.isEmpty
      ? '?'
      : (p.first[0] + (p.length > 1 ? p.last[0] : '')).toUpperCase();
}

String _statusName(StudentStatus s) {
  switch (s) {
    case StudentStatus.enrollmentInProgress:
    case StudentStatus.pendingAdmission:
    case StudentStatus.admitted:
      return 'Provisional';
    default:
      break;
  }
  final v = s.name.replaceAllMapped(
    RegExp(r'([a-z])([A-Z])'),
    (m) => '${m.group(1)} ${m.group(2)}',
  );
  return '${v[0].toUpperCase()}${v.substring(1)}';
}

String _studentNumber(Student student) {
  final candidate = student.admissionNumber.trim().isNotEmpty
      ? student.admissionNumber.trim()
      : student.studentCode.trim();
  return RegExp(r'^[A-Z]{2,12}-\d{4}-\d{3,}$').hasMatch(candidate)
      ? candidate
      : 'Number pending';
}

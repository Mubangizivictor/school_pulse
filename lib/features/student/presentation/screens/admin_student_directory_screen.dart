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
  _DirectorySort _sort = _DirectorySort.recentlyAdded;
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
        if (mounted && _query == value.trim()) {
          setState(() => _guardianHits = hits);
        }
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
    // The roster's source order is retained for the default “Recently added”
    // view. Student does not expose a created timestamp, so inventing one here
    // would make the sort misleading. Alphabetical sorting remains available.
    if (_sort == _DirectorySort.name) {
      result.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    return result;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      toolbarHeight: 64,
      centerTitle: true,
      title: const Text('Students'),
      leadingWidth: 56,
      leading: IconButton(
        tooltip: 'Back',
        icon: const Icon(Icons.arrow_back_ios_new),
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/staff/admin');
          }
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: IconButton(
            tooltip: 'Enrol learner',
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(
              minimumSize: const Size(44, 44),
              side: BorderSide(color: Theme.of(context).colorScheme.outline),
              shape: const CircleBorder(),
            ),
            onPressed: _enrol,
          ),
        ),
      ],
    ),
    body: BlocBuilder<StudentsBloc, StudentsState>(
      builder: (context, state) {
        if (state is StudentsLoading) {
          return const _DirectoryLoading();
        }
        if (state is StudentsError) {
          return _StateMessage(
            'Could not load learners',
            state.message,
            'Retry',
            _load,
          );
        }
        final all = state is StudentsLoaded
            ? state.students
            : const <Student>[];
        return BlocBuilder<StructureBloc, StructureState>(
          builder: (context, structure) {
            final list = _filtered(all);
            final shown = list.take((_page + 1) * _pageSize).toList();
            return LayoutBuilder(
              builder: (context, constraints) => RefreshIndicator(
                onRefresh: () async => _load(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: constraints.maxWidth >= 900
                          ? 860
                          : double.infinity,
                    ),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      children: [
                        _searchBox(),
                        const SizedBox(height: 12),
                        _filters(structure),
                        const SizedBox(height: 20),
                        _listHeader(list.length),
                        const SizedBox(height: 6),
                        if (list.isEmpty)
                          _StateMessage(
                            _query.isNotEmpty
                                ? 'No search results'
                                : 'No learners found',
                            _query.isNotEmpty
                                ? 'Try another name, learner number, or guardian phone.'
                                : 'Enrol a learner or adjust the filters to see results.',
                            _hasCriteria ? 'Clear filters' : 'Enrol learner',
                            _hasCriteria ? _clear : _enrol,
                          )
                        else ...[
                          for (var i = 0; i < shown.length; i++) ...[
                            _row(shown[i], structure),
                            const Divider(height: 1, thickness: .6),
                          ],
                          if (shown.length < list.length)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: OutlinedButton(
                                onPressed: () => setState(() => _page++),
                                child: Text(
                                  'Show more (${list.length - shown.length})',
                                ),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
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
      contentPadding: const EdgeInsets.symmetric(vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      ),
    ),
  );
  bool get _hasCriteria =>
      _query.isNotEmpty ||
      _year != null ||
      _classId != null ||
      _stream != null ||
      _status != null ||
      _boarding != null;

  Widget _filters(StructureState s) => SizedBox(
    height: 48,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        _select('Academic year', _year, [
          const DropdownMenuItem(value: null, child: Text('All years')),
          ...s.academicYears.map(
            (x) => DropdownMenuItem(value: x.id, child: Text(x.name)),
          ),
        ], (x) => setState(() => _year = x)),
        _select('Class', _classId, [
          const DropdownMenuItem(value: null, child: Text('All classes')),
          ...s.classes.map(
            (x) => DropdownMenuItem(value: x.id, child: Text(x.name)),
          ),
        ], (x) => setState(() => _classId = x)),
        _select('Stream', _stream, [
          const DropdownMenuItem(value: null, child: Text('All streams')),
          ...s.streams
              .where((x) => _classId == null || x.classId == _classId)
              .map((x) => DropdownMenuItem(value: x.id, child: Text(x.name))),
        ], (x) => setState(() => _stream = x)),
        _select('Status', _status, [
          const DropdownMenuItem(value: null, child: Text('All statuses')),
          ...StudentStatus.values.map(
            (x) => DropdownMenuItem(value: x, child: Text(_statusName(x))),
          ),
        ], (x) => setState(() => _status = x)),
        _select('Day / boarding', _boarding, [
          const DropdownMenuItem(value: null, child: Text('Day / boarding')),
          ...StudentBoardingType.values.map(
            (x) => DropdownMenuItem(
              value: x,
              child: Text(x.name == 'boarding' ? 'Boarding' : 'Day'),
            ),
          ),
        ], (x) => setState(() => _boarding = x)),
        const SizedBox(width: 8),
        IconButton(
          tooltip: 'Filter settings',
          icon: const Icon(Icons.tune),
          style: IconButton.styleFrom(
            minimumSize: const Size(48, 48),
            side: BorderSide(color: Theme.of(context).colorScheme.outline),
            shape: const CircleBorder(),
          ),
          onPressed: _openFilterSettings,
        ),
      ],
    ),
  );

  Widget _select<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T?>> items,
    ValueChanged<T?> changed,
  ) {
    final selectedLabel = value == null
        ? label
        : items
                  .where((item) => item.value == value)
                  .map((item) => (item.child as Text).data ?? label)
                  .firstOrNull ??
              label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: PopupMenuButton<T?>(
        tooltip: '$label filter',
        onSelected: (next) {
          changed(next);
          setState(() => _page = 0);
        },
        itemBuilder: (_) => [
          if (value != null)
            PopupMenuItem<T?>(
              onTap: () {
                changed(null);
                setState(() => _page = 0);
              },
              child: Text('Clear $label'),
            ),
          ...items
              .where((item) => item.value != null)
              .map(
                (item) =>
                    PopupMenuItem<T?>(value: item.value, child: item.child),
              ),
        ],
        child: Semantics(
          button: true,
          label: value == null
              ? '$label filter'
              : '$label: $selectedLabel. Tap to change or clear.',
          child: Container(
            constraints: const BoxConstraints(minHeight: 48),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.outline),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(selectedLabel, overflow: TextOverflow.ellipsis),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, size: 19),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listHeader(int count) => Row(
    children: [
      Expanded(
        child: Text(
          '$count learner${count == 1 ? '' : 's'}',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      PopupMenuButton<_DirectorySort>(
        tooltip: 'Sort learners',
        initialValue: _sort,
        onSelected: (sort) => setState(() => _sort = sort),
        itemBuilder: (_) => const [
          PopupMenuItem(
            value: _DirectorySort.recentlyAdded,
            child: Text('Recently added'),
          ),
          PopupMenuItem(value: _DirectorySort.name, child: Text('Name A–Z')),
        ],
        child: Semantics(
          button: true,
          label: 'Sort: ${_sort.label}',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_sort.label),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    ],
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
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      minVerticalPadding: 8,
      leading: CircleAvatar(
        radius: 27,
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        backgroundImage: s.photoUrl?.isNotEmpty == true
            ? NetworkImage(s.photoUrl!)
            : null,
        child: s.photoUrl?.isNotEmpty == true
            ? null
            : Text(
                _initials(s.name),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
      title: Text(
        s.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number, maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(
            '$c${stream == null ? '' : ' · $stream'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
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
    if (widget.schoolId.isNotEmpty) {
      context.push('/staff/admin/admissions/register', extra: widget.schoolId);
    }
  }

  void _openFilterSettings() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter settings',
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                _hasCriteria
                    ? 'Individual filter chips can be changed or cleared.'
                    : 'Choose a filter chip to narrow the learner list.',
              ),
              const SizedBox(height: 20),
              if (_hasCriteria)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _clear();
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear all filters'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _DirectorySort { recentlyAdded, name }

extension on _DirectorySort {
  String get label => switch (this) {
    _DirectorySort.recentlyAdded => 'Recently added',
    _DirectorySort.name => 'Name A–Z',
  };
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

class _DirectoryLoading extends StatelessWidget {
  const _DirectoryLoading();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      const SizedBox(height: 4),
      Container(
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      const SizedBox(height: 14),
      SizedBox(
        height: 48,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, _) => Container(
            width: 108,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
      const SizedBox(height: 24),
      for (var index = 0; index < 6; index++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FractionallySizedBox(
                      widthFactor: .58,
                      child: Container(
                        height: 14,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                    const SizedBox(height: 9),
                    FractionallySizedBox(
                      widthFactor: .38,
                      child: Container(
                        height: 11,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ],
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
  return candidate.isEmpty ? 'ID pending' : candidate;
}

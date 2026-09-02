import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_category.dart';
import 'package:school_pulse/features/attendance_hub/domain/entities/attendance_record.dart'
    as attendance;
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_bloc.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_event.dart';
import 'package:school_pulse/features/attendance_hub/presentation/bloc/attendance_state.dart';
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
    final user = auth is AuthAuthenticated ? auth.user : null;
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              di.sl<StudentsBloc>()..add(LoadSchoolStudents(schoolId)),
        ),
        if (user != null)
          BlocProvider(
            create: (_) =>
                di.sl<AttendanceBloc>()
                  ..add(_todayRecordsRequest(schoolId, user)),
          ),
      ],
      child: _Directory(schoolId, user),
    );
  }
}

LoadRecordsRequested _todayRecordsRequest(String schoolId, UserEntity user) {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day);
  return LoadRecordsRequested(
    schoolId: schoolId,
    operatorUser: user,
    category: AttendanceCategory.students,
    from: start,
    to: start.add(const Duration(days: 1)),
  );
}

class _Directory extends StatefulWidget {
  final String schoolId;
  final UserEntity? user;
  const _Directory(this.schoolId, this.user);
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
  _AttendanceFilter _attendanceFilter = _AttendanceFilter.all;
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
  void _refresh() {
    _load();
    final user = widget.user;
    if (user != null) {
      context.read<AttendanceBloc>().add(
        _todayRecordsRequest(widget.schoolId, user),
      );
    }
  }

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
      _attendanceFilter = _AttendanceFilter.all;
      _guardianHits = const {};
      _page = 0;
    });
  }

  List<Student> _filtered(
    List<Student> students,
    Map<String, attendance.AttendanceStatus> marks,
  ) {
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
          (_boarding == null || s.boardingType == _boarding) &&
          (_attendanceFilter == _AttendanceFilter.all ||
              (_attendanceFilter == _AttendanceFilter.noData &&
                  !marks.containsKey(s.id)) ||
              marks[s.id]?.name == _attendanceFilter.name);
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
    backgroundColor: AppColors.background(context),
    body: SafeArea(
      child: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const _DirectoryLoading();
          }
          if (state is StudentsError) {
            return _StateMessage(
              'Could not load learners',
              state.message,
              'Retry',
              _refresh,
            );
          }
          final all = state is StudentsLoaded
              ? state.students
              : const <Student>[];
          return BlocBuilder<StructureBloc, StructureState>(
            builder: (context, structure) {
              return BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, attendanceState) {
                  final records = attendanceState is RecordsLoaded
                      ? attendanceState.records
                      : const <attendance.AttendanceRecord>[];
                  final marks = _todayMarks(records);
                  final list = _filtered(all, marks);
                  final shown = list.take((_page + 1) * _pageSize).toList();
                  return LayoutBuilder(
                    builder: (context, constraints) => RefreshIndicator(
                      onRefresh: () async => _refresh(),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: constraints.maxWidth >= 900
                                ? 1120
                                : double.infinity,
                          ),
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                            children: [
                              _header(),
                              const SizedBox(height: 22),
                              _classSelector(structure),
                              const SizedBox(height: 30),
                              Text(
                                "Today's attendance",
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w800),
                              ),
                              const SizedBox(height: 14),
                              _attendanceCards(
                                all,
                                marks,
                                constraints.maxWidth,
                              ),
                              if (attendanceState is AttendanceError) ...[
                                const SizedBox(height: 12),
                                _AttendanceRetry(
                                  message: attendanceState.message,
                                  onRetry: _refresh,
                                ),
                              ],
                              const SizedBox(height: 24),
                              _searchBox(),
                              const SizedBox(height: 12),
                              _attendanceFilters(all, marks),
                              const SizedBox(height: 12),
                              _filters(structure),
                              if (_hasCriteria) ...[
                                const SizedBox(height: 12),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: _clear,
                                    icon: const Icon(Icons.clear),
                                    label: const Text('Clear filters'),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              _listHeader(list.length),
                              const SizedBox(height: 6),
                              if (list.isEmpty)
                                _StateMessage(
                                  'No students found',
                                  all.isEmpty && !_hasCriteria
                                      ? 'There are no students enrolled in this class yet.'
                                      : 'No students match your search or selected filter.',
                                  _hasCriteria
                                      ? 'Clear filters'
                                      : 'Enrol learner',
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
          );
        },
      ),
    ),
  );
  Widget _header() => Row(
    children: [
      Expanded(
        child: Text(
          'Students',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
      ),
      IconButton(
        tooltip: 'Add student',
        icon: const Icon(Icons.person_add_alt_1),
        style: _headerActionStyle(),
        onPressed: _enrol,
      ),
      const SizedBox(width: 8),
      IconButton(
        tooltip: 'Filter settings',
        icon: const Icon(Icons.tune),
        style: _headerActionStyle(),
        onPressed: _openFilterSettings,
      ),
      const SizedBox(width: 8),
      IconButton(
        tooltip: 'Refresh students and attendance',
        icon: const Icon(Icons.refresh),
        style: _headerActionStyle(),
        onPressed: _refresh,
      ),
    ],
  );

  ButtonStyle _headerActionStyle() => IconButton.styleFrom(
    minimumSize: const Size(48, 48),
    side: BorderSide(color: AppColors.border(context)),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  Widget _classSelector(StructureState structure) {
    final className = structure.classes
        .where((item) => item.id == _classId)
        .map((item) => item.name)
        .firstOrNull;
    final streamName = structure.streams
        .where((item) => item.id == _stream)
        .map((item) => item.name)
        .firstOrNull;
    final label =
        '${className ?? 'All classes'} · ${streamName ?? 'All streams'}';
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<String>(
        tooltip: 'Select class and stream',
        onSelected: (value) {
          setState(() {
            if (value.startsWith('class:')) {
              _classId = value.substring(6);
              _stream = null;
            } else if (value.startsWith('stream:')) {
              _stream = value.substring(7);
            } else {
              _classId = _stream = null;
            }
            _page = 0;
          });
        },
        itemBuilder: (_) => [
          const PopupMenuItem(
            value: 'all',
            child: Text('All classes · All streams'),
          ),
          ...structure.classes.map(
            (item) => PopupMenuItem(
              value: 'class:${item.id}',
              child: Text('${item.name} · All streams'),
            ),
          ),
          ...structure.streams
              .where((item) => _classId == null || item.classId == _classId)
              .map(
                (item) => PopupMenuItem(
                  value: 'stream:${item.id}',
                  child: Text(item.name),
                ),
              ),
        ],
        child: Semantics(
          button: true,
          label: 'Class and stream: $label',
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border(context)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Map<String, attendance.AttendanceStatus> _todayMarks(
    List<attendance.AttendanceRecord> records,
  ) => {for (final record in records) record.personId: record.status};

  Widget _attendanceCards(
    List<Student> students,
    Map<String, attendance.AttendanceStatus> marks,
    double width,
  ) {
    final scoped = students
        .where(
          (student) =>
              (_classId == null || student.classId == _classId) &&
              (_stream == null || student.streamId == _stream),
        )
        .toList();
    final ids = scoped.map((student) => student.id).toSet();
    final present = marks.entries
        .where(
          (item) =>
              ids.contains(item.key) &&
              item.value == attendance.AttendanceStatus.present,
        )
        .length;
    final absent = marks.entries
        .where(
          (item) =>
              ids.contains(item.key) &&
              item.value == attendance.AttendanceStatus.absent,
        )
        .length;
    final late = marks.entries
        .where(
          (item) =>
              ids.contains(item.key) &&
              item.value == attendance.AttendanceStatus.late,
        )
        .length;
    final cards = [
      _AttendanceStat(
        'Total',
        scoped.length,
        Icons.groups_outlined,
        AppColors.information(context),
      ),
      _AttendanceStat(
        'Present',
        present,
        Icons.check_circle_outline,
        AppColors.success(context),
      ),
      _AttendanceStat(
        'Absent',
        absent,
        Icons.person_off_outlined,
        AppColors.danger(context),
      ),
      _AttendanceStat(
        'Late',
        late,
        Icons.schedule_outlined,
        AppColors.warning(context),
      ),
    ];
    final columns = width >= 900
        ? 4
        : width >= 560
        ? 2
        : 2;
    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: width >= 900 ? 1.35 : 1.08,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  Widget _attendanceFilters(
    List<Student> students,
    Map<String, attendance.AttendanceStatus> marks,
  ) {
    final scoped = students
        .where(
          (student) =>
              (_classId == null || student.classId == _classId) &&
              (_stream == null || student.streamId == _stream),
        )
        .toList();
    int count(_AttendanceFilter filter) => filter == _AttendanceFilter.all
        ? scoped.length
        : scoped
              .where(
                (student) => filter == _AttendanceFilter.noData
                    ? !marks.containsKey(student.id)
                    : marks[student.id]?.name == filter.name,
              )
              .length;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _AttendanceFilter.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final filter = _AttendanceFilter.values[index];
          final selected = filter == _attendanceFilter;
          final color = filter.color(context);
          return ChoiceChip(
            label: Text('${filter.label} ${count(filter)}'),
            selected: selected,
            selectedColor: color.withValues(alpha: .16),
            side: BorderSide(
              color: selected ? color : AppColors.border(context),
            ),
            labelStyle: TextStyle(
              color: selected ? color : null,
              fontWeight: FontWeight.w700,
            ),
            onSelected: (_) => setState(() {
              _attendanceFilter = filter;
              _page = 0;
            }),
          );
        },
      ),
    );
  }

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
      hintText: 'Search students',
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
      _boarding != null ||
      _attendanceFilter != _AttendanceFilter.all;

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

enum _AttendanceFilter { all, present, absent, late, noData }

extension on _AttendanceFilter {
  String get label => switch (this) {
    _AttendanceFilter.all => 'All',
    _AttendanceFilter.present => 'Present',
    _AttendanceFilter.absent => 'Absent',
    _AttendanceFilter.late => 'Late',
    _AttendanceFilter.noData => 'No data',
  };

  Color color(BuildContext context) => switch (this) {
    _AttendanceFilter.all => AppColors.information(context),
    _AttendanceFilter.present => AppColors.success(context),
    _AttendanceFilter.absent => AppColors.danger(context),
    _AttendanceFilter.late => AppColors.warning(context),
    _AttendanceFilter.noData => AppColors.textSecondary(context),
  };
}

class _AttendanceStat extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _AttendanceStat(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) => AppCard(
    color: AppColors.surfaceContainer(context),
    borderColor: AppColors.border(context),
    padding: const EdgeInsets.all(16),
    child: Semantics(
      label: '$label attendance: $value',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 31),
          Text(
            '$value',
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(label, style: Theme.of(context).textTheme.titleMedium),
          Container(
            height: 4,
            width: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    ),
  );
}

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
    padding: const EdgeInsets.symmetric(vertical: 26),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 46),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(c),
        border: Border.all(color: AppColors.border(c)),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(
            Icons.manage_search_outlined,
            size: 62,
            color: AppColors.textSecondary(c),
          ),
          const SizedBox(height: 20),
          Text(
            title,
            style: Theme.of(
              c,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(c).textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          OutlinedButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    ),
  );
}

class _AttendanceRetry extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _AttendanceRetry({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.dangerSurface(context),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      children: [
        Icon(Icons.error_outline, color: AppColors.danger(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Could not load today\'s attendance. $message',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Retry')),
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

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/design_system/theme/app_radius.dart';
import 'package:school_pulse/design_system/theme/app_breakpoints.dart';
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

/// Learner-management workspace. School context comes only from AuthBloc.
class AdminStudentDirectoryScreen extends StatelessWidget {
  /// Overridable only from tests, which cannot construct the real
  /// Firestore-backed default without a live Firebase app.
  final StudentProfileDataSource? profileDataSource;

  const AdminStudentDirectoryScreen({super.key, this.profileDataSource});
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
      child: _Directory(schoolId, user, profileDataSource),
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
  final StudentProfileDataSource? profileDataSource;
  const _Directory(this.schoolId, this.user, this.profileDataSource);
  @override
  State<_Directory> createState() => _DirectoryState();
}

class _DirectoryState extends State<_Directory> {
  final _search = TextEditingController();
  late final _profiles = widget.profileDataSource ?? StudentProfileDataSource();
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
      _guardianHits = const {};
      _page = 0;
    });
  }

  int get _activeFilterCount => [
    _year,
    _classId,
    _stream,
    _status,
    _boarding,
  ].where((x) => x != null).length;

  bool get _hasCriteria => _query.isNotEmpty || _activeFilterCount > 0;

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

  Map<String, attendance.AttendanceStatus> _todayMarks(
    List<attendance.AttendanceRecord> records,
  ) => {for (final record in records) record.personId: record.status};

  void _enrol() {
    if (widget.schoolId.isNotEmpty) {
      context.push('/staff/admin/admissions/register', extra: widget.schoolId);
    }
  }

  void _openFilters(StructureState structure) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => _FilterSheet(
        structure: structure,
        year: _year,
        classId: _classId,
        stream: _stream,
        status: _status,
        boarding: _boarding,
        onApply: (year, classId, stream, status, boarding) {
          setState(() {
            _year = year;
            _classId = classId;
            _stream = stream;
            _status = status;
            _boarding = boarding;
            _page = 0;
          });
        },
        onClear: _clear,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.background(context),
    child: SafeArea(
      child: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          if (state is StudentsLoading) {
            return const _DirectoryLoading();
          }
          if (state is StudentsError) {
            return _StateMessage(
              icon: Icons.cloud_off,
              title: 'Could not load learners',
              message: state.message,
              action: 'Retry',
              onAction: _refresh,
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
                  final list = _filtered(all);
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop =
                          constraints.maxWidth >= AppBreakpoints.smallDesktop;
                      // Desktop shows one discrete page at a time (with a
                      // numbered pagination footer); mobile/tablet keep the
                      // cumulative "Show more" pattern instead.
                      final shown = isDesktop
                          ? list
                                .skip(_page * _pageSize)
                                .take(_pageSize)
                                .toList()
                          : list.take((_page + 1) * _pageSize).toList();
                      return RefreshIndicator(
                        onRefresh: () async => _refresh(),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.fromLTRB(
                            isDesktop ? AppSpacing.x3l : AppSpacing.xl,
                            AppSpacing.x2l,
                            isDesktop ? AppSpacing.x3l : AppSpacing.xl,
                            AppSpacing.x4l,
                          ),
                          child: Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isDesktop ? 1280 : double.infinity,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _header(context, list.length, isDesktop),
                                  if (!isDesktop) ...[
                                    const SizedBox(height: AppSpacing.l),
                                    _searchAndFilterRow(context, isDesktop),
                                  ],
                                  const SizedBox(height: AppSpacing.l),
                                  _filterRow(context, structure, isDesktop),
                                  const SizedBox(height: AppSpacing.xl),
                                  _AttendanceStrip(
                                    students: all,
                                    marks: marks,
                                    classId: _classId,
                                    streamId: _stream,
                                    error: attendanceState is AttendanceError
                                        ? attendanceState.message
                                        : null,
                                    onRetry: _refresh,
                                    onViewAttendance: () =>
                                        context.push('/staff/attendance'),
                                  ),
                                  const SizedBox(height: AppSpacing.x2l),
                                  _listHeader(context, list.length),
                                  const SizedBox(height: AppSpacing.m),
                                  if (list.isEmpty)
                                    _StateMessage(
                                      icon: Icons.manage_search_outlined,
                                      title: 'No students found',
                                      message: all.isEmpty && !_hasCriteria
                                          ? 'There are no students enrolled yet.'
                                          : 'No students match your search or selected filters.',
                                      action: _hasCriteria
                                          ? 'Clear filters'
                                          : 'Add learner',
                                      onAction: _hasCriteria
                                          ? _clear
                                          : _enrol,
                                    )
                                  else if (isDesktop)
                                    _DesktopTable(
                                      students: shown,
                                      structure: structure,
                                      marks: marks,
                                      onTap: (id) => context.push(
                                        '/staff/admin/students/$id',
                                      ),
                                      sort: _sort,
                                      onSortChanged: (sort) =>
                                          setState(() => _sort = sort),
                                    )
                                  else
                                    _MobileList(
                                      students: shown,
                                      structure: structure,
                                      marks: marks,
                                      onTap: (id) => context.push(
                                        '/staff/admin/students/$id',
                                      ),
                                    ),
                                  if (list.isNotEmpty && isDesktop)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.l,
                                      ),
                                      child: _PaginationFooter(
                                        shownCount: shown.length,
                                        totalCount: list.length,
                                        page: _page,
                                        pageSize: _pageSize,
                                        onPageChanged: (page) =>
                                            setState(() => _page = page),
                                      ),
                                    )
                                  else if (shown.length < list.length)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        top: AppSpacing.l,
                                      ),
                                      child: Center(
                                        child: OutlinedButton(
                                          onPressed: () =>
                                              setState(() => _page++),
                                          child: Text(
                                            'Show more (${list.length - shown.length})',
                                          ),
                                        ),
                                      ),
                                    ),
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
          );
        },
      ),
    ),
  );

  Widget _header(BuildContext context, int count, bool isDesktop) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Students',
          style: Theme.of(
            context,
          ).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          '$count learner${count == 1 ? '' : 's'}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
      ],
    );

    // Desktop keeps the inline search box, filters, refresh and Add all in
    // the sticky header row (room for it). Mobile/tablet collapse search and
    // filters to compact icon buttons so the row never wraps or clips.
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          SizedBox(width: 320, child: _searchBox(context)),
          const SizedBox(width: AppSpacing.m),
          _filterButton(context),
          const SizedBox(width: AppSpacing.m),
          _iconAction(
            context,
            icon: Icons.refresh,
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
          const SizedBox(width: AppSpacing.m),
          _addLearnerButton(context),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: title),
        _addLearnerButton(context),
      ],
    );
  }

  Widget _searchAndFilterRow(BuildContext context, bool isDesktop) {
    if (isDesktop) return const SizedBox.shrink();
    return Row(
      children: [
        Expanded(child: _searchBox(context)),
        const SizedBox(width: AppSpacing.m),
        _filterButton(context),
        const SizedBox(width: AppSpacing.m),
        _iconAction(
          context,
          icon: Icons.refresh,
          tooltip: 'Refresh',
          onPressed: _refresh,
        ),
      ],
    );
  }

  Widget _addLearnerButton(BuildContext context) => ElevatedButton.icon(
    onPressed: _enrol,
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary(context),
      foregroundColor: AppColors.background(context),
      minimumSize: const Size(44, 48),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    ),
    icon: const Icon(Icons.add),
    label: const Text('Add learner'),
  );

  Widget _iconAction(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) => IconButton(
    tooltip: tooltip,
    icon: Icon(icon),
    onPressed: onPressed,
    style: IconButton.styleFrom(
      minimumSize: const Size(48, 48),
      side: BorderSide(color: AppColors.border(context)),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
    ),
  );

  Widget _filterButton(BuildContext context, {StructureState? structure}) => Stack(
    clipBehavior: Clip.none,
    children: [
      _iconAction(
        context,
        icon: Icons.tune,
        tooltip: 'Filters',
        onPressed: () => _openFilters(structure ?? context.read<StructureBloc>().state),
      ),
      if (_activeFilterCount > 0)
        Positioned(
          right: -4,
          top: -4,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.information(context),
              borderRadius: AppRadius.full,
            ),
            child: Text(
              '$_activeFilterCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
    ],
  );

  Widget _searchBox(BuildContext context) => TextField(
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
      hintText: 'Search learners...',
      contentPadding: const EdgeInsets.symmetric(vertical: 13),
      border: OutlineInputBorder(borderRadius: AppRadius.medium),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppRadius.medium,
        borderSide: BorderSide(color: AppColors.border(context)),
      ),
    ),
  );

  Widget _filterRow(
    BuildContext context,
    StructureState structure,
    bool isDesktop,
  ) {
    if (!isDesktop) {
      // Compact filter access on mobile/tablet: a class pill plus a single
      // "N active" pill that opens the full filter sheet.
      return SizedBox(
        height: 44,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: [
            _classPill(context, structure),
            const SizedBox(width: AppSpacing.m),
            _streamPill(context, structure),
            const SizedBox(width: AppSpacing.m),
            _activeFilterPill(context, structure),
          ],
        ),
      );
    }

    final children = <Widget>[
      _termPill(context, structure),
      _classPill(context, structure),
      _streamPill(context, structure),
      _pillSelect('Status', _status, [
        const DropdownMenuItem(value: null, child: Text('All statuses')),
        ...StudentStatus.values.map(
          (x) => DropdownMenuItem(value: x, child: Text(_statusName(x))),
        ),
      ], (x) => setState(() { _status = x; _page = 0; })),
      _pillSelect('Day / boarding', _boarding, [
        const DropdownMenuItem(value: null, child: Text('Day / boarding')),
        ...StudentBoardingType.values.map(
          (x) => DropdownMenuItem(
            value: x,
            child: Text(x.name == 'boarding' ? 'Boarding' : 'Day'),
          ),
        ),
      ], (x) => setState(() { _boarding = x; _page = 0; })),
      if (_hasCriteria)
        TextButton(onPressed: _clear, child: const Text('Clear filters')),
    ];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.m),
        itemBuilder: (_, i) => children[i],
      ),
    );
  }

  Widget _termPill(BuildContext context, StructureState structure) {
    final year = structure.academicYears
        .where((y) => y.id == _year)
        .firstOrNull;
    final currentYear = structure.academicYears
        .where((y) => y.isCurrent)
        .firstOrNull;
    final label = (year ?? currentYear)?.name ?? 'Academic year';
    return PopupMenuButton<String?>(
      tooltip: 'Academic year',
      onSelected: (v) => setState(() {
        _year = v;
        _page = 0;
      }),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All years')),
        ...structure.academicYears.map(
          (y) => PopupMenuItem(value: y.id, child: Text(y.name)),
        ),
      ],
      child: _pillContainer(context, label),
    );
  }

  Widget _classPill(BuildContext context, StructureState structure) {
    final className = structure.classes
        .where((item) => item.id == _classId)
        .map((item) => item.name)
        .firstOrNull;
    return PopupMenuButton<String?>(
      tooltip: 'Class',
      onSelected: (value) => setState(() {
        _classId = value;
        _stream = null;
        _page = 0;
      }),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All classes')),
        ...structure.classes.map(
          (item) => PopupMenuItem(value: item.id, child: Text(item.name)),
        ),
      ],
      child: _pillContainer(context, className ?? 'All classes'),
    );
  }

  Widget _streamPill(BuildContext context, StructureState structure) {
    final streamName = structure.streams
        .where((item) => item.id == _stream)
        .map((item) => item.name)
        .firstOrNull;
    return PopupMenuButton<String?>(
      tooltip: 'Stream',
      onSelected: (value) => setState(() {
        _stream = value;
        _page = 0;
      }),
      itemBuilder: (_) => [
        const PopupMenuItem(value: null, child: Text('All streams')),
        ...structure.streams
            .where((item) => _classId == null || item.classId == _classId)
            .map(
              (item) => PopupMenuItem(value: item.id, child: Text(item.name)),
            ),
      ],
      child: _pillContainer(context, streamName ?? 'All streams'),
    );
  }

  Widget _pillContainer(BuildContext context, String label) => Semantics(
    button: true,
    label: label,
    child: Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.m,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border(context)),
        borderRadius: AppRadius.medium,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.s),
          const Icon(Icons.keyboard_arrow_down, size: 19),
        ],
      ),
    ),
  );

  Widget _activeFilterPill(BuildContext context, StructureState structure) {
    final active = _activeFilterCount;
    if (active == 0) {
      return OutlinedButton.icon(
        onPressed: () => _openFilters(structure),
        icon: const Icon(Icons.tune, size: 18),
        label: const Text('Filters'),
      );
    }
    return FilledButton.icon(
      onPressed: () => _openFilters(structure),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.informationSurface(context),
        foregroundColor: AppColors.information(context),
      ),
      icon: const Icon(Icons.tune, size: 18),
      label: Text('$active active'),
    );
  }

  Widget _pillSelect<T>(
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
    return PopupMenuButton<T?>(
      tooltip: '$label filter',
      onSelected: changed,
      itemBuilder: (_) => [
        if (value != null)
          PopupMenuItem<T?>(
            onTap: () => changed(null),
            child: Text('Clear $label'),
          ),
        ...items
            .where((item) => item.value != null)
            .map(
              (item) => PopupMenuItem<T?>(value: item.value, child: item.child),
            ),
      ],
      child: Semantics(
        button: true,
        label: value == null
            ? '$label filter'
            : '$label: $selectedLabel. Tap to change or clear.',
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border(context)),
            borderRadius: AppRadius.medium,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(selectedLabel, overflow: TextOverflow.ellipsis),
              const SizedBox(width: AppSpacing.s),
              const Icon(Icons.keyboard_arrow_down, size: 19),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listHeader(BuildContext context, int count) => Row(
    children: [
      Expanded(
        child: Text(
          'All learners · $count',
          style: Theme.of(
            context,
          ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      Text(
        'Sort by ',
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: AppColors.textSecondary(context),
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
              Text(
                _sort.label,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.keyboard_arrow_down),
            ],
          ),
        ),
      ),
    ],
  );
}

enum _DirectorySort { recentlyAdded, name }

extension on _DirectorySort {
  String get label => switch (this) {
    _DirectorySort.recentlyAdded => 'Recently added',
    _DirectorySort.name => 'Name A–Z',
  };
}

/// Compact today-attendance summary: percentage/count + progress line + link.
class _AttendanceStrip extends StatelessWidget {
  final List<Student> students;
  final Map<String, attendance.AttendanceStatus> marks;
  final String? classId;
  final String? streamId;
  final String? error;
  final VoidCallback onRetry;
  final VoidCallback onViewAttendance;

  const _AttendanceStrip({
    required this.students,
    required this.marks,
    required this.classId,
    required this.streamId,
    required this.error,
    required this.onRetry,
    required this.onViewAttendance,
  });

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface(context),
          borderRadius: AppRadius.medium,
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.danger(context)),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: Text(
                'Could not load today\'s attendance. $error',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    final scoped = students
        .where(
          (s) =>
              (classId == null || s.classId == classId) &&
              (streamId == null || s.streamId == streamId),
        )
        .toList();

    if (scoped.isEmpty || marks.isEmpty) {
      return const SizedBox.shrink();
    }

    final total = scoped.length;
    final present = scoped
        .where((s) => marks[s.id] == attendance.AttendanceStatus.present)
        .length;
    final percent = total == 0 ? 0 : ((present / total) * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.l,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(context),
        border: Border.all(color: AppColors.border(context)),
        borderRadius: AppRadius.medium,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 460;
          final label = RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textPrimary(context),
              ),
              children: [
                const TextSpan(
                  text: "Today's attendance · ",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text: '$percent% present',
                  style: TextStyle(
                    color: AppColors.success(context),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(text: ' · $present / $total'),
              ],
            ),
          );
          final bar = ClipRRect(
            borderRadius: AppRadius.full,
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : present / total,
              minHeight: 6,
              backgroundColor: AppColors.border(context),
              valueColor: AlwaysStoppedAnimation(AppColors.success(context)),
            ),
          );
          final link = TextButton.icon(
            onPressed: onViewAttendance,
            label: const Text('View attendance'),
            icon: const Icon(Icons.chevron_right, size: 18),
            iconAlignment: IconAlignment.end,
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label,
                const SizedBox(height: AppSpacing.m),
                bar,
                Align(alignment: Alignment.centerRight, child: link),
              ],
            );
          }
          return Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label,
                    const SizedBox(height: AppSpacing.m),
                    bar,
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.xl),
              link,
            ],
          );
        },
      ),
    );
  }
}

class _DesktopTable extends StatelessWidget {
  final List<Student> students;
  final StructureState structure;
  final Map<String, attendance.AttendanceStatus> marks;
  final ValueChanged<String> onTap;
  final _DirectorySort sort;
  final ValueChanged<_DirectorySort> onSortChanged;

  const _DesktopTable({
    required this.students,
    required this.structure,
    required this.marks,
    required this.onTap,
    required this.sort,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      border: Border.all(color: AppColors.border(context)),
      borderRadius: AppRadius.medium,
    ),
    clipBehavior: Clip.antiAlias,
    child: Column(
      children: [
        Container(
          color: AppColors.surfaceContainer(context),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.m,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: InkWell(
                  onTap: () => onSortChanged(
                    sort == _DirectorySort.name
                        ? _DirectorySort.recentlyAdded
                        : _DirectorySort.name,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Learner',
                        style: Theme.of(context).textTheme.labelLarge
                            ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary(context),
                            ),
                      ),
                      const SizedBox(width: AppSpacing.s),
                      Icon(
                        sort == _DirectorySort.name
                            ? Icons.arrow_upward
                            : Icons.unfold_more,
                        size: 16,
                        color: AppColors.textMuted(context),
                      ),
                    ],
                  ),
                ),
              ),
              _headCell(context, 'Admission no.', flex: 2),
              _headCell(context, 'Class · Stream', flex: 2),
              _headCell(context, 'Attendance', flex: 2),
              _headCell(context, 'Parent', flex: 2),
              const SizedBox(width: 40),
            ],
          ),
        ),
        for (final s in students) ...[
          const Divider(height: 1, thickness: .6),
          _TableRow(
            student: s,
            structure: structure,
            status: marks[s.id],
            onTap: () => onTap(s.id),
          ),
        ],
      ],
    ),
  );

  Widget _headCell(BuildContext context, String text, {required int flex}) =>
      Expanded(
        flex: flex,
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary(context),
          ),
        ),
      );
}

class _TableRow extends StatelessWidget {
  final Student student;
  final StructureState structure;
  final attendance.AttendanceStatus? status;
  final VoidCallback onTap;

  const _TableRow({
    required this.student,
    required this.structure,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final className =
        structure.classes
            .where((x) => x.id == student.classId)
            .firstOrNull
            ?.name ??
        'Unassigned';
    final streamName = structure.streams
        .where((x) => x.id == student.streamId)
        .firstOrNull
        ?.name;
    final number = _studentNumber(student);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.m,
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: student.photoUrl?.isNotEmpty == true
                        ? AppColors.surfaceContainerHigh(context)
                        : _avatarColor(context, student.name),
                    backgroundImage: student.photoUrl?.isNotEmpty == true
                        ? NetworkImage(student.photoUrl!)
                        : null,
                    child: student.photoUrl?.isNotEmpty == true
                        ? null
                        : Text(
                            _initials(student.name),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: _avatarTextColor(context, student.name),
                            ),
                          ),
                  ),
                  const SizedBox(width: AppSpacing.m),
                  Flexible(
                    child: Text(
                      student.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(flex: 2, child: Text(number)),
            Expanded(
              flex: 2,
              child: Text(
                '$className${streamName == null ? '' : ' · $streamName'}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(flex: 2, child: _AttendanceDot(status: status)),
            Expanded(flex: 2, child: _ParentLinkIndicator(student: student)),
            SizedBox(
              width: 40,
              child: Icon(
                Icons.chevron_right,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileList extends StatelessWidget {
  final List<Student> students;
  final StructureState structure;
  final Map<String, attendance.AttendanceStatus> marks;
  final ValueChanged<String> onTap;

  const _MobileList({
    required this.students,
    required this.structure,
    required this.marks,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      for (var i = 0; i < students.length; i++) ...[
        _MobileRow(
          student: students[i],
          structure: structure,
          status: marks[students[i].id],
          onTap: () => onTap(students[i].id),
        ),
        if (i < students.length - 1)
          const Divider(height: 1, thickness: .6),
      ],
    ],
  );
}

class _MobileRow extends StatelessWidget {
  final Student student;
  final StructureState structure;
  final attendance.AttendanceStatus? status;
  final VoidCallback onTap;

  const _MobileRow({
    required this.student,
    required this.structure,
    required this.status,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final className =
        structure.classes
            .where((x) => x.id == student.classId)
            .firstOrNull
            ?.name ??
        'Unassigned';
    final streamName = structure.streams
        .where((x) => x.id == student.streamId)
        .firstOrNull
        ?.name;
    final number = _studentNumber(student);
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppSpacing.s,
        horizontal: 4,
      ),
      minVerticalPadding: AppSpacing.m,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: student.photoUrl?.isNotEmpty == true
            ? AppColors.surfaceContainerHigh(context)
            : _avatarColor(context, student.name),
        backgroundImage: student.photoUrl?.isNotEmpty == true
            ? NetworkImage(student.photoUrl!)
            : null,
        child: student.photoUrl?.isNotEmpty == true
            ? null
            : Text(
                _initials(student.name),
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _avatarTextColor(context, student.name),
                ),
              ),
      ),
      title: Text(
        student.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '$number · $className${streamName == null ? '' : ' · $streamName'}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _AttendanceDot(status: status),
          const SizedBox(width: AppSpacing.s),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}

class _ParentLinkIndicator extends StatelessWidget {
  final Student student;
  const _ParentLinkIndicator({required this.student});

  @override
  Widget build(BuildContext context) {
    final linked = student.parentIds.isNotEmpty;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          linked ? Icons.link : Icons.link_off,
          size: 16,
          color: linked
              ? AppColors.information(context)
              : AppColors.textMuted(context),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(
          linked ? 'Linked' : 'Not linked',
          style: TextStyle(
            color: linked
                ? AppColors.information(context)
                : AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }
}

class _AttendanceDot extends StatelessWidget {
  final attendance.AttendanceStatus? status;
  const _AttendanceDot({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;
    switch (status) {
      case attendance.AttendanceStatus.present:
        color = AppColors.success(context);
        label = 'Present';
        break;
      case attendance.AttendanceStatus.absent:
        color = AppColors.danger(context);
        label = 'Absent';
        break;
      case attendance.AttendanceStatus.late:
        color = AppColors.warning(context);
        label = 'Late';
        break;
      default:
        color = AppColors.textMuted(context);
        label = 'No data';
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.s),
        Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final StructureState structure;
  final String? year;
  final String? classId;
  final String? stream;
  final StudentStatus? status;
  final StudentBoardingType? boarding;
  final void Function(
    String? year,
    String? classId,
    String? stream,
    StudentStatus? status,
    StudentBoardingType? boarding,
  )
  onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.structure,
    required this.year,
    required this.classId,
    required this.stream,
    required this.status,
    required this.boarding,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String? _year = widget.year;
  late String? _classId = widget.classId;
  late String? _stream = widget.stream;
  late StudentStatus? _status = widget.status;
  late StudentBoardingType? _boarding = widget.boarding;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.x2l,
        right: AppSpacing.x2l,
        top: AppSpacing.x2l,
        bottom: AppSpacing.x2l + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filters',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppSpacing.x2l),
            _dropdownField<String?>(
              'Academic year',
              _year,
              [
                const DropdownMenuItem(value: null, child: Text('All years')),
                ...widget.structure.academicYears.map(
                  (x) => DropdownMenuItem(value: x.id, child: Text(x.name)),
                ),
              ],
              (v) => setState(() => _year = v),
            ),
            const SizedBox(height: AppSpacing.l),
            _dropdownField<String?>(
              'Class',
              _classId,
              [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All classes'),
                ),
                ...widget.structure.classes.map(
                  (x) => DropdownMenuItem(value: x.id, child: Text(x.name)),
                ),
              ],
              (v) => setState(() {
                _classId = v;
                _stream = null;
              }),
            ),
            const SizedBox(height: AppSpacing.l),
            _dropdownField<String?>(
              'Stream',
              _stream,
              [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All streams'),
                ),
                ...widget.structure.streams
                    .where(
                      (x) => _classId == null || x.classId == _classId,
                    )
                    .map(
                      (x) =>
                          DropdownMenuItem(value: x.id, child: Text(x.name)),
                    ),
              ],
              (v) => setState(() => _stream = v),
            ),
            const SizedBox(height: AppSpacing.l),
            _dropdownField<StudentStatus?>(
              'Status',
              _status,
              [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All statuses'),
                ),
                ...StudentStatus.values.map(
                  (x) =>
                      DropdownMenuItem(value: x, child: Text(_statusName(x))),
                ),
              ],
              (v) => setState(() => _status = v),
            ),
            const SizedBox(height: AppSpacing.l),
            _dropdownField<StudentBoardingType?>(
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
              (v) => setState(() => _boarding = v),
            ),
            const SizedBox(height: AppSpacing.x2l),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      widget.onClear();
                    },
                    child: const Text('Clear all'),
                  ),
                ),
                const SizedBox(width: AppSpacing.l),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary(context),
                      foregroundColor: AppColors.background(context),
                      minimumSize: const Size(0, 48),
                    ),
                    onPressed: () {
                      widget.onApply(
                        _year,
                        _classId,
                        _stream,
                        _status,
                        _boarding,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  Widget _dropdownField<T>(
    String label,
    T value,
    List<DropdownMenuItem<T>> items,
    ValueChanged<T> onChanged,
  ) => DropdownButtonFormField<T>(
    initialValue: value,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: AppRadius.medium),
    ),
    items: items,
    onChanged: (v) => onChanged(v as T),
  );
}

class _PaginationFooter extends StatelessWidget {
  final int shownCount;
  final int totalCount;
  final int page;
  final int pageSize;
  final ValueChanged<int> onPageChanged;

  const _PaginationFooter({
    required this.shownCount,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pageCount = (totalCount / pageSize).ceil().clamp(1, 1 << 30);
    final start = totalCount == 0 ? 0 : page * pageSize + 1;
    final end = page * pageSize + shownCount;

    // Cap the visible page-number buttons; a "…" placeholder covers the gap
    // for large rosters instead of rendering hundreds of buttons.
    const maxButtons = 5;
    final buttons = <Widget>[];
    if (pageCount <= maxButtons) {
      for (var i = 0; i < pageCount; i++) {
        buttons.add(_pageButton(context, i));
      }
    } else {
      buttons.add(_pageButton(context, 0));
      buttons.add(_pageButton(context, 1));
      buttons.add(_pageButton(context, 2));
      buttons.add(const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.s),
        child: Text('…'),
      ));
      buttons.add(_pageButton(context, pageCount - 1));
    }

    return Row(
      children: [
        Text(
          'Showing $start to $end of $totalCount learners',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary(context),
          ),
        ),
        const Spacer(),
        IconButton(
          tooltip: 'Previous page',
          onPressed: page > 0 ? () => onPageChanged(page - 1) : null,
          icon: const Icon(Icons.chevron_left),
        ),
        ...buttons,
        IconButton(
          tooltip: 'Next page',
          onPressed: page < pageCount - 1
              ? () => onPageChanged(page + 1)
              : null,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }

  Widget _pageButton(BuildContext context, int index) {
    final selected = index == page;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: SizedBox(
        width: 36,
        height: 36,
        child: OutlinedButton(
          onPressed: selected ? null : () => onPageChanged(index),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            backgroundColor: selected
                ? AppColors.primary(context)
                : Colors.transparent,
            foregroundColor: selected
                ? AppColors.background(context)
                : AppColors.textPrimary(context),
            side: BorderSide(color: AppColors.border(context)),
            shape: RoundedRectangleBorder(borderRadius: AppRadius.small),
          ),
          child: Text('${index + 1}'),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title, message, action;
  final VoidCallback onAction;
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    required this.action,
    required this.onAction,
  });
  @override
  Widget build(BuildContext c) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.x3l),
    child: Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x3l,
        vertical: AppSpacing.x5l,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer(c),
        border: Border.all(color: AppColors.border(c)),
        borderRadius: AppRadius.large,
      ),
      child: Column(
        children: [
          Icon(icon, size: 56, color: AppColors.textMuted(c)),
          const SizedBox(height: AppSpacing.x2l),
          Text(
            title,
            style: Theme.of(
              c,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: AppSpacing.m),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(c).textTheme.bodyLarge,
          ),
          const SizedBox(height: AppSpacing.x2l),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary(c),
              foregroundColor: AppColors.background(c),
            ),
            onPressed: onAction,
            child: Text(action),
          ),
        ],
      ),
    ),
  );
}

class _DirectoryLoading extends StatelessWidget {
  const _DirectoryLoading();

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(AppSpacing.xl),
    children: [
      const SizedBox(height: 4),
      Container(
        height: 52,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.medium,
        ),
      ),
      const SizedBox(height: AppSpacing.l),
      SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 5,
          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.m),
          itemBuilder: (_, _) => Container(
            width: 108,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: AppRadius.medium,
            ),
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.x3l),
      Container(
        height: 64,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: AppRadius.medium,
        ),
      ),
      const SizedBox(height: AppSpacing.x2l),
      for (var index = 0; index < 6; index++)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.l),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(width: AppSpacing.l),
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
                    const SizedBox(height: AppSpacing.s),
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

Color _avatarColor(BuildContext context, String name) {
  final palette = [
    AppColors.information(context),
    AppColors.success(context),
    AppColors.warning(context),
    AppColors.danger(context),
  ];
  final surfaces = [
    AppColors.informationSurface(context),
    AppColors.successSurface(context),
    AppColors.warningSurface(context),
    AppColors.dangerSurface(context),
  ];
  final index = name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length;
  return surfaces[index];
}

Color _avatarTextColor(BuildContext context, String name) {
  final palette = [
    AppColors.information(context),
    AppColors.success(context),
    AppColors.warning(context),
    AppColors.danger(context),
  ];
  final index = name.isEmpty ? 0 : name.codeUnitAt(0) % palette.length;
  return palette[index];
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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/entities/structure_entities.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/attendance_category.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_scope.dart';
import '../bloc/attendance_bloc.dart';
import '../bloc/attendance_event.dart';
import '../bloc/attendance_state.dart';
import 'attendance_detail_screen.dart';
import 'attendance_statistics_screen.dart';

class _StatusFilter {
  final String label;
  final AttendanceStatus? status;
  const _StatusFilter(this.label, this.status);
}

const List<_StatusFilter> _kStatusFilters = [
  _StatusFilter('All Statuses', null),
  _StatusFilter('Present', AttendanceStatus.present),
  _StatusFilter('Absent', AttendanceStatus.absent),
  _StatusFilter('Late', AttendanceStatus.late),
  _StatusFilter('Excused', AttendanceStatus.excused),
];

/// One aggregated (scope, day, sessionType) group of AttendanceRecords -
/// the real per-person marks are grouped client-side since attendance_hub
/// stores one record per person, not one row per session.
class _SessionGroup {
  final String scopeId;
  final String scopeName;
  final String sessionType;
  final DateTime date;
  final List<AttendanceRecord> records;

  _SessionGroup({
    required this.scopeId,
    required this.scopeName,
    required this.sessionType,
    required this.date,
    required this.records,
  });

  int get present =>
      records.where((r) => r.status == AttendanceStatus.present).length;
  int get absent =>
      records.where((r) => r.status == AttendanceStatus.absent).length;
  int get late => records.where((r) => r.status == AttendanceStatus.late).length;
  int get total => records.length;
}

/// Matches the "Previous Attendances" mockup - one card per past session
/// grouped by (scope, day), with search, class/status/term filters, a
/// present/total count, a status pill, and an attendance-summary footer.
/// All data comes from AttendanceRepository.getRecords() via AttendanceBloc
/// - no mock/hardcoded records.
class PreviousAttendanceScreen extends StatefulWidget {
  const PreviousAttendanceScreen({super.key});

  @override
  State<PreviousAttendanceScreen> createState() =>
      _PreviousAttendanceScreenState();
}

class _PreviousAttendanceScreenState extends State<PreviousAttendanceScreen> {
  final _searchController = TextEditingController();
  final _scopesBloc = di.sl<AttendanceBloc>();

  List<AttendanceScope> _classes = [];
  String? _selectedScopeId;
  _StatusFilter _selectedStatus = _kStatusFilters.first;

  List<AcademicTerm> _terms = [];
  AcademicTerm? _selectedTerm;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _scopesBloc.add(
        LoadScopesRequested(
          schoolId: authState.user.schoolId,
          category: AttendanceCategory.students,
          operatorUser: authState.user,
        ),
      );
      _loadTerms(authState.user.schoolId);
    }
    _loadRecords();
  }

  Future<void> _loadTerms(String schoolId) async {
    List<AcademicTerm> terms;
    try {
      terms = await di
          .sl<StructureRepository>()
          .watchAcademicTerms(schoolId)
          .first
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      terms = const [];
    }
    if (!mounted) return;
    setState(() {
      _terms = terms;
      _selectedTerm = terms.isEmpty
          ? null
          : terms.firstWhere((t) => t.isCurrent, orElse: () => terms.first);
    });
    if (terms.isNotEmpty) _loadRecords();
  }

  void _loadRecords() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;
    context.read<AttendanceBloc>().add(
      LoadRecordsRequested(
        schoolId: authState.user.schoolId,
        operatorUser: authState.user,
        category: AttendanceCategory.students,
        scopeId: _selectedScopeId,
        from: _selectedTerm?.startDate,
        to: _selectedTerm?.endDate,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scopesBloc.close();
    super.dispose();
  }

  List<_SessionGroup> _groupBySession(List<AttendanceRecord> records) {
    final grouped = <String, _SessionGroup>{};
    for (final r in records) {
      final key =
          '${r.scopeId}_${r.sessionType}_${r.date.year}${r.date.month}${r.date.day}';
      final existing = grouped[key];
      if (existing != null) {
        existing.records.add(r);
      } else {
        grouped[key] = _SessionGroup(
          scopeId: r.scopeId,
          scopeName: r.scopeName.isEmpty ? r.scopeId : r.scopeName,
          sessionType: r.sessionType,
          date: r.date,
          records: [r],
        );
      }
    }
    final sessions = grouped.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return sessions;
  }

  List<_SessionGroup> _applyFilters(List<_SessionGroup> sessions) {
    final query = _searchController.text.trim().toLowerCase();
    return sessions.where((s) {
      if (_selectedStatus.status != null) {
        final hasStatus = s.records.any((r) => r.status == _selectedStatus.status);
        if (!hasStatus) return false;
      }
      if (query.isEmpty) return true;
      final dateText = DateFormat('d MMM yyyy').format(s.date).toLowerCase();
      final statusText = s.records.map((r) => r.status.name).join(' ');
      return s.scopeName.toLowerCase().contains(query) ||
          dateText.contains(query) ||
          statusText.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _scopesBloc,
      child: Scaffold(
        backgroundColor: AppColors.background(context),
        body: SafeArea(child: _buildBody(context)),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.border(context)),
              ),
              child: Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary(context),
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Previous Attendances',
              style: TextStyle(
                color: AppColors.textPrimary(context),
                fontWeight: FontWeight.w900,
                fontSize: 22,
                letterSpacing: -0.4,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.bar_chart_rounded,
              color: AppColors.primary(context),
            ),
            tooltip: 'Statistics',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BlocProvider(
                  create: (_) => di.sl<AttendanceBloc>(),
                  child: const AttendanceStatisticsScreen(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: AppColors.textPrimary(context)),
        decoration: InputDecoration(
          hintText: 'Search by class, date, or status',
          hintStyle: TextStyle(color: AppColors.textMuted(context)),
          prefixIcon: Icon(Icons.search, color: AppColors.textMuted(context)),
          filled: true,
          fillColor: AppColors.surfaceContainer(context),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primarySoft(context),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.primary(context)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: AppColors.primary(context),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 16,
              color: AppColors.primary(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFiltersRow(BuildContext context) {
    final classLabel = _selectedScopeId == null
        ? 'All Classes'
        : (_classes
                  .where((c) => c.id == _selectedScopeId)
                  .map((c) => c.name)
                  .firstOrNull ??
              'Class');
    final termLabel = _selectedTerm?.name ?? 'This Term';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip(
              context,
              icon: Icons.school_outlined,
              label: classLabel,
              onTap: _showClassSelector,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              icon: Icons.filter_alt_outlined,
              label: _selectedStatus.label,
              onTap: _showStatusSelector,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              context,
              icon: Icons.calendar_today_outlined,
              label: termLabel,
              onTap: _terms.isEmpty ? () {} : _showTermSelector,
            ),
          ],
        ),
      ),
    );
  }

  void _showClassSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              ListTile(
                title: Text(
                  'All Classes',
                  style: TextStyle(color: AppColors.textPrimary(context)),
                ),
                trailing: _selectedScopeId == null
                    ? Icon(Icons.check, color: AppColors.primary(context))
                    : null,
                onTap: () {
                  setState(() => _selectedScopeId = null);
                  Navigator.pop(context);
                  _loadRecords();
                },
              ),
              for (final c in _classes)
                ListTile(
                  title: Text(
                    c.name,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                  trailing: _selectedScopeId == c.id
                      ? Icon(Icons.check, color: AppColors.primary(context))
                      : null,
                  onTap: () {
                    setState(() => _selectedScopeId = c.id);
                    Navigator.pop(context);
                    _loadRecords();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showStatusSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final f in _kStatusFilters)
                ListTile(
                  title: Text(
                    f.label,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                  trailing: _selectedStatus.label == f.label
                      ? Icon(Icons.check, color: AppColors.primary(context))
                      : null,
                  onTap: () {
                    setState(() => _selectedStatus = f);
                    Navigator.pop(context);
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  void _showTermSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ListView(
            shrinkWrap: true,
            children: [
              for (final t in _terms)
                ListTile(
                  title: Text(
                    t.name,
                    style: TextStyle(color: AppColors.textPrimary(context)),
                  ),
                  trailing: _selectedTerm?.id == t.id
                      ? Icon(Icons.check, color: AppColors.primary(context))
                      : null,
                  onTap: () {
                    setState(() => _selectedTerm = t);
                    Navigator.pop(context);
                    _loadRecords();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(BuildContext context, _SessionGroup s) {
    if (s.absent > 0 && s.absent == s.total) return AppColors.danger(context);
    if (s.present == s.total) return AppColors.success(context);
    if (s.absent > 0) return AppColors.danger(context);
    return AppColors.warning(context);
  }

  String _statusLabel(_SessionGroup s) {
    if (s.present == s.total) return 'Present';
    if (s.present == 0) return 'Absent';
    return 'Partial';
  }

  Widget _buildSessionCard(BuildContext context, _SessionGroup session) {
    final color = _statusColor(context, session);
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<AttendanceBloc>(),
            child: AttendanceDetailScreen(
              records: session.records,
              title: session.scopeName,
            ),
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.l),
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated(context),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.groups_rounded, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.scopeName,
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    session.sessionType[0].toUpperCase() +
                        session.sessionType.substring(1),
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: AppColors.textMuted(context),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('d MMM yyyy').format(session.date),
                        style: TextStyle(
                          color: AppColors.textMuted(context),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(session),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${session.present} / ${session.total}',
                  style: TextStyle(
                    color: AppColors.textPrimary(context),
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(BuildContext context, List<_SessionGroup> sessions) {
    if (sessions.isEmpty) return const SizedBox.shrink();
    final totalPresent = sessions.fold<int>(0, (sum, s) => sum + s.present);
    final totalMarks = sessions.fold<int>(0, (sum, s) => sum + s.total);
    final avg = totalMarks == 0 ? 0 : (totalPresent / totalMarks * 100).round();

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) => di.sl<AttendanceBloc>(),
            child: const AttendanceStatisticsScreen(),
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.l),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary(context),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Summary',
                    style: TextStyle(
                      color: AppColors.textPrimary(context),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_selectedTerm?.name ?? 'This term'} average attendance: $avg%',
                    style: TextStyle(
                      color: AppColors.textMuted(context),
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocListener<AttendanceBloc, AttendanceState>(
      listenWhen: (previous, current) => current is ScopesLoaded,
      listener: (context, state) {
        if (state is ScopesLoaded) {
          setState(() => _classes = state.scopes);
        }
      },
      child: BlocBuilder<AttendanceBloc, AttendanceState>(
        buildWhen: (previous, current) =>
            current is RecordsLoaded ||
            current is AttendanceLoading ||
            current is AttendanceError ||
            current is AttendanceActionDenied,
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return Column(
              children: [
                _buildHeader(context),
                const Expanded(child: Center(child: SchoolPulseLoader())),
              ],
            );
          }
          if (state is AttendanceError || state is AttendanceActionDenied) {
            final message = state is AttendanceError
                ? state.message
                : (state as AttendanceActionDenied).message;
            return Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted(context)),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          if (state is! RecordsLoaded) {
            return Column(children: [_buildHeader(context)]);
          }

          final sessions = _applyFilters(_groupBySession(state.records));

          return Column(
            children: [
              _buildHeader(context),
              const SizedBox(height: 14),
              _buildSearchBar(context),
              const SizedBox(height: 12),
              _buildFiltersRow(context),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Records',
                      style: TextStyle(
                        color: AppColors.textPrimary(context),
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: sessions.isEmpty
                    ? Center(
                        child: Text(
                          'No attendance records yet',
                          style: TextStyle(color: AppColors.textMuted(context)),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        itemCount: sessions.length,
                        itemBuilder: (context, index) =>
                            _buildSessionCard(context, sessions[index]),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  AppSpacing.l,
                ),
                child: _buildSummary(context, sessions),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/components/pulse_table.dart';
import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/domain/repositories/staff_attendance_repository.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_cubit.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_state.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/admin/presentation/widgets/staff_attendance_correction_sheet.dart';
import 'package:school_pulse/features/admin/presentation/widgets/staff_attendance_export.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/structure/domain/repositories/structure_repository.dart';
import 'package:school_pulse/injection_container.dart' as di;

class AdminStaffAttendanceScreen extends StatelessWidget {
  const AdminStaffAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthBloc>().state;
    final user = auth is AuthAuthenticated ? auth.user : null;
    if (user == null || user.schoolId.isEmpty) {
      return const Scaffold(
        appBar: AdminAppBar(title: 'Staff Attendance'),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: 'Session unavailable',
          message: 'Sign in again to view staff attendance.',
        ),
      );
    }
    return BlocProvider(
      create: (_) => StaffAttendanceCubit(
        repository: di.sl<StaffAttendanceRepository>(),
        getStaffMembers: di.sl<GetStaffMembers>(),
        structureRepository: di.sl<StructureRepository>(),
        schoolId: user.schoolId,
      )..init(),
      child: StaffAttendanceView(user: user),
    );
  }
}

@visibleForTesting
class StaffAttendanceView extends StatelessWidget {
  const StaffAttendanceView({super.key, required this.user});

  final UserEntity user;

  bool get _canManage =>
      user.roles.any(UserRoleDisplay.staffAttendanceManagers.contains);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AdminAppBar(
        title: 'Staff Attendance',
        actions: [
          IconButton(
            tooltip: 'Filter by status',
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          if (_canManage)
            IconButton(
              tooltip: 'Export CSV',
              icon: const Icon(Icons.file_download_outlined),
              onPressed: () => _export(context),
            ),
        ],
      ),
      body: BlocBuilder<StaffAttendanceCubit, StaffAttendanceState>(
        builder: (context, state) {
          final cubit = context.read<StaffAttendanceCubit>();
          return RefreshIndicator(
            onRefresh: cubit.retry,
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                OfflineIndicator(
                  isOffline: state.isOffline,
                  lastSynced: DateTime.now(),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Controls(state: state),
                      const SizedBox(height: 20),
                      if (state.isLoading && state.records.isEmpty)
                        const _AttendanceSkeleton()
                      else if (state.error != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: EmptyState(
                            icon: Icons.cloud_off,
                            title: 'Could not load attendance',
                            message: state.error!,
                            ctaLabel: 'Retry',
                            onCtaPressed: cubit.retry,
                          ),
                        )
                      else ...[
                        _SummaryCards(summary: state.summary),
                        const SizedBox(height: 20),
                        _AttendanceLog(
                          state: state,
                          canManage: _canManage,
                          schoolId: user.schoolId,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    final cubit = context.read<StaffAttendanceCubit>();
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in StaffAttendanceFilter.values)
              ListTile(
                leading: Icon(
                  cubit.state.filter == f
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: cubit.state.filter == f
                      ? Theme.of(sheetContext).colorScheme.primary
                      : null,
                ),
                title: Text(_filterLabel(f)),
                onTap: () {
                  cubit.setFilter(f);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _export(BuildContext context) async {
    final cubit = context.read<StaffAttendanceCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final day = cubit.state.day;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(day.year - 2),
      lastDate: DateTime.now(),
      initialDateRange: DateTimeRange(start: day, end: day),
    );
    if (range == null) return;

    List<StaffAttendanceRecord> records;
    try {
      records = await cubit.fetchRange(from: range.start, to: range.end);
    } catch (_) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Export failed. Try again.')),
      );
      return;
    }

    final byStaff = {for (final s in cubit.state.roster) s.id: s};
    final buf = StringBuffer(
      'Staff,Staff code,Role,Campus,Clock-in,Clock-out,Status,Location,Corrected\n',
    );
    final fmt = DateFormat('yyyy-MM-dd HH:mm');
    for (final r in records) {
      final s = byStaff[r.staffId];
      buf.writeln(
        [
          _csv(s?.name ?? r.staffId),
          _csv(s?.staffCode ?? ''),
          _csv(s?.role.name ?? ''),
          _csv(r.campusId ?? ''),
          _csv(fmt.format(r.clockIn)),
          _csv(r.clockOut != null ? fmt.format(r.clockOut!) : ''),
          _csv(_statusWord(r.status)),
          _csv(r.location),
          _csv(r.wasCorrected ? 'yes' : 'no'),
        ].join(','),
      );
    }

    final name =
        'staff-attendance_${DateFormat('yyyyMMdd').format(range.start)}-'
        '${DateFormat('yyyyMMdd').format(range.end)}.csv';
    try {
      final outcome = await saveStaffAttendanceCsv(
        fileName: name,
        content: buf.toString(),
      );
      messenger.showSnackBar(SnackBar(content: Text('$outcome $name')));
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: buf.toString()));
      messenger.showSnackBar(
        const SnackBar(content: Text('CSV copied to clipboard')),
      );
    }
  }
}

String _csv(String v) => '"${v.replaceAll('"', '""')}"';

String _filterLabel(StaffAttendanceFilter f) => switch (f) {
  StaffAttendanceFilter.all => 'All staff',
  StaffAttendanceFilter.present => 'Present',
  StaffAttendanceFilter.late => 'Late',
  StaffAttendanceFilter.notClockedIn => 'Not clocked in',
  StaffAttendanceFilter.onLeave => 'On leave',
  StaffAttendanceFilter.absent => 'Absent',
};

String _statusWord(StaffAttendanceStatus s) => switch (s) {
  StaffAttendanceStatus.onTime => 'On time',
  StaffAttendanceStatus.late => 'Late',
  StaffAttendanceStatus.notClockedIn => 'Not clocked in',
  StaffAttendanceStatus.onLeave => 'On leave',
  StaffAttendanceStatus.absent => 'Absent',
};

Color _statusColor(BuildContext context, StaffAttendanceStatus s) {
  final semantic = Theme.of(context).extension<SemanticColors>()!;
  return switch (s) {
    StaffAttendanceStatus.onTime => semantic.success,
    StaffAttendanceStatus.late => semantic.warning,
    StaffAttendanceStatus.onLeave => semantic.info,
    StaffAttendanceStatus.absent => Theme.of(context).colorScheme.error,
    StaffAttendanceStatus.notClockedIn => Theme.of(context).colorScheme.outline,
  };
}

// --- Controls (date nav + campus + search) -----------------------------------

class _Controls extends StatelessWidget {
  const _Controls({required this.state});

  final StaffAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StaffAttendanceCubit>();
    final isToday =
        state.day ==
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    final dateRow = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Previous day',
          icon: const Icon(Icons.chevron_left),
          onPressed: cubit.previousDay,
        ),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: state.day,
              firstDate: DateTime(state.day.year - 2),
              lastDate: DateTime.now(),
            );
            if (picked != null) cubit.setDay(picked);
          },
          child: Text(
            isToday
                ? 'Today · ${DateFormat('d MMM').format(state.day)}'
                : DateFormat('EEE, d MMM y').format(state.day),
          ),
        ),
        IconButton(
          tooltip: 'Next day',
          icon: const Icon(Icons.chevron_right),
          onPressed: cubit.canGoNext ? cubit.nextDay : null,
        ),
        if (!isToday)
          TextButton(onPressed: cubit.goToToday, child: const Text('Today')),
      ],
    );

    final campusDropdown = state.campuses.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            width: 200,
            child: DropdownButtonFormField<String?>(
              initialValue: state.campusId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Campus',
                isDense: true,
              ),
              items: [
                const DropdownMenuItem(
                  value: null,
                  child: Text('All campuses'),
                ),
                for (final c in state.campuses)
                  DropdownMenuItem(value: c.id, child: Text(c.name)),
              ],
              onChanged: cubit.setCampus,
            ),
          );

    final search = SizedBox(
      width: 280,
      child: AppSearchField(
        hintText: 'Search staff name or code…',
        onChanged: cubit.setQuery,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 720) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: dateRow,
              ),
              const SizedBox(height: 8),
              if (state.campuses.isNotEmpty) ...[
                campusDropdown,
                const SizedBox(height: 8),
              ],
              SizedBox(width: double.infinity, child: search),
            ],
          );
        }
        return Wrap(
          spacing: 16,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            dateRow,
            if (state.campuses.isNotEmpty) campusDropdown,
            search,
          ],
        );
      },
    );
  }
}

// --- Summary cards ---------------------------------------------------------

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.summary});

  final StaffAttendanceSummary summary;

  @override
  Widget build(BuildContext context) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final avg = summary.avgClockInMinutes;
    final avgLabel = avg == null
        ? '--'
        : '${(avg ~/ 60).toString().padLeft(2, '0')}:'
              '${(avg % 60).toString().padLeft(2, '0')}';

    final cards = [
      DashboardStatCard(
        title: 'Present now',
        value: summary.present.toDouble(),
        icon: Icons.person_pin_circle,
        color: semantic.success,
        trend: 'of ${summary.total} staff',
      ),
      DashboardStatCard(
        title: 'Late arrivals',
        value: summary.late.toDouble(),
        icon: Icons.access_time_filled,
        color: semantic.warning,
        trend: 'clocked in late',
      ),
      DashboardStatCard(
        title: 'Not clocked in',
        value: summary.notClockedIn.toDouble(),
        icon: Icons.event_busy,
        color: semantic.info,
        trend: summary.onLeave > 0 ? '${summary.onLeave} on leave' : 'today',
      ),
      DashboardStatCard(
        title: 'Average clock-in',
        value: 0,
        suffix: avgLabel,
        icon: Icons.speed,
        color: Theme.of(context).colorScheme.primary,
        trend: 'today',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 16.0;
        // Give each card at least ~230px; drop to 2-up, then 1-up as space
        // shrinks so the shared DashboardStatCard never has to overflow.
        final perRow = constraints.maxWidth >= 4 * 230 + 3 * gap
            ? 4
            : constraints.maxWidth >= 2 * 230 + gap
            ? 2
            : 1;
        final cardWidth = perRow == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - (perRow - 1) * gap) / perRow;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final c in cards) SizedBox(width: cardWidth, child: c),
          ],
        );
      },
    );
  }
}

// --- Attendance log ------------------------------------------------------

class _AttendanceLog extends StatelessWidget {
  const _AttendanceLog({
    required this.state,
    required this.canManage,
    required this.schoolId,
  });

  final StaffAttendanceState state;
  final bool canManage;
  final String schoolId;

  @override
  Widget build(BuildContext context) {
    final rows = state.pagedRows;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              'Attendance log  (${state.filteredCount})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: EmptyState(
                icon: Icons.badge_outlined,
                title: state.roster.isEmpty
                    ? 'No staff yet'
                    : 'No records match',
                message: state.roster.isEmpty
                    ? 'Add staff members to start tracking attendance.'
                    : 'Try a different date, campus, search or filter.',
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 720) {
                  return Column(
                    children: [
                      for (final r in rows)
                        _StaffTile(
                          row: r,
                          canManage: canManage,
                          onCorrect: () => _openCorrection(context, r),
                        ),
                    ],
                  );
                }
                return _DesktopTable(
                  rows: rows,
                  canManage: canManage,
                  onCorrect: (r) => _openCorrection(context, r),
                );
              },
            ),
          if (rows.isNotEmpty) _Pager(state: state),
        ],
      ),
    );
  }

  Future<void> _openCorrection(
    BuildContext context,
    StaffAttendanceRow row,
  ) async {
    final ok = await StaffAttendanceCorrectionSheet.show(
      context,
      schoolId: schoolId,
      day: state.day,
      row: row,
    );
    if (ok == true && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Attendance corrected')));
    }
  }
}

class _DesktopTable extends StatelessWidget {
  const _DesktopTable({
    required this.rows,
    required this.canManage,
    required this.onCorrect,
  });

  final List<StaffAttendanceRow> rows;
  final bool canManage;
  final void Function(StaffAttendanceRow) onCorrect;

  @override
  Widget build(BuildContext context) {
    final timeFmt = DateFormat('hh:mm a');
    return PulseTable<StaffAttendanceRow>(
      items: rows,
      columns: [
        PulseTableColumn(
          title: 'Staff',
          cellBuilder: (r) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AvatarInitials(name: r.staff.name, size: 32),
              const SizedBox(width: 12),
              Text(
                r.staff.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        PulseTableColumn(
          title: 'Role',
          cellBuilder: (r) => Text(r.staff.role.name),
        ),
        PulseTableColumn(
          title: 'Clock-in',
          cellBuilder: (r) =>
              Text(r.record != null ? timeFmt.format(r.record!.clockIn) : '--'),
        ),
        PulseTableColumn(
          title: 'Clock-out',
          cellBuilder: (r) => Text(
            r.record?.clockOut != null
                ? timeFmt.format(r.record!.clockOut!)
                : '--',
          ),
        ),
        PulseTableColumn(
          title: 'Status',
          cellBuilder: (r) => StatusBadge(
            label: _statusWord(r.status),
            color: _statusColor(context, r.status),
          ),
        ),
        PulseTableColumn(
          title: 'Location',
          cellBuilder: (r) => Text(r.record?.location ?? '—'),
        ),
        if (canManage)
          PulseTableColumn(
            title: '',
            cellBuilder: (r) => IconButton(
              tooltip: 'Correct',
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: () => onCorrect(r),
            ),
          ),
      ],
    );
  }
}

class _StaffTile extends StatelessWidget {
  const _StaffTile({
    required this.row,
    required this.canManage,
    required this.onCorrect,
  });

  final StaffAttendanceRow row;
  final bool canManage;
  final VoidCallback onCorrect;

  @override
  Widget build(BuildContext context) {
    final record = row.record;
    final timeFmt = DateFormat('hh:mm a');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          AvatarInitials(name: row.staff.name, size: 36),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  row.staff.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  record != null
                      ? '${timeFmt.format(record.clockIn)}'
                            '${record.clockOut != null ? ' – ${timeFmt.format(record.clockOut!)}' : ''}'
                      : row.staff.role.name,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          StatusBadge(
            label: _statusWord(row.status),
            color: _statusColor(context, row.status),
          ),
          if (canManage)
            IconButton(
              tooltip: 'Correct',
              icon: const Icon(Icons.edit_outlined, size: 18),
              onPressed: onCorrect,
            ),
        ],
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  const _Pager({required this.state});

  final StaffAttendanceState state;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<StaffAttendanceCubit>();
    final (start, end) = state.pageRange;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Showing $start–$end of ${state.filteredCount}',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: state.safePage > 0 ? cubit.previousPage : null,
              ),
              Text('${state.safePage + 1} / ${state.pageCount}'),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: state.safePage < state.pageCount - 1
                    ? cubit.nextPage
                    : null,
              ),
            ],
          ),
        ],
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
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: List.generate(4, (_) => const Skeleton(borderRadius: 16)),
        ),
        const SizedBox(height: 20),
        const AppCard(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Skeleton(width: 150, height: 20),
                  Skeleton(width: 200, height: 40),
                ],
              ),
              SizedBox(height: 20),
              Skeleton(height: 360),
            ],
          ),
        ),
      ],
    );
  }
}

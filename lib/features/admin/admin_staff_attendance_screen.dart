import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/data/repositories/staff_attendance_repository.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/injection_container.dart' as di;

enum _StatusFilter { all, present, late, notClockedIn }

class AdminStaffAttendanceScreen extends StatefulWidget {
  const AdminStaffAttendanceScreen({super.key});

  @override
  State<AdminStaffAttendanceScreen> createState() => _AdminStaffAttendanceScreenState();
}

class _AdminStaffAttendanceScreenState extends State<AdminStaffAttendanceScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  _StatusFilter _filter = _StatusFilter.all;
  List<UserEntity>? _staff;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    result.fold(
      (_) => setState(() => _staff = const []),
      (staff) => setState(() => _staff = staff),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
      appBar: AppBar(
        title: const Text('Staff Attendance Monitor'),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list), onPressed: _showFilterSheet),
          IconButton(icon: const Icon(Icons.file_download_outlined), onPressed: _exportCsv),
        ],
      ),
      body: StreamBuilder<Map<String, StaffAttendanceRecord>>(
        stream: di.sl<StaffAttendanceRepository>().watchToday(),
        builder: (context, snapshot) {
          if (_staff == null || snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data ?? const {};
          final staff = _staff!;

          var rows = staff.map((s) => (staff: s, record: records[s.id])).toList();
          if (_query.isNotEmpty) {
            rows = rows.where((r) => r.staff.name.toLowerCase().contains(_query)).toList();
          }
          rows = rows.where((r) {
            switch (_filter) {
              case _StatusFilter.all:
                return true;
              case _StatusFilter.present:
                return r.record != null && r.record!.status != 'late';
              case _StatusFilter.late:
                return r.record?.status == 'late';
              case _StatusFilter.notClockedIn:
                return r.record == null;
            }
          }).toList();

          final presentCount = staff.where((s) => records[s.id] != null).length;
          final lateCount = staff.where((s) => records[s.id]?.status == 'late').length;
          final notClockedIn = staff.length - presentCount;
          final clockTimes = records.values.map((r) => r.clockIn).toList();
          final avgClockIn = clockTimes.isEmpty
              ? null
              : clockTimes.map((t) => t.hour * 60 + t.minute).reduce((a, b) => a + b) ~/ clockTimes.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                _buildAttendanceOverview(context, staff.length, presentCount, lateCount, notClockedIn, avgClockIn),
                const SizedBox(height: 24),
                _buildStaffList(context, rows),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceOverview(
    BuildContext context,
    int total,
    int present,
    int late,
    int notClockedIn,
    int? avgClockInMinutes,
  ) {
    final semantic = Theme.of(context).extension<SemanticColors>()!;
    final avgLabel = avgClockInMinutes == null
        ? '--'
        : '${(avgClockInMinutes ~/ 60).toString().padLeft(2, '0')}:${(avgClockInMinutes % 60).toString().padLeft(2, '0')}';

    return LayoutBuilder(builder: (context, constraints) {
      final isMobile = constraints.maxWidth < 700;
      final cards = [
        DashboardStatCard(title: 'Present Now', value: present.toDouble(), icon: Icons.person_pin_circle, color: semantic.success, trend: 'Out of $total total'),
        DashboardStatCard(title: 'Late Arrivals', value: late.toDouble(), icon: Icons.access_time_filled, color: semantic.warning, trend: 'Today'),
        DashboardStatCard(title: 'Not Clocked In', value: notClockedIn.toDouble(), icon: Icons.event_busy, color: semantic.info, trend: 'Today'),
        DashboardStatCard(title: 'Avg. Clock-in', value: 0, suffix: avgLabel, icon: Icons.speed, color: Colors.purple, trend: 'Today', decimalPlaces: 0),
      ];
      if (isMobile) {
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.3,
          children: cards,
        );
      }
      return Row(
        children: cards
            .expand((c) => [Expanded(child: c), const SizedBox(width: 16)])
            .toList()
          ..removeLast(),
      );
    });
  }

  Widget _buildStaffList(BuildContext context, List<({UserEntity staff, StaffAttendanceRecord? record})> rows) {
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daily Attendance Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                SizedBox(
                  width: 250,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
                    decoration: const InputDecoration(
                      hintText: 'Search staff name...',
                      prefixIcon: Icon(Icons.search),
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: EmptyState(
                icon: Icons.badge_outlined,
                title: 'No staff match',
                message: 'Try a different search or filter.',
              ),
            )
          else
            DataTable(
              columnSpacing: 24,
              columns: const [
                DataColumn(label: Text('Staff Member')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Clock In')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Location')),
              ],
              rows: rows.map((r) {
                final semantic = Theme.of(context).extension<SemanticColors>()!;
                final record = r.record;
                return DataRow(cells: [
                  DataCell(Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AvatarInitials(name: r.staff.name, size: 32),
                      const SizedBox(width: 12),
                      Text(r.staff.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  )),
                  DataCell(Text(r.staff.role.name)),
                  DataCell(Text(record != null ? DateFormat('hh:mm a').format(record.clockIn) : '--')),
                  DataCell(StatusBadge(
                    label: record == null ? 'Not Clocked In' : (record.status == 'late' ? 'Late' : 'On Time'),
                    color: record == null ? Theme.of(context).colorScheme.outline : (record.status == 'late' ? semantic.warning : semantic.success),
                  )),
                  DataCell(Text(record?.location ?? '—')),
                ]);
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final f in _StatusFilter.values)
              ListTile(
                leading: Icon(
                  _filter == f ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                  color: _filter == f ? Theme.of(sheetContext).colorScheme.primary : null,
                ),
                title: Text(switch (f) {
                  _StatusFilter.all => 'All Staff',
                  _StatusFilter.present => 'Present',
                  _StatusFilter.late => 'Late',
                  _StatusFilter.notClockedIn => 'Not Clocked In',
                }),
                onTap: () {
                  setState(() => _filter = f);
                  Navigator.pop(sheetContext);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportCsv() async {
    if (_staff == null) return;
    final buffer = StringBuffer('Name,Role,Status\n');
    for (final s in _staff!) {
      buffer.writeln('"${s.name}","${s.role.name}","${s.isActive ? 'Active' : 'Disabled'}"');
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Staff roster copied to clipboard as CSV')),
      );
    }
  }
}

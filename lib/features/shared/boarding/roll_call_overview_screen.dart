import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/shared/boarding/boarding_list_widgets.dart';

/// Plain, role-agnostic data shape for a single dormitory shown in the Roll
/// Call overview - deliberately not the Patron/Matron `Dormitory` entity, so
/// this file never imports either role's domain layer.
class RollCallDormitory {
  final String id;
  final String name;

  const RollCallDormitory({required this.id, required this.name});
}

/// Plain, role-agnostic attendance record shape mirroring the fields this
/// screen needs from `BoardingAttendance` (Patron/Matron entity), passed in
/// by the per-role wrapper so this file stays bloc/entity-agnostic.
class RollCallAttendanceRecord {
  final String studentId;
  final String dormitoryId;
  final String status; // 'present' | 'absent' | 'late' | 'leave'

  const RollCallAttendanceRecord({
    required this.studentId,
    required this.dormitoryId,
    required this.status,
  });
}

const kRollCallSessionTypes = ['Morning', 'Evening', 'Weekend'];

/// Shared Roll Call overview/landing screen - segmented session tabs, a date
/// header, the present-percent gauge, a per-dorm breakdown list, and a
/// "Start Roll Call" button that opens a dormitory picker. Identical for
/// Patron (boys) and Matron (girls); the per-role wrapper screen supplies
/// live data + callbacks so no PatronBloc/MatronBloc reference belongs here.
class RollCallOverviewScreen extends StatelessWidget {
  final String selectedType;
  final ValueChanged<String> onTypeChanged;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final List<RollCallDormitory> dormitories;
  final List<RollCallAttendanceRecord> attendanceRecords;
  final bool isLoading;
  final void Function(String dormitoryId, String dormitoryName) onStartRollCall;
  final String title;

  const RollCallOverviewScreen({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.selectedDate,
    required this.onDateChanged,
    required this.dormitories,
    required this.attendanceRecords,
    required this.isLoading,
    required this.onStartRollCall,
    this.title = 'Roll Call',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final presentCount = attendanceRecords
        .where((r) => r.status.toLowerCase() == 'present')
        .length;
    final absentCount = attendanceRecords
        .where((r) => r.status.toLowerCase() == 'absent')
        .length;
    final lateCount = attendanceRecords
        .where((r) => r.status.toLowerCase() == 'late')
        .length;
    final totalCount = attendanceRecords.length;
    final presentPercent = totalCount == 0 ? 0.0 : presentCount / totalCount;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: RefreshIndicator(
        onRefresh: () async => onDateChanged(selectedDate),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.l,
            AppSpacing.x4l,
          ),
          children: [
            SegmentedTabControl(
              labels: kRollCallSessionTypes,
              selectedIndex: kRollCallSessionTypes.contains(selectedType)
                  ? kRollCallSessionTypes.indexOf(selectedType)
                  : 0,
              onChanged: (i) => onTypeChanged(kRollCallSessionTypes[i]),
            ),
            const SizedBox(height: AppSpacing.l),
            _DateHeader(
              selectedDate: selectedDate,
              onDateChanged: onDateChanged,
            ),
            const SizedBox(height: AppSpacing.l),
            if (isLoading)
              const Skeleton(height: 260, borderRadius: 20)
            else
              RollCallGaugeCard(
                presentPercent: presentPercent,
                presentCount: presentCount,
                absentCount: absentCount,
                lateCount: lateCount,
                totalCount: totalCount,
              ),
            const SizedBox(height: AppSpacing.x3l),
            SectionHeader(title: 'Dormitory Breakdown'),
            const SizedBox(height: AppSpacing.s),
            if (isLoading)
              const Skeleton(height: 160, borderRadius: 16)
            else if (dormitories.isEmpty)
              const EmptyState(
                icon: Icons.home_outlined,
                title: 'No Dormitories',
                message: 'No dormitories have been added yet.',
              )
            else
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
                child: Column(
                  children: [
                    for (var i = 0; i < dormitories.length; i++) ...[
                      if (i > 0)
                        Divider(
                          height: 1,
                          color: theme.colorScheme.outlineVariant,
                        ),
                      _dormBreakdownRow(dormitories[i]),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.x3l),
            PrimaryButton(
              label: 'Start Roll Call',
              icon: Icons.how_to_reg_outlined,
              onPressed: dormitories.isEmpty
                  ? null
                  : () => _showDormPicker(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dormBreakdownRow(RollCallDormitory dorm) {
    final records = attendanceRecords.where((r) => r.dormitoryId == dorm.id);
    final present = records
        .where((r) => r.status.toLowerCase() == 'present')
        .length;
    final absent = records
        .where((r) => r.status.toLowerCase() == 'absent')
        .length;
    final late = records.where((r) => r.status.toLowerCase() == 'late').length;

    return RollCallDormBreakdownRow(
      dormName: dorm.name,
      presentCount: present,
      absentCount: absent,
      lateCount: late,
      onTap: () => onStartRollCall(dorm.id, dorm.name),
    );
  }

  void _showDormPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        itemCount: dormitories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(dormitories[index].name),
          onTap: () {
            Navigator.pop(context);
            onStartRollCall(dormitories[index].id, dormitories[index].name);
          },
        ),
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const _DateHeader({required this.selectedDate, required this.onDateChanged});

  bool get _isToday {
    final now = DateTime.now();
    return selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () =>
              onDateChanged(selectedDate.subtract(const Duration(days: 1))),
        ),
        Column(
          children: [
            Text(
              _isToday
                  ? 'Today'
                  : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (_isToday)
              Text(
                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed:
              selectedDate.isBefore(
                DateTime.now().subtract(const Duration(days: 1)),
              )
              ? () => onDateChanged(selectedDate.add(const Duration(days: 1)))
              : null,
        ),
      ],
    );
  }
}

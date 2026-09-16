import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_state.dart';

/// Desktop right-hand panel showing the selected staff member's detail and
/// quick actions - replaces unused blank space in the wide layout. Shown
/// when [row] is non-null (i.e. `state.selectedStaffId` matches a roster
/// entry); [StaffAttendanceView] renders a prompt state itself when nothing
/// is selected, so this widget never needs its own empty branch.
class StaffAttendanceDetailPanel extends StatelessWidget {
  const StaffAttendanceDetailPanel({
    super.key,
    required this.row,
    required this.canManage,
    required this.onCorrect,
    required this.onMarkAttendance,
    required this.onClose,
  });

  final StaffAttendanceRow row;
  final bool canManage;
  final VoidCallback onCorrect;
  final VoidCallback onMarkAttendance;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final record = row.record;
    final shift = row.shift;
    final timeFmt = DateFormat('hh:mm a');
    final semantic = Theme.of(context).extension<SemanticColors>()!;

    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Staff details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Close',
                icon: const Icon(Icons.close, size: 18),
                onPressed: onClose,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              AvatarInitials(name: row.staff.name, size: 48),
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
                      row.staff.role.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          _DetailRow(
            label: 'Status',
            child: StatusBadge(
              label: _statusWord(row.status),
              color: switch (row.status) {
                StaffAttendanceStatus.onTime => semantic.success,
                StaffAttendanceStatus.late => semantic.warning,
                StaffAttendanceStatus.onLeave => semantic.info,
                StaffAttendanceStatus.absent => Theme.of(
                  context,
                ).colorScheme.error,
                StaffAttendanceStatus.notClockedIn => Theme.of(
                  context,
                ).colorScheme.error,
              },
            ),
          ),
          _DetailRow(
            label: 'Scheduled shift',
            value: shift != null
                ? '${shift.scheduledStart} – ${shift.scheduledEnd}'
                : '—',
          ),
          _DetailRow(
            label: 'Clock-in',
            value: record != null ? timeFmt.format(record.clockIn) : '—',
          ),
          _DetailRow(
            label: 'Clock-out',
            value: record?.clockOut != null
                ? timeFmt.format(record!.clockOut!)
                : '—',
          ),
          _DetailRow(label: 'Location', value: record?.location ?? '—'),
          if (record?.wasCorrected ?? false)
            const _DetailRow(label: 'Corrected', value: 'Yes'),
          if (canManage) ...[
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Text(
              'Quick actions',
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            if (row.status == StaffAttendanceStatus.notClockedIn)
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onMarkAttendance,
                  icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                  label: const Text('Mark attendance'),
                ),
              ),
            if (row.status != StaffAttendanceStatus.notClockedIn) ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onCorrect,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Correct attendance'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, this.value, this.child});

  final String label;
  final String? value;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child:
                child ??
                Text(value ?? '—', style: const TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

String _statusWord(StaffAttendanceStatus s) => switch (s) {
  StaffAttendanceStatus.onTime => 'On time',
  StaffAttendanceStatus.late => 'Late',
  StaffAttendanceStatus.notClockedIn => 'Not clocked in',
  StaffAttendanceStatus.onLeave => 'On leave',
  StaffAttendanceStatus.absent => 'Absent',
};

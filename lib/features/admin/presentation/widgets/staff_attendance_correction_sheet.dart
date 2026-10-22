import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:school_pulse/features/admin/data/models/staff_attendance_record.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_cubit.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_state.dart';

/// Bottom sheet for an authorised manual correction of one staff member's
/// attendance on a given day. Submits via [StaffAttendanceCubit.submitCorrection]
/// (the `correctStaffAttendance` callable, with an offline-queue fallback);
/// the dashboard's live stream picks up the change once synced.
class StaffAttendanceCorrectionSheet extends StatefulWidget {
  const StaffAttendanceCorrectionSheet({
    super.key,
    required this.cubit,
    required this.schoolId,
    required this.day,
    required this.row,
  });

  final StaffAttendanceCubit cubit;
  final String schoolId;
  final DateTime day;
  final StaffAttendanceRow row;

  static Future<bool?> show(
    BuildContext context, {
    required StaffAttendanceCubit cubit,
    required String schoolId,
    required DateTime day,
    required StaffAttendanceRow row,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: StaffAttendanceCorrectionSheet(
          cubit: cubit,
          schoolId: schoolId,
          day: day,
          row: row,
        ),
      ),
    );
  }

  @override
  State<StaffAttendanceCorrectionSheet> createState() =>
      _StaffAttendanceCorrectionSheetState();
}

class _StaffAttendanceCorrectionSheetState
    extends State<StaffAttendanceCorrectionSheet> {
  late StaffAttendanceStatus _status;
  TimeOfDay? _clockIn;
  TimeOfDay? _clockOut;
  late final TextEditingController _location;
  final _reason = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    final rec = widget.row.record;
    _status = rec?.status ?? StaffAttendanceStatus.onTime;
    if (_status == StaffAttendanceStatus.notClockedIn) {
      _status = StaffAttendanceStatus.onTime;
    }
    _clockIn = rec != null ? TimeOfDay.fromDateTime(rec.clockIn) : null;
    _clockOut = rec?.clockOut != null
        ? TimeOfDay.fromDateTime(rec!.clockOut!)
        : null;
    _location = TextEditingController(text: rec?.location ?? '');
  }

  @override
  void dispose() {
    _location.dispose();
    _reason.dispose();
    super.dispose();
  }

  DateTime? _combine(TimeOfDay? t) {
    if (t == null) return null;
    return DateTime(
      widget.day.year,
      widget.day.month,
      widget.day.day,
      t.hour,
      t.minute,
    );
  }

  bool get _needsClockTimes =>
      _status == StaffAttendanceStatus.onTime ||
      _status == StaffAttendanceStatus.late;

  Future<void> _submit() async {
    final reason = _reason.text.trim();
    if (reason.isEmpty) {
      setState(() => _error = 'A reason is required.');
      return;
    }
    final clockIn = _combine(_clockIn);
    final clockOut = _combine(_clockOut);
    if (_needsClockTimes && clockIn == null) {
      setState(() => _error = 'Set a clock-in time.');
      return;
    }
    if (clockIn != null && clockOut != null && clockOut.isBefore(clockIn)) {
      setState(() => _error = 'Clock-out cannot be before clock-in.');
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final queued = await widget.cubit.submitCorrection(
        staffId: widget.row.staff.id,
        day: widget.day,
        reason: reason,
        patch: {
          'status': _status.wire,
          if (clockIn != null) 'clockIn': clockIn.toIso8601String(),
          if (clockOut != null) 'clockOut': clockOut.toIso8601String(),
          if (_location.text.trim().isNotEmpty)
            'location': _location.text.trim(),
        },
      );
      if (mounted) Navigator.of(context).pop(queued ? false : true);
    } on FirebaseFunctionsException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message ?? 'Correction failed. Try again.';
      });
    } catch (_) {
      setState(() {
        _submitting = false;
        _error = 'Correction failed. Check your connection and try again.';
      });
    }
  }

  Future<void> _pickTime(bool isClockIn) async {
    final picked = await showTimePicker(
      context: context,
      initialTime:
          (isClockIn ? _clockIn : _clockOut) ??
          const TimeOfDay(hour: 8, minute: 0),
    );
    if (picked == null) return;
    setState(() {
      if (isClockIn) {
        _clockIn = picked;
      } else {
        _clockOut = picked;
      }
    });
  }

  String _statusLabel(StaffAttendanceStatus s) => switch (s) {
    StaffAttendanceStatus.onTime => 'On time',
    StaffAttendanceStatus.late => 'Late',
    StaffAttendanceStatus.onLeave => 'On leave',
    StaffAttendanceStatus.absent => 'Absent',
    StaffAttendanceStatus.notClockedIn => 'Not clocked in',
  };

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Correct attendance',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.row.staff.name} · '
              '${DateFormat('EEE, d MMM y').format(widget.day)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<StaffAttendanceStatus>(
              initialValue: _status,
              decoration: const InputDecoration(labelText: 'Status'),
              items: StaffAttendanceStatus.correctable
                  .map(
                    (s) => DropdownMenuItem(
                      value: s,
                      child: Text(_statusLabel(s)),
                    ),
                  )
                  .toList(),
              onChanged: _submitting
                  ? null
                  : (s) => setState(() => _status = s ?? _status),
            ),
            const SizedBox(height: 12),
            if (_needsClockTimes) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _submitting ? null : () => _pickTime(true),
                      icon: const Icon(Icons.login, size: 18),
                      label: Text(
                        _clockIn == null
                            ? 'Clock-in'
                            : _clockIn!.format(context),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _submitting ? null : () => _pickTime(false),
                      icon: const Icon(Icons.logout, size: 18),
                      label: Text(
                        _clockOut == null
                            ? 'Clock-out'
                            : _clockOut!.format(context),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _location,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g. Main campus',
                ),
              ),
              const SizedBox(height: 12),
            ],
            TextField(
              controller: _reason,
              enabled: !_submitting,
              maxLength: 300,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Reason (required)',
                hintText: 'Why is this being corrected?',
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(
                _error!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save correction'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

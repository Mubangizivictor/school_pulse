import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_cubit.dart';
import 'package:school_pulse/features/admin/presentation/bloc/staff_attendance/staff_attendance_state.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';

/// Bottom sheet for the authorised "Mark staff attendance" action - a
/// same-day clock-in, distinct from [StaffAttendanceCorrectionSheet] which
/// edits an existing day's record. Submits via [StaffAttendanceCubit.markAttendance],
/// which calls the `clockInStaff` callable.
class MarkStaffAttendanceSheet extends StatefulWidget {
  const MarkStaffAttendanceSheet({
    super.key,
    required this.cubit,
    required this.staff,
  });

  final StaffAttendanceCubit cubit;
  final UserEntity staff;

  static Future<bool?> show(
    BuildContext context, {
    required StaffAttendanceCubit cubit,
    required UserEntity staff,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: MarkStaffAttendanceSheet(cubit: cubit, staff: staff),
      ),
    );
  }

  @override
  State<MarkStaffAttendanceSheet> createState() =>
      _MarkStaffAttendanceSheetState();
}

class _MarkStaffAttendanceSheetState extends State<MarkStaffAttendanceSheet> {
  final _location = TextEditingController();

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = await widget.cubit.markAttendance(
      widget.staff.id,
      location: _location.text.trim().isEmpty ? null : _location.text.trim(),
    );
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StaffAttendanceCubit, StaffAttendanceState>(
      bloc: widget.cubit,
      builder: (context, state) {
        final submitting = state.isSubmittingAction;
        final error = state.actionError;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mark staff attendance',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.staff.name} · clock in now',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _location,
                  enabled: !submitting,
                  decoration: const InputDecoration(
                    labelText: 'Location (optional)',
                    hintText: 'e.g. Main campus',
                  ),
                ),
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    error,
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
                    onPressed: submitting ? null : _submit,
                    child: submitting
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Mark attendance'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

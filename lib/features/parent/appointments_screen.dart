import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:school_pulse/features/appointments/domain/entities/appointment.dart';
import 'package:school_pulse/features/appointments/domain/entities/appointment_status.dart';
import 'package:school_pulse/features/appointments/domain/entities/appointment_type.dart';
import 'package:school_pulse/features/appointments/domain/entities/staff_summary.dart';
import 'package:school_pulse/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_bloc.dart';
import 'package:school_pulse/features/student/presentation/bloc/selected_student_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'widgets/student_app_bar.dart';

/// Parent-facing view over [AppointmentRepository.watchForParent]. Parents
/// may request and cancel their own appointments only - approve/reject,
/// check-in/out and deletion stay staff-only actions on
/// AppointmentsWorkspaceScreen, so this screen exposes a deliberately
/// smaller action set than that one.
class ParentAppointmentsScreen extends StatefulWidget {
  const ParentAppointmentsScreen({super.key});

  @override
  State<ParentAppointmentsScreen> createState() =>
      _ParentAppointmentsScreenState();
}

class _ParentAppointmentsScreenState extends State<ParentAppointmentsScreen> {
  final AppointmentRepository _repo = di.sl<AppointmentRepository>();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: SchoolPulseLoader()));
    }
    final parent = authState.user;

    return Scaffold(
      appBar: const StudentAppBar(title: 'Appointments'),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRequestSheet(context, parent),
        icon: const Icon(Icons.add),
        label: const Text('Request'),
      ),
      body: StreamBuilder<List<Appointment>>(
        stream: _repo.watchForParent(parent.id, parent.schoolId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: SchoolPulseLoader());
          }
          if (snapshot.hasError) {
            return EmptyState(
              icon: Icons.cloud_off,
              title: 'Could not load appointments',
              message: 'Check your connection, then try again.',
              ctaLabel: 'Retry',
              onCtaPressed: () => setState(() {}),
            );
          }
          final appointments = snapshot.data ?? const <Appointment>[];
          if (appointments.isEmpty) {
            return EmptyState(
              icon: Icons.event_available_outlined,
              title: 'No appointments yet',
              message: 'Request a meeting with a teacher or staff member.',
            );
          }
          final sorted = [...appointments]
            ..sort((a, b) => b.scheduledStart.compareTo(a.scheduledStart));
          return RefreshIndicator(
            onRefresh: () async => setState(() {}),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              itemCount: sorted.length,
              itemBuilder: (context, index) {
                final appointment = sorted[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _AppointmentCard(
                    appointment: appointment,
                    onCancel: appointment.requesterId == parent.id
                        ? () => _cancel(context, appointment, parent.id)
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _cancel(
    BuildContext context,
    Appointment appointment,
    String parentId,
  ) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Cancel appointment?',
      message:
          'This cancels the ${appointment.appointmentTypeName} meeting with '
          '${appointment.staffName}.',
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    final result = await _repo.cancelAppointment(
      id: appointment.id,
      cancelledBy: parentId,
    );
    if (!context.mounted) return;
    result.fold(
      (failure) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure.message))),
      (_) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Appointment cancelled'))),
    );
  }

  Future<void> _openRequestSheet(
    BuildContext context,
    UserEntity parent,
  ) async {
    final selectedStudent = context.read<SelectedStudentBloc>().state;
    final studentName = selectedStudent is SelectedStudentLoaded
        ? selectedStudent.student.name
        : null;
    final studentId = selectedStudent is SelectedStudentLoaded
        ? selectedStudent.student.id
        : null;

    final result = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .92,
      ),
      builder: (_) => _RequestAppointmentSheet(
        repo: _repo,
        parentId: parent.id,
        parentName: parent.name,
        schoolId: parent.schoolId,
        studentId: studentId,
        studentName: studentName,
      ),
    );
    if (result != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Appointment request sent')),
      );
    }
  }
}

class _AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback? onCancel;
  const _AppointmentCard({required this.appointment, this.onCancel});

  @override
  Widget build(BuildContext context) {
    final canCancel =
        onCancel != null &&
        ![
          AppointmentStatus.cancelled,
          AppointmentStatus.completed,
          AppointmentStatus.rejected,
          AppointmentStatus.noShow,
          AppointmentStatus.expired,
        ].contains(appointment.status);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  appointment.appointmentTypeName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              StatusBadge(
                label: appointment.status.label,
                color: _statusColor(appointment.status),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _row(context, Icons.person_outline, 'With ${appointment.staffName}'),
          const SizedBox(height: 6),
          _row(
            context,
            Icons.schedule_outlined,
            DateFormat(
              'EEE, d MMM yyyy • h:mm a',
            ).format(appointment.scheduledStart),
          ),
          if (appointment.location != null) ...[
            const SizedBox(height: 6),
            _row(context, Icons.location_on_outlined, appointment.location!),
          ],
          const SizedBox(height: 6),
          _row(context, Icons.notes_outlined, appointment.reason),
          if (canCancel) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                ),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodySmall)),
      ],
    );
  }

  Color _statusColor(AppointmentStatus status) => switch (status) {
    AppointmentStatus.approved || AppointmentStatus.completed => Colors.green,
    AppointmentStatus.pending ||
    AppointmentStatus.rescheduleProposed => Colors.orange,
    AppointmentStatus.cancelled ||
    AppointmentStatus.rejected ||
    AppointmentStatus.noShow => Colors.red,
    _ => Colors.grey,
  };
}

/// Roles a parent may reasonably request a meeting with, mirroring the
/// spec's approved-recipient list for parent messaging/appointments (class
/// teacher, subject teacher, bursar, admin, nurse, discipline, reception) -
/// deliberately excludes roles like storeInventory/gatekeeper/hrOfficer that
/// have no parent-facing reason to be booked.
const _parentFacingStaffRoles = [
  UserRole.classTeacher,
  UserRole.subjectTeacher,
  UserRole.headTeacher,
  UserRole.deputyHead,
  UserRole.deanOfStudies,
  UserRole.schoolAdmin,
  UserRole.bursar,
  UserRole.nurse,
  UserRole.guidanceDiscipline,
  UserRole.receptionist,
];

class _RequestAppointmentSheet extends StatefulWidget {
  final AppointmentRepository repo;
  final String parentId;
  final String parentName;
  final String schoolId;
  final String? studentId;
  final String? studentName;

  const _RequestAppointmentSheet({
    required this.repo,
    required this.parentId,
    required this.parentName,
    required this.schoolId,
    this.studentId,
    this.studentName,
  });

  @override
  State<_RequestAppointmentSheet> createState() =>
      _RequestAppointmentSheetState();
}

class _RequestAppointmentSheetState extends State<_RequestAppointmentSheet> {
  List<StaffSummary> _staff = const [];
  StaffSummary? _selectedStaff;
  DateTime _date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  final _reason = TextEditingController();
  bool _loadingStaff = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final result = await widget.repo.getStaffByRoles(
      widget.schoolId,
      _parentFacingStaffRoles,
    );
    if (!mounted) return;
    result.fold(
      (failure) => setState(() {
        _loadingStaff = false;
        _error = failure.message;
      }),
      (staff) => setState(() {
        _staff = staff;
        _loadingStaff = false;
      }),
    );
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Request Appointment',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            if (widget.studentName != null) ...[
              const SizedBox(height: 4),
              Text(
                'For ${widget.studentName}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 16),
            if (_loadingStaff)
              const Center(child: SchoolPulseLoader())
            else if (_staff.isEmpty)
              EmptyState(
                icon: Icons.person_off_outlined,
                title: 'No staff available',
                message:
                    _error ??
                    'There is no staff member available to book right now.',
              )
            else ...[
              DropdownButtonFormField<StaffSummary>(
                initialValue: _selectedStaff,
                decoration: const InputDecoration(labelText: 'Staff member'),
                items: _staff
                    .map(
                      (staff) => DropdownMenuItem(
                        value: staff,
                        child: Text(
                          '${staff.name} • ${UserRoleDisplay.name(staff.role)}',
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedStaff = value),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reason,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Reason for the appointment',
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today),
                title: const Text('Date'),
                subtitle: Text(DateFormat('EEE, d MMM yyyy').format(_date)),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateUtils.dateOnly(DateTime.now()),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) setState(() => _date = picked);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.access_time),
                title: const Text('Time'),
                subtitle: Text(_time.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (picked != null) setState(() => _time = picked);
                },
              ),
              const SizedBox(height: 12),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _submit,
                  child: Text(_saving ? 'Sending…' : 'Send Request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_selectedStaff == null || _reason.text.trim().isEmpty) {
      setState(() => _error = 'Select a staff member and enter a reason.');
      return;
    }
    final start = DateTime(
      _date.year,
      _date.month,
      _date.day,
      _time.hour,
      _time.minute,
    );
    setState(() {
      _saving = true;
      _error = null;
    });
    final appointment = Appointment(
      id: '',
      schoolId: widget.schoolId,
      appointmentTypeId: 'parent_meeting',
      appointmentTypeName: 'Parent Meeting',
      department: UserRoleDisplay.name(_selectedStaff!.role),
      category: AppointmentCategory.parentStaff,
      requesterId: widget.parentId,
      requesterName: widget.parentName,
      requesterRole: UserRole.parent,
      studentId: widget.studentId,
      studentName: widget.studentName,
      staffId: _selectedStaff!.id,
      staffName: _selectedStaff!.name,
      scheduledStart: start,
      scheduledEnd: start.add(const Duration(minutes: 20)),
      reason: _reason.text.trim(),
      requiresApproval: true,
      status: AppointmentStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final result = await widget.repo.requestAppointment(appointment);
    if (!mounted) return;
    setState(() => _saving = false);
    result.fold(
      (failure) => setState(() => _error = failure.message),
      (saved) => Navigator.pop(context, saved),
    );
  }
}

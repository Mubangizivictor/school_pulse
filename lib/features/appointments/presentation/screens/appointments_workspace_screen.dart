import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/components/school_pulse_loader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/appointments/domain/entities/appointment.dart';
import 'package:school_pulse/features/appointments/domain/entities/appointment_note.dart';
import 'package:school_pulse/features/appointments/domain/entities/appointment_status.dart';
import 'package:school_pulse/features/appointments/domain/entities/appointment_type.dart';
import 'package:school_pulse/features/appointments/domain/entities/staff_summary.dart';
import 'package:school_pulse/features/appointments/domain/repositories/appointment_repository.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:school_pulse/injection_container.dart' as di;
import 'package:flutter_bloc/flutter_bloc.dart';

/// The school-scoped operational workspace. It deliberately replaces only
/// the legacy `/staff/admin/appointments` surface; visitor check-in remains
/// owned by the Visitors feature and is linked through [Appointment.visitorId].
class AppointmentsWorkspaceScreen extends StatefulWidget {
  const AppointmentsWorkspaceScreen({super.key});

  @override
  State<AppointmentsWorkspaceScreen> createState() =>
      _AppointmentsWorkspaceScreenState();
}

class _AppointmentsWorkspaceScreenState
    extends State<AppointmentsWorkspaceScreen> {
  final AppointmentRepository _repo = di.sl<AppointmentRepository>();
  final _search = TextEditingController();
  String _tab = 'Upcoming';
  bool _calendar = false;

  bool _canManage(UserRole role) => const {
    UserRole.director,
    UserRole.headTeacher,
    UserRole.deputyHead,
    UserRole.schoolAdmin,
    UserRole.receptionist,
    UserRole.securityHead,
  }.contains(role);

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthBloc>().state;
    if (auth is! AuthAuthenticated) return const SizedBox.shrink();
    final user = auth.user;
    final canManage = _canManage(user.role);
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(title: const Text('Appointments & Schedule')),
      floatingActionButton: canManage
          ? FloatingActionButton.extended(
              onPressed: () => _openEditor(user),
              icon: const Icon(Icons.add),
              label: const Text('New appointment'),
            )
          : null,
      body: SafeArea(
        child: StreamBuilder<List<Appointment>>(
          stream: _repo.watchForSchool(user.schoolId),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: SchoolPulseLoader());
            }
            if (snap.hasError) {
              return _StatePanel(
                icon: Icons.cloud_off_outlined,
                title: 'Appointments are unavailable',
                message: 'Check your connection, then try again.',
                action: 'Retry',
                onAction: () => setState(() {}),
              );
            }
            final all = snap.data ?? const <Appointment>[];
            final visible = _filter(all);
            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 104),
                children: [
                  _Stats(all: all),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: 'Search appointments…',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              _calendar
                                  ? Icons.view_list_outlined
                                  : Icons.calendar_month_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _calendar = !_calendar),
                          ),
                          PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down),
                            tooltip: 'Filter',
                            initialValue: _tab,
                            onSelected: (item) => setState(() => _tab = item),
                            itemBuilder: (context) =>
                                [
                                      'Upcoming',
                                      'Pending',
                                      'Completed',
                                      'Cancelled',
                                      'Missed',
                                      'All',
                                    ]
                                    .map(
                                      (item) => PopupMenuItem(
                                        value: item,
                                        child: Text(item),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_calendar) _CalendarStrip(appointments: visible),
                  if (_calendar) const SizedBox(height: 12),
                  if (visible.isEmpty)
                    _StatePanel(
                      icon: Icons.event_available_outlined,
                      title: _search.text.isEmpty
                          ? 'No ${_tab.toLowerCase()} appointments'
                          : 'No matching appointments',
                      message: canManage
                          ? 'Create an appointment to start the schedule.'
                          : 'Your schedule will appear here when appointments are assigned.',
                    ),
                  ...visible.map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _AppointmentTile(
                        appointment: a,
                        onTap: () => _openDetails(a, user, canManage),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Appointment> _filter(List<Appointment> items) {
    final now = DateTime.now();
    final q = _search.text.trim().toLowerCase();
    return items.where((a) {
      final tab = switch (_tab) {
        'Upcoming' =>
          a.scheduledEnd.isAfter(now) &&
              (a.status == AppointmentStatus.approved ||
                  a.status == AppointmentStatus.pending),
        'Pending' => a.status == AppointmentStatus.pending,
        'Completed' => a.status == AppointmentStatus.completed,
        'Cancelled' =>
          a.status == AppointmentStatus.cancelled ||
              a.status == AppointmentStatus.rejected,
        'Missed' =>
          a.status == AppointmentStatus.noShow ||
              a.status == AppointmentStatus.expired,
        _ => true,
      };
      return tab &&
          (q.isEmpty ||
              '${a.appointmentTypeName} ${a.requesterName} ${a.staffName} ${a.department} ${a.location ?? ''}'
                  .toLowerCase()
                  .contains(q));
    }).toList();
  }

  Future<void> _openEditor(dynamic user) async {
    final result = await showModalBottomSheet<Appointment>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .92,
      ),
      builder: (_) => _AppointmentEditor(user: user, repo: _repo),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment scheduled and reminders queued.'),
        ),
      );
    }
  }

  Future<void> _openDetails(Appointment a, dynamic user, bool canManage) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _AppointmentDetails(
        appointment: a,
        repo: _repo,
        operatorId: user.id,
        operatorName: user.name,
        canManage: canManage,
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  final List<Appointment> all;
  const _Stats({required this.all});
  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    int count(bool Function(Appointment) p) => all.where(p).length;
    final stats = [
      (
        'Today',
        count((a) => DateUtils.isSameDay(a.scheduledStart, today)),
        Colors.black,
      ),
      (
        'Upcoming',
        count(
          (a) =>
              a.scheduledStart.isAfter(DateTime.now()) &&
              a.status == AppointmentStatus.approved,
        ),
        Colors.black,
      ),
      (
        'Pending',
        count((a) => a.status == AppointmentStatus.pending),
        Colors.black,
      ),
      (
        'Completed',
        count((a) => a.status == AppointmentStatus.completed),
        Colors.black,
      ),
      (
        'Cancelled',
        count((a) => a.status == AppointmentStatus.cancelled),
        Colors.black,
      ),
      (
        'Missed',
        count(
          (a) =>
              a.status == AppointmentStatus.noShow ||
              a.status == AppointmentStatus.expired,
        ),
        Colors.black,
      ),
    ];
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const minCardWidth = 112.0;
        final perRow =
            ((constraints.maxWidth + spacing) / (minCardWidth + spacing))
                .floor()
                .clamp(1, stats.length);
        final cardWidth =
            (constraints.maxWidth - spacing * (perRow - 1)) / perRow;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: stats.map((s) {
            return SizedBox(
              width: cardWidth,
              height: 86,
              child: AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.$1, style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 4),
                    Text(
                      '${s.$2}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: s.$3, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _AppointmentTile extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onTap;
  const _AppointmentTile({required this.appointment, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final color = _statusColor(appointment.status);
    return AppCard(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Container(
                width: 50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('h:mm').format(appointment.scheduledStart),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('a').format(appointment.scheduledStart),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.appointmentTypeName,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'With ${appointment.staffName} • ${appointment.location ?? appointment.department}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    _Status(status: appointment.status),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentEditor extends StatefulWidget {
  final dynamic user;
  final AppointmentRepository repo;
  const _AppointmentEditor({required this.user, required this.repo});
  @override
  State<_AppointmentEditor> createState() => _AppointmentEditorState();
}

class _AppointmentEditorState extends State<_AppointmentEditor> {
  int step = 0;
  String type = 'Visitor Meeting';
  DateTime date = DateTime.now().add(const Duration(days: 1));
  TimeOfDay start = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay end = const TimeOfDay(hour: 10, minute: 30);
  bool saving = false;
  bool approval = false;
  int reminderMinutes = 15;
  String? submitError;
  List<StaffSummary> hosts = const [];
  String? selectedHostId;
  final requester = TextEditingController(),
      customType = TextEditingController(),
      host = TextEditingController(),
      department = TextEditingController(text: 'Administration'),
      campus = TextEditingController(text: 'Main Campus'),
      location = TextEditingController(text: 'Main Office'),
      purpose = TextEditingController(),
      notes = TextEditingController(),
      visitorId = TextEditingController(),
      attachments = TextEditingController();
  @override
  void initState() {
    super.initState();
    host.text = widget.user.name;
    requester.text = widget.user.name;
    selectedHostId = FirebaseAuth.instance.currentUser?.uid ?? widget.user.id;
    _loadHosts();
  }

  Future<void> _loadHosts() async {
    final result = await widget.repo.getStaffByRoles(
      widget.user.schoolId,
      const [],
    );
    if (!mounted) return;
    result.fold((_) {}, (items) => setState(() => hosts = items));
  }

  @override
  void dispose() {
    for (final c in [
      requester,
      customType,
      host,
      department,
      campus,
      location,
      purpose,
      notes,
      visitorId,
      attachments,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contents = [_type(), _details(), _schedule()];
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.viewInsetsOf(context).bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
              const SizedBox(width: 8),
              Text(
                'New Appointment',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProgressSteps(current: step),
          const SizedBox(height: 18),
          Flexible(child: SingleChildScrollView(child: contents[step])),
          const SizedBox(height: 12),
          if (submitError != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                submitError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
              ),
            ),
          Row(
            children: [
              if (step > 0)
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: saving ? null : () => setState(() => step--),
                      style: OutlinedButton.styleFrom(
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Back', maxLines: 1),
                    ),
                  ),
                ),
              if (step > 0) const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: FilledButton(
                    onPressed: saving ? null : _next,
                    style: FilledButton.styleFrom(
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      saving
                          ? 'Checking…'
                          : step == 2
                          ? 'Schedule'
                          : 'Next',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _type() {
    const types = [
      'Visitor Meeting',
      'Staff Meeting',
      'Parent Meeting',
      'Student Meeting',
      'Interview',
      'Counselling',
      'Support',
      'Custom',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select appointment type',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 6),
        Text(
          'Choose the type of appointment you want to schedule.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: types
              .map(
                (x) => ChoiceChip(
                  label: Text(x),
                  selected: type == x,
                  onSelected: (_) => setState(() => type = x),
                ),
              )
              .toList(),
        ),
        if (type == 'Custom') ...[
          const SizedBox(height: 20),
          _field(customType, 'Custom appointment type'),
          Text(
            'Give this appointment a clear name, e.g. “Alumni mentoring session”.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ],
    );
  }

  Widget _details() => Column(
    children: [
      _field(requester, 'Requester / guest'),
      if (hosts.isEmpty)
        _field(host, 'Host')
      else
        DropdownButtonFormField<String>(
          initialValue: hosts.any((x) => x.id == selectedHostId)
              ? selectedHostId
              : null,
          decoration: const InputDecoration(labelText: 'Host'),
          items: hosts
              .map((x) => DropdownMenuItem(value: x.id, child: Text(x.name)))
              .toList(),
          onChanged: (id) {
            final selected = hosts.firstWhere((x) => x.id == id);
            setState(() {
              selectedHostId = id;
              host.text = selected.name;
            });
          },
        ),
      _field(department, 'Department'),
      _field(campus, 'Campus'),
      _field(location, 'Location'),
      _field(purpose, 'Purpose', max: 2),
      _field(notes, 'Notes (optional)', max: 2),
      if (type == 'Visitor Meeting')
        _field(visitorId, 'Pre-registered visitor ID (optional)'),
      _field(attachments, 'Attachment links (comma separated)', max: 2),
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text('Approval required'),
        subtitle: const Text('Require host approval before confirmation'),
        value: approval,
        onChanged: (v) => setState(() => approval = v),
      ),
    ],
  );
  Widget _schedule() => Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.calendar_today),
        title: const Text('Date'),
        subtitle: Text(DateFormat('EEE, d MMM yyyy').format(date)),
        onTap: () async {
          final x = await showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateUtils.dateOnly(DateTime.now()),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (x != null) setState(() => date = x);
        },
      ),
      Row(
        children: [
          Expanded(
            child: _time('Start time', start, (x) => setState(() => start = x)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _time('End time', end, (x) => setState(() => end = x)),
          ),
        ],
      ),
      DropdownButtonFormField<int>(
        initialValue: reminderMinutes,
        decoration: const InputDecoration(labelText: 'Reminder'),
        items: const [
          (15, '15 minutes before'),
          (30, '30 minutes before'),
          (60, '1 hour before'),
        ].map((x) => DropdownMenuItem(value: x.$1, child: Text(x.$2))).toList(),
        onChanged: (value) {
          if (value != null) setState(() => reminderMinutes = value);
        },
      ),
    ],
  );
  Widget _time(
    String label,
    TimeOfDay value,
    ValueChanged<TimeOfDay> onChange,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(label),
    subtitle: Text(value.format(context)),
    onTap: () async {
      final x = await showTimePicker(context: context, initialTime: value);
      if (x != null) onChange(x);
    },
  );
  Widget _field(TextEditingController c, String label, {int max = 1}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: TextField(
          controller: c,
          maxLines: max,
          decoration: InputDecoration(labelText: label),
        ),
      );
  Future<void> _next() async {
    if (step < 2) {
      if (step == 0 && type == 'Custom' && customType.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Enter a name for the custom appointment type.'),
          ),
        );
        return;
      }
      setState(() => step++);
      return;
    }
    if ([
      requester,
      host,
      department,
      location,
      purpose,
    ].any((c) => c.text.trim().isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Complete requester, host, department, location and purpose.',
          ),
        ),
      );
      setState(() => step = 1);
      return;
    }
    final s = DateTime(
          date.year,
          date.month,
          date.day,
          start.hour,
          start.minute,
        ),
        e = DateTime(date.year, date.month, date.day, end.hour, end.minute);
    if (!e.isAfter(s)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End time must be after start time.')),
      );
      return;
    }
    setState(() {
      saving = true;
      submitError = null;
    });
    final actorId = FirebaseAuth.instance.currentUser?.uid ?? widget.user.id;
    final appointmentTypeName = type == 'Custom'
        ? customType.text.trim()
        : type;
    final category = type == 'Visitor Meeting'
        ? AppointmentCategory.external
        : type == 'Staff Meeting'
        ? AppointmentCategory.internalStaff
        : AppointmentCategory.parentStaff;
    final a = Appointment(
      id: '',
      schoolId: widget.user.schoolId,
      appointmentTypeId: appointmentTypeName.toLowerCase().replaceAll(
        RegExp(r'[^a-z0-9]+'),
        '_',
      ),
      appointmentTypeName: appointmentTypeName,
      department: department.text.trim(),
      category: category,
      requesterId: actorId,
      requesterName: requester.text.trim(),
      requesterRole: widget.user.role,
      staffId: selectedHostId ?? actorId,
      staffName: host.text.trim(),
      scheduledStart: s,
      scheduledEnd: e,
      reason: purpose.text.trim(),
      location: location.text.trim(),
      campus: campus.text.trim(),
      notes: notes.text.trim().isEmpty ? null : notes.text.trim(),
      visitorId: visitorId.text.trim().isEmpty ? null : visitorId.text.trim(),
      attachmentUrls: attachments.text
          .split(',')
          .map((x) => x.trim())
          .where((x) => x.isNotEmpty)
          .toList(),
      reminderMinutes: [reminderMinutes],
      requiresApproval: approval,
      status: approval ? AppointmentStatus.pending : AppointmentStatus.approved,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    final r = await widget.repo.requestAppointment(a);
    if (!mounted) return;
    setState(() => saving = false);
    r.fold(
      (f) => setState(() => submitError = _friendlyFailure(f.message)),
      (ok) => Navigator.pop(context, ok),
    );
  }

  String _friendlyFailure(String message) {
    if (message.contains('permission-denied')) {
      return 'You do not have an appointment-management grant for this school. Ask a school administrator to grant access.';
    }
    if (message.contains('no longer available')) return message;
    return 'Could not schedule the appointment. Check your connection and try again.';
  }
}

class _ProgressSteps extends StatelessWidget {
  final int current;
  const _ProgressSteps({required this.current});

  @override
  Widget build(BuildContext context) {
    const labels = ['Type', 'Details', 'Schedule'];
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      children: List.generate(labels.length, (index) {
        final active = index <= current;
        return Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: active
                    ? color
                    : Theme.of(context).colorScheme.surfaceContainerHighest,
                child: active
                    ? Icon(
                        Icons.check,
                        size: 14,
                        color: Theme.of(context).colorScheme.onPrimary,
                      )
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(fontSize: 11),
                      ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  labels[index],
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: active ? color : null,
                  ),
                ),
              ),
              if (index < labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < current
                        ? color
                        : Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}

class _AppointmentDetails extends StatelessWidget {
  final Appointment appointment;
  final AppointmentRepository repo;
  final String operatorId;
  final String operatorName;
  final bool canManage;
  const _AppointmentDetails({
    required this.appointment,
    required this.repo,
    required this.operatorId,
    required this.operatorName,
    required this.canManage,
  });
  @override
  Widget build(BuildContext context) {
    final rows = [
      ('With', appointment.staffName),
      ('Requester', appointment.requesterName),
      (
        'When',
        '${DateFormat('EEE, d MMM yyyy • h:mm a').format(appointment.scheduledStart)} – ${DateFormat('h:mm a').format(appointment.scheduledEnd)}',
      ),
      (
        'Location',
        '${appointment.location ?? appointment.department}${appointment.campus == null ? '' : ' • ${appointment.campus}'}',
      ),
      ('Purpose', appointment.reason),
      if (appointment.notes?.isNotEmpty == true) ('Notes', appointment.notes!),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Appointment Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _Status(status: appointment.status),
              const SizedBox(height: 18),
              Text(
                appointment.appointmentTypeName,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              ...rows.map(
                (x) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 90,
                        child: Text(
                          x.$1,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                      ),
                      Expanded(child: Text(x.$2)),
                    ],
                  ),
                ),
              ),
              if (appointment.visitorId != null)
                AppCard(
                  child: ListTile(
                    leading: const Icon(Icons.verified_user_outlined),
                    title: const Text('Visitor pre-registration linked'),
                    subtitle: Text(
                      'Gate verification ID: ${appointment.visitorId}',
                    ),
                  ),
                ),
              if (canManage) ...[
                const SizedBox(height: 16),
                Wrap(spacing: 8, runSpacing: 8, children: _actions(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _actions(BuildContext context) {
    Future<void> update(AppointmentStatus status) async {
      final r = await repo.respondToAppointment(
        id: appointment.id,
        status: status,
        respondedBy: operatorId,
        proposedStart: status == AppointmentStatus.rescheduleProposed
            ? appointment.scheduledStart.add(const Duration(days: 1))
            : null,
        proposedEnd: status == AppointmentStatus.rescheduleProposed
            ? appointment.scheduledEnd.add(const Duration(days: 1))
            : null,
      );
      if (context.mounted) {
        r.fold(
          (f) => ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(f.message))),
          (_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Appointment ${status.label.toLowerCase()}'),
              ),
            );
            Navigator.pop(context);
          },
        );
      }
    }

    final buttons = <Widget>[];
    if (appointment.status == AppointmentStatus.pending) {
      buttons.add(
        FilledButton(
          onPressed: () => update(AppointmentStatus.approved),
          child: const Text('Approve'),
        ),
      );
      buttons.add(
        OutlinedButton(
          onPressed: () => update(AppointmentStatus.rejected),
          child: const Text('Reject'),
        ),
      );
    }
    if (appointment.status == AppointmentStatus.approved) {
      buttons.add(
        FilledButton.tonal(
          onPressed: () => repo
              .markCompleted(appointment.id)
              .then((_) => Navigator.pop(context)),
          child: const Text('Mark completed'),
        ),
      );
      buttons.add(
        OutlinedButton(
          onPressed: () => update(AppointmentStatus.noShow),
          child: const Text('Mark missed'),
        ),
      );
      buttons.add(
        OutlinedButton(
          onPressed: () => update(AppointmentStatus.rescheduleProposed),
          child: const Text('Reschedule'),
        ),
      );
    }
    buttons.add(
      TextButton.icon(
        onPressed: () => _addNote(context),
        icon: const Icon(Icons.note_add_outlined),
        label: const Text('Add note'),
      ),
    );
    if (![
      AppointmentStatus.cancelled,
      AppointmentStatus.completed,
      AppointmentStatus.rejected,
    ].contains(appointment.status)) {
      buttons.add(
        OutlinedButton(
          onPressed: () => repo
              .cancelAppointment(id: appointment.id, cancelledBy: operatorId)
              .then((_) => Navigator.pop(context)),
          child: const Text('Cancel'),
        ),
      );
    }
    buttons.add(
      OutlinedButton.icon(
        onPressed: () => _delete(context),
        icon: const Icon(Icons.delete_outline),
        label: const Text('Delete'),
        style: OutlinedButton.styleFrom(
          foregroundColor: Theme.of(context).colorScheme.error,
          side: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
    return buttons;
  }

  Future<void> _delete(BuildContext context) async {
    final confirmed = await confirmActionDialog(
      context,
      title: 'Delete appointment?',
      message:
          'This permanently removes "${appointment.appointmentTypeName}" with '
          '${appointment.staffName}. This cannot be undone.',
      isDestructive: true,
    );
    if (confirmed != true || !context.mounted) return;
    final r = await repo.deleteAppointment(appointment.id);
    if (!context.mounted) return;
    r.fold(
      (f) => ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(f.message))),
      (_) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appointment deleted')));
        Navigator.pop(context);
      },
    );
  }

  Future<void> _addNote(BuildContext context) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add appointment note'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Outcome, follow-up, or internal note',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (note == null || note.isEmpty) return;
    final result = await repo.addNote(
      AppointmentNote(
        id: '',
        appointmentId: appointment.id,
        authorId: operatorId,
        authorName: operatorName,
        summary: note,
        createdAt: DateTime.now(),
      ),
    );
    if (context.mounted) {
      result.fold(
        (f) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(f.message))),
        (_) => ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Appointment note added'))),
      );
    }
  }
}

class _CalendarStrip extends StatelessWidget {
  final List<Appointment> appointments;
  const _CalendarStrip({required this.appointments});
  @override
  Widget build(BuildContext context) {
    final first = DateUtils.dateOnly(DateTime.now());
    return AppCard(
      child: SizedBox(
        height: 82,
        child: Row(
          children: List.generate(7, (i) {
            final day = first.add(Duration(days: i));
            final n = appointments
                .where((a) => DateUtils.isSameDay(a.scheduledStart, day))
                .length;
            return Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('EEE').format(day),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const SizedBox(height: 5),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: n > 0
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${day.day}',
                      style: TextStyle(
                        color: n > 0
                            ? Theme.of(context).colorScheme.onPrimary
                            : null,
                      ),
                    ),
                  ),
                  if (n > 0) Text('$n', style: const TextStyle(fontSize: 10)),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Status extends StatelessWidget {
  final AppointmentStatus status;
  const _Status({required this.status});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: _statusColor(status),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.label,
      style: TextStyle(
        color: _statusColor(status),
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

Color _statusColor(AppointmentStatus s) => switch (s) {
  AppointmentStatus.approved || AppointmentStatus.completed => Colors.black,
  AppointmentStatus.pending ||
  AppointmentStatus.rescheduleProposed => Colors.black,
  AppointmentStatus.cancelled ||
  AppointmentStatus.rejected ||
  AppointmentStatus.noShow => Colors.black,
  _ => Colors.black,
};

class _StatePanel extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final String? action;
  final VoidCallback? onAction;
  const _StatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.onAction,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 54),
    child: Center(
      child: Column(
        children: [
          Icon(icon, size: 46, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center),
          if (action != null)
            TextButton(onPressed: onAction, child: Text(action!)),
        ],
      ),
    ),
  );
}

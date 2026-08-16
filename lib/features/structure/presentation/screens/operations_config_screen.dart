import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';

import '../../domain/entities/attendance_defaults_config.dart';
import '../../domain/entities/communication_defaults_config.dart';
import '../../domain/entities/timetable_config.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_empty_hint.dart';

/// The operational settings hub. Timetable, attendance defaults and
/// communication defaults are Structure-owned singleton documents; calendar
/// and examination data intentionally route to their existing owners rather
/// than being copied into this screen.
class OperationsConfigScreen extends StatefulWidget {
  const OperationsConfigScreen({super.key, this.initialTab = 0});
  final int initialTab;

  @override
  State<OperationsConfigScreen> createState() => _OperationsConfigScreenState();
}

class _OperationsConfigScreenState extends State<OperationsConfigScreen> {
  static const _sections = <String>[
    'Timetable',
    'Attendance Defaults',
    'Communication Defaults',
    'Academic Calendar',
    'Exam Configuration',
  ];
  late int _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialTab.clamp(0, _sections.length - 1);
  }

  @override
  void didUpdateWidget(covariant OperationsConfigScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selected = widget.initialTab.clamp(0, _sections.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: const AdminAppBar(title: 'Operations Config'),
    body: BlocBuilder<StructureBloc, StructureState>(
      builder: (context, state) => switch (_selected) {
        0 => _TimetableOverview(config: state.timetableConfig),
        1 => _AttendanceDefaults(config: state.attendanceDefaultsConfig),
        2 => _CommunicationDefaults(config: state.communicationDefaultsConfig),
        3 => const _OwnedModuleNotice(
          title: 'Academic Calendar',
          icon: Icons.calendar_month_outlined,
          message:
              'School dates, holidays, exams and events are managed in the shared School Calendar.',
          button: 'Open School Calendar',
          route: '/staff/calendar',
        ),
        _ => const _OwnedModuleNotice(
          title: 'Exam Configuration',
          icon: Icons.assignment_outlined,
          message:
              'Assessment types, grading systems and exam defaults are managed by the academic assessment configuration.',
          button: 'Open Assessment Configuration',
          route: '/staff/admin/structure/assessment',
        ),
      },
    ),
  );
}

// -------------------------- Timetable overview --------------------------

class _TimetableOverview extends StatelessWidget {
  const _TimetableOverview({required this.config});
  final TimetableConfig config;

  bool get _isEmpty =>
      config.teachingDays.isEmpty &&
      config.slots.isEmpty &&
      config.schoolStartTime.isEmpty;

  @override
  Widget build(BuildContext context) {
    if (_isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: AppColors.primary(context).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.calendar_month_outlined,
                  size: 54,
                  color: AppColors.primary(context),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'No timetable configured yet.',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                'Set up your school week, periods and breaks to get started.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: () => _open(context, _EditTimetable(config: config)),
                icon: const Icon(Icons.add),
                label: const Text('Add Timetable'),
              ),
            ],
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
      children: [
        const _Heading('School Week'),
        _SettingsCard(
          children: [
            _SettingsRow(
              title: 'Teaching Days',
              value: _daySummary(config.teachingDays),
              onTap: () => _open(context, _EditTimetable(config: config)),
            ),
            _SettingsRow(
              title: 'Weekend Days',
              value: _daySummary(config.weekendDays),
              onTap: () => _open(context, _EditTimetable(config: config)),
            ),
            _SettingsRow(
              title: 'Periods Per Day',
              value: config.periodsPerDay == 0
                  ? 'Not set'
                  : '${config.periodsPerDay}',
              onTap: () => _open(context, _EditTimetable(config: config)),
              isLast: true,
            ),
          ],
        ),
        const _Heading('School Timings'),
        _SettingsCard(
          children: [
            _SettingsRow(
              title: 'School Timings',
              value:
                  '${_blank(config.schoolStartTime)} - ${_blank(config.schoolEndTime)}',
              onTap: () => _open(context, _EditTimetable(config: config)),
              isLast: true,
            ),
          ],
        ),
        const _Heading('Periods, Breaks, Lunch & Assembly'),
        _SettingsCard(
          children: [
            _SettingsRow(
              icon: Icons.calendar_view_day_outlined,
              title: 'Manage Time Slots',
              value: 'View and manage all periods, breaks and assemblies',
              onTap: () => _open(context, _ManageSlots(config: config)),
              isLast: true,
            ),
          ],
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: () => _open(context, _EditTimetable(config: config)),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit Timetable'),
        ),
      ],
    );
  }

  static void _open(BuildContext context, Widget page) =>
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  static String _blank(String value) => value.isEmpty ? 'Not set' : value;
  static String _daySummary(List<String> days) =>
      days.isEmpty ? 'Not set' : days.join(', ');
}

class _EditTimetable extends StatefulWidget {
  const _EditTimetable({required this.config});
  final TimetableConfig config;
  @override
  State<_EditTimetable> createState() => _EditTimetableState();
}

class _EditTimetableState extends State<_EditTimetable> {
  static const _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];
  late Set<String> teaching = widget.config.teachingDays.toSet();
  late Set<String> weekend = widget.config.weekendDays.toSet();
  late final TextEditingController periods = TextEditingController(
    text: widget.config.periodsPerDay == 0
        ? ''
        : '${widget.config.periodsPerDay}',
  );
  late String start = widget.config.schoolStartTime;
  late String end = widget.config.schoolEndTime;
  bool _dirty = false;

  @override
  void dispose() {
    periods.dispose();
    super.dispose();
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('You have unsaved changes to the timetable.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _save() {
    final count = int.tryParse(periods.text);
    if (teaching.isEmpty ||
        count == null ||
        count < 1 ||
        !_before(start, end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Choose teaching days, a valid period count and school timings.',
          ),
        ),
      );
      return;
    }
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<StructureBloc>().add(
      UpdateTimetableConfigRequested(
        widget.config.copyWith(
          teachingDays: teaching.toList(),
          weekendDays: weekend.toList(),
          periodsPerDay: count,
          schoolStartTime: start,
          schoolEndTime: end,
        ),
        schoolId,
      ),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Timetable saved')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      final discard = await _confirmDiscard();
      if (!mounted || !discard) return;
      Navigator.pop(context);
    },
    child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const AdminAppBar(title: 'Edit Timetable'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Heading('School Week'),
          const Text(
            'Teaching Days',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the days when classes are held',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          _DayChips(
            days: _days,
            selected: teaching,
            onChanged: (day, on) => setState(() {
              _dirty = true;
              if (on) {
                teaching.add(day);
                weekend.remove(day);
              } else {
                teaching.remove(day);
              }
            }),
          ),
          const SizedBox(height: 22),
          const Text(
            'Weekend Days',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Select the weekend days',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          _DayChips(
            days: _days,
            selected: weekend,
            onChanged: (day, on) => setState(() {
              _dirty = true;
              if (on) {
                weekend.add(day);
                teaching.remove(day);
              } else {
                weekend.remove(day);
              }
            }),
          ),
          const SizedBox(height: 22),
          const _Heading('Periods Per Day'),
          TextField(
            controller: periods,
            keyboardType: TextInputType.number,
            onChanged: (_) => _dirty = true,
            decoration: const InputDecoration(
              labelText: 'Number of periods in a day',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 22),
          const _Heading('School Timings'),
          Row(
            children: [
              Expanded(
                child: _TimeField(
                  label: 'School Start Time',
                  value: start,
                  onChanged: (v) => setState(() {
                    _dirty = true;
                    start = v;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TimeField(
                  label: 'School End Time',
                  value: end,
                  onChanged: (v) => setState(() {
                    _dirty = true;
                    end = v;
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save Changes'),
          ),
        ],
      ),
    ),
  );
}

// -------------------------- Manage Time Slots --------------------------

class _ManageSlots extends StatefulWidget {
  const _ManageSlots({required this.config});
  final TimetableConfig config;
  @override
  State<_ManageSlots> createState() => _ManageSlotsState();
}

const _filterTypes = {
  'Periods': 'period',
  'Breaks': 'break',
  'Lunch': 'lunch',
  'Assembly': 'assembly',
};

class _ManageSlotsState extends State<_ManageSlots> {
  String filter = 'All';
  List<TimetableSlot> get slots => widget.config.slots
      .where((s) => filter == 'All' || s.type == _filterTypes[filter])
      .toList();

  void _edit([TimetableSlot? slot]) async {
    final saved = await Navigator.of(context).push<TimetableSlot>(
      MaterialPageRoute(
        builder: (_) =>
            _SlotForm(existing: slot, occupied: widget.config.slots),
      ),
    );
    if (saved == null || !mounted) return;
    final all = [...widget.config.slots];
    if (slot == null) {
      all.add(saved.copyWith(displayOrder: all.length + 1));
    } else {
      all[all.indexOf(slot)] = saved;
    }
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<StructureBloc>().add(
      UpdateTimetableConfigRequested(
        widget.config.copyWith(slots: all),
        schoolId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: const AdminAppBar(title: 'Manage Time Slots'),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(),
      icon: const Icon(Icons.add),
      label: const Text('Add Slot'),
    ),
    body: Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
          child: Row(
            children: ['All', 'Periods', 'Breaks', 'Lunch', 'Assembly']
                .map(
                  (x) => Padding(
                    padding: const EdgeInsets.only(right: 7),
                    child: ChoiceChip(
                      label: Text(x),
                      selected: filter == x,
                      onSelected: (_) => setState(() => filter = x),
                      showCheckmark: false,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        Expanded(
          child: slots.isEmpty
              ? const StructureEmptyHint('No time slots match this filter.')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  itemCount: slots.length,
                  itemBuilder: (_, i) {
                    final slot = slots[i];
                    final order = slot.displayOrder == 0
                        ? widget.config.slots.indexOf(slot) + 1
                        : slot.displayOrder;
                    return _SettingsCard(
                      margin: const EdgeInsets.only(bottom: 10),
                      children: [
                        _SettingsRow(
                          title: '$order. ${slot.name}',
                          value: '${slot.startTime} - ${slot.endTime}',
                          badge: slot.type,
                          onTap: () => _edit(slot),
                          isLast: true,
                        ),
                      ],
                    );
                  },
                ),
        ),
      ],
    ),
  );
}

class _SlotForm extends StatefulWidget {
  const _SlotForm({this.existing, required this.occupied});
  final TimetableSlot? existing;
  final List<TimetableSlot> occupied;
  @override
  State<_SlotForm> createState() => _SlotFormState();
}

class _SlotFormState extends State<_SlotForm> {
  late String type = widget.existing?.type ?? 'period';
  late final name = TextEditingController(text: widget.existing?.name);
  late final displayOrder = TextEditingController(
    text: (widget.existing?.displayOrder ?? 0) == 0
        ? ''
        : '${widget.existing!.displayOrder}',
  );
  late String start = widget.existing?.startTime ?? '';
  late String end = widget.existing?.endTime ?? '';
  late bool active = widget.existing?.isActive ?? true;

  @override
  void dispose() {
    name.dispose();
    displayOrder.dispose();
    super.dispose();
  }

  void _save() {
    if (name.text.trim().isEmpty || !_before(start, end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter a label and valid start and end times.'),
        ),
      );
      return;
    }
    final order = int.tryParse(displayOrder.text) ?? 0;
    final overlap = widget.occupied
        .where((s) => s != widget.existing)
        .any((s) => _overlaps(start, end, s.startTime, s.endTime));
    if (overlap) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This slot overlaps an existing time slot.'),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      TimetableSlot(
        name: name.text.trim(),
        startTime: start,
        endTime: end,
        type: type,
        displayOrder: order,
        isActive: active,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    appBar: AdminAppBar(
      title: widget.existing == null ? 'Add Time Slot' : 'Edit Time Slot',
    ),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        DropdownButtonFormField(
          initialValue: type,
          decoration: const InputDecoration(
            labelText: 'Slot Type *',
            border: OutlineInputBorder(),
          ),
          items: const ['period', 'break', 'lunch', 'assembly', 'other']
              .map((x) => DropdownMenuItem(value: x, child: Text(_title(x))))
              .toList(),
          onChanged: (v) => setState(() => type = v!),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: name,
          decoration: const InputDecoration(
            labelText: 'Name / Label *',
            hintText: 'e.g. 1st Period',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _TimeField(
                label: 'Start Time *',
                value: start,
                onChanged: (v) => setState(() => start = v),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _TimeField(
                label: 'End Time *',
                value: end,
                onChanged: (v) => setState(() => end = v),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: displayOrder,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Display Order',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 6),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Active'),
          value: active,
          onChanged: (v) => setState(() => active = v),
        ),
        const SizedBox(height: 22),
        FilledButton.icon(
          onPressed: _save,
          icon: const Icon(Icons.save_outlined),
          label: const Text('Save Slot'),
        ),
      ],
    ),
  );
}

// -------------------------- Attendance Defaults --------------------------

class _AttendanceDefaults extends StatefulWidget {
  const _AttendanceDefaults({required this.config});
  final AttendanceDefaultsConfig config;
  @override
  State<_AttendanceDefaults> createState() => _AttendanceDefaultsState();
}

class _AttendanceDefaultsState extends State<_AttendanceDefaults> {
  late String mode = widget.config.attendanceMode;
  late String window = widget.config.markingWindow;
  late bool backdated = widget.config.allowBackdatedAttendance;
  late bool autoPresent = widget.config.autoPresentOnAdmission;
  bool _dirty = false;

  @override
  void didUpdateWidget(covariant _AttendanceDefaults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dirty && oldWidget.config != widget.config) {
      mode = widget.config.attendanceMode;
      window = widget.config.markingWindow;
      backdated = widget.config.allowBackdatedAttendance;
      autoPresent = widget.config.autoPresentOnAdmission;
    }
  }

  void _save(BuildContext context) {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<StructureBloc>().add(
      UpdateAttendanceDefaultsConfigRequested(
        AttendanceDefaultsConfig(
          attendanceMode: mode,
          markingWindow: window,
          allowBackdatedAttendance: backdated,
          autoPresentOnAdmission: autoPresent,
        ),
        schoolId,
      ),
    );
    setState(() => _dirty = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Attendance defaults saved')));
  }

  @override
  Widget build(BuildContext context) => _SettingsPage(
    title: 'Attendance Defaults',
    button: 'Save Settings',
    dirty: _dirty,
    onSave: () => _save(context),
    children: [
      _SettingsCard(
        children: [
          const _CardHeading('General Settings'),
          DropdownButtonFormField(
            initialValue: mode,
            decoration: const InputDecoration(
              labelText: 'Attendance Mode',
              helperText: 'How attendance is recorded',
            ),
            items: const [
              'Daily',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) => setState(() {
              mode = v!;
              _dirty = true;
            }),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField(
            initialValue: window,
            decoration: const InputDecoration(
              labelText: 'Marking Window',
              helperText: 'Time allowed for marking attendance',
            ),
            items: const [
              'Until End of School Day',
              'Same session only',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) => setState(() {
              window = v!;
              _dirty = true;
            }),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Allow Backdated Attendance'),
            subtitle: const Text('Allow marking attendance for past dates'),
            value: backdated,
            onChanged: (v) => setState(() {
              backdated = v;
              _dirty = true;
            }),
          ),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Auto Present on Admission'),
            subtitle: const Text('Mark new admissions as present by default'),
            value: autoPresent,
            onChanged: (v) => setState(() {
              autoPresent = v;
              _dirty = true;
            }),
          ),
        ],
      ),
    ],
  );
}

// -------------------------- Communication Defaults --------------------------

class _CommunicationDefaults extends StatefulWidget {
  const _CommunicationDefaults({required this.config});
  final CommunicationDefaultsConfig config;
  @override
  State<_CommunicationDefaults> createState() => _CommunicationDefaultsState();
}

class _CommunicationDefaultsState extends State<_CommunicationDefaults> {
  late Set<String> channels = widget.config.defaultChannels.toSet();
  late String language = widget.config.defaultLanguage;
  bool _dirty = false;

  @override
  void didUpdateWidget(covariant _CommunicationDefaults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_dirty && oldWidget.config != widget.config) {
      channels = widget.config.defaultChannels.toSet();
      language = widget.config.defaultLanguage;
    }
  }

  void _save(BuildContext context) {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    context.read<StructureBloc>().add(
      UpdateCommunicationDefaultsConfigRequested(
        CommunicationDefaultsConfig(
          defaultChannels: channels.toList(),
          defaultLanguage: language,
        ),
        schoolId,
      ),
    );
    setState(() => _dirty = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Communication defaults saved')),
    );
  }

  @override
  Widget build(BuildContext context) => _SettingsPage(
    title: 'Communication Defaults',
    button: 'Save Settings',
    dirty: _dirty,
    onSave: () => _save(context),
    children: [
      _SettingsCard(
        children: [
          const _CardHeading('General Settings'),
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              'Default Channels',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            'Select default communication channels',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('App Notification'),
            value: channels.contains('app'),
            onChanged: (v) => setState(() {
              v! ? channels.add('app') : channels.remove('app');
              _dirty = true;
            }),
          ),
          const _DisabledChannelTile(
            label: 'Email',
            reason: 'Not connected yet',
          ),
          const _DisabledChannelTile(
            label: 'WhatsApp',
            reason: 'Not connected yet',
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField(
            initialValue: language,
            decoration: const InputDecoration(labelText: 'Default Language'),
            items: const [
              'English',
            ].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
            onChanged: (v) => setState(() {
              language = v!;
              _dirty = true;
            }),
          ),
        ],
      ),
    ],
  );
}

class _DisabledChannelTile extends StatelessWidget {
  const _DisabledChannelTile({required this.label, required this.reason});
  final String label, reason;
  @override
  Widget build(BuildContext context) => Opacity(
    opacity: 0.5,
    child: CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(reason, style: const TextStyle(fontSize: 11)),
      value: false,
      onChanged: null,
    ),
  );
}

// -------------------------- Shared page/card shells --------------------------

class _SettingsPage extends StatelessWidget {
  const _SettingsPage({
    required this.title,
    required this.button,
    required this.children,
    required this.onSave,
    this.dirty = false,
  });
  final String title, button;
  final List<Widget> children;
  final VoidCallback onSave;
  final bool dirty;

  Future<bool> _confirmDiscard(BuildContext context) async {
    if (!dirty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: Text('You have unsaved changes to $title.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !dirty,
    onPopInvokedWithResult: (didPop, _) async {
      if (didPop) return;
      if (await _confirmDiscard(context) && context.mounted) {
        Navigator.pop(context);
      }
    },
    child: Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AdminAppBar(title: title),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...children,
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onSave,
            icon: const Icon(Icons.save_outlined),
            label: Text(button),
          ),
        ],
      ),
    ),
  );
}

class _OwnedModuleNotice extends StatelessWidget {
  const _OwnedModuleNotice({
    required this.title,
    required this.icon,
    required this.message,
    required this.button,
    required this.route,
  });
  final String title, message, button, route;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 58, color: AppColors.primary(context)),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => context.push(route),
            child: Text(button),
          ),
        ],
      ),
    ),
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
    ),
  );
}

class _CardHeading extends StatelessWidget {
  const _CardHeading(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children, this.margin});
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;
  @override
  Widget build(BuildContext context) => AppCard(
    margin: margin,
    showShadow: false,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
    child: Column(children: children),
  );
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    this.icon,
    required this.title,
    required this.value,
    required this.onTap,
    this.badge,
    this.isLast = false,
  });
  final IconData? icon;
  final String title, value;
  final VoidCallback onTap;
  final String? badge;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: icon == null
            ? null
            : Icon(icon, color: AppColors.primary(context)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(value),
        trailing: badge == null
            ? const Icon(Icons.chevron_right)
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _TypeBadge(badge!),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right),
                ],
              ),
        onTap: onTap,
      ),
      if (!isLast)
        Divider(
          height: 1,
          color: Theme.of(
            context,
          ).colorScheme.outlineVariant.withValues(alpha: 0.4),
        ),
    ],
  );
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.primary(context).withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      _title(value),
      style: TextStyle(
        fontSize: 10,
        color: AppColors.primary(context),
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

class _DayChips extends StatelessWidget {
  const _DayChips({
    required this.days,
    required this.selected,
    required this.onChanged,
  });
  final List<String> days;
  final Set<String> selected;
  final void Function(String, bool) onChanged;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: AppSpacing.m,
    runSpacing: AppSpacing.m,
    children: days
        .map(
          (day) => ChoiceChip(
            label: Text(day.substring(0, 3)),
            selected: selected.contains(day),
            onSelected: (v) => onChanged(day, v),
            showCheckmark: false,
          ),
        )
        .toList(),
  );
}

class _TimeField extends StatelessWidget {
  const _TimeField({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label, value;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      alignment: Alignment.centerLeft,
      minimumSize: const Size(0, 56),
    ),
    onPressed: () async {
      final initial = _parseTime(value) ?? TimeOfDay.now();
      final time = await showTimePicker(context: context, initialTime: initial);
      if (time != null) {
        onChanged(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        );
      }
    },
    icon: const Icon(Icons.access_time_outlined, size: 17),
    label: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: const TextStyle(fontSize: 11)),
        Text(value.isEmpty ? 'HH:MM' : value),
      ],
    ),
  );
}

TimeOfDay? _parseTime(String value) {
  final p = value.split(':');
  if (p.length != 2) return null;
  final h = int.tryParse(p[0]);
  final m = int.tryParse(p[1]);
  return h == null || m == null || h > 23 || m > 59
      ? null
      : TimeOfDay(hour: h, minute: m);
}

int _minutes(String value) {
  final time = _parseTime(value);
  return time == null ? -1 : time.hour * 60 + time.minute;
}

bool _before(String start, String end) =>
    _minutes(start) >= 0 && _minutes(end) > _minutes(start);
bool _overlaps(String aStart, String aEnd, String bStart, String bEnd) =>
    _minutes(aStart) < _minutes(bEnd) && _minutes(bStart) < _minutes(aEnd);
String _title(String text) =>
    text.isEmpty ? text : '${text[0].toUpperCase()}${text.substring(1)}';

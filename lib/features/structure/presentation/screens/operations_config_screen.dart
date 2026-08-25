import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/fee_category_entities.dart';
import '../../domain/entities/timetable_config.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/operations_config_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

/// Focused operational Structure editor.
///
/// The setup wizard opens exactly one section at a time. This removes the old
/// Timetable/Attendance/Communication tab bar that exposed future setup before
/// its prerequisites existed.
class OperationsConfigScreen extends StatelessWidget {
  const OperationsConfigScreen({
    super.key,
    this.showAppBar = true,
    this.timetableSectionKey,
  });

  final bool showAppBar;
  final GlobalKey<TimetableSectionState>? timetableSectionKey;

  @override
  Widget build(BuildContext context) {
    final requested =
        GoRouterState.of(context).uri.queryParameters['section'] ?? 'timetable';
    final section =
        const {
          'timetable',
          'attendance',
          'communication',
          'documents',
          'custom',
          'fees',
        }.contains(requested)
        ? requested
        : 'timetable';
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: Text(_title(section))) : null,
      backgroundColor: showAppBar ? null : Colors.transparent,
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => switch (section) {
          'attendance' => _AttendanceSection(state: state, schoolId: schoolId),
          'communication' => _CommunicationSection(
            state: state,
            schoolId: schoolId,
          ),
          'documents' => _DocumentTemplatesSection(
            state: state,
            schoolId: schoolId,
          ),
          'custom' => _CustomFieldsSection(state: state, schoolId: schoolId),
          'fees' => _FeeCategoriesSection(state: state, schoolId: schoolId),
          _ => _TimetableSection(
            key: timetableSectionKey,
            config: state.timetableConfig,
            schoolId: schoolId,
          ),
        },
      ),
    );
  }

  String _title(String section) => switch (section) {
    'attendance' => 'Attendance Configuration',
    'communication' => 'Communication Foundation',
    'documents' => 'Document Templates',
    'custom' => 'Custom Fields',
    'fees' => 'Finance Foundation',
    _ => 'School day & periods',
  };
}

class _TimetableSection extends StatefulWidget {
  final TimetableConfig config;
  final String schoolId;
  const _TimetableSection({
    super.key,
    required this.config,
    required this.schoolId,
  });

  @override
  State<_TimetableSection> createState() => TimetableSectionState();
}

class TimetableSectionState extends State<_TimetableSection> {
  static const _weekDays = <String>[
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late Set<String> _teachingDays;
  late TextEditingController _periodsPerDay;
  late String _startTime;
  late String _endTime;
  bool _isDirty = false;
  bool _isConfigured = false;

  @override
  void initState() {
    super.initState();
    _readConfig(widget.config);
    _isConfigured = _isValid(showError: false);
  }

  @override
  void didUpdateWidget(covariant _TimetableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isDirty && oldWidget.config != widget.config) {
      _periodsPerDay.text = widget.config.periodsPerDay.toString();
      _teachingDays = widget.config.teachingDays.toSet();
      _startTime = widget.config.schoolStartTime;
      _endTime = widget.config.schoolEndTime;
      _isConfigured = _isValid(showError: false);
    }
  }

  void _readConfig(TimetableConfig config) {
    _teachingDays = config.teachingDays.toSet();
    _periodsPerDay = TextEditingController(
      text: config.periodsPerDay == 0 ? '' : config.periodsPerDay.toString(),
    );
    _startTime = config.schoolStartTime;
    _endTime = config.schoolEndTime;
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  @override
  void dispose() {
    _periodsPerDay.dispose();
    super.dispose();
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parsed = _parseTime(current) ?? const TimeOfDay(hour: 8, minute: 0);
    final selected = await showTimePicker(
      context: context,
      initialTime: parsed,
    );
    if (selected == null) return null;
    return '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay? _parseTime(String raw) {
    final parts = raw.split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return null;
    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  String? _validationError() {
    if (_teachingDays.isEmpty) {
      return 'Select at least one teaching day.';
    }
    final start = _parseTime(_startTime);
    final end = _parseTime(_endTime);
    if (start == null || end == null) {
      return 'Set both the start and end time.';
    }
    final startMinutes = start.hour * 60 + start.minute;
    final endMinutes = end.hour * 60 + end.minute;
    if (endMinutes <= startMinutes) {
      return 'End time must be after the start time.';
    }
    final periods = int.tryParse(_periodsPerDay.text);
    if (periods == null || periods <= 0) {
      return 'Enter at least one period per day.';
    }
    return null;
  }

  bool _isValid({required bool showError}) {
    final error = _validationError();
    if (error != null) {
      if (showError && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error)));
      }
      return false;
    }
    return true;
  }

  /// Persists the school week if it has unsaved, valid edits. Returns false
  /// (leaving the admin on this step) when dirty but invalid.
  Future<bool> saveIfDirty() async {
    if (!_isDirty) return true;
    if (!_isValid(showError: true)) return false;
    final teaching = _weekDays
        .where((day) => _teachingDays.contains(day))
        .toList(growable: false);
    final nonTeaching = _weekDays
        .where((day) => !_teachingDays.contains(day))
        .toList(growable: false);
    final updated = widget.config.copyWith(
      teachingDays: teaching,
      weekendDays: nonTeaching,
      periodsPerDay: int.tryParse(_periodsPerDay.text) ?? 0,
      schoolStartTime: _startTime,
      schoolEndTime: _endTime,
    );
    context.read<StructureBloc>().add(
      UpdateTimetableConfigRequested(updated, widget.schoolId),
    );
    setState(() {
      _isDirty = false;
      _isConfigured = true;
    });
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final scheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          _isConfigured
              ? 'Review the teaching week before configuring period times.'
              : 'Set teaching days, school hours and the number of periods.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'School week',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              Text(
                'Teaching days',
                style: TextStyle(color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _weekDays.map((day) {
                  final selected = _teachingDays.contains(day);
                  return ChoiceChip(
                    label: Text(day.substring(0, 3)),
                    selected: selected,
                    showCheckmark: false,
                    labelStyle: TextStyle(
                      color: selected ? scheme.onPrimary : scheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: scheme.surface,
                    selectedColor: scheme.primary,
                    side: BorderSide(color: scheme.outlineVariant),
                    onSelected: (value) {
                      _markDirty();
                      setState(() {
                        if (value) {
                          _teachingDays.add(day);
                        } else {
                          _teachingDays.remove(day);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              if (_isConfigured && !_isDirty) ...[
                Row(
                  children: [
                    Expanded(
                      child: _TimeSummary(
                        label: 'Starts',
                        value: _formatTime12h(_startTime),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: VerticalDivider(color: scheme.outlineVariant),
                    ),
                    Expanded(
                      child: _TimeSummary(
                        label: 'Ends',
                        value: _formatTime12h(_endTime),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 28),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: scheme.primary),
                      ),
                      child: Icon(
                        Icons.calendar_today_outlined,
                        size: 18,
                        color: scheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _periodsPerDay.text,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'periods per day',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ] else ...[
                Text(
                  'Starts',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _TimeButton(
                        label: null,
                        value: _startTime,
                        onTap: () async {
                          final value = await _pickTime(context, _startTime);
                          if (value != null && mounted) {
                            _markDirty();
                            setState(() => _startTime = value);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _TimeButton(
                        label: null,
                        value: _endTime,
                        onTap: () async {
                          final value = await _pickTime(context, _endTime);
                          if (value != null && mounted) {
                            _markDirty();
                            setState(() => _endTime = value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Starts',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Ends',
                        style: TextStyle(color: scheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Periods per day',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                _PeriodsStepper(
                  controller: _periodsPerDay,
                  onChanged: (value) {
                    _markDirty();
                    setState(() => _periodsPerDay.text = value.toString());
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Individual period times are configured next.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_isConfigured && !_isDirty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle_outline, color: scheme.primary),
                const SizedBox(width: 10),
                Text(
                  'School week configured',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        StructureSectionHeader(
          title: 'Periods, Breaks, Lunch, Prep & Activities',
          actionLabel: 'Add Slot',
          onAction: () => showTimetableSlotFormDialog(
            context,
            onSave: (slot) {
              final updated = widget.config.copyWith(
                slots: [...widget.config.slots, slot],
              );
              bloc.add(
                UpdateTimetableConfigRequested(updated, widget.schoolId),
              );
            },
          ),
        ),
        if (widget.config.slots.isEmpty)
          const StructureEmptyHint(
            'No school-day slots yet. Add lessons, break, lunch, prep, assembly, worship, games or other custom slots in the exact order your school uses.',
          ),
        ...widget.config.slots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          return StructureListRow(
            icon: _slotIcon(slot.type),
            color: Colors.black,
            title: slot.name,
            subtitle:
                '${slot.startTime} - ${slot.endTime} • ${_pretty(slot.type)}',
            onEdit: () => showTimetableSlotFormDialog(
              context,
              existing: slot,
              onSave: (updatedSlot) {
                final slots = [...widget.config.slots];
                slots[index] = updatedSlot;
                bloc.add(
                  UpdateTimetableConfigRequested(
                    widget.config.copyWith(slots: slots),
                    widget.schoolId,
                  ),
                );
              },
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Slot',
                message: 'Delete "${slot.name}"?',
              );
              if (confirmed == true) {
                final slots = [...widget.config.slots]..removeAt(index);
                bloc.add(
                  UpdateTimetableConfigRequested(
                    widget.config.copyWith(slots: slots),
                    widget.schoolId,
                  ),
                );
              }
            },
          );
        }),
      ],
    );
  }
}

/// Formats "HH:mm" (24-hour) as "h:mm AM/PM"; returns the input unchanged if
/// it isn't a valid HH:mm string.
String _formatTime12h(String raw) {
  final parts = raw.split(':');
  if (parts.length != 2) return raw;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null || minute == null) return raw;
  final period = hour >= 12 ? 'PM' : 'AM';
  final displayHour = hour % 12 == 0 ? 12 : hour % 12;
  return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
}

class _TimeSummary extends StatelessWidget {
  final String label;
  final String value;

  const _TimeSummary({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: scheme.primary),
          ),
          child: Icon(Icons.schedule_outlined, size: 18, color: scheme.primary),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: scheme.onSurfaceVariant)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class _PeriodsStepper extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<int> onChanged;

  const _PeriodsStepper({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final value = int.tryParse(controller.text) ?? 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline),
            onPressed: value <= 0 ? null : () => onChanged(value - 1),
          ),
          Expanded(
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onChanged(value + 1),
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  final String? label;
  final String value;
  final VoidCallback onTap;

  const _TimeButton({this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? 'Select time' : _formatTime12h(value),
              ),
            ),
            const Icon(Icons.schedule_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _AttendanceSection({required this.state, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: Text(
            'Configure attendance labels and sessions used by the school. QR, NFC and other verification methods remain separate capabilities and are not forced here.',
          ),
        ),
        StructureSectionHeader(
          title: 'Attendance Types',
          actionLabel: 'Add Type',
          onAction: () => showAttendanceTypeFormDialog(
            context,
            schoolId: schoolId,
            onSave: (t) => bloc.add(SaveAttendanceTypeRequested(t)),
          ),
        ),
        if (state.attendanceTypes.isEmpty)
          const StructureEmptyHint(
            'No attendance types defined yet. Add the labels your school uses, such as Present, Absent, Late or Excused.',
          ),
        ...state.attendanceTypes.map(
          (type) => StructureListRow(
            icon: Icons.check_circle_outline,
            color: _safeHex(type.colorHex, Colors.black),
            title: type.name,
            isActive: type.isActive,
            onEdit: () => showAttendanceTypeFormDialog(
              context,
              schoolId: schoolId,
              existing: type,
              onSave: (u) => bloc.add(SaveAttendanceTypeRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Type',
                message: 'Delete "${type.name}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteAttendanceTypeRequested(type.id));
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Attendance Sessions',
          actionLabel: 'Add Session',
          onAction: () => showAttendanceSessionFormDialog(
            context,
            schoolId: schoolId,
            onSave: (s) => bloc.add(SaveAttendanceSessionRequested(s)),
          ),
        ),
        if (state.attendanceSessions.isEmpty)
          const StructureEmptyHint(
            'No sessions defined yet. Sessions can represent Morning, Afternoon, Gate, Transport or another school-defined context.',
          ),
        ...state.attendanceSessions.map(
          (session) => StructureListRow(
            icon: Icons.access_time_outlined,
            color: Colors.black,
            title: session.name,
            isActive: session.isActive,
            onEdit: () => showAttendanceSessionFormDialog(
              context,
              schoolId: schoolId,
              existing: session,
              onSave: (u) => bloc.add(SaveAttendanceSessionRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Session',
                message: 'Delete "${session.name}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteAttendanceSessionRequested(session.id));
              }
            },
          ),
        ),
      ],
    );
  }
}

class _CommunicationSection extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _CommunicationSection({required this.state, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        StructureSectionHeader(
          title: 'Announcement Categories',
          actionLabel: 'Add',
          onAction: () => showAnnouncementCategoryFormDialog(
            context,
            schoolId: schoolId,
            onSave: (c) => bloc.add(SaveAnnouncementCategoryRequested(c)),
          ),
        ),
        if (state.announcementCategories.isEmpty)
          const StructureEmptyHint('No announcement categories defined yet.'),
        ...state.announcementCategories.map(
          (category) => StructureListRow(
            icon: Icons.campaign_outlined,
            color: Colors.black,
            title: category.name,
            isActive: category.isActive,
            onEdit: () => showAnnouncementCategoryFormDialog(
              context,
              schoolId: schoolId,
              existing: category,
              onSave: (u) => bloc.add(SaveAnnouncementCategoryRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Category',
                message: 'Delete "${category.name}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteAnnouncementCategoryRequested(category.id));
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Notification Categories',
          actionLabel: 'Add',
          onAction: () => showNotificationCategoryFormDialog(
            context,
            schoolId: schoolId,
            onSave: (c) => bloc.add(SaveNotificationCategoryRequested(c)),
          ),
        ),
        if (state.notificationCategories.isEmpty)
          const StructureEmptyHint('No notification categories defined yet.'),
        ...state.notificationCategories.map(
          (category) => StructureListRow(
            icon: Icons.notifications_outlined,
            color: Colors.black,
            title: category.name,
            isActive: category.isActive,
            onEdit: () => showNotificationCategoryFormDialog(
              context,
              schoolId: schoolId,
              existing: category,
              onSave: (u) => bloc.add(SaveNotificationCategoryRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Category',
                message: 'Delete "${category.name}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteNotificationCategoryRequested(category.id));
              }
            },
          ),
        ),
        const SizedBox(height: 20),
        StructureSectionHeader(
          title: 'Message Templates',
          actionLabel: 'Add',
          onAction: () => showMessageTemplateFormDialog(
            context,
            schoolId: schoolId,
            onSave: (t) => bloc.add(SaveMessageTemplateRequested(t)),
          ),
        ),
        if (state.messageTemplates.isEmpty)
          const StructureEmptyHint('No message templates defined yet.'),
        ...state.messageTemplates.map(
          (template) => StructureListRow(
            icon: Icons.sms_outlined,
            color: Colors.black,
            title: template.name,
            subtitle: template.channel.toUpperCase(),
            isActive: template.isActive,
            onEdit: () => showMessageTemplateFormDialog(
              context,
              schoolId: schoolId,
              existing: template,
              onSave: (u) => bloc.add(SaveMessageTemplateRequested(u)),
            ),
            onDelete: () async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete Template',
                message: 'Delete "${template.name}"?',
              );
              if (confirmed == true) {
                bloc.add(DeleteMessageTemplateRequested(template.id));
              }
            },
          ),
        ),
      ],
    );
  }
}

class _FeeCategoriesSection extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _FeeCategoriesSection({required this.state, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return Scaffold(
      body: state.feeCategories.isEmpty
          ? const StructureEmptyHint(
              'No fee categories defined yet. Create only the finance categories needed as structural defaults; detailed fee structures remain in Finance.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.feeCategories.length,
              itemBuilder: (context, index) {
                final category = state.feeCategories[index];
                return StructureListRow(
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.black,
                  title: category.name,
                  subtitle: [
                    if (category.code.isNotEmpty) category.code,
                    category.isMandatory ? 'Mandatory' : 'Optional',
                  ].join(' - '),
                  isActive: category.isActive,
                  onEdit: () => _showFeeCategoryForm(
                    context,
                    schoolId: schoolId,
                    existing: category,
                    onSave: (u) => bloc.add(SaveFeeCategoryRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Fee Category',
                      message: 'Delete "${category.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteFeeCategoryRequested(category.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showFeeCategoryForm(
          context,
          schoolId: schoolId,
          onSave: (category) => bloc.add(SaveFeeCategoryRequested(category)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Fee Category'),
      ),
    );
  }
}

class _DocumentTemplatesSection extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _DocumentTemplatesSection({
    required this.state,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return Scaffold(
      body: state.documentTemplates.isEmpty
          ? const StructureEmptyHint(
              'No document templates defined yet. Examples include student ID cards, report cards or gate passes.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.documentTemplates.length,
              itemBuilder: (context, index) {
                final template = state.documentTemplates[index];
                return StructureListRow(
                  icon: Icons.description_outlined,
                  color: Colors.black,
                  title: template.name,
                  subtitle: template.templateType,
                  isActive: template.isActive,
                  onEdit: () => showDocumentTemplateFormDialog(
                    context,
                    schoolId: schoolId,
                    existing: template,
                    onSave: (u) => bloc.add(SaveDocumentTemplateRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Template',
                      message: 'Delete "${template.name}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteDocumentTemplateRequested(template.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDocumentTemplateFormDialog(
          context,
          schoolId: schoolId,
          onSave: (t) => bloc.add(SaveDocumentTemplateRequested(t)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Template'),
      ),
    );
  }
}

class _CustomFieldsSection extends StatelessWidget {
  final StructureState state;
  final String schoolId;
  const _CustomFieldsSection({required this.state, required this.schoolId});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return Scaffold(
      body: state.customFields.isEmpty
          ? const StructureEmptyHint(
              'No custom fields defined yet. Add only institution-specific fields that are not already part of the core model.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.customFields.length,
              itemBuilder: (context, index) {
                final field = state.customFields[index];
                return StructureListRow(
                  icon: Icons.dynamic_form_outlined,
                  color: Colors.black,
                  title: field.fieldName,
                  subtitle:
                      '${field.appliesTo} - ${field.fieldType}${field.isRequired ? ' - Required' : ''}',
                  isActive: field.isActive,
                  onEdit: () => showCustomFieldFormDialog(
                    context,
                    schoolId: schoolId,
                    existing: field,
                    onSave: (u) => bloc.add(SaveCustomFieldRequested(u)),
                  ),
                  onDelete: () async {
                    final confirmed = await showDeleteConfirmDialog(
                      context,
                      title: 'Delete Field',
                      message: 'Delete "${field.fieldName}"?',
                    );
                    if (confirmed == true) {
                      bloc.add(DeleteCustomFieldRequested(field.id));
                    }
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCustomFieldFormDialog(
          context,
          schoolId: schoolId,
          onSave: (f) => bloc.add(SaveCustomFieldRequested(f)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Field'),
      ),
    );
  }
}

Future<void> _showFeeCategoryForm(
  BuildContext context, {
  required String schoolId,
  FeeCategory? existing,
  required ValueChanged<FeeCategory> onSave,
}) async {
  final name = TextEditingController(text: existing?.name ?? '');
  final code = TextEditingController(text: existing?.code ?? '');
  final description = TextEditingController(text: existing?.description ?? '');
  var mandatory = existing?.isMandatory ?? true;
  var active = existing?.isActive ?? true;

  await showDialog<void>(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(
          existing == null ? 'Add Fee Category' : 'Edit Fee Category',
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: code,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Mandatory'),
                value: mandatory,
                onChanged: (value) => setState(() => mandatory = value),
              ),
              if (existing != null)
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Active'),
                  value: active,
                  onChanged: (value) => setState(() => active = value),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (name.text.trim().isEmpty) return;
              onSave(
                FeeCategory(
                  id: existing?.id ?? const Uuid().v4(),
                  schoolId: existing?.schoolId ?? schoolId,
                  name: name.text.trim(),
                  code: code.text.trim(),
                  description: description.text.trim(),
                  isMandatory: mandatory,
                  isActive: active,
                ),
              );
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    ),
  );

  name.dispose();
  code.dispose();
  description.dispose();
}

IconData _slotIcon(String type) => switch (type) {
  'break' => Icons.free_breakfast_outlined,
  'lunch' => Icons.restaurant_outlined,
  'assembly' => Icons.groups_outlined,
  'prep' || 'study' => Icons.menu_book_outlined,
  'games' => Icons.sports_soccer_outlined,
  'club' => Icons.groups_2_outlined,
  'worship' => Icons.church_outlined,
  'free' => Icons.hourglass_empty_outlined,
  _ => Icons.schedule_outlined,
};

Color _safeHex(String raw, Color fallback) {
  if (raw.trim().isEmpty) return fallback;
  final parsed = int.tryParse(raw.replaceFirst('#', ''), radix: 16);
  return parsed == null ? fallback : Color(0xFF000000 | parsed);
}

String _pretty(String raw) {
  if (raw.isEmpty) return raw;
  return '${raw[0].toUpperCase()}${raw.substring(1).replaceAll('_', ' ')}';
}

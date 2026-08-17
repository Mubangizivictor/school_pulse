import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
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
  const OperationsConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final requested =
        GoRouterState.of(context).uri.queryParameters['section'] ?? 'timetable';
    final section = const {
      'timetable',
      'attendance',
      'communication',
      'documents',
      'custom',
      'fees',
    }.contains(requested)
        ? requested
        : 'timetable';

    return Scaffold(
      appBar: AppBar(title: Text(_title(section))),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => switch (section) {
          'attendance' => _AttendanceSection(state: state),
          'communication' => _CommunicationSection(state: state),
          'documents' => _DocumentTemplatesSection(state: state),
          'custom' => _CustomFieldsSection(state: state),
          'fees' => _FeeCategoriesSection(state: state),
          _ => _TimetableSection(config: state.timetableConfig),
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
        _ => 'School Day & Periods',
      };
}

class _TimetableSection extends StatefulWidget {
  final TimetableConfig config;
  const _TimetableSection({required this.config});

  @override
  State<_TimetableSection> createState() => _TimetableSectionState();
}

class _TimetableSectionState extends State<_TimetableSection> {
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

  @override
  void initState() {
    super.initState();
    _readConfig(widget.config);
  }

  @override
  void didUpdateWidget(covariant _TimetableSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config) {
      _periodsPerDay.text = widget.config.periodsPerDay.toString();
      _teachingDays = widget.config.teachingDays.toSet();
      _startTime = widget.config.schoolStartTime;
      _endTime = widget.config.schoolEndTime;
    }
  }

  void _readConfig(TimetableConfig config) {
    _teachingDays = config.teachingDays.toSet();
    _periodsPerDay =
        TextEditingController(text: config.periodsPerDay.toString());
    _startTime = config.schoolStartTime;
    _endTime = config.schoolEndTime;
  }

  @override
  void dispose() {
    _periodsPerDay.dispose();
    super.dispose();
  }

  Future<String?> _pickTime(BuildContext context, String current) async {
    final parsed = _parseTime(current) ?? const TimeOfDay(hour: 8, minute: 0);
    final selected = await showTimePicker(context: context, initialTime: parsed);
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

  void _save(BuildContext context) {
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
    context.read<StructureBloc>().add(UpdateTimetableConfigRequested(updated));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Define the school day before building class timetables. Every school controls its own days, times, lesson lengths, breaks, lunch, prep and custom slots.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Teaching days',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _weekDays.map((day) {
                  final selected = _teachingDays.contains(day);
                  return FilterChip(
                    label: Text(day.substring(0, 3)),
                    selected: selected,
                    onSelected: (value) => setState(() {
                      if (value) {
                        _teachingDays.add(day);
                      } else {
                        _teachingDays.remove(day);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _TimeButton(
                      label: 'School starts',
                      value: _startTime,
                      onTap: () async {
                        final value = await _pickTime(context, _startTime);
                        if (value != null && mounted) {
                          setState(() => _startTime = value);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TimeButton(
                      label: 'School ends',
                      value: _endTime,
                      onTap: () async {
                        final value = await _pickTime(context, _endTime);
                        if (value != null && mounted) {
                          setState(() => _endTime = value);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _periodsPerDay,
                decoration: const InputDecoration(
                  labelText: 'Teaching periods per normal day',
                  helperText: 'Each period can still use its own start/end time.',
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _save(context),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save School Day'),
                ),
              ),
            ],
          ),
        ),
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
              bloc.add(UpdateTimetableConfigRequested(updated));
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
            color: Colors.purple,
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

class _TimeButton extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _TimeButton({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Row(
          children: [
            Expanded(child: Text(value.isEmpty ? 'Select' : value)),
            const Icon(Icons.schedule_outlined, size: 18),
          ],
        ),
      ),
    );
  }
}

class _AttendanceSection extends StatelessWidget {
  final StructureState state;
  const _AttendanceSection({required this.state});

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
            color: _safeHex(type.colorHex, Colors.blueGrey),
            title: type.name,
            isActive: type.isActive,
            onEdit: () => showAttendanceTypeFormDialog(
              context,
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
            color: Colors.purple,
            title: session.name,
            isActive: session.isActive,
            onEdit: () => showAttendanceSessionFormDialog(
              context,
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
  const _CommunicationSection({required this.state});

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
            onSave: (c) => bloc.add(SaveAnnouncementCategoryRequested(c)),
          ),
        ),
        if (state.announcementCategories.isEmpty)
          const StructureEmptyHint('No announcement categories defined yet.'),
        ...state.announcementCategories.map(
          (category) => StructureListRow(
            icon: Icons.campaign_outlined,
            color: Colors.purple,
            title: category.name,
            isActive: category.isActive,
            onEdit: () => showAnnouncementCategoryFormDialog(
              context,
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
            onSave: (c) => bloc.add(SaveNotificationCategoryRequested(c)),
          ),
        ),
        if (state.notificationCategories.isEmpty)
          const StructureEmptyHint('No notification categories defined yet.'),
        ...state.notificationCategories.map(
          (category) => StructureListRow(
            icon: Icons.notifications_outlined,
            color: Colors.purple,
            title: category.name,
            isActive: category.isActive,
            onEdit: () => showNotificationCategoryFormDialog(
              context,
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
            onSave: (t) => bloc.add(SaveMessageTemplateRequested(t)),
          ),
        ),
        if (state.messageTemplates.isEmpty)
          const StructureEmptyHint('No message templates defined yet.'),
        ...state.messageTemplates.map(
          (template) => StructureListRow(
            icon: Icons.sms_outlined,
            color: Colors.purple,
            title: template.name,
            subtitle: template.channel.toUpperCase(),
            isActive: template.isActive,
            onEdit: () => showMessageTemplateFormDialog(
              context,
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
  const _FeeCategoriesSection({required this.state});

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
                  color: Colors.green,
                  title: category.name,
                  subtitle: [
                    if (category.code.isNotEmpty) category.code,
                    category.isMandatory ? 'Mandatory' : 'Optional',
                  ].join(' - '),
                  isActive: category.isActive,
                  onEdit: () => _showFeeCategoryForm(
                    context,
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
  const _DocumentTemplatesSection({required this.state});

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
                  color: Colors.purple,
                  title: template.name,
                  subtitle: template.templateType,
                  isActive: template.isActive,
                  onEdit: () => showDocumentTemplateFormDialog(
                    context,
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
  const _CustomFieldsSection({required this.state});

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
                  color: Colors.purple,
                  title: field.fieldName,
                  subtitle:
                      '${field.appliesTo} - ${field.fieldType}${field.isRequired ? ' - Required' : ''}',
                  isActive: field.isActive,
                  onEdit: () => showCustomFieldFormDialog(
                    context,
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
        title: Text(existing == null ? 'Add Fee Category' : 'Edit Fee Category'),
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

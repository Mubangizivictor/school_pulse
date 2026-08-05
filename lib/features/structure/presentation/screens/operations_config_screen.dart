import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/timetable_config.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart' show showDeleteConfirmDialog;
import '../widgets/operations_config_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';

/// Timetable, Attendance, Communication, Document Templates, and Custom
/// Fields - the operational configuration every module reads instead of
/// hardcoding these values.
class OperationsConfigScreen extends StatefulWidget {
  const OperationsConfigScreen({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<OperationsConfigScreen> createState() => _OperationsConfigScreenState();
}

class _OperationsConfigScreenState extends State<OperationsConfigScreen> {
  static const _sections = [
    'Timetable',
    'Attendance',
    'Communication',
    'Document templates',
    'Custom fields',
  ];
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
  }

  @override
  void didUpdateWidget(covariant OperationsConfigScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Operations Config')),
      body: Column(
        children: [
          StructureSectionPicker(
            sections: _sections,
            selectedIndex: _selectedIndex,
            onSelected: (index) =>
                context.go('/staff/admin/structure/operations?tab=$index'),
          ),
          Expanded(
            child: BlocBuilder<StructureBloc, StructureState>(
              builder: (context, state) => IndexedStack(
                index: _selectedIndex,
                children: [
                  _TimetableTab(config: state.timetableConfig),
                  _AttendanceTab(state: state),
                  _CommunicationTab(state: state),
                  _DocumentTemplatesTab(state: state),
                  _CustomFieldsTab(state: state),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimetableTab extends StatefulWidget {
  final TimetableConfig config;
  const _TimetableTab({required this.config});

  @override
  State<_TimetableTab> createState() => _TimetableTabState();
}

class _TimetableTabState extends State<_TimetableTab> {
  late TextEditingController _teachingDays;
  late TextEditingController _weekendDays;
  late TextEditingController _periodsPerDay;
  late TextEditingController _startTime;
  late TextEditingController _endTime;

  @override
  void initState() {
    super.initState();
    _teachingDays = TextEditingController(
      text: widget.config.teachingDays.join(', '),
    );
    _weekendDays = TextEditingController(
      text: widget.config.weekendDays.join(', '),
    );
    _periodsPerDay = TextEditingController(
      text: widget.config.periodsPerDay.toString(),
    );
    _startTime = TextEditingController(text: widget.config.schoolStartTime);
    _endTime = TextEditingController(text: widget.config.schoolEndTime);
  }

  @override
  void dispose() {
    _teachingDays.dispose();
    _weekendDays.dispose();
    _periodsPerDay.dispose();
    _startTime.dispose();
    _endTime.dispose();
    super.dispose();
  }

  List<String> _split(String text) =>
      text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();

  void _save(BuildContext context) {
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final updated = widget.config.copyWith(
      teachingDays: _split(_teachingDays.text),
      weekendDays: _split(_weekendDays.text),
      periodsPerDay: int.tryParse(_periodsPerDay.text) ?? 0,
      schoolStartTime: _startTime.text,
      schoolEndTime: _endTime.text,
    );
    context.read<StructureBloc>().add(
      UpdateTimetableConfigRequested(updated, schoolId),
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Timetable config saved')));
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'School Week',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _teachingDays,
                decoration: const InputDecoration(
                  labelText: 'Teaching Days (comma-separated)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _weekendDays,
                decoration: const InputDecoration(
                  labelText: 'Weekend Days (comma-separated)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _periodsPerDay,
                decoration: const InputDecoration(labelText: 'Periods Per Day'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _startTime,
                      decoration: const InputDecoration(
                        labelText: 'School Start (e.g. 08:00)',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _endTime,
                      decoration: const InputDecoration(
                        labelText: 'School End (e.g. 16:00)',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _save(context),
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
        StructureSectionHeader(
          title: 'Periods, Breaks, Lunch & Assembly',
          actionLabel: 'Add Slot',
          onAction: () => showTimetableSlotFormDialog(
            context,
            onSave: (slot) {
              final updated = widget.config.copyWith(
                slots: [...widget.config.slots, slot],
              );
              bloc.add(UpdateTimetableConfigRequested(updated, schoolId));
            },
          ),
        ),
        if (widget.config.slots.isEmpty)
          const StructureEmptyHint('No slots defined yet.'),
        ...widget.config.slots.asMap().entries.map((entry) {
          final index = entry.key;
          final slot = entry.value;
          final icon = switch (slot.type) {
            'break' => Icons.free_breakfast_outlined,
            'lunch' => Icons.restaurant_outlined,
            'assembly' => Icons.groups_outlined,
            _ => Icons.schedule_outlined,
          };
          return StructureListRow(
            icon: icon,
            color: Colors.purple,
            title: slot.name,
            subtitle: '${slot.startTime} - ${slot.endTime}',
            onEdit: () => showTimetableSlotFormDialog(
              context,
              existing: slot,
              onSave: (updatedSlot) {
                final slots = [...widget.config.slots];
                slots[index] = updatedSlot;
                bloc.add(
                  UpdateTimetableConfigRequested(
                    widget.config.copyWith(slots: slots),
                    schoolId,
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
                    schoolId,
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

class _AttendanceTab extends StatelessWidget {
  final StructureState state;
  const _AttendanceTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
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
            'No attendance types defined yet.\ne.g. Present, Absent, Late, Excused.',
          ),
        ...state.attendanceTypes.map(
          (type) => StructureListRow(
            icon: Icons.check_circle_outline,
            color: type.colorHex.isNotEmpty
                ? Color(int.parse(type.colorHex.replaceFirst('#', '0xff')))
                : Colors.blueGrey,
            title: type.name,
            isActive: type.isActive,
            onEdit: () => showAttendanceTypeFormDialog(
              context,
              existing: type,
              schoolId: schoolId,
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
            'No sessions defined yet.\ne.g. Morning, Afternoon, Gate, Transport.',
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
              schoolId: schoolId,
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

class _CommunicationTab extends StatelessWidget {
  final StructureState state;
  const _CommunicationTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
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
            color: Colors.purple,
            title: category.name,
            isActive: category.isActive,
            onEdit: () => showAnnouncementCategoryFormDialog(
              context,
              existing: category,
              schoolId: schoolId,
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
            color: Colors.purple,
            title: category.name,
            isActive: category.isActive,
            onEdit: () => showNotificationCategoryFormDialog(
              context,
              existing: category,
              schoolId: schoolId,
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
            color: Colors.purple,
            title: template.name,
            subtitle: template.channel.toUpperCase(),
            isActive: template.isActive,
            onEdit: () => showMessageTemplateFormDialog(
              context,
              existing: template,
              schoolId: schoolId,
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

class _DocumentTemplatesTab extends StatelessWidget {
  final StructureState state;
  const _DocumentTemplatesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      body: state.documentTemplates.isEmpty
          ? const StructureEmptyHint(
              'No document templates defined yet.\ne.g. Student ID Card, Report Card, Gate Pass.',
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
                    schoolId: schoolId,
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

class _CustomFieldsTab extends StatelessWidget {
  final StructureState state;
  const _CustomFieldsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      body: state.customFields.isEmpty
          ? const StructureEmptyHint(
              'No custom fields defined yet.\ne.g. Blood Group, Clan, License Number.',
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
                    schoolId: schoolId,
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

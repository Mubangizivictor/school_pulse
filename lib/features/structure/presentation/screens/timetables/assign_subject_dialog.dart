import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import 'package:school_pulse/design_system/searchable_picker.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/auth/domain/usecases/get_staff_members.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../../domain/entities/structure_entities.dart';
import '../../../domain/entities/timetable.dart';
import '../../../domain/entities/timetable_config.dart';
import '../../../domain/services/timetable_conflict_resolver.dart';
import '../../bloc/timetable_bloc.dart';
import '../../bloc/timetable_event.dart';
import '../../bloc/timetable_state.dart';
import '../../widgets/structure_ui_kit.dart';

/// Structure -> Timetable Builder -> tap an empty period: assign a subject,
/// teacher, optional room/group to one or more consecutive slots. Runs the
/// candidate lesson through [TimetableConflictResolver] before saving and
/// surfaces exactly which existing lesson it collides with.
Future<void> showAssignSubjectDialog(
  BuildContext context, {
  required Timetable timetable,
  required String day,
  required List<TimetableSlot> consecutivePeriodSlots,
  required List<Subject> subjects,
  TimetableLesson? existing,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => BlocProvider.value(
      value: context.read<TimetableBloc>(),
      child: _AssignSubjectSheet(
        timetable: timetable,
        day: day,
        consecutivePeriodSlots: consecutivePeriodSlots,
        subjects: subjects,
        existing: existing,
      ),
    ),
  );
}

class _AssignSubjectSheet extends StatefulWidget {
  final Timetable timetable;
  final String day;
  final List<TimetableSlot> consecutivePeriodSlots;
  final List<Subject> subjects;
  final TimetableLesson? existing;

  const _AssignSubjectSheet({
    required this.timetable,
    required this.day,
    required this.consecutivePeriodSlots,
    required this.subjects,
    this.existing,
  });

  @override
  State<_AssignSubjectSheet> createState() => _AssignSubjectSheetState();
}

class _AssignSubjectSheetState extends State<_AssignSubjectSheet> {
  Subject? _subject;
  UserEntity? _teacher;
  final _roomController = TextEditingController();
  final _notesController = TextEditingController();
  List<UserEntity> _staff = const [];
  bool _loadingStaff = true;
  List<TimetableConflict>? _conflicts;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _subject = widget.subjects
          .where((s) => s.id == existing.subjectId)
          .firstOrNull;
      _roomController.text = existing.roomName ?? '';
      _notesController.text = existing.notes;
    }
    _loadStaff();
  }

  Future<void> _loadStaff() async {
    final result = await di.sl<GetStaffMembers>()(NoParams());
    if (!mounted) return;
    setState(() {
      _staff = result.getOrElse(() => const []);
      _loadingStaff = false;
      final existing = widget.existing;
      if (existing != null) {
        _teacher = _staff.where((s) => s.id == existing.teacherId).firstOrNull;
      }
    });
  }

  @override
  void dispose() {
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  TimetableLesson _buildCandidate() {
    final t = widget.timetable;
    return TimetableLesson(
      id: widget.existing?.id ?? '',
      schoolId: t.schoolId,
      timetableId: t.id,
      academicYearId: t.academicYearId,
      termId: t.termId,
      classId: t.classId,
      streamId: t.streamId,
      subjectId: _subject?.id ?? '',
      subjectName: _subject?.name ?? '',
      teacherId: _teacher?.id ?? '',
      teacherName: _teacher?.name ?? '',
      roomName: _roomController.text.trim().isEmpty
          ? null
          : _roomController.text.trim(),
      notes: _notesController.text.trim(),
      occurrences: widget.consecutivePeriodSlots
          .map((s) => TimetableLessonOccurrence(day: widget.day, slotId: s.id))
          .toList(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
      createdBy: widget.existing?.createdBy ?? '',
    );
  }

  void _save() {
    if (_subject == null || _teacher == null) return;
    context.read<TimetableBloc>().add(
      TimetableLessonSaveRequested(_buildCandidate()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TimetableBloc, TimetableState>(
      listenWhen: (previous, current) =>
          previous.lastSaveConflicts != current.lastSaveConflicts ||
          previous.isSaving != current.isSaving,
      listener: (context, state) {
        if (state.lastSaveConflicts.isNotEmpty) {
          setState(() => _conflicts = state.lastSaveConflicts);
        } else if (!state.isSaving && _conflicts != null) {
          Navigator.of(context).pop();
        }
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            expand: false,
            builder: (context, scrollController) => Material(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                      children: [
                        Text(
                          widget.existing == null
                              ? 'Assign Subject'
                              : 'Edit Lesson',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${widget.day} - ${widget.consecutivePeriodSlots.map((s) => s.name).join(' + ')}',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        StructureFieldGroup(
                          children: [
                            _PickerField(
                              label: 'Subject',
                              required: true,
                              valueLabel: _subject?.name,
                              onTap: () async {
                                final picked =
                                    await showSearchablePicker<Subject>(
                                      context: context,
                                      title: 'Select Subject',
                                      items: widget.subjects,
                                      labelBuilder: (s) => s.name,
                                    );
                                if (picked != null) {
                                  setState(() => _subject = picked);
                                }
                              },
                            ),
                            _PickerField(
                              label: 'Teacher',
                              required: true,
                              valueLabel: _teacher?.name,
                              loading: _loadingStaff,
                              onTap: _loadingStaff
                                  ? null
                                  : () async {
                                      final picked =
                                          await showSearchablePicker<
                                            UserEntity
                                          >(
                                            context: context,
                                            title: 'Select Teacher',
                                            items: _staff,
                                            labelBuilder: (s) => s.name,
                                          );
                                      if (picked != null) {
                                        setState(() => _teacher = picked);
                                      }
                                    },
                            ),
                            TextField(
                              controller: _roomController,
                              decoration: const InputDecoration(
                                labelText: 'Room (optional)',
                              ),
                            ),
                            TextField(
                              controller: _notesController,
                              maxLines: 2,
                              decoration: const InputDecoration(
                                labelText: 'Notes (optional)',
                              ),
                            ),
                          ],
                        ),
                        if (_conflicts != null && _conflicts!.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          _ConflictBanner(conflicts: _conflicts!),
                        ],
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      12,
                      20,
                      12 + MediaQuery.paddingOf(context).bottom,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed:
                                (_subject != null &&
                                    _teacher != null &&
                                    !state.isSaving)
                                ? _save
                                : null,
                            child: state.isSaving
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Assign'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PickerField extends StatelessWidget {
  final String label;
  final bool required;
  final String? valueLabel;
  final bool loading;
  final VoidCallback? onTap;

  const _PickerField({
    required this.label,
    this.required = false,
    required this.valueLabel,
    this.loading = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.labelSmall,
            children: [
              TextSpan(text: label),
              if (required)
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: colors.error),
                ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        InkWell(
          borderRadius: BorderRadius.circular(7),
          onTap: onTap,
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              border: Border.all(color: colors.outline.withValues(alpha: .35)),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    loading ? 'Loading...' : (valueLabel ?? 'Select $label'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      color: valueLabel == null
                          ? colors.onSurfaceVariant
                          : null,
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: colors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ConflictBanner extends StatelessWidget {
  final List<TimetableConflict> conflicts;

  const _ConflictBanner({required this.conflicts});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: .4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: colors.error, size: 18),
              const SizedBox(width: 8),
              Text(
                'Conflict Detected',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: colors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...conflicts.map(
            (c) => Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                c.message,
                style: TextStyle(fontSize: 12, color: colors.onSurface),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

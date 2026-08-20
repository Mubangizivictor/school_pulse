import 'package:flutter/material.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/app_theme.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
import 'package:school_pulse/design_system/theme/app_spacing.dart';
import 'package:school_pulse/features/shared/boarding/boarding_list_widgets.dart';

/// Plain, role-agnostic boarder shape for the checklist - deliberately not
/// the Patron/Matron `BoardingStudent` entity, so this file stays
/// bloc/entity-agnostic and reusable by both wings.
class RollCallStudent {
  final String id;
  final String name;
  final String? photoUrl;
  final String? bedNumber;
  final String? studentClass;

  const RollCallStudent({
    required this.id,
    required this.name,
    this.photoUrl,
    this.bedNumber,
    this.studentClass,
  });
}

/// One saved attendance mark, handed back to the per-role wrapper's
/// `onSave` callback so it can build the real `BoardingAttendance` records
/// and dispatch the bulk-save bloc event.
class RollCallAttendanceMark {
  final String studentId;
  final AttendanceQuickStatus status;

  const RollCallAttendanceMark({required this.studentId, required this.status});
}

/// Shared Roll Call student checklist - restyled port of the old
/// `boarding_attendance_screen.dart` body. Manages only local UI state
/// (search query + in-progress marks); the per-role wrapper owns bloc wiring
/// and persistence via [onSave].
class RollCallChecklistScreen extends StatefulWidget {
  final String dormitoryId;
  final String dormitoryName;
  final String type;
  final DateTime date;
  final List<RollCallStudent> students;
  final Map<String, AttendanceQuickStatus> initialAttendance;
  final bool isLoading;
  final void Function(List<RollCallAttendanceMark> marks) onSave;

  const RollCallChecklistScreen({
    super.key,
    required this.dormitoryId,
    required this.dormitoryName,
    required this.type,
    required this.date,
    required this.students,
    this.initialAttendance = const {},
    this.isLoading = false,
    required this.onSave,
  });

  @override
  State<RollCallChecklistScreen> createState() =>
      _RollCallChecklistScreenState();
}

class _RollCallChecklistScreenState extends State<RollCallChecklistScreen> {
  late Map<String, AttendanceQuickStatus> _marks;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _marks = Map.of(widget.initialAttendance);
  }

  @override
  void didUpdateWidget(covariant RollCallChecklistScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialAttendance != widget.initialAttendance) {
      for (final entry in widget.initialAttendance.entries) {
        _marks.putIfAbsent(entry.key, () => entry.value);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final semanticColors = Theme.of(context).extension<SemanticColors>()!;

    final filteredStudents = widget.students
        .where(
          (s) =>
              s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              s.id.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    final absentCount = widget.students
        .where(
          (s) => (_marks[s.id] ?? AttendanceQuickStatus.present) ==
              AttendanceQuickStatus.absent,
        )
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.dormitoryName} · ${widget.type}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: widget.isLoading
                ? const _ChecklistSkeleton()
                : widget.students.isEmpty
                    ? const EmptyState(
                        icon: Icons.people_outline,
                        title: 'No Boarders Found',
                        message: 'This dormitory has no allocated students.',
                      )
                    : ListView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.l,
                        ),
                        children: [
                          const SizedBox(height: AppSpacing.m),
                          if (absentCount > 0)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.m,
                              ),
                              child: AlertBanner(
                                title: 'Absentees Detected',
                                message:
                                    '$absentCount marked absent — will alert parents on save.',
                                color: semanticColors.error,
                                icon: Icons.warning_amber_rounded,
                              ),
                            ),
                          AppSearchField(
                            hintText: 'Search boarders...',
                            onChanged: (value) =>
                                setState(() => _searchQuery = value),
                          ),
                          const SizedBox(height: AppSpacing.m),
                          Text(
                            '${filteredStudents.length} Students',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: AppSpacing.s),
                          for (final student in filteredStudents)
                            StudentListRow(
                              name: student.name,
                              photoUrl: student.photoUrl,
                              bedLabel: student.bedNumber != null
                                  ? 'Bed: ${student.bedNumber}'
                                  : null,
                              classLabel: student.studentClass,
                              trailing: AttendanceStatusToggle(
                                selected: _marks[student.id] ??
                                    AttendanceQuickStatus.present,
                                onChanged: (status) => setState(
                                  () => _marks[student.id] = status,
                                ),
                              ),
                            ),
                        ],
                      ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.l),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated(context),
        border: Border(top: BorderSide(color: AppColors.border(context))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: widget.students.isEmpty
                    ? null
                    : () => setState(() {
                          for (final s in widget.students) {
                            _marks[s.id] = AttendanceQuickStatus.present;
                          }
                        }),
                icon: const Icon(Icons.done_all, size: 18),
                label: const Text('Mark All Present'),
              ),
            ),
            const SizedBox(width: AppSpacing.m),
            Expanded(
              child: PrimaryButton(
                label: 'Save Roll Call',
                onPressed: widget.students.isEmpty ? null : _save,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _save() {
    final marks = widget.students
        .map(
          (s) => RollCallAttendanceMark(
            studentId: s.id,
            status: _marks[s.id] ?? AttendanceQuickStatus.present,
          ),
        )
        .toList();
    widget.onSave(marks);
  }
}

class _ChecklistSkeleton extends StatelessWidget {
  const _ChecklistSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
      children: [
        const SizedBox(height: AppSpacing.m),
        const Skeleton(height: 44, borderRadius: 12),
        const SizedBox(height: AppSpacing.m),
        for (var i = 0; i < 10; i++)
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Skeleton(height: 60, borderRadius: 12),
          ),
      ],
    );
  }
}

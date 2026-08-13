import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/admin/presentation/widgets/admin_app_bar.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';
import '../widgets/structure_empty_hint.dart';
import '../widgets/structure_ui_kit.dart';
import '../../domain/services/structure_dependency_service.dart';
import 'package:school_pulse/injection_container.dart' as di;

/// Shows a dependency-aware delete confirmation: if [dependentCount] is
/// greater than 0, offers Archive instead of a destructive delete. Returns
/// 'delete', 'archive', or null (cancelled).
Future<String?> _confirmDeleteOrArchive(
  BuildContext context, {
  required String title,
  required String itemName,
  required int dependentCount,
  required String dependentDescription,
}) async {
  if (dependentCount == 0) {
    final confirmed = await showDeleteConfirmDialog(
      context,
      title: title,
      message: 'Delete "$itemName"?',
    );
    return confirmed == true ? 'delete' : null;
  }
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(
        '"$itemName" is still referenced by $dependentCount $dependentDescription. '
        'Archive it instead of deleting it to keep that data intact.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, 'archive'),
          child: const Text('Archive'),
        ),
      ],
    ),
  );
}

/// Levels, Academic Years/Terms, Classes/Streams, and Subjects - the core
/// academic hierarchy every other module reads from.
class AcademicStructureScreen extends StatefulWidget {
  final int initialTab;

  const AcademicStructureScreen({super.key, this.initialTab = 0});

  @override
  State<AcademicStructureScreen> createState() =>
      _AcademicStructureScreenState();
}

class _AcademicStructureScreenState extends State<AcademicStructureScreen> {
  static const _sections = [
    'Levels',
    'Years & terms',
    'Classes & streams',
    'Subjects',
  ];

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
  }

  @override
  void didUpdateWidget(covariant AcademicStructureScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) {
      _selectedIndex = widget.initialTab.clamp(0, _sections.length - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AdminAppBar(title: 'Academic Structure'),
      body: Column(
        children: [
          StructureSectionPicker(
            sections: _sections,
            selectedIndex: _selectedIndex,
            onSelected: (index) =>
                context.go('/staff/admin/structure/academic?tab=$index'),
          ),
          Expanded(
            child: BlocBuilder<StructureBloc, StructureState>(
              builder: (context, state) {
                final pages = [
                  _LevelsTab(state: state),
                  _YearsAndTermsTab(state: state),
                  _ClassesAndStreamsTab(state: state),
                  _SubjectsTab(state: state),
                ];
                return IndexedStack(index: _selectedIndex, children: pages);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _LevelsTab extends StatelessWidget {
  final StructureState state;
  const _LevelsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      body: state.levels.isEmpty
          ? const StructureEmptyHint(
              'No educational levels yet.\nAdd Kindergarten, Primary, Secondary - or whatever tiers this school offers.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.levels.length,
              itemBuilder: (context, index) {
                final level = state.levels[index];
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text(
                      level.name,
                      style: TextStyle(
                        decoration: level.isActive
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      [
                        if (level.code.isNotEmpty) level.code,
                        if (level.description.isNotEmpty) level.description,
                      ].join(' - '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showLevelFormDialog(
                            context,
                            existing: level,
                            schoolId: schoolId,
                            onSave: (updated) =>
                                bloc.add(SaveLevelRequested(updated)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final dependentCount = await di
                                .sl<StructureDependencyService>()
                                .countClassesInLevel(schoolId, level.id);
                            if (!context.mounted) return;
                            final action = await _confirmDeleteOrArchive(
                              context,
                              title: 'Delete Level',
                              itemName: level.name,
                              dependentCount: dependentCount,
                              dependentDescription: 'class(es)',
                            );
                            if (action == 'delete') {
                              bloc.add(DeleteLevelRequested(level.id));
                            } else if (action == 'archive') {
                              bloc.add(ArchiveLevelRequested(level.id));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showLevelFormDialog(
          context,
          schoolId: schoolId,
          onSave: (level) => bloc.add(SaveLevelRequested(level)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Level'),
      ),
    );
  }
}

class _YearsAndTermsTab extends StatelessWidget {
  final StructureState state;
  const _YearsAndTermsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    final dateFmt = DateFormat('MMM dd, yyyy');
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Academic Years',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () => showAcademicYearFormDialog(
                context,
                schoolId: schoolId,
                onSave: (y) => bloc.add(SaveAcademicYearRequested(y)),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add Year'),
            ),
          ],
        ),
        if (state.academicYears.isEmpty)
          const StructureEmptyHint('No academic years defined yet.'),
        ...state.academicYears.map(
          (year) => AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Row(
                children: [
                  Text(
                    year.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (year.isCurrent) ...[
                    const SizedBox(width: 8),
                    const Chip(
                      label: Text('Current'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                '${dateFmt.format(year.startDate)} - ${dateFmt.format(year.endDate)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!year.isCurrent)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      tooltip: 'Set as current year',
                      onPressed: () => bloc.add(
                        SetCurrentAcademicYearRequested(year.id, year.schoolId),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showAcademicYearFormDialog(
                      context,
                      existing: year,
                      schoolId: schoolId,
                      onSave: (updated) =>
                          bloc.add(SaveAcademicYearRequested(updated)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDeleteConfirmDialog(
                        context,
                        title: 'Delete Year',
                        message: 'Delete "${year.name}"?',
                      );
                      if (confirmed == true) {
                        bloc.add(DeleteAcademicYearRequested(year.id));
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Terms / Semesters',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: state.academicYears.isEmpty
                  ? null
                  : () => showAcademicTermFormDialog(
                      context,
                      years: state.academicYears,
                      schoolId: schoolId,
                      onSave: (t) => bloc.add(SaveAcademicTermRequested(t)),
                    ),
              icon: const Icon(Icons.add),
              label: const Text('Add Term'),
            ),
          ],
        ),
        if (state.academicYears.isEmpty)
          const StructureEmptyHint('Add an academic year first.')
        else if (state.academicTerms.isEmpty)
          const StructureEmptyHint(
            'No terms defined yet.\nAdd Term 1/2/3, Semester 1/2, or whatever system this school uses.',
          ),
        ...state.academicTerms.map((term) {
          final year = state.academicYears
              .where((y) => y.id == term.academicYearId)
              .firstOrNull;
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Row(
                children: [
                  Text(
                    term.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (term.isCurrent) ...[
                    const SizedBox(width: 8),
                    const Chip(
                      label: Text('Current'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ],
              ),
              subtitle: Text(
                '${year?.name ?? 'Unknown year'} - ${dateFmt.format(term.startDate)} to ${dateFmt.format(term.endDate)}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!term.isCurrent)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      tooltip: 'Set as current term',
                      onPressed: () => bloc.add(
                        SetCurrentAcademicTermRequested(term.id, term.schoolId),
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showAcademicTermFormDialog(
                      context,
                      existing: term,
                      years: state.academicYears,
                      schoolId: schoolId,
                      onSave: (updated) =>
                          bloc.add(SaveAcademicTermRequested(updated)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDeleteConfirmDialog(
                        context,
                        title: 'Delete Term',
                        message: 'Delete "${term.name}"?',
                      );
                      if (confirmed == true) {
                        bloc.add(DeleteAcademicTermRequested(term.id));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ClassesAndStreamsTab extends StatelessWidget {
  final StructureState state;
  const _ClassesAndStreamsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Classes',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: state.levels.isEmpty
                  ? null
                  : () => showClassFormDialog(
                      context,
                      levels: state.levels,
                      schoolId: schoolId,
                      onSave: (c) => bloc.add(SaveClassRequested(c)),
                    ),
              icon: const Icon(Icons.add),
              label: const Text('Add Class'),
            ),
          ],
        ),
        if (state.levels.isEmpty)
          const StructureEmptyHint(
            'Add an educational level first (see the Levels tab).',
          )
        else if (state.classes.isEmpty)
          const StructureEmptyHint('No classes defined yet.'),
        ...state.classes.map((schoolClass) {
          final level = state.levels
              .where((l) => l.id == schoolClass.levelId)
              .firstOrNull;
          final streamCount = state.streams
              .where((s) => s.classId == schoolClass.id)
              .length;
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                schoolClass.name,
                style: TextStyle(
                  decoration: schoolClass.isActive
                      ? null
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                '${level?.name ?? 'No level'} - $streamCount stream(s) - Capacity ${schoolClass.capacity}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showClassFormDialog(
                      context,
                      existing: schoolClass,
                      levels: state.levels,
                      schoolId: schoolId,
                      onSave: (updated) =>
                          bloc.add(SaveClassRequested(updated)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final dependentCount = await di
                          .sl<StructureDependencyService>()
                          .countStudentsInClass(schoolId, schoolClass.id);
                      if (!context.mounted) return;
                      final action = await _confirmDeleteOrArchive(
                        context,
                        title: 'Delete Class',
                        itemName: schoolClass.name,
                        dependentCount: dependentCount,
                        dependentDescription: 'student(s)',
                      );
                      if (action == 'delete') {
                        bloc.add(DeleteClassRequested(schoolClass.id));
                      } else if (action == 'archive') {
                        bloc.add(ArchiveClassRequested(schoolClass.id));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Streams / Sections',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: state.classes.isEmpty
                  ? null
                  : () => showStreamFormDialog(
                      context,
                      classes: state.classes,
                      schoolId: schoolId,
                      onSave: (s) => bloc.add(SaveStreamRequested(s)),
                    ),
              icon: const Icon(Icons.add),
              label: const Text('Add Stream'),
            ),
          ],
        ),
        if (state.classes.isEmpty)
          const StructureEmptyHint('Add a class first.')
        else if (state.streams.isEmpty)
          const StructureEmptyHint(
            'No streams defined yet.\nAdd East/West, A/B/C, or whatever sections this school uses.',
          ),
        ...state.streams.map((stream) {
          final schoolClass = state.classes
              .where((c) => c.id == stream.classId)
              .firstOrNull;
          return AppCard(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(
                stream.name,
                style: TextStyle(
                  decoration: stream.isActive
                      ? null
                      : TextDecoration.lineThrough,
                ),
              ),
              subtitle: Text(
                '${schoolClass?.name ?? 'No class'} - Capacity ${stream.capacity}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => showStreamFormDialog(
                      context,
                      existing: stream,
                      classes: state.classes,
                      schoolId: schoolId,
                      onSave: (updated) =>
                          bloc.add(SaveStreamRequested(updated)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () async {
                      final confirmed = await showDeleteConfirmDialog(
                        context,
                        title: 'Delete Stream',
                        message: 'Delete "${stream.name}"?',
                      );
                      if (confirmed == true) {
                        bloc.add(DeleteStreamRequested(stream.id));
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SubjectsTab extends StatelessWidget {
  final StructureState state;
  const _SubjectsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final schoolId =
        (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;
    return Scaffold(
      body: state.subjects.isEmpty
          ? const StructureEmptyHint('No subjects defined yet.')
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.subjects.length,
              itemBuilder: (context, index) {
                final subject = state.subjects[index];
                final department = state.departments
                    .where((d) => d.id == subject.departmentId)
                    .firstOrNull;
                final color = subject.color.isNotEmpty
                    ? Color(int.parse(subject.color.replaceFirst('#', '0xff')))
                    : Colors.blueGrey;
                return AppCard(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: color, radius: 12),
                    title: Text(
                      subject.name,
                      style: TextStyle(
                        decoration: subject.isActive
                            ? null
                            : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text(
                      [
                        department?.name ?? 'No department',
                        if (subject.isElective) 'Elective',
                        if (subject.isPractical) 'Practical',
                      ].join(' - '),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showSubjectFormDialog(
                            context,
                            existing: subject,
                            departments: state.departments,
                            schoolId: schoolId,
                            onSave: (updated) =>
                                bloc.add(SaveSubjectRequested(updated)),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () async {
                            final confirmed = await showDeleteConfirmDialog(
                              context,
                              title: 'Delete Subject',
                              message: 'Delete "${subject.name}"?',
                            );
                            if (confirmed == true) {
                              bloc.add(DeleteSubjectRequested(subject.id));
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSubjectFormDialog(
          context,
          departments: state.departments,
          schoolId: schoolId,
          onSave: (s) => bloc.add(SaveSubjectRequested(s)),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Subject'),
      ),
    );
  }
}

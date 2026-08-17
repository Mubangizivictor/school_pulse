import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/services/structure_integrity_validator.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';
import '../widgets/structure_empty_hint.dart';

const _validator = StructureIntegrityValidator();

/// One academic setup task at a time. The Structure wizard passes `section`
/// in the query string, avoiding the old tabbed/random-navigation experience.
class AcademicStructureScreen extends StatelessWidget {
  final String section;

  const AcademicStructureScreen({super.key, this.section = 'levels'});

  @override
  Widget build(BuildContext context) {
    final requested = GoRouterState.of(context).uri.queryParameters['section'] ?? section;
    final normalized = const {
      'levels',
      'years',
      'terms',
      'classes',
      'streams',
      'subjects',
    }.contains(requested)
        ? requested
        : 'levels';

    return Scaffold(
      appBar: AppBar(title: Text(_title(normalized))),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) => switch (normalized) {
          'years' => _years(context, state),
          'terms' => _terms(context, state),
          'classes' => _classes(context, state),
          'streams' => _streams(context, state),
          'subjects' => _subjects(context, state),
          _ => _levels(context, state),
        },
      ),
    );
  }

  String _title(String value) => switch (value) {
        'years' => 'Academic Years',
        'terms' => 'Terms / Semesters',
        'classes' => 'Classes',
        'streams' => 'Streams / Sections',
        'subjects' => 'Subjects',
        _ => 'Educational Levels',
      };

  Widget _levels(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    return _AcademicSectionPage(
      intro: 'Define the education tiers offered by this school. Classes are created only after levels exist.',
      addLabel: 'Add Level',
      onAdd: () => showLevelFormDialog(
        context,
        onSave: (value) => _dispatchIfValid(
          context,
          _validator.validateLevel(value, state.levels),
          () => bloc.add(SaveLevelRequested(value)),
        ),
      ),
      child: state.levels.isEmpty
          ? const StructureEmptyHint('No educational levels yet. Add only the levels this school actually offers.')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final level = state.levels[index];
                final classCount = state.classes.where((item) => item.levelId == level.id && item.isActive).length;
                return AppCard(
                  child: ListTile(
                    title: Text(
                      level.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: level.isActive ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text([
                      if (level.code.trim().isNotEmpty) level.code.trim(),
                      '$classCount active class${classCount == 1 ? '' : 'es'}',
                    ].join(' • ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showLevelFormDialog(
                        context,
                        existing: level,
                        onSave: (value) => _dispatchIfValid(
                          context,
                          _validator.validateLevel(value, state.levels),
                          () => bloc.add(SaveLevelRequested(value)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _years(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final fmt = DateFormat('dd MMM yyyy');
    return _AcademicSectionPage(
      intro: 'Create school years first. Exactly one non-archived year should be current before year-scoped setup continues.',
      addLabel: 'Add Academic Year',
      onAdd: () => showAcademicYearFormDialog(
        context,
        onSave: (value) => _dispatchIfValid(
          context,
          _validator.validateAcademicYear(value, state.academicYears),
          () => bloc.add(SaveAcademicYearRequested(value)),
        ),
      ),
      child: state.academicYears.isEmpty
          ? const StructureEmptyHint('No academic years configured yet.')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.academicYears.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final year = state.academicYears[index];
                final termCount = state.academicTerms.where((term) => term.academicYearId == year.id).length;
                return AppCard(
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(year.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                        if (year.isCurrent) const Chip(label: Text('Current')),
                      ],
                    ),
                    subtitle: Text('${fmt.format(year.startDate)} – ${fmt.format(year.endDate)}\n$termCount academic period${termCount == 1 ? '' : 's'}'),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (action) {
                        if (action == 'current') {
                          bloc.add(SetCurrentAcademicYearRequested(year.id));
                        } else {
                          showAcademicYearFormDialog(
                            context,
                            existing: year,
                            onSave: (value) => _dispatchIfValid(
                              context,
                              _validator.validateAcademicYear(value, state.academicYears),
                              () => bloc.add(SaveAcademicYearRequested(value)),
                            ),
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        if (!year.isCurrent) const PopupMenuItem(value: 'current', child: Text('Set as current')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _terms(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final fmt = DateFormat('dd MMM yyyy');
    final currentYear = state.academicYears.where((year) => year.isCurrent && !year.isArchived).firstOrNull;
    final items = currentYear == null
        ? <AcademicTerm>[]
        : state.academicTerms.where((term) => term.academicYearId == currentYear.id).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return _AcademicSectionPage(
      intro: currentYear == null
          ? 'Set one academic year as current before adding its terms or semesters.'
          : 'Configure periods inside ${currentYear.name}. Dates must remain inside the year and may not overlap.',
      addLabel: 'Add Term / Semester',
      onAdd: currentYear == null
          ? null
          : () => showAcademicTermFormDialog(
                context,
                years: [currentYear],
                onSave: (value) => _dispatchIfValid(
                  context,
                  _validator.validateAcademicTerm(value, state.academicYears, state.academicTerms),
                  () => bloc.add(SaveAcademicTermRequested(value)),
                ),
              ),
      child: currentYear == null
          ? const StructureEmptyHint('Return to Academic Years and select one current year first.')
          : items.isEmpty
              ? const StructureEmptyHint('No terms or semesters configured for the current year.')
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final term = items[index];
                    return AppCard(
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(child: Text(term.name, style: const TextStyle(fontWeight: FontWeight.w700))),
                            if (term.isCurrent) const Chip(label: Text('Current')),
                          ],
                        ),
                        subtitle: Text('${fmt.format(term.startDate)} – ${fmt.format(term.endDate)}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'current') {
                              bloc.add(SetCurrentAcademicTermRequested(term.id));
                            } else {
                              showAcademicTermFormDialog(
                                context,
                                existing: term,
                                years: [currentYear],
                                onSave: (value) => _dispatchIfValid(
                                  context,
                                  _validator.validateAcademicTerm(value, state.academicYears, state.academicTerms),
                                  () => bloc.add(SaveAcademicTermRequested(value)),
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            if (!term.isCurrent) const PopupMenuItem(value: 'current', child: Text('Set as current')),
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _classes(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final activeLevels = state.levels.where((item) => item.isActive).toList();
    return _AcademicSectionPage(
      intro: 'Create classes under existing levels. Class definitions never require teachers; staff assignments happen later.',
      addLabel: 'Add Class',
      onAdd: activeLevels.isEmpty
          ? null
          : () => showClassFormDialog(
                context,
                levels: activeLevels,
                onSave: (value) => _dispatchIfValid(
                  context,
                  _validator.validateClass(
                    value,
                    levels: state.levels,
                    classes: state.classes,
                    streams: state.streams,
                  ),
                  () => bloc.add(SaveClassRequested(value)),
                ),
              ),
      child: activeLevels.isEmpty
          ? const StructureEmptyHint('Add an educational level before creating classes.')
          : state.classes.isEmpty
              ? const StructureEmptyHint('No classes configured yet.')
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: state.classes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final schoolClass = state.classes[index];
                    final level = state.levels.where((item) => item.id == schoolClass.levelId).firstOrNull;
                    final activeStreams = state.streams.where((item) => item.classId == schoolClass.id && item.isActive);
                    final allocated = activeStreams.fold<int>(0, (sum, item) => sum + item.capacity);
                    final available = schoolClass.capacity > 0 ? (schoolClass.capacity - allocated).clamp(0, schoolClass.capacity) : 0;
                    return AppCard(
                      child: ListTile(
                        title: Text(
                          schoolClass.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: schoolClass.isActive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text([
                          level?.name ?? 'Missing level',
                          'Capacity ${schoolClass.capacity}',
                          if (allocated > 0) '$allocated allocated • $available available',
                        ].join(' • ')),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showClassFormDialog(
                            context,
                            existing: schoolClass,
                            levels: activeLevels,
                            onSave: (value) => _dispatchIfValid(
                              context,
                              _validator.validateClass(
                                value,
                                levels: state.levels,
                                classes: state.classes,
                                streams: state.streams,
                              ),
                              () => bloc.add(SaveClassRequested(value)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _streams(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final activeClasses = state.classes.where((item) => item.isActive).toList();
    return _AcademicSectionPage(
      intro: 'Streams are children of a class. The sum of active stream capacities must stay inside the parent class capacity.',
      addLabel: 'Add Stream / Section',
      onAdd: activeClasses.isEmpty
          ? null
          : () => showStreamFormDialog(
                context,
                classes: activeClasses,
                onSave: (value) => _dispatchIfValid(
                  context,
                  _validator.validateStream(value, classes: state.classes, streams: state.streams),
                  () => bloc.add(SaveStreamRequested(value)),
                ),
              ),
      child: activeClasses.isEmpty
          ? const StructureEmptyHint('Create classes before adding streams or sections.')
          : state.streams.isEmpty
              ? const StructureEmptyHint('No streams configured yet.')
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: state.streams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final stream = state.streams[index];
                    final parent = state.classes.where((item) => item.id == stream.classId).firstOrNull;
                    final allocated = state.streams
                        .where((item) => item.classId == stream.classId && item.isActive)
                        .fold<int>(0, (sum, item) => sum + item.capacity);
                    final available = parent == null ? 0 : (parent.capacity - allocated).clamp(0, parent.capacity);
                    return AppCard(
                      child: ListTile(
                        title: Text(
                          stream.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: stream.isActive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text('${parent?.name ?? 'Missing class'} • Capacity ${stream.capacity}\nClass allocation $allocated / ${parent?.capacity ?? 0} • $available unallocated'),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showStreamFormDialog(
                            context,
                            existing: stream,
                            classes: activeClasses,
                            onSave: (value) => _dispatchIfValid(
                              context,
                              _validator.validateStream(value, classes: state.classes, streams: state.streams),
                              () => bloc.add(SaveStreamRequested(value)),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _subjects(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final departments = state.departments.where((item) => item.isActive).toList();
    return _AcademicSectionPage(
      intro: 'Define the subject catalogue here. Teachers are assigned later, so Subject creation cannot create circular setup dependencies.',
      addLabel: 'Add Subject',
      onAdd: () => showSubjectFormDialog(
        context,
        departments: departments,
        onSave: (value) => _dispatchIfValid(
          context,
          _validator.validateSubject(value, subjects: state.subjects, departments: state.departments),
          () => bloc.add(SaveSubjectRequested(value)),
        ),
      ),
      child: state.subjects.isEmpty
          ? const StructureEmptyHint('No subjects configured yet.')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (_, index) {
                final subject = state.subjects[index];
                final department = state.departments.where((item) => item.id == subject.departmentId).firstOrNull;
                return AppCard(
                  child: ListTile(
                    leading: CircleAvatar(radius: 8, backgroundColor: _safeColor(subject.color)),
                    title: Text(
                      subject.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        decoration: subject.isActive ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    subtitle: Text([
                      if (subject.code.trim().isNotEmpty) subject.code.trim(),
                      if (department != null) department.name,
                      subject.isElective ? 'Elective' : 'Core / standard',
                      if (subject.isPractical) 'Practical',
                    ].join(' • ')),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => showSubjectFormDialog(
                        context,
                        existing: subject,
                        departments: departments,
                        onSave: (value) => _dispatchIfValid(
                          context,
                          _validator.validateSubject(value, subjects: state.subjects, departments: state.departments),
                          () => bloc.add(SaveSubjectRequested(value)),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AcademicSectionPage extends StatelessWidget {
  final String intro;
  final String addLabel;
  final VoidCallback? onAdd;
  final Widget child;

  const _AcademicSectionPage({
    required this.intro,
    required this.addLabel,
    required this.onAdd,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              intro,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdd,
                icon: const Icon(Icons.add),
                label: Text(addLabel),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

void _dispatchIfValid(
  BuildContext context,
  String? validationError,
  VoidCallback dispatch,
) {
  if (validationError == null) {
    dispatch();
    return;
  }
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(validationError)));
}

Color _safeColor(String raw) {
  final parsed = int.tryParse(raw.replaceFirst('#', ''), radix: 16);
  return parsed == null ? Colors.blueGrey : Color(0xFF000000 | parsed);
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

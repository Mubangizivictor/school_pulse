import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import '../../domain/entities/structure_entities.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';
import '../widgets/structure_empty_hint.dart';

/// Focused academic Structure editor.
///
/// The old tab bar let admins jump into dependent configuration in arbitrary
/// order. The setup wizard now routes here with a single section, so this
/// screen intentionally shows only one academic task at a time.
class AcademicStructureScreen extends StatelessWidget {
  final String section;

  const AcademicStructureScreen({
    super.key,
    this.section = 'levels',
  });

  @override
  Widget build(BuildContext context) {
    final normalized = _normalizeSection(section);
    return Scaffold(
      appBar: AppBar(title: Text(_titleFor(normalized))),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, state) {
          return switch (normalized) {
            'years' => _AcademicYearsSection(state: state),
            'terms' => _AcademicTermsSection(state: state),
            'classes' => _ClassesSection(state: state),
            'streams' => _StreamsSection(state: state),
            'subjects' => _SubjectsSection(state: state),
            _ => _LevelsSection(state: state),
          };
        },
      ),
    );
  }

  String _normalizeSection(String value) {
    const supported = {'levels', 'years', 'terms', 'classes', 'streams', 'subjects'};
    return supported.contains(value) ? value : 'levels';
  }

  String _titleFor(String value) {
    return switch (value) {
      'years' => 'Academic Years',
      'terms' => 'Terms / Semesters',
      'classes' => 'Classes',
      'streams' => 'Streams / Sections',
      'subjects' => 'Subjects',
      _ => 'Educational Levels',
    };
  }
}

class _LevelsSection extends StatelessWidget {
  final StructureState state;

  const _LevelsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    return _SectionScaffold(
      intro: 'Define the education tiers offered by this school. Classes are created only after levels exist.',
      addLabel: 'Add Level',
      onAdd: () => showLevelFormDialog(
        context,
        onSave: (level) {
          final error = _validateLevel(level, state);
          if (error != null) return _showError(context, error);
          bloc.add(SaveLevelRequested(level));
        },
      ),
      child: state.levels.isEmpty
          ? const StructureEmptyHint(
              'No educational levels yet. Add only the levels this school actually offers.',
            )
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.levels.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final level = state.levels[index];
                final classCount = state.classes.where((c) => c.levelId == level.id && c.isActive).length;
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
                        onSave: (updated) {
                          final error = _validateLevel(updated, state);
                          if (error != null) return _showError(context, error);
                          bloc.add(SaveLevelRequested(updated));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AcademicYearsSection extends StatelessWidget {
  final StructureState state;

  const _AcademicYearsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final fmt = DateFormat('dd MMM yyyy');
    return _SectionScaffold(
      intro: 'Create school years first. Exactly one active year should be current before terms and year-scoped setup continue.',
      addLabel: 'Add Academic Year',
      onAdd: () => showAcademicYearFormDialog(
        context,
        onSave: (year) {
          final error = _validateYear(year, state);
          if (error != null) return _showError(context, error);
          bloc.add(SaveAcademicYearRequested(year));
        },
      ),
      child: state.academicYears.isEmpty
          ? const StructureEmptyHint('No academic years configured yet.')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.academicYears.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final year = state.academicYears[index];
                final termCount = state.academicTerms.where((t) => t.academicYearId == year.id).length;
                return AppCard(
                  child: ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            year.name,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (year.isCurrent) const Chip(label: Text('Current')),
                      ],
                    ),
                    subtitle: Text(
                      '${fmt.format(year.startDate)} – ${fmt.format(year.endDate)}\n$termCount academic period${termCount == 1 ? '' : 's'}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'current') {
                          bloc.add(SetCurrentAcademicYearRequested(year.id));
                        } else if (value == 'edit') {
                          showAcademicYearFormDialog(
                            context,
                            existing: year,
                            onSave: (updated) {
                              final error = _validateYear(updated, state);
                              if (error != null) return _showError(context, error);
                              bloc.add(SaveAcademicYearRequested(updated));
                            },
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        if (!year.isCurrent)
                          const PopupMenuItem(value: 'current', child: Text('Set as current')),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _AcademicTermsSection extends StatelessWidget {
  final StructureState state;

  const _AcademicTermsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final fmt = DateFormat('dd MMM yyyy');
    final currentYear = state.academicYears.where((year) => year.isCurrent && !year.isArchived).firstOrNull;
    final visibleTerms = currentYear == null
        ? <AcademicTerm>[]
        : state.academicTerms.where((term) => term.academicYearId == currentYear.id).toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return _SectionScaffold(
      intro: currentYear == null
          ? 'Set an academic year as current before creating its terms or semesters.'
          : 'Configure the academic periods inside ${currentYear.name}. Dates must stay inside the year and may not overlap.',
      addLabel: 'Add Term / Semester',
      onAdd: currentYear == null
          ? null
          : () => showAcademicTermFormDialog(
                context,
                years: [currentYear],
                onSave: (term) {
                  final error = _validateTerm(term, state);
                  if (error != null) return _showError(context, error);
                  bloc.add(SaveAcademicTermRequested(term));
                },
              ),
      child: currentYear == null
          ? const StructureEmptyHint('Return to Academic Years and select one current year first.')
          : visibleTerms.isEmpty
              ? const StructureEmptyHint('No terms or semesters configured for the current academic year.')
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: visibleTerms.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final term = visibleTerms[index];
                    return AppCard(
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                term.name,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (term.isCurrent) const Chip(label: Text('Current')),
                          ],
                        ),
                        subtitle: Text('${fmt.format(term.startDate)} – ${fmt.format(term.endDate)}'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'current') {
                              bloc.add(SetCurrentAcademicTermRequested(term.id));
                            } else if (value == 'edit') {
                              showAcademicTermFormDialog(
                                context,
                                existing: term,
                                years: [currentYear],
                                onSave: (updated) {
                                  final error = _validateTerm(updated, state);
                                  if (error != null) return _showError(context, error);
                                  bloc.add(SaveAcademicTermRequested(updated));
                                },
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            if (!term.isCurrent)
                              const PopupMenuItem(value: 'current', child: Text('Set as current')),
                            const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _ClassesSection extends StatelessWidget {
  final StructureState state;

  const _ClassesSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final activeLevels = state.levels.where((level) => level.isActive).toList();
    return _SectionScaffold(
      intro: 'Create classes under existing educational levels. Staff assignment is deliberately handled later, so classes never depend on teachers.',
      addLabel: 'Add Class',
      onAdd: activeLevels.isEmpty
          ? null
          : () => showClassFormDialog(
                context,
                levels: activeLevels,
                onSave: (schoolClass) {
                  final error = _validateClass(schoolClass, state);
                  if (error != null) return _showError(context, error);
                  bloc.add(SaveClassRequested(schoolClass));
                },
              ),
      child: activeLevels.isEmpty
          ? const StructureEmptyHint('Add an educational level before creating classes.')
          : state.classes.isEmpty
              ? const StructureEmptyHint('No classes configured yet.')
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: state.classes.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final schoolClass = state.classes[index];
                    final level = state.levels.where((l) => l.id == schoolClass.levelId).firstOrNull;
                    final activeStreams = state.streams
                        .where((stream) => stream.classId == schoolClass.id && stream.isActive)
                        .toList();
                    final allocated = activeStreams.fold<int>(0, (sum, stream) => sum + stream.capacity);
                    final remaining = schoolClass.capacity > 0 ? schoolClass.capacity - allocated : 0;
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
                          if (activeStreams.isNotEmpty) '$allocated allocated • $remaining available',
                        ].join(' • ')),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showClassFormDialog(
                            context,
                            existing: schoolClass,
                            levels: activeLevels,
                            onSave: (updated) {
                              final error = _validateClass(updated, state);
                              if (error != null) return _showError(context, error);
                              bloc.add(SaveClassRequested(updated));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _StreamsSection extends StatelessWidget {
  final StructureState state;

  const _StreamsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final activeClasses = state.classes.where((schoolClass) => schoolClass.isActive).toList();
    return _SectionScaffold(
      intro: 'Streams are children of a class. Their combined active capacity can never exceed the parent class capacity.',
      addLabel: 'Add Stream / Section',
      onAdd: activeClasses.isEmpty
          ? null
          : () => showStreamFormDialog(
                context,
                classes: activeClasses,
                onSave: (stream) {
                  final error = _validateStream(stream, state);
                  if (error != null) return _showError(context, error);
                  bloc.add(SaveStreamRequested(stream));
                },
              ),
      child: activeClasses.isEmpty
          ? const StructureEmptyHint('Create classes before adding streams or sections.')
          : state.streams.isEmpty
              ? const StructureEmptyHint('No streams configured yet.')
              : ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: state.streams.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final stream = state.streams[index];
                    final parent = state.classes.where((c) => c.id == stream.classId).firstOrNull;
                    final siblings = state.streams
                        .where((s) => s.classId == stream.classId && s.isActive)
                        .toList();
                    final allocated = siblings.fold<int>(0, (sum, item) => sum + item.capacity);
                    final available = parent == null ? 0 : parent.capacity - allocated;
                    return AppCard(
                      child: ListTile(
                        title: Text(
                          stream.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: stream.isActive ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          '${parent?.name ?? 'Missing class'} • Capacity ${stream.capacity}\n'
                          'Class allocation $allocated / ${parent?.capacity ?? 0} • ${available < 0 ? 0 : available} unallocated',
                        ),
                        isThreeLine: true,
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showStreamFormDialog(
                            context,
                            existing: stream,
                            classes: activeClasses,
                            onSave: (updated) {
                              final error = _validateStream(updated, state);
                              if (error != null) return _showError(context, error);
                              bloc.add(SaveStreamRequested(updated));
                            },
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class _SubjectsSection extends StatelessWidget {
  final StructureState state;

  const _SubjectsSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final activeDepartments = state.departments.where((d) => d.isActive).toList();
    return _SectionScaffold(
      intro: 'Define the subject catalogue here. Teachers are assigned later, preventing circular dependencies between Subjects, Classes and Staff.',
      addLabel: 'Add Subject',
      onAdd: () => showSubjectFormDialog(
        context,
        departments: activeDepartments,
        onSave: (subject) {
          final error = _validateSubject(subject, state);
          if (error != null) return _showError(context, error);
          bloc.add(SaveSubjectRequested(subject));
        },
      ),
      child: state.subjects.isEmpty
          ? const StructureEmptyHint('No subjects configured yet.')
          : ListView.separated(
              padding: EdgeInsets.zero,
              itemCount: state.subjects.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final subject = state.subjects[index];
                final department = state.departments.where((d) => d.id == subject.departmentId).firstOrNull;
                final color = _safeColor(subject.color);
                return AppCard(
                  child: ListTile(
                    leading: CircleAvatar(radius: 8, backgroundColor: color),
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
                        departments: activeDepartments,
                        onSave: (updated) {
                          final error = _validateSubject(updated, state);
                          if (error != null) return _showError(context, error);
                          bloc.add(SaveSubjectRequested(updated));
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class _SectionScaffold extends StatelessWidget {
  final String intro;
  final String addLabel;
  final VoidCallback? onAdd;
  final Widget child;

  const _SectionScaffold({
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

String? _validateLevel(EducationalLevel candidate, StructureState state) {
  if (candidate.name.trim().isEmpty) return 'Enter a level name.';
  final duplicateName = state.levels.any(
    (level) => level.id != candidate.id &&
        level.isActive &&
        candidate.isActive &&
        level.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
  );
  if (duplicateName) return 'An active level with this name already exists.';
  final code = candidate.code.trim().toLowerCase();
  if (code.isNotEmpty &&
      state.levels.any(
        (level) => level.id != candidate.id &&
            level.isActive &&
            candidate.isActive &&
            level.code.trim().toLowerCase() == code,
      )) {
    return 'This level code is already in use.';
  }
  return null;
}

String? _validateYear(AcademicYear candidate, StructureState state) {
  if (candidate.name.trim().isEmpty) return 'Enter an academic year name.';
  if (!candidate.startDate.isBefore(candidate.endDate)) {
    return 'Academic year end date must be after the start date.';
  }
  if (state.academicYears.any(
    (year) => year.id != candidate.id &&
        year.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
  )) {
    return 'An academic year with this name already exists.';
  }
  return null;
}

String? _validateTerm(AcademicTerm candidate, StructureState state) {
  final years = state.academicYears.where((year) => year.id == candidate.academicYearId);
  if (years.isEmpty) return 'Select a valid academic year.';
  final year = years.first;
  if (!candidate.startDate.isBefore(candidate.endDate)) {
    return 'Term end date must be after the start date.';
  }
  if (candidate.startDate.isBefore(year.startDate) || candidate.endDate.isAfter(year.endDate)) {
    return '${candidate.name} must fall inside ${year.name}.';
  }
  final overlap = state.academicTerms.any((other) {
    if (other.id == candidate.id || other.academicYearId != candidate.academicYearId) return false;
    return !candidate.endDate.isBefore(other.startDate) &&
        !candidate.startDate.isAfter(other.endDate);
  });
  if (overlap) return 'This academic period overlaps another period in ${year.name}.';
  final duplicateName = state.academicTerms.any(
    (other) => other.id != candidate.id &&
        other.academicYearId == candidate.academicYearId &&
        other.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
  );
  if (duplicateName) return 'A period with this name already exists in ${year.name}.';
  return null;
}

String? _validateClass(SchoolClass candidate, StructureState state) {
  if (candidate.name.trim().isEmpty) return 'Enter a class name.';
  if (!state.levels.any((level) => level.id == candidate.levelId && level.isActive)) {
    return 'Select an active educational level.';
  }
  if (candidate.capacity < 0) return 'Class capacity cannot be negative.';
  final duplicateName = state.classes.any(
    (item) => item.id != candidate.id &&
        item.isActive &&
        candidate.isActive &&
        item.levelId == candidate.levelId &&
        item.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
  );
  if (duplicateName) return 'This class already exists under the selected level.';
  final code = candidate.code.trim().toLowerCase();
  if (code.isNotEmpty &&
      state.classes.any(
        (item) => item.id != candidate.id &&
            item.isActive &&
            candidate.isActive &&
            item.code.trim().toLowerCase() == code,
      )) {
    return 'This class code is already in use.';
  }

  final allocated = state.streams
      .where((stream) => stream.classId == candidate.id && stream.isActive)
      .fold<int>(0, (sum, stream) => sum + stream.capacity);
  if (allocated > 0 && candidate.capacity <= 0) {
    return 'This class already has $allocated stream places. Set a class capacity of at least $allocated.';
  }
  if (candidate.capacity > 0 && allocated > candidate.capacity) {
    return 'Class capacity cannot be reduced to ${candidate.capacity}; active streams already allocate $allocated places.';
  }
  return null;
}

String? _validateStream(ClassStream candidate, StructureState state) {
  final parents = state.classes.where((item) => item.id == candidate.classId && item.isActive);
  if (parents.isEmpty) return 'Select an active parent class.';
  final parent = parents.first;
  if (candidate.capacity <= 0 && candidate.isActive) {
    return 'Enter a stream capacity greater than zero.';
  }
  if (parent.capacity <= 0 && candidate.isActive) {
    return 'Set ${parent.name} capacity before adding active streams.';
  }

  final duplicateName = state.streams.any(
    (stream) => stream.id != candidate.id &&
        stream.classId == candidate.classId &&
        stream.isActive &&
        candidate.isActive &&
        stream.name.trim().toLowerCase() == candidate.name.trim().toLowerCase(),
  );
  if (duplicateName) return 'This stream name is already used in ${parent.name}.';

  final code = candidate.code.trim().toLowerCase();
  if (code.isNotEmpty &&
      state.streams.any(
        (stream) => stream.id != candidate.id &&
            stream.classId == candidate.classId &&
            stream.isActive &&
            candidate.isActive &&
            stream.code.trim().toLowerCase() == code,
      )) {
    return 'This stream code is already used in ${parent.name}.';
  }

  final otherAllocated = state.streams
      .where((stream) =>
          stream.id != candidate.id && stream.classId == candidate.classId && stream.isActive)
      .fold<int>(0, (sum, stream) => sum + stream.capacity);
  final proposedTotal = otherAllocated + (candidate.isActive ? candidate.capacity : 0);
  if (proposedTotal > parent.capacity) {
    final available = (parent.capacity - otherAllocated).clamp(0, parent.capacity);
    return 'Stream capacity exceeds ${parent.name} capacity. '
        'Class capacity: ${parent.capacity}, already allocated: $otherAllocated, available: $available.';
  }
  return null;
}

String? _validateSubject(Subject candidate, StructureState state) {
  if (candidate.name.trim().isEmpty) return 'Enter a subject name.';
  final code = candidate.code.trim().toLowerCase();
  if (code.isNotEmpty &&
      state.subjects.any(
        (subject) => subject.id != candidate.id &&
            subject.isActive &&
            candidate.isActive &&
            subject.code.trim().toLowerCase() == code,
      )) {
    return 'This subject code is already in use.';
  }
  if (candidate.departmentId.isNotEmpty &&
      !state.departments.any((d) => d.id == candidate.departmentId && d.isActive)) {
    return 'Select an active department or leave Department empty.';
  }
  return null;
}

void _showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

Color _safeColor(String raw) {
  if (raw.trim().isEmpty) return Colors.blueGrey;
  final normalized = raw.replaceFirst('#', '');
  final parsed = int.tryParse(normalized, radix: 16);
  if (parsed == null) return Colors.blueGrey;
  return Color(0xFF000000 | parsed);
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

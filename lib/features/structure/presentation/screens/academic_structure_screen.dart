import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/services/structure_integrity_validator.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../widgets/structure_dialogs.dart';

const _validator = StructureIntegrityValidator();

/// One academic setup task at a time. The Structure wizard passes `section`
/// in the query string, avoiding the old tabbed/random-navigation experience.
class AcademicStructureScreen extends StatelessWidget {
  final String section;
  final VoidCallback? onSetUpTerms;
  final bool showAppBar;

  const AcademicStructureScreen({
    super.key,
    this.section = 'levels',
    this.onSetUpTerms,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    final requested =
        GoRouterState.of(context).uri.queryParameters['section'] ?? section;
    final normalized =
        const {
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
      appBar: showAppBar ? AppBar(title: Text(_title(normalized))) : null,
      backgroundColor: showAppBar ? null : Colors.transparent,
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

  String _schoolId(BuildContext context) =>
      (context.read<AuthBloc>().state as AuthAuthenticated).user.schoolId;

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
    final schoolId = _schoolId(context);
    final scheme = Theme.of(context).colorScheme;
    void onAddLevel() => showLevelFormDialog(
      context,
      schoolId: schoolId,
      nextOrder: state.levels.length,
      onSave: (value) => _dispatchIfValid(
        context,
        _validator.validateLevel(value, state.levels),
        () => bloc.add(SaveLevelRequested(value)),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    'Add the education levels your school offers.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onAddLevel,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add level'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.levels.isEmpty)
              _LevelsEmptyState(onAdd: onAddLevel)
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: state.levels.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final level = state.levels[index];
                    final classCount = state.classes
                        .where(
                          (item) => item.levelId == level.id && item.isActive,
                        )
                        .length;
                    return AppCard(
                      child: ListTile(
                        title: Text(
                          level.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: level.isActive
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Text(
                          [
                            if (level.code.trim().isNotEmpty) level.code.trim(),
                            '$classCount active class${classCount == 1 ? '' : 'es'}',
                          ].join(' • '),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => showLevelFormDialog(
                            context,
                            schoolId: schoolId,
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _years(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final schoolId = _schoolId(context);
    final fmt = DateFormat('dd MMM yyyy');
    void onAddYear() => showAcademicYearFormDialog(
      context,
      schoolId: schoolId,
      onSave: (value) => _dispatchIfValid(
        context,
        _validator.validateAcademicYear(value, state.academicYears),
        () => bloc.add(SaveAcademicYearRequested(value)),
      ),
    );
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose the current school year.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: state.academicYears.isEmpty
                  ? _AcademicYearEmptyState(onAdd: onAddYear)
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: state.academicYears.length + 1,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, index) {
                        if (index == state.academicYears.length) {
                          return _AddAcademicYearTile(onTap: onAddYear);
                        }
                        final year = state.academicYears[index];
                        final scheme = Theme.of(context).colorScheme;
                        return AppCard(
                          borderColor: year.isCurrent
                              ? scheme.primary.withValues(alpha: 0.5)
                              : null,
                          showShadow: false,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 20,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            year.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            '${fmt.format(year.startDate)} – ${fmt.format(year.endDate)}',
                                            style: TextStyle(
                                              color: scheme.onSurfaceVariant,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (year.isCurrent) ...[
                                      Icon(
                                        Icons.check_circle_rounded,
                                        color: scheme.primary,
                                        size: 23,
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Current',
                                        style: TextStyle(
                                          color: scheme.primary,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                    PopupMenuButton<String>(
                                      icon: const Icon(Icons.more_vert),
                                      onSelected: (action) {
                                        if (action == 'current') {
                                          bloc.add(
                                            SetCurrentAcademicYearRequested(
                                              year.id,
                                              schoolId,
                                            ),
                                          );
                                          return;
                                        }
                                        showAcademicYearFormDialog(
                                          context,
                                          schoolId: schoolId,
                                          existing: year,
                                          onSave: (value) => _dispatchIfValid(
                                            context,
                                            _validator.validateAcademicYear(
                                              value,
                                              state.academicYears,
                                            ),
                                            () => bloc.add(
                                              SaveAcademicYearRequested(value),
                                            ),
                                          ),
                                        );
                                      },
                                      itemBuilder: (_) => [
                                        if (!year.isCurrent)
                                          const PopupMenuItem(
                                            value: 'current',
                                            child: Text('Set as current'),
                                          ),
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Text('Edit'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (year.isCurrent && onSetUpTerms != null) ...[
                                  const SizedBox(height: 12),
                                  InkWell(
                                    onTap: onSetUpTerms,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Set up terms',
                                          style: TextStyle(
                                            color: scheme.primary,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Icon(
                                          Icons.chevron_right,
                                          color: scheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _terms(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final schoolId = _schoolId(context);
    final fmt = DateFormat('dd MMM yyyy');
    final currentYear = state.academicYears
        .where((year) => year.isCurrent && !year.isArchived)
        .firstOrNull;
    final items =
        currentYear == null
              ? <AcademicTerm>[]
              : state.academicTerms
                    .where((term) => term.academicYearId == currentYear.id)
                    .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

    void onAddPeriod() => showAcademicTermFormDialog(
      context,
      schoolId: schoolId,
      years: [currentYear!],
      onSave: (value) => _dispatchIfValid(
        context,
        _validator.validateAcademicTerm(
          value,
          state.academicYears,
          state.academicTerms,
        ),
        () => bloc.add(SaveAcademicTermRequested(value)),
      ),
    );
    final scheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    currentYear == null
                        ? 'Set one academic year as current before adding its terms or semesters.'
                        : 'Add the terms or semesters for ${currentYear.name}.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: currentYear == null ? null : onAddPeriod,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add period'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (currentYear == null)
              const Expanded(
                child: EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No current academic year set',
                  message:
                      'Return to Academic Years and select one current year first.',
                ),
              )
            else if (items.isEmpty)
              _TermsEmptyState(onAdd: onAddPeriod)
            else
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final term = items[index];
                    return AppCard(
                      child: ListTile(
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                term.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (term.isCurrent)
                              Chip(
                                label: const Text('Current'),
                                backgroundColor: scheme.primary,
                                labelStyle: TextStyle(
                                  color: scheme.onPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                                side: BorderSide.none,
                              ),
                          ],
                        ),
                        subtitle: Text(
                          '${fmt.format(term.startDate)} – ${fmt.format(term.endDate)}',
                        ),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'current') {
                              bloc.add(
                                SetCurrentAcademicTermRequested(
                                  term.id,
                                  schoolId,
                                ),
                              );
                            } else {
                              showAcademicTermFormDialog(
                                context,
                                schoolId: schoolId,
                                existing: term,
                                years: [currentYear],
                                onSave: (value) => _dispatchIfValid(
                                  context,
                                  _validator.validateAcademicTerm(
                                    value,
                                    state.academicYears,
                                    state.academicTerms,
                                  ),
                                  () => bloc.add(
                                    SaveAcademicTermRequested(value),
                                  ),
                                ),
                              );
                            }
                          },
                          itemBuilder: (_) => [
                            if (!term.isCurrent)
                              const PopupMenuItem(
                                value: 'current',
                                child: Text('Set as current'),
                              ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _classes(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final schoolId = _schoolId(context);
    final scheme = Theme.of(context).colorScheme;
    final activeLevels = state.levels.where((item) => item.isActive).toList();

    void onAddClass() => showClassFormDialog(
      context,
      schoolId: schoolId,
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
    );

    final byLevel = <EducationalLevel, List<SchoolClass>>{};
    for (final level in activeLevels) {
      final classes = state.classes
          .where((item) => item.levelId == level.id)
          .toList();
      if (classes.isNotEmpty) byLevel[level] = classes;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (activeLevels.isNotEmpty && state.classes.isNotEmpty)
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: scheme.onSurfaceVariant,
                        ),
                      if (activeLevels.isNotEmpty && state.classes.isNotEmpty)
                        const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activeLevels.isEmpty
                              ? 'Add an educational level before creating classes.'
                              : state.classes.isEmpty
                              ? 'Add classes under the correct education level.'
                              : 'Classes are grouped by education level.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: scheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: activeLevels.isEmpty ? null : onAddClass,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add class'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.classes.isEmpty)
              _ClassesEmptyState(
                onAdd: activeLevels.isEmpty ? null : onAddClass,
              )
            else
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final entry in byLevel.entries) ...[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w800),
                            children: [
                              TextSpan(text: entry.key.name),
                              TextSpan(
                                text:
                                    ' • ${entry.value.length} class${entry.value.length == 1 ? '' : 'es'}',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      for (final schoolClass in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.school_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                schoolClass.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: schoolClass.isActive
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: Text(
                                'Capacity ${schoolClass.capacity}',
                              ),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (_) => showClassFormDialog(
                                  context,
                                  schoolId: schoolId,
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
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _streams(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final schoolId = _schoolId(context);
    final scheme = Theme.of(context).colorScheme;
    final activeClasses = state.classes.where((item) => item.isActive).toList();

    void onAddStream() => showStreamFormDialog(
      context,
      schoolId: schoolId,
      classes: activeClasses,
      streams: state.streams,
      onSave: (value) => _dispatchIfValid(
        context,
        _validator.validateStream(
          value,
          classes: state.classes,
          streams: state.streams,
        ),
        () => bloc.add(SaveStreamRequested(value)),
      ),
    );

    final byClass = <SchoolClass, List<ClassStream>>{};
    for (final schoolClass in activeClasses) {
      final streams = state.streams
          .where((item) => item.classId == schoolClass.id)
          .toList();
      if (streams.isNotEmpty) byClass[schoolClass] = streams;
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    activeClasses.isEmpty
                        ? 'Create classes before adding streams or sections.'
                        : state.streams.isEmpty
                        ? 'Optionally divide classes into streams or sections.'
                        : 'Streams are grouped under their parent class.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: activeClasses.isEmpty ? null : onAddStream,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add stream'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.streams.isEmpty)
              _StreamsEmptyState(
                onAdd: activeClasses.isEmpty ? null : onAddStream,
              )
            else
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    for (final entry in byClass.entries) ...[
                      Builder(
                        builder: (context) {
                          final allocated = entry.value
                              .where((s) => s.isActive)
                              .fold<int>(0, (sum, s) => sum + s.capacity);
                          final capacity = entry.key.capacity;
                          final progress = capacity > 0
                              ? (allocated / capacity).clamp(0.0, 1.0)
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text.rich(
                                  TextSpan(
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w800),
                                    children: [
                                      TextSpan(text: entry.key.name),
                                      TextSpan(
                                        text:
                                            ' • $allocated of $capacity allocated',
                                        style: TextStyle(
                                          color: scheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 5,
                                    backgroundColor:
                                        scheme.surfaceContainerHighest,
                                    color: scheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      for (final stream in entry.value)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: AppCard(
                            child: ListTile(
                              leading: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.account_tree_outlined,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                stream.name,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  decoration: stream.isActive
                                      ? null
                                      : TextDecoration.lineThrough,
                                ),
                              ),
                              subtitle: Text('Capacity ${stream.capacity}'),
                              trailing: PopupMenuButton<String>(
                                icon: const Icon(Icons.more_vert),
                                onSelected: (_) => showStreamFormDialog(
                                  context,
                                  schoolId: schoolId,
                                  existing: stream,
                                  classes: activeClasses,
                                  streams: state.streams,
                                  onSave: (value) => _dispatchIfValid(
                                    context,
                                    _validator.validateStream(
                                      value,
                                      classes: state.classes,
                                      streams: state.streams,
                                    ),
                                    () => bloc.add(SaveStreamRequested(value)),
                                  ),
                                ),
                                itemBuilder: (_) => const [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: Text('Edit'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _subjects(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final schoolId = _schoolId(context);
    final scheme = Theme.of(context).colorScheme;
    final departments = state.departments
        .where((item) => item.isActive)
        .toList();

    void onAddSubject() => showSubjectFormDialog(
      context,
      schoolId: schoolId,
      departments: departments,
      onSave: (value) => _dispatchIfValid(
        context,
        _validator.validateSubject(
          value,
          subjects: state.subjects,
          departments: state.departments,
        ),
        () => bloc.add(SaveSubjectRequested(value)),
      ),
    );

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    state.subjects.isEmpty
                        ? 'Build the subject catalogue for your school.'
                        : 'Subjects are added to the school catalogue.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onAddSubject,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add subject'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (state.subjects.isEmpty)
              _SubjectsEmptyState(onAdd: onAddSubject)
            else ...[
              Text(
                '${state.subjects.length} subject${state.subjects.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: state.subjects.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (_, index) {
                    final subject = state.subjects[index];
                    return AppCard(
                      child: ListTile(
                        leading: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scheme.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.menu_book_outlined,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          subject.name,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            decoration: subject.isActive
                                ? null
                                : TextDecoration.lineThrough,
                          ),
                        ),
                        subtitle: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            if (subject.isElective)
                              Chip(
                                label: const Text('Elective'),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: scheme.secondaryContainer,
                                labelStyle: TextStyle(
                                  color: scheme.onSecondaryContainer,
                                ),
                                side: BorderSide.none,
                              ),
                            if (subject.isPractical)
                              Chip(
                                label: const Text('Practical'),
                                visualDensity: VisualDensity.compact,
                                backgroundColor: scheme.secondaryContainer,
                                labelStyle: TextStyle(
                                  color: scheme.onSecondaryContainer,
                                ),
                                side: BorderSide.none,
                              ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert),
                          onSelected: (_) => showSubjectFormDialog(
                            context,
                            schoolId: schoolId,
                            existing: subject,
                            departments: departments,
                            onSave: (value) => _dispatchIfValid(
                              context,
                              _validator.validateSubject(
                                value,
                                subjects: state.subjects,
                                departments: state.departments,
                              ),
                              () => bloc.add(SaveSubjectRequested(value)),
                            ),
                          ),
                          itemBuilder: (_) => const [
                            PopupMenuItem(value: 'edit', child: Text('Edit')),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StreamsEmptyState extends StatelessWidget {
  final VoidCallback? onAdd;

  const _StreamsEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.account_tree_outlined,
      title: 'No streams added',
      message: 'You can skip this step if your classes have no streams.',
      ctaLabel: onAdd == null ? null : 'Add stream',
      onCtaPressed: onAdd,
    );
  }
}

class _ClassesEmptyState extends StatelessWidget {
  final VoidCallback? onAdd;

  const _ClassesEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.desktop_windows_outlined,
      title: 'No classes added',
      message: 'Add your first class to continue.',
      ctaLabel: onAdd == null ? null : 'Add class',
      onCtaPressed: onAdd,
    );
  }
}

class _SubjectsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _SubjectsEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.menu_book_outlined,
      title: 'No subjects added',
      message: 'Add your first subject to continue.',
      ctaLabel: 'Add subject',
      onCtaPressed: onAdd,
    );
  }
}

class _LevelsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _LevelsEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.account_balance_outlined,
      title: 'No levels added',
      message: 'Add your first education level to continue.',
      ctaLabel: 'Add level',
      onCtaPressed: onAdd,
    );
  }
}

class _TermsEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _TermsEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: 'No periods added',
      message: 'Add your first term or semester to continue.',
      ctaLabel: 'Add term',
      onCtaPressed: onAdd,
    );
  }
}

class _AcademicYearEmptyState extends StatelessWidget {
  final VoidCallback onAdd;

  const _AcademicYearEmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return EmptyState(
      icon: Icons.calendar_today_outlined,
      title: 'No academic year yet',
      message: 'Create one to continue your school setup.',
      ctaLabel: 'Add academic year',
      onCtaPressed: onAdd,
    );
  }
}

class _AddAcademicYearTile extends StatelessWidget {
  const _AddAcademicYearTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
        decoration: BoxDecoration(
          color: scheme.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: scheme.primary.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded, color: scheme.primary),
            const SizedBox(width: 10),
            Text(
              'Add another academic year',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: scheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
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

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

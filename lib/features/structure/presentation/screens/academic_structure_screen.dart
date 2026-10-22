import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:school_pulse/features/auth/presentation/bloc/auth_state.dart';
import 'package:uuid/uuid.dart';
import 'package:school_pulse/injection_container.dart' as di;
import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/structure_setup_preferences.dart';
import '../../domain/services/structure_integrity_validator.dart';
import '../../domain/services/class_suggestion_resolver.dart';
import '../../domain/services/structure_dependency_service.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_event.dart';
import '../bloc/structure_state.dart';
import '../bloc/structure_setup_cubit.dart';
import '../widgets/structure_dialogs.dart';

const _validator = StructureIntegrityValidator();

/// Standard education stages offered as suggestions for a given school type
/// (the same free-text values captured on the Institution Profile step -
/// see `institution_tab.dart`'s `_schoolTypes`). This is presentation-layer
/// convenience only: nothing here is a curriculum policy, it just narrows
/// which of the universal stages are suggested first; any of them can still
/// be added via "Add a custom level" regardless of school type.
class _StageSuggestion {
  final String name;
  final String code;
  final String description;
  const _StageSuggestion(this.name, this.code, this.description);
}

const _kAllStages = <_StageSuggestion>[
  _StageSuggestion('Early years', 'EY', 'Nursery and pre-primary'),
  _StageSuggestion('Primary', 'PRI', 'Primary 1 to Primary 7'),
  _StageSuggestion('Secondary', 'SEC', 'S1 to S6'),
  _StageSuggestion('Vocational', 'VOC', 'Vocational and technical training'),
  _StageSuggestion('College', 'COL', 'College-level programmes'),
  _StageSuggestion('University', 'UNI', 'Undergraduate and postgraduate'),
];

const _kStagesBySchoolType = <String, List<String>>{
  'Nursery': ['Early years'],
  'Primary': ['Early years', 'Primary'],
  'Secondary': ['Secondary'],
  'Mixed school': ['Early years', 'Primary', 'Secondary'],
  'Vocational': ['Vocational'],
  'College': ['College'],
  'University': ['University'],
};

List<_StageSuggestion> _suggestedStages(String schoolType) {
  final types = schoolType.split(',').map((e) => e.trim());
  final names = <String>{};
  for (final type in types) {
    names.addAll(_kStagesBySchoolType[type] ?? const []);
  }
  if (names.isEmpty) return _kAllStages;
  return _kAllStages.where((s) => names.contains(s.name)).toList();
}

class _CalendarTimelineItem extends StatelessWidget {
  const _CalendarTimelineItem({
    required this.sequence,
    required this.isLast,
    required this.term,
    required this.dateLabel,
    required this.onMenu,
  });
  final int sequence;
  final bool isLast;
  final AcademicTerm term;
  final String dateLabel;
  final ValueChanged<String> onMenu;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 44,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: scheme.outline),
                ),
                child: Text(
                  '$sequence',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(width: 1, color: scheme.outlineVariant),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            term.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          if (term.isCurrent) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: const Text('Current'),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                              labelStyle: const TextStyle(fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, size: 20),
                  onSelected: onMenu,
                  itemBuilder: (_) => [
                    if (!term.isCurrent)
                      const PopupMenuItem(
                        value: 'current',
                        child: Text('Set as current'),
                      ),
                    const PopupMenuItem(value: 'edit', child: Text('Edit')),
                    if (!term.isCurrent && !term.isArchived)
                      const PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

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
      body: BlocListener<StructureBloc, StructureState>(
        listenWhen: (previous, current) =>
            current.errorMessage != null &&
            current.errorMessage != previous.errorMessage,
        listener: (context, state) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                action: SnackBarAction(
                  label: 'Retry',
                  onPressed: () => context.read<StructureBloc>().add(
                    LoadStructureData(_schoolId(context)),
                  ),
                ),
              ),
            );
        },
        child: BlocBuilder<StructureBloc, StructureState>(
          builder: (context, state) => switch (normalized) {
            'years' => _years(context, state),
            'terms' => _terms(context, state),
            'classes' => _classes(context, state),
            'streams' => _streams(context, state),
            'subjects' => _subjects(context, state),
            _ => _levels(context, state),
          },
        ),
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
    final schoolId = _schoolId(context);
    final activeLevels = [...state.levels.where((l) => l.isActive)]
      ..sort((a, b) => a.order.compareTo(b.order));

    void onAddCustom() => showLevelFormDialog(
      context,
      schoolId: schoolId,
      existingLevels: state.levels,
      onSave: (levels) => context.read<StructureBloc>().add(
        SaveLevelWithReorderRequested(levels),
      ),
    );

    if (activeLevels.isEmpty) {
      return _LevelSelectionView(
        schoolId: schoolId,
        schoolType: state.institutionProfile.schoolType,
        existingLevels: state.levels,
        onAddCustom: onAddCustom,
      );
    }
    return _ConfiguredLevelsView(
      schoolId: schoolId,
      levels: activeLevels,
      classes: state.classes,
      allLevels: state.levels,
      onAddAnother: onAddCustom,
    );
  }

  Widget _years(BuildContext context, StructureState state) {
    if (state.isLoading && state.academicYears.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    return _AcademicYearSetupView(
      state: state,
      schoolId: _schoolId(context),
      onSetUpTerms: onSetUpTerms,
    );
  }

  Widget _terms(BuildContext context, StructureState state) {
    final bloc = context.read<StructureBloc>();
    final schoolId = _schoolId(context);
    final fmt = DateFormat('dd MMM yyyy');
    final scheme = Theme.of(context).colorScheme;
    final currentYear = state.academicYears
        .where((year) => year.isCurrent && !year.isArchived)
        .firstOrNull;

    if (state.isLoading && state.academicYears.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (currentYear == null) {
      return const SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: EmptyState(
            icon: Icons.event_busy_outlined,
            title: 'No current academic year set',
            message:
                'Return to Academic Years and select one current year first.',
          ),
        ),
      );
    }

    final items =
        state.academicTerms
            .where(
              (term) =>
                  term.academicYearId == currentYear.id && !term.isArchived,
            )
            .toList()
          ..sort((a, b) => a.startDate.compareTo(b.startDate));

    final system = items.isEmpty ? null : items.first.periodType;
    final periodWord = system == AcademicPeriodType.semester
        ? 'Semester'
        : 'Term';

    Future<void> addPeriod(AcademicPeriodType type) {
      final periodTerms = state.academicTerms
          .where((term) => term.academicYearId == currentYear.id)
          .toList();
      return showAcademicTermFormDialog(
        context,
        schoolId: schoolId,
        years: [currentYear],
        fixedPeriodType: type,
        existingCount: periodTerms.where((t) => !t.isArchived).length,
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
    }

    void onEditPeriod(AcademicTerm term) {
      showAcademicTermFormDialog(
        context,
        schoolId: schoolId,
        existing: term,
        years: [currentYear],
        fixedPeriodType: system,
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
    }

    // No period exists yet for this year: the reference shows a dedicated
    // "choose the calendar system" step (year summary card + two large
    // selectable cards) before the first Add-period sheet opens, rather
    // than a small modal picker.
    if (items.isEmpty) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: _CalendarSystemChooser(
            year: currentYear,
            dateLabel:
                '${fmt.format(currentYear.startDate)} – ${fmt.format(currentYear.endDate)}',
            onContinue: (type) => addPeriod(type),
          ),
        ),
      );
    }

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: scheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month_outlined, color: scheme.primary),
                  const SizedBox(width: 10),
                  Text(
                    currentYear.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      system == AcademicPeriodType.semester
                          ? 'Semesters'
                          : 'Terms',
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    labelStyle: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (_, index) {
                  final term = items[index];
                  return _CalendarTimelineItem(
                    sequence: index + 1,
                    isLast: index == items.length - 1,
                    term: term,
                    dateLabel:
                        '${fmt.format(term.startDate)} – ${fmt.format(term.endDate)}',
                    onMenu: (action) {
                      if (action == 'current') {
                        bloc.add(
                          SetCurrentAcademicTermRequested(term.id, schoolId),
                        );
                      } else if (action == 'archive') {
                        bloc.add(ArchiveAcademicTermRequested(term.id));
                      } else {
                        onEditPeriod(term);
                      }
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => addPeriod(system!),
                icon: const Icon(Icons.add, size: 18),
                label: Text('Add ${periodWord.toLowerCase()}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _classes(BuildContext context, StructureState state) {
    return _ClassesBulkSetup(
      state: state,
      schoolId: _schoolId(context),
      onCreate: (classes) =>
          context.read<StructureBloc>().add(CreateClassesRequested(classes)),
      onEdit: (value) =>
          context.read<StructureBloc>().add(SaveClassRequested(value)),
    );
  }

  Widget _streams(BuildContext context, StructureState state) {
    return _StreamsSetup(state: state, schoolId: _schoolId(context));
  }

  Widget _subjects(BuildContext context, StructureState state) {
    return _SubjectCatalogueSetup(
      state: state,
      schoolId: _schoolId(context),
      onBulkCreate: (subjects) =>
          context.read<StructureBloc>().add(CreateSubjectsRequested(subjects)),
      onSave: (subject) =>
          context.read<StructureBloc>().add(SaveSubjectRequested(subject)),
      onArchive: (id) =>
          context.read<StructureBloc>().add(ArchiveSubjectRequested(id)),
      onReorder: (subjects) =>
          context.read<StructureBloc>().add(ReorderSubjectsRequested(subjects)),
    );
  }
}

/// Step 6, top-level: choose whether this school uses streams at all before
/// showing anything else. "No streams" is itself a saved decision (via
/// [StructureSetupCubit]) so an empty stream list is never read as
/// "not configured yet" elsewhere in the app.
class _StreamsSetup extends StatelessWidget {
  const _StreamsSetup({required this.state, required this.schoolId});

  final StructureState state;
  final String schoolId;

  @override
  Widget build(BuildContext context) {
    if (state.streams.isNotEmpty) {
      return _ConfiguredStreamsView(state: state, schoolId: schoolId);
    }
    return BlocProvider<StructureSetupCubit>(
      create: (_) => di.sl<StructureSetupCubit>(),
      child: _StreamsChoiceView(state: state, schoolId: schoolId),
    );
  }
}

class _StreamsChoiceView extends StatelessWidget {
  const _StreamsChoiceView({required this.state, required this.schoolId});

  final StructureState state;
  final String schoolId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return BlocBuilder<StructureSetupCubit, StructureSetupCubitState>(
      builder: (context, setupState) {
        final choice = setupState.preferences.streams;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streams are optional. Use them only when a class is divided into groups.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: scheme.onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                _StreamsChoiceCard(
                  icon: Icons.people_alt_outlined,
                  title: 'No streams',
                  subtitle: 'Enrol learners directly into classes',
                  selected: choice == StructureUseChoice.disabled,
                  onTap: () => context.read<StructureSetupCubit>().setStreams(
                    StructureUseChoice.disabled,
                  ),
                ),
                const SizedBox(height: 12),
                _StreamsChoiceCard(
                  icon: Icons.account_tree_outlined,
                  title: 'Add streams',
                  subtitle: 'Create groups such as East and West',
                  selected: choice == StructureUseChoice.enabled,
                  onTap: () => context.read<StructureSetupCubit>().setStreams(
                    StructureUseChoice.enabled,
                  ),
                ),
                const Spacer(),
                if (choice == StructureUseChoice.disabled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: scheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You can add streams later.',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (choice == StructureUseChoice.enabled)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () =>
                          _openAddStreamsSheet(context, state, schoolId),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add streams'),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StreamsChoiceCard extends StatelessWidget {
  const _StreamsChoiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? scheme.onSurface : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? scheme.onSurface : scheme.outline,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(icon, color: scheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

Future<void> _openAddStreamsSheet(
  BuildContext context,
  StructureState state,
  String schoolId,
) {
  final bloc = context.read<StructureBloc>();
  final activeClasses = state.classes.where((c) => c.isActive).toList()
    ..sort((a, b) => a.order.compareTo(b.order));
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => _AddStreamsSheet(
      classes: activeClasses,
      existingStreams: state.streams,
      schoolId: schoolId,
      onCreate: (streams) => bloc.add(CreateStreamsRequested(streams)),
    ),
  );
}

class _AddStreamsSheet extends StatefulWidget {
  const _AddStreamsSheet({
    required this.classes,
    required this.existingStreams,
    required this.schoolId,
    required this.onCreate,
  });

  final List<SchoolClass> classes;
  final List<ClassStream> existingStreams;
  final String schoolId;
  final ValueChanged<List<ClassStream>> onCreate;

  @override
  State<_AddStreamsSheet> createState() => _AddStreamsSheetState();
}

class _AddStreamsSheetState extends State<_AddStreamsSheet> {
  final Set<String> _selectedClassIds = {};
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  bool _applyToAll = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.classes.isNotEmpty) {
      _selectedClassIds.add(widget.classes.first.id);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 4,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add streams',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Choose the class or classes to divide.',
                style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              if (widget.classes.isEmpty)
                Text(
                  'Create classes before adding streams.',
                  style: TextStyle(color: scheme.onSurfaceVariant),
                )
              else ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedClassIds.isNotEmpty
                      ? _selectedClassIds.first
                      : null,
                  decoration: const InputDecoration(labelText: 'Class'),
                  items: widget.classes
                      .map(
                        (item) => DropdownMenuItem(
                          value: item.id,
                          child: Text(item.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() {
                    _selectedClassIds
                      ..clear()
                      ..add(value!);
                  }),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _pickMoreClasses(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add to more classes'),
                ),
              ],
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Stream name',
                  hintText: 'e.g. East',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _capacityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Capacity (optional)',
                  hintText: 'Leave empty for no limit',
                ),
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _applyToAll,
                onChanged: (value) =>
                    setState(() => _applyToAll = value ?? true),
                title: const Text('Apply this stream to selected classes'),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'If a class capacity is set, stream capacities cannot exceed it.',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: scheme.outline),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _error!,
                    style: TextStyle(color: scheme.onSurface),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: widget.classes.isEmpty ? null : _submit,
                  child: const Text('Add stream'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickMoreClasses(BuildContext context) async {
    final result = await showModalBottomSheet<Set<String>>(
      context: context,
      showDragHandle: true,
      builder: (context) => _MultiClassPicker(
        classes: widget.classes,
        initiallySelected: _selectedClassIds,
      ),
    );
    if (result != null) {
      setState(() {
        _selectedClassIds
          ..clear()
          ..addAll(result);
      });
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Enter a stream name.');
      return;
    }
    if (_selectedClassIds.isEmpty) {
      setState(() => _error = 'Choose at least one class.');
      return;
    }
    final capacityText = _capacityController.text.trim();
    final capacity = capacityText.isEmpty ? 0 : int.tryParse(capacityText);
    if (capacity == null || capacity < 0) {
      setState(
        () =>
            _error = 'Enter a valid capacity, or leave it empty for no limit.',
      );
      return;
    }
    if (!_applyToAll && _selectedClassIds.length > 1) {
      setState(
        () => _error =
            'Turn on "Apply to selected classes" to use one class, or enable it for all.',
      );
      return;
    }
    final streams = [
      for (final classId in _selectedClassIds)
        ClassStream(
          id: const Uuid().v4(),
          schoolId: widget.schoolId,
          name: name,
          classId: classId,
          capacity: capacity,
        ),
    ];
    widget.onCreate(streams);
    Navigator.pop(context);
  }
}

class _MultiClassPicker extends StatefulWidget {
  const _MultiClassPicker({
    required this.classes,
    required this.initiallySelected,
  });

  final List<SchoolClass> classes;
  final Set<String> initiallySelected;

  @override
  State<_MultiClassPicker> createState() => _MultiClassPickerState();
}

class _MultiClassPickerState extends State<_MultiClassPicker> {
  late final Set<String> _selected = {...widget.initiallySelected};

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Add to more classes',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            for (final item in widget.classes)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                value: _selected.contains(item.id),
                onChanged: (value) => setState(() {
                  if (value == true) {
                    _selected.add(item.id);
                  } else {
                    _selected.remove(item.id);
                  }
                }),
                title: Text(item.name),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _selected),
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfiguredStreamsView extends StatelessWidget {
  const _ConfiguredStreamsView({required this.state, required this.schoolId});

  final StructureState state;
  final String schoolId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeClasses = state.classes.where((c) => c.isActive).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final byClass = <SchoolClass, List<ClassStream>>{};
    for (final schoolClass in activeClasses) {
      final streams = state.streams
          .where((item) => item.classId == schoolClass.id && item.isActive)
          .toList();
      if (streams.isNotEmpty) byClass[schoolClass] = streams;
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Review your class streams. You can edit or add more streams.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final entry in byClass.entries)
                    _StreamClassGroup(
                      schoolClass: entry.key,
                      streams: entry.value,
                      schoolId: schoolId,
                      allClasses: activeClasses,
                      allStreams: state.streams,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () => _openAddStreamsSheet(context, state, schoolId),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add streams'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StreamClassGroup extends StatelessWidget {
  const _StreamClassGroup({
    required this.schoolClass,
    required this.streams,
    required this.schoolId,
    required this.allClasses,
    required this.allStreams,
  });

  final SchoolClass schoolClass;
  final List<ClassStream> streams;
  final String schoolId;
  final List<SchoolClass> allClasses;
  final List<ClassStream> allStreams;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      schoolClass.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${streams.length} stream${streams.length == 1 ? '' : 's'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final stream in streams)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outlineVariant),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${stream.name} · ${stream.capacity == 0 ? 'No limit' : 'Capacity ${stream.capacity}'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (action) =>
                          _handleAction(context, action, stream),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'archive', child: Text('Archive')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _handleAction(
    BuildContext context,
    String action,
    ClassStream stream,
  ) async {
    final bloc = context.read<StructureBloc>();
    if (action == 'edit') {
      showStreamFormDialog(
        context,
        schoolId: schoolId,
        existing: stream,
        classes: allClasses,
        streams: allStreams,
        onSave: (value) => _dispatchIfValid(
          context,
          _validator.validateStream(
            value,
            classes: allClasses,
            streams: allStreams,
          ),
          () => bloc.add(SaveStreamRequested(value)),
        ),
      );
      return;
    }
    if (action == 'archive') {
      bloc.add(ArchiveStreamRequested(stream.id));
      return;
    }
    if (action == 'delete') {
      final dependents = await di
          .sl<StructureDependencyService>()
          .countStudentsInStream(schoolId, stream.id);
      if (!context.mounted) return;
      if (dependents > 0) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                'This stream has $dependents enrolled student${dependents == 1 ? '' : 's'}. Archive it instead of deleting it.',
              ),
            ),
          );
        return;
      }
      final confirmed = await showDeleteConfirmDialog(
        context,
        title: 'Delete stream',
        message: 'Delete "${stream.name}"? This cannot be undone.',
      );
      if (confirmed == true && context.mounted) {
        bloc.add(DeleteStreamRequested(stream.id));
      }
    }
  }
}

/// Step 4, state 1: pick from the standard stages suggested for this
/// school's declared type (Institution Profile), or add a custom one.
/// Nothing is created until the admin taps a card - the school-type hint
/// only narrows suggestions, it never silently creates levels.
class _LevelSelectionView extends StatefulWidget {
  const _LevelSelectionView({
    required this.schoolId,
    required this.schoolType,
    required this.existingLevels,
    required this.onAddCustom,
  });

  final String schoolId;
  final String schoolType;
  final List<EducationalLevel> existingLevels;
  final VoidCallback onAddCustom;

  @override
  State<_LevelSelectionView> createState() => _LevelSelectionViewState();
}

class _LevelSelectionViewState extends State<_LevelSelectionView> {
  final Set<String> _selected = {};
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final stages = _suggestedStages(widget.schoolType);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select the stages your school offers. Classes are added next.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: scheme.onSurface,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            if (widget.schoolType.trim().isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  border: Border.all(color: scheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 20,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14,
                            color: scheme.onSurface,
                          ),
                          children: [
                            const TextSpan(text: 'Based on your school type: '),
                            TextSpan(
                              text: widget.schoolType,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  for (final stage in stages) ...[
                    _StageCard(
                      stage: stage,
                      selected: _selected.contains(stage.name),
                      onTap: () => setState(() {
                        if (!_selected.remove(stage.name)) {
                          _selected.add(stage.name);
                        }
                      }),
                    ),
                    const SizedBox(height: 10),
                  ],
                  OutlinedButton.icon(
                    onPressed: widget.onAddCustom,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add a custom level'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 52),
                      side: BorderSide(
                        color: scheme.outline,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _selected.isEmpty || _saving ? null : _continue,
                child: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _continue() async {
    setState(() => _saving = true);
    final bloc = context.read<StructureBloc>();
    final stages = _suggestedStages(widget.schoolType);
    final startOrder = widget.existingLevels.length;
    final chosen = stages.where((s) => _selected.contains(s.name)).toList();
    final levels = [
      for (var i = 0; i < chosen.length; i++)
        EducationalLevel(
          id: const Uuid().v4(),
          schoolId: widget.schoolId,
          name: chosen[i].name,
          code: chosen[i].code,
          description: chosen[i].description,
          order: startOrder + i,
          isActive: true,
        ),
    ];
    bloc.add(SaveLevelWithReorderRequested(levels));
    if (mounted) setState(() => _saving = false);
  }
}

class _StageCard extends StatelessWidget {
  const _StageCard({
    required this.stage,
    required this.selected,
    required this.onTap,
  });

  final _StageSuggestion stage;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: selected ? scheme.onSurface : scheme.outlineVariant,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stage.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    stage.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.check_circle : Icons.radio_button_off,
              color: selected ? scheme.onSurface : scheme.outline,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 4, state 2: the school's chosen levels in teaching order, reorderable
/// by drag before classes exist under them (once classes/enrolments exist
/// for a level, reordering elsewhere in the app must still respect this
/// `order`, but the wizard itself only touches levels here).
class _ConfiguredLevelsView extends StatefulWidget {
  const _ConfiguredLevelsView({
    required this.schoolId,
    required this.levels,
    required this.classes,
    required this.allLevels,
    required this.onAddAnother,
  });

  final String schoolId;
  final List<EducationalLevel> levels;
  final List<SchoolClass> classes;
  final List<EducationalLevel> allLevels;
  final VoidCallback onAddAnother;

  @override
  State<_ConfiguredLevelsView> createState() => _ConfiguredLevelsViewState();
}

class _ConfiguredLevelsViewState extends State<_ConfiguredLevelsView> {
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your education levels',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 4),
            Text(
              'Add classes within each level in the next step.',
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ReorderableListView.builder(
                buildDefaultDragHandles: false,
                padding: EdgeInsets.zero,
                itemCount: widget.levels.length,
                onReorder: _onReorder,
                itemBuilder: (context, index) {
                  final level = widget.levels[index];
                  final classCount = widget.classes
                      .where((c) => c.levelId == level.id && c.isActive)
                      .length;
                  return _LevelRow(
                    key: ValueKey(level.id),
                    index: index,
                    level: level,
                    classCount: classCount,
                    onEdit: () => _edit(level),
                    onAction: (action) => _action(action, level),
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Drag to arrange the teaching order.',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            OutlinedButton.icon(
              onPressed: widget.onAddAnother,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add another level'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onReorder(int oldIndex, int newIndex) {
    final reordered = [...widget.levels];
    if (newIndex > oldIndex) newIndex -= 1;
    final moved = reordered.removeAt(oldIndex);
    reordered.insert(newIndex, moved);
    final resequenced = [
      for (var i = 0; i < reordered.length; i++)
        reordered[i].copyWith(order: i),
    ];
    context.read<StructureBloc>().add(ReorderLevelsRequested(resequenced));
  }

  void _edit(EducationalLevel level) => showLevelFormDialog(
    context,
    schoolId: widget.schoolId,
    existing: level,
    existingLevels: widget.allLevels,
    onSave: (levels) => context.read<StructureBloc>().add(
      SaveLevelWithReorderRequested(levels),
    ),
  );

  Future<void> _action(String action, EducationalLevel level) async {
    final bloc = context.read<StructureBloc>();
    final hasClasses = widget.classes.any((c) => c.levelId == level.id);
    if (action == 'archive') {
      bloc.add(ArchiveLevelRequested(level.id));
      return;
    }
    if (action == 'delete') {
      if (hasClasses) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'This level is used by classes. Archive it instead of deleting it.',
              ),
            ),
          );
        return;
      }
      final confirmed = await showDeleteConfirmDialog(
        context,
        title: 'Delete level',
        message: 'Delete "${level.name}"? This cannot be undone.',
      );
      if (confirmed == true) bloc.add(DeleteLevelRequested(level.id));
    }
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required super.key,
    required this.index,
    required this.level,
    required this.classCount,
    required this.onEdit,
    required this.onAction,
  });

  final int index;
  final EducationalLevel level;
  final int classCount;
  final VoidCallback onEdit;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Text(
              '${index + 1}.',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: scheme.outlineVariant),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      classCount == 0
                          ? 'No classes yet'
                          : '$classCount class${classCount == 1 ? '' : 'es'}',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 20),
              onSelected: onAction,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'archive', child: Text('Archive')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 3's first-state screen: pick exactly one calendar system for the
/// whole academic year (Terms or Semesters) before adding any period. Shown
/// only while the year has zero non-archived periods - once one exists, the
/// system is locked in (enforced by [StructureIntegrityValidator]) and this
/// screen never reappears for that year.
class _CalendarSystemChooser extends StatefulWidget {
  const _CalendarSystemChooser({
    required this.year,
    required this.dateLabel,
    required this.onContinue,
  });

  final AcademicYear year;
  final String dateLabel;
  final ValueChanged<AcademicPeriodType> onContinue;

  @override
  State<_CalendarSystemChooser> createState() => _CalendarSystemChooserState();
}

class _CalendarSystemChooserState extends State<_CalendarSystemChooser> {
  AcademicPeriodType? _selected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month_outlined, color: scheme.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Academic year ${widget.year.name}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      widget.dateLabel,
                      style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'How is your year organised?',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          'Choose one calendar system for this academic year.',
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 16),
        _SystemCard(
          icon: Icons.calendar_view_month_outlined,
          title: 'Terms',
          subtitle: 'Usually 3 periods',
          selected: _selected == AcademicPeriodType.term,
          onTap: () => setState(() => _selected = AcademicPeriodType.term),
        ),
        const SizedBox(height: 12),
        _SystemCard(
          icon: Icons.menu_book_outlined,
          title: 'Semesters',
          subtitle: 'Usually 2 periods',
          selected: _selected == AcademicPeriodType.semester,
          onTap: () => setState(() => _selected = AcademicPeriodType.semester),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _selected == null
                ? null
                : () => widget.onContinue(_selected!),
            child: const Text('Continue'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SystemCard extends StatelessWidget {
  const _SystemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outline, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: scheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

/// Step 2 (Academic years): a direct inline setup workspace, replacing the
/// old empty-state + "Add academic year" modal. The form always renders
/// (no giant empty state); once fields are valid a live preview card shows
/// below, and after persistence the saved record renders with its actual
/// Current/edit affordances. `onSetUpTerms` lets the just-saved year link
/// straight into the Terms step, same as the old card list did.
class _AcademicYearSetupView extends StatefulWidget {
  const _AcademicYearSetupView({
    required this.state,
    required this.schoolId,
    required this.onSetUpTerms,
  });

  final StructureState state;
  final String schoolId;
  final VoidCallback? onSetUpTerms;

  @override
  State<_AcademicYearSetupView> createState() => _AcademicYearSetupViewState();
}

class _AcademicYearSetupViewState extends State<_AcademicYearSetupView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isCurrent = true;
  bool _advancedExpanded = false;
  bool _isSaving = false;
  String? _dateError;
  AcademicYear? _editingYear;

  @override
  void initState() {
    super.initState();
    // First-time setup seeds sensible defaults for the current calendar
    // year; editing an existing year loads its saved values instead.
    final currentYear = DateTime.now().year;
    _nameController.text = '$currentYear';
    _startDate = DateTime(currentYear, 1, 1);
    _endDate = DateTime(currentYear, 12, 31);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _loadForEditing(AcademicYear year) {
    setState(() {
      _editingYear = year;
      _nameController.text = year.name;
      _startDate = year.startDate;
      _endDate = year.endDate;
      _isCurrent = year.isCurrent;
      _dateError = null;
    });
  }

  void _resetForNewYear() {
    final currentYear = DateTime.now().year;
    setState(() {
      _editingYear = null;
      _nameController.text = '$currentYear';
      _startDate = DateTime(currentYear, 1, 1);
      _endDate = DateTime(currentYear, 12, 31);
      _isCurrent = widget.state.academicYears.isEmpty;
      _dateError = null;
    });
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
      _dateError = null;
    });
  }

  AcademicYear? _buildCandidate() {
    if (_startDate == null || _endDate == null) return null;
    return AcademicYear(
      id: _editingYear?.id ?? const Uuid().v4(),
      schoolId: _editingYear?.schoolId ?? widget.schoolId,
      name: _nameController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      isCurrent: _isCurrent,
      isArchived: _editingYear?.isArchived ?? false,
    );
  }

  Future<void> _submit(StructureBloc bloc) async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      setState(() => _dateError = 'Select a start and end date.');
      return;
    }
    if (!_startDate!.isBefore(_endDate!)) {
      setState(() => _dateError = 'End date must be after start date.');
      return;
    }
    final candidate = _buildCandidate()!;
    final validationError = _validator.validateAcademicYear(
      candidate,
      widget.state.academicYears,
    );
    if (validationError != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(validationError)));
      return;
    }
    setState(() => _isSaving = true);
    bloc.add(SaveAcademicYearRequested(candidate));
    if (mounted) {
      setState(() {
        _isSaving = false;
        _editingYear = candidate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<StructureBloc>();
    final scheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd MMM yyyy');
    final years = widget.state.academicYears;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your academic year',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'This is the calendar used for terms, enrolments and reports.',
              style: TextStyle(
                fontSize: 14,
                color: scheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            _InfoBanner(
              title: 'A school needs one current academic year',
              message:
                  'Add the dates for the academic year you’re currently '
                  'using. You can add future years later.',
            ),
            const SizedBox(height: 20),
            Material(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _editingYear == null
                            ? 'Academic year details'
                            : 'Editing ${_editingYear!.name}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'These details are required to continue.',
                        style: TextStyle(
                          fontSize: 12.5,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Academic year name *',
                          hintText: 'e.g. 2026',
                          helperText:
                              'Use a year (e.g. 2026) or a name (e.g. 2025/26).',
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Required'
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: AcademicYearDateField(
                              label: 'Start date *',
                              value: _startDate == null
                                  ? 'Select start date'
                                  : fmt.format(_startDate!),
                              isPlaceholder: _startDate == null,
                              onTap: () => _pickDate(isStart: true),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: AcademicYearDateField(
                              label: 'End date *',
                              value: _endDate == null
                                  ? 'Select end date'
                                  : fmt.format(_endDate!),
                              isPlaceholder: _endDate == null,
                              onTap: () => _pickDate(isStart: false),
                            ),
                          ),
                        ],
                      ),
                      if (_dateError != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 16,
                              color: scheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _dateError!,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 12),
                      InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => setState(() => _isCurrent = !_isCurrent),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: scheme.surface,
                            border: Border.all(color: scheme.outlineVariant),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Switch(
                                value: _isCurrent,
                                onChanged: (value) =>
                                    setState(() => _isCurrent = value),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Set as current academic year'),
                                    const SizedBox(height: 2),
                                    Text(
                                      'This will be used for new enrolments '
                                      'and terms.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: _advancedExpanded,
                          onExpansionChanged: (value) =>
                              setState(() => _advancedExpanded = value),
                          tilePadding: EdgeInsets.zero,
                          title: const Text(
                            'Advanced dates (optional)',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: Text(
                            'Set term dates or multiple calendars '
                            '(e.g. primary/secondary).',
                            style: TextStyle(
                              fontSize: 12,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          childrenPadding: const EdgeInsets.only(bottom: 8),
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                years.length > 1 || widget.onSetUpTerms == null
                                    ? 'Manage term dates from the Terms / '
                                          'semesters step after saving this '
                                          'year.'
                                    : 'Save this year first, then use "Set '
                                          'up terms" below to add term dates.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: scheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Preview',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(
              'This is how your academic year will appear.',
              style: TextStyle(fontSize: 12.5, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: 10),
            _AcademicYearPreviewCard(
              name: _nameController.text.trim().isEmpty
                  ? 'Untitled year'
                  : _nameController.text.trim(),
              dateLabel: _startDate != null && _endDate != null
                  ? '${fmt.format(_startDate!)} – ${fmt.format(_endDate!)}'
                  : 'Select start and end dates',
              isCurrent: _isCurrent,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton.icon(
                onPressed: () => _submit(bloc),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_rounded, size: 18),
                label: Text(
                  _editingYear == null ? 'Save academic year' : 'Save changes',
                ),
              ),
            ),
            if (years.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'Your academic years',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'View and manage your academic years.',
                style: TextStyle(
                  fontSize: 12.5,
                  color: scheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              for (final year in years)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SavedAcademicYearTile(
                    year: year,
                    dateLabel:
                        '${fmt.format(year.startDate)} – ${fmt.format(year.endDate)}',
                    termCount: widget.state.academicTerms
                        .where((term) => term.academicYearId == year.id)
                        .length,
                    onEdit: () => _loadForEditing(year),
                    onSetCurrent: year.isCurrent
                        ? null
                        : () => bloc.add(
                            SetCurrentAcademicYearRequested(
                              year.id,
                              widget.schoolId,
                            ),
                          ),
                    onArchive: year.isCurrent || year.isArchived
                        ? null
                        : () => bloc.add(ArchiveAcademicYearRequested(year.id)),
                    onSetUpTerms: year.isCurrent ? widget.onSetUpTerms : null,
                  ),
                ),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _resetForNewYear,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add another academic year'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    // Pale-blue explanatory banner: a fixed light-blue tone works in both
    // themes because the banner is an informational accent, not a
    // theme-derived surface (matches the reference screenshots exactly).
    const bannerColor = Color(0xFFEAF2FE);
    const bannerBorder = Color(0xFFBFD8FB);
    const bannerText = Color(0xFF0B4EA2);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bannerColor,
        border: Border.all(color: bannerBorder),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: bannerText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: bannerText,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    color: bannerText,
                    fontSize: 12.5,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AcademicYearPreviewCard extends StatelessWidget {
  const _AcademicYearPreviewCard({
    required this.name,
    required this.dateLabel,
    required this.isCurrent,
  });

  final String name;
  final String dateLabel;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.primary.withValues(alpha: 0.12),
            child: Icon(Icons.calendar_month_outlined, color: scheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      const _CurrentBadge(),
                    ],
                  ],
                ),
                Text(
                  dateLabel,
                  style: TextStyle(
                    fontSize: 13,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}

/// Green "Current" status pill, used both in the live preview and on saved
/// academic year records, matching the reference screenshots.
class _CurrentBadge extends StatelessWidget {
  const _CurrentBadge();

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF1E8E3E);
    const greenBg = Color(0xFFE6F4EA);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: greenBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'Current',
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: green,
        ),
      ),
    );
  }
}

class _SavedAcademicYearTile extends StatelessWidget {
  const _SavedAcademicYearTile({
    required this.year,
    required this.dateLabel,
    required this.termCount,
    required this.onEdit,
    required this.onSetCurrent,
    required this.onArchive,
    required this.onSetUpTerms,
  });

  final AcademicYear year;
  final String dateLabel;
  final int termCount;
  final VoidCallback onEdit;
  final VoidCallback? onSetCurrent;
  final VoidCallback? onArchive;
  final VoidCallback? onSetUpTerms;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      borderColor: year.isCurrent ? scheme.primary : scheme.outlineVariant,
      showShadow: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            year.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 17,
                            ),
                          ),
                          if (year.isCurrent) ...[
                            const SizedBox(width: 8),
                            const _CurrentBadge(),
                          ],
                        ],
                      ),
                      Text(
                        dateLabel,
                        style: TextStyle(
                          color: scheme.onSurfaceVariant,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (action) {
                    if (action == 'current') onSetCurrent?.call();
                    if (action == 'archive') onArchive?.call();
                  },
                  itemBuilder: (_) => [
                    if (onSetCurrent != null)
                      const PopupMenuItem(
                        value: 'current',
                        child: Text('Set as current'),
                      ),
                    if (onArchive != null)
                      const PopupMenuItem(
                        value: 'archive',
                        child: Text('Archive'),
                      ),
                  ],
                ),
              ],
            ),
            const Divider(height: 28),
            Row(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    termCount == 0
                        ? 'Terms not set up'
                        : '$termCount term${termCount == 1 ? '' : 's'} set up',
                  ),
                ),
                if (onSetUpTerms != null)
                  OutlinedButton(
                    onPressed: onSetUpTerms,
                    child: const Text('Set up terms'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Per-level classes configuration workspace: a level switcher, editable
/// suggested classes, a reorderable "Your classes" list and a custom-class
/// flow. On wide (web) layouts a right-hand summary card shows every level's
/// configured count side by side; on mobile the switcher becomes a
/// horizontal scroller above a single-column editor.
class _ClassesBulkSetup extends StatefulWidget {
  const _ClassesBulkSetup({
    required this.state,
    required this.schoolId,
    required this.onCreate,
    required this.onEdit,
  });

  final StructureState state;
  final String schoolId;
  final ValueChanged<List<SchoolClass>> onCreate;
  final ValueChanged<SchoolClass> onEdit;

  @override
  State<_ClassesBulkSetup> createState() => _ClassesBulkSetupState();
}

class _ClassesBulkSetupState extends State<_ClassesBulkSetup> {
  String? _levelId;
  final Set<String> _selected = {};

  EducationalLevel? get _level => widget.state.levels
      .where((level) => level.id == _levelId && level.isActive)
      .firstOrNull;

  @override
  void didUpdateWidget(covariant _ClassesBulkSetup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_level == null && widget.state.levels.any((item) => item.isActive)) {
      _levelId = widget.state.levels.firstWhere((item) => item.isActive).id;
    }
  }

  @override
  void initState() {
    super.initState();
    final level = widget.state.levels
        .where((item) => item.isActive)
        .firstOrNull;
    _levelId = level?.id;
  }

  void _selectLevel(String levelId) {
    if (levelId == _levelId) return;
    setState(() {
      _levelId = levelId;
      _selected.clear();
    });
  }

  List<String> _suggestions(EducationalLevel level) =>
      const ClassSuggestionResolver().resolve(
        level: level,
        profile: widget.state.institutionProfile,
        classes: widget.state.classes,
      );

  bool _isTaken(String name, EducationalLevel level) =>
      widget.state.classes.any(
        (item) =>
            item.levelId == level.id &&
            item.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );

  int _classCount(EducationalLevel level) => widget.state.classes
      .where((item) => item.levelId == level.id && item.isActive)
      .length;

  Future<void> _addCustom() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add a custom class'),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(labelText: 'Class name'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    final value = name?.trim() ?? '';
    final level = _level;
    if (value.isEmpty || level == null) return;
    if (_isTaken(value, level) ||
        _selected.any((item) => item.toLowerCase() == value.toLowerCase())) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'This class already exists under the selected level.',
            ),
          ),
        );
      }
      return;
    }
    setState(() => _selected.add(value));
  }

  Future<void> _openCreateSheet() async {
    final level = _level;
    if (level == null || _selected.isEmpty) return;
    final capacity = TextEditingController();
    var applyToAll = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              4,
              20,
              MediaQuery.viewInsetsOf(context).bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create classes',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_selected.length} class${_selected.length == 1 ? '' : 'es'} will be added under ${level.name}.',
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _selected
                        .map(
                          (name) => InputChip(
                            label: Text(name),
                            onDeleted: () {
                              setState(() => _selected.remove(name));
                              setSheetState(() {});
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: capacity,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Default capacity (optional)',
                      hintText: 'Leave empty for no limit',
                    ),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Apply the same capacity to all classes'),
                    value: applyToAll,
                    onChanged: (value) =>
                        setSheetState(() => applyToAll = value),
                  ),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await _addCustom();
                      setSheetState(() {});
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Add another custom class'),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final parsed = capacity.text.trim().isEmpty
                            ? 0
                            : int.tryParse(capacity.text);
                        if (parsed == null || parsed < 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Enter a valid capacity, or leave it empty for no limit.',
                              ),
                            ),
                          );
                          return;
                        }
                        final startOrder =
                            widget.state.classes
                                .where((item) => item.levelId == level.id)
                                .fold<int>(
                                  -1,
                                  (max, item) =>
                                      item.order > max ? item.order : max,
                                ) +
                            1;
                        widget.onCreate(
                          _selected
                              .toList()
                              .asMap()
                              .entries
                              .map(
                                (entry) => SchoolClass(
                                  id: const Uuid().v4(),
                                  schoolId: widget.schoolId,
                                  name: entry.value,
                                  levelId: level.id,
                                  capacity: applyToAll ? parsed : 0,
                                  order: startOrder + entry.key,
                                ),
                              )
                              .toList(),
                        );
                        Navigator.pop(context);
                        setState(() => _selected.clear());
                      },
                      child: Text(
                        'Create ${_selected.length} class${_selected.length == 1 ? '' : 'es'}',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    capacity.dispose();
  }

  List<EducationalLevel> get _levels =>
      widget.state.levels.where((item) => item.isActive).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  List<SchoolClass> _classesForLevel(String levelId) {
    final items =
        widget.state.classes
            .where((item) => item.levelId == levelId && item.isActive)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final levels = _levels;
    if (levels.isEmpty) {
      return const Center(
        child: Text('Add an education level before creating classes.'),
      );
    }
    final level = _level ?? levels.first;
    if (_levelId != level.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _levelId = level.id);
      });
    }

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final workspace = _LevelWorkspace(
            level: level,
            selected: _selected,
            suggestions: _suggestions(level),
            onSelectAll: (names) => setState(() => _selected.addAll(names)),
            onClearAll: () => setState(() => _selected.clear()),
            onToggle: (name, value) => setState(
              () => value ? _selected.add(name) : _selected.remove(name),
            ),
            onAddCustom: _addCustom,
            onCreateSelected: _selected.isEmpty ? null : _openCreateSheet,
            configured: _classesForLevel(level.id),
            hasStreams: (classId) =>
                widget.state.streams.any((stream) => stream.classId == classId),
            onEdit: (classItem) => showClassFormDialog(
              context,
              schoolId: widget.schoolId,
              existing: classItem,
              levels: levels,
              onSave: widget.onEdit,
            ),
            onArchive: (classItem) => context.read<StructureBloc>().add(
              ArchiveClassRequested(classItem.id),
            ),
            onDelete: (classItem) async {
              final confirmed = await showDeleteConfirmDialog(
                context,
                title: 'Delete class',
                message: 'Delete "${classItem.name}"? This cannot be undone.',
              );
              if (confirmed == true && context.mounted) {
                context.read<StructureBloc>().add(
                  DeleteClassRequested(classItem.id),
                );
              }
            },
            onReorder: (reordered) => context.read<StructureBloc>().add(
              ReorderClassesRequested(reordered),
            ),
          );

          if (isWide) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LevelSwitcher(
                          levels: levels,
                          selectedId: level.id,
                          classCount: _classCount,
                          onSelect: _selectLevel,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(child: workspace),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 300,
                    child: _EducationLevelsSummary(
                      levels: levels,
                      selectedId: level.id,
                      classCount: _classCount,
                      totalClasses: widget.state.classes
                          .where((item) => item.isActive)
                          .length,
                      onSelect: _selectLevel,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: _LevelSwitcher(
                  levels: levels,
                  selectedId: level.id,
                  classCount: _classCount,
                  onSelect: _selectLevel,
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [workspace],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Horizontal, scrollable level switcher shared by mobile and web layouts.
/// Never hides or reorders levels based on school type — every active level
/// chosen in Step 4 shows up here exactly as configured.
class _LevelSwitcher extends StatelessWidget {
  const _LevelSwitcher({
    required this.levels,
    required this.selectedId,
    required this.classCount,
    required this.onSelect,
  });

  final List<EducationalLevel> levels;
  final String selectedId;
  final int Function(EducationalLevel) classCount;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: levels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = levels[index];
          final selected = item.id == selectedId;
          final count = classCount(item);
          return Semantics(
            button: true,
            selected: selected,
            label: '${item.name}, $count class${count == 1 ? '' : 'es'}',
            child: InkWell(
              onTap: () => onSelect(item.id),
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? scheme.primaryContainer : scheme.surface,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outlineVariant,
                      width: selected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count == 0 ? 'No classes' : '$count classes',
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? scheme.onPrimaryContainer.withValues(alpha: 0.8)
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

/// The right-hand "Education levels summary" card shown on wide (web)
/// layouts: every level's configured count plus a completion banner. A
/// level with zero classes is shown as "Not set up" rather than blocked —
/// intentionally configured empty levels are allowed.
class _EducationLevelsSummary extends StatelessWidget {
  const _EducationLevelsSummary({
    required this.levels,
    required this.selectedId,
    required this.classCount,
    required this.totalClasses,
    required this.onSelect,
  });

  final List<EducationalLevel> levels;
  final String selectedId;
  final int Function(EducationalLevel) classCount;
  final int totalClasses;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final configuredLevels = levels.where((l) => classCount(l) > 0).length;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Education levels summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            'Classes configured for each level.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          for (final level in levels) ...[
            _LevelSummaryRow(
              level: level,
              count: classCount(level),
              selected: level.id == selectedId,
              onTap: () => onSelect(level.id),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          if (totalClasses > 0)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                border: Border.all(color: Colors.green.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Looks good!',
                          style: TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$totalClasses class${totalClasses == 1 ? '' : 'es'} across '
                          '$configuredLevels level${configuredLevels == 1 ? '' : 's'}. '
                          'You can edit these later.',
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _LevelSummaryRow extends StatelessWidget {
  const _LevelSummaryRow({
    required this.level,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final EducationalLevel level;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      count == 0 ? 'Not set up' : '$count classes',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The single-level editor: suggested-classes chips with select-all/clear-all
/// and the reorderable "Your classes" list. Identical widget tree is reused
/// for mobile (inside a ListView) and web (inside the left configuration
/// panel), so behavior never diverges between platforms.
class _LevelWorkspace extends StatelessWidget {
  const _LevelWorkspace({
    required this.level,
    required this.selected,
    required this.suggestions,
    required this.onSelectAll,
    required this.onClearAll,
    required this.onToggle,
    required this.onAddCustom,
    required this.onCreateSelected,
    required this.configured,
    required this.hasStreams,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    required this.onReorder,
  });

  final EducationalLevel level;
  final Set<String> selected;
  final List<String> suggestions;
  final ValueChanged<List<String>> onSelectAll;
  final VoidCallback onClearAll;
  final void Function(String name, bool value) onToggle;
  final VoidCallback onAddCustom;
  final VoidCallback? onCreateSelected;
  final List<SchoolClass> configured;
  final bool Function(String classId) hasStreams;
  final ValueChanged<SchoolClass> onEdit;
  final ValueChanged<SchoolClass> onArchive;
  final ValueChanged<SchoolClass> onDelete;
  final ValueChanged<List<SchoolClass>> onReorder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final allSelected =
        suggestions.isNotEmpty && suggestions.every(selected.contains);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                level.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Suggested classes for a standard ${level.name.toLowerCase()} setup. '
          'You can edit, remove or add your own.',
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Suggested classes',
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (suggestions.isNotEmpty)
                    TextButton(
                      onPressed: allSelected
                          ? onClearAll
                          : () => onSelectAll(suggestions),
                      child: Text(allSelected ? 'Clear all' : 'Select all'),
                    ),
                ],
              ),
              if (suggestions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'No configured suggestions for this level. Add the class names your school uses.',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: suggestions
                        .map(
                          (name) => FilterChip(
                            label: Text(name),
                            selected: selected.contains(name),
                            onSelected: (value) => onToggle(name, value),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: onAddCustom,
            icon: const Icon(Icons.add),
            label: const Text('Add custom class'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Streams are configured next — this step only sets up class names.',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        if (onCreateSelected != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onCreateSelected,
              child: Text(
                'Create ${selected.length} class${selected.length == 1 ? '' : 'es'}',
              ),
            ),
          ),
        ],
        if (configured.isNotEmpty) ...[
          const SizedBox(height: 28),
          Row(
            children: [
              Text(
                'Your classes (${configured.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                'Drag to reorder',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _ClassLevelGroup(
            levelClasses: configured,
            hasStreams: hasStreams,
            onEdit: onEdit,
            onArchive: onArchive,
            onDelete: onDelete,
            onReorder: onReorder,
          ),
        ],
      ],
    );
  }
}

/// One education level's classes: a plain, non-nested list when reorder is
/// unsafe (streams already depend on one of these classes), or a drag
/// reorderable list otherwise. Kept level-scoped so drags can't move a class
/// out from under its level by accident.
class _ClassLevelGroup extends StatelessWidget {
  const _ClassLevelGroup({
    required this.levelClasses,
    required this.hasStreams,
    required this.onEdit,
    required this.onArchive,
    required this.onDelete,
    required this.onReorder,
  });

  final List<SchoolClass> levelClasses;
  final bool Function(String classId) hasStreams;
  final ValueChanged<SchoolClass> onEdit;
  final ValueChanged<SchoolClass> onArchive;
  final ValueChanged<SchoolClass> onDelete;
  final ValueChanged<List<SchoolClass>> onReorder;

  bool get _reorderable => !levelClasses.any((item) => hasStreams(item.id));

  @override
  Widget build(BuildContext context) {
    if (!_reorderable) {
      return Column(
        children: [
          for (var i = 0; i < levelClasses.length; i++)
            _ClassCard(
              index: i,
              schoolClass: levelClasses[i],
              draggable: false,
              onEdit: () => onEdit(levelClasses[i]),
              onAction: (action) =>
                  _handleAction(context, action, levelClasses[i]),
            ),
        ],
      );
    }
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      buildDefaultDragHandles: false,
      padding: EdgeInsets.zero,
      itemCount: levelClasses.length,
      onReorder: (oldIndex, newIndex) {
        final reordered = [...levelClasses];
        if (newIndex > oldIndex) newIndex -= 1;
        final moved = reordered.removeAt(oldIndex);
        reordered.insert(newIndex, moved);
        onReorder([
          for (var i = 0; i < reordered.length; i++)
            reordered[i].copyWith(order: i),
        ]);
      },
      itemBuilder: (context, index) => _ClassCard(
        key: ValueKey(levelClasses[index].id),
        index: index,
        schoolClass: levelClasses[index],
        draggable: true,
        onEdit: () => onEdit(levelClasses[index]),
        onAction: (action) =>
            _handleAction(context, action, levelClasses[index]),
      ),
    );
  }

  void _handleAction(
    BuildContext context,
    String action,
    SchoolClass schoolClass,
  ) {
    if (action == 'archive') {
      onArchive(schoolClass);
      return;
    }
    if (action == 'delete') {
      if (hasStreams(schoolClass.id)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text(
                'This class has streams. Archive it instead of deleting it.',
              ),
            ),
          );
        return;
      }
      onDelete(schoolClass);
    }
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({
    super.key,
    required this.index,
    required this.schoolClass,
    required this.draggable,
    required this.onEdit,
    required this.onAction,
  });

  final int index;
  final SchoolClass schoolClass;
  final bool draggable;
  final VoidCallback onEdit;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final row = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          if (draggable)
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant),
            )
          else
            SizedBox(
              width: 24,
              child: Icon(
                Icons.lock_outline,
                size: 18,
                color: scheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(width: 12),
          Text(
            '${index + 1}.',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schoolClass.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${schoolClass.capacity == 0 ? 'No capacity set' : 'Capacity ${schoolClass.capacity}'} • Streams added next',
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20),
            tooltip: 'Edit class',
            onPressed: onEdit,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, size: 20),
            onSelected: onAction,
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'archive', child: Text('Archive')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ],
      ),
    );
    return Padding(
      key: key,
      padding: const EdgeInsets.only(bottom: 10),
      child: row,
    );
  }
}

/// One template's fixed suggestion set for a given level/programme name.
/// Deliberately generic labels ("a common set") rather than any named
/// curriculum/board - templates are optional, editable starting points, not
/// an imposed syllabus. Matched case-insensitively against the active
/// level's name so any custom or international level can opt in.
class _SubjectTemplate {
  final String levelNameMatch;
  final String label;
  final List<_SuggestedSubject> subjects;
  const _SubjectTemplate(this.levelNameMatch, this.label, this.subjects);
}

class _SuggestedSubject {
  final String name;
  final String code;
  const _SuggestedSubject(this.name, this.code);
}

const _kSubjectTemplates = <_SubjectTemplate>[
  _SubjectTemplate('early years', 'Common early-years set', [
    _SuggestedSubject('Numeracy', 'NUM'),
    _SuggestedSubject('Literacy', 'LIT'),
    _SuggestedSubject('Creative play', 'PLAY'),
    _SuggestedSubject('Physical development', 'PHYS'),
  ]),
  _SubjectTemplate('primary', 'Common primary set', [
    _SuggestedSubject('English', 'ENG'),
    _SuggestedSubject('Mathematics', 'MATH'),
    _SuggestedSubject('Science', 'SCI'),
    _SuggestedSubject('Social studies', 'SS'),
    _SuggestedSubject('Art', 'ART'),
    _SuggestedSubject('Physical education', 'PE'),
    _SuggestedSubject('Music', 'MUS'),
    _SuggestedSubject('Design and technology', 'DT'),
  ]),
  _SubjectTemplate('secondary', 'Common secondary set', [
    _SuggestedSubject('English', 'ENG'),
    _SuggestedSubject('Mathematics', 'MATH'),
    _SuggestedSubject('Biology', 'BIO'),
    _SuggestedSubject('Chemistry', 'CHEM'),
    _SuggestedSubject('Physics', 'PHY'),
    _SuggestedSubject('History', 'HIST'),
    _SuggestedSubject('Geography', 'GEO'),
    _SuggestedSubject('Computing', 'COMP'),
  ]),
];

/// Suggested subjects for the active level: the level's own opt-in
/// `Subjects: Name|CODE, ...` configuration (see Step 4's description
/// field) takes priority; otherwise falls back to a generic template
/// matched by level name, and finally to nothing so a fully custom/
/// international level starts blank rather than guessing.
List<_SuggestedSubject> _suggestionsForLevel(EducationalLevel? level) {
  if (level == null) return const [];
  final match = RegExp(
    r'^subjects\s*:',
    caseSensitive: false,
  ).firstMatch(level.description);
  if (match != null) {
    return level.description
        .substring(match.end)
        .split(RegExp(r'[,\n]'))
        .map((raw) {
          final parts = raw.trim().split('|');
          final name = parts.first.trim();
          return _SuggestedSubject(
            name,
            parts.length > 1 ? parts[1].trim() : '',
          );
        })
        .where((s) => s.name.isNotEmpty)
        .toList();
  }
  final template = _kSubjectTemplates
      .where((t) => level.name.toLowerCase().contains(t.levelNameMatch))
      .firstOrNull;
  return template?.subjects ?? const [];
}

/// One entry in the Step 7 level/programme navigator: every active level
/// from Step 4 (Early years, Primary, Secondary, any custom or
/// international level), each showing its own configured-subject count.
/// A subject counts toward a level once that level's id is in its
/// [Subject.assignedLevelIds] - the same subject can count toward several
/// levels at once, matching the multi-level applicability model.
class _SubjectCatalogueSetup extends StatefulWidget {
  const _SubjectCatalogueSetup({
    required this.state,
    required this.schoolId,
    required this.onBulkCreate,
    required this.onSave,
    required this.onArchive,
    required this.onReorder,
  });
  final StructureState state;
  final String schoolId;
  final ValueChanged<List<Subject>> onBulkCreate;
  final ValueChanged<Subject> onSave;
  final ValueChanged<String> onArchive;
  final ValueChanged<List<Subject>> onReorder;
  @override
  State<_SubjectCatalogueSetup> createState() => _SubjectCatalogueSetupState();
}

class _SubjectCatalogueSetupState extends State<_SubjectCatalogueSetup> {
  String? _levelId;
  String _query = '';
  final Set<String> _selected = {};
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<EducationalLevel> get _levels =>
      widget.state.levels.where((l) => l.isActive).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  EducationalLevel? get _level =>
      _levels.where((l) => l.id == _levelId).firstOrNull;

  int _subjectCountForLevel(String levelId) => widget.state.subjects
      .where((s) => s.isActive && s.assignedLevelIds.contains(levelId))
      .length;

  List<Subject> _subjectsForLevel(String levelId) {
    final items =
        widget.state.subjects
            .where((s) => s.isActive && s.assignedLevelIds.contains(levelId))
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));
    return items;
  }

  void _selectLevel(String id) => setState(() {
    _levelId = id;
    _selected.clear();
    _query = '';
  });

  List<_SuggestedSubject> _suggestions(EducationalLevel level) {
    final existing = widget.state.subjects
        .where((s) => s.assignedLevelIds.contains(level.id))
        .map((s) => s.name.trim().toLowerCase())
        .toSet();
    return _suggestionsForLevel(
      level,
    ).where((s) => !existing.contains(s.name.toLowerCase())).toList();
  }

  Future<void> _addSelectedSuggestions(
    EducationalLevel level,
    List<_SuggestedSubject> suggestions,
  ) async {
    final chosen = suggestions
        .where((s) => _selected.contains(s.name))
        .map(
          (s) => Subject(
            id: const Uuid().v4(),
            schoolId: widget.schoolId,
            name: s.name,
            code: s.code,
            assignedLevelIds: [level.id],
          ),
        )
        .toList();
    if (chosen.isEmpty) return;
    widget.onBulkCreate(chosen);
    setState(() => _selected.clear());
  }

  Future<void> _custom({Subject? existing, String? defaultLevelId}) async {
    final name = TextEditingController(text: existing?.name);
    final code = TextEditingController(text: existing?.code);
    final levels = _levels;
    final initialLevelIds =
        existing?.assignedLevelIds.toList() ??
        (defaultLevelId != null ? [defaultLevelId] : <String>[]);
    final selectedLevelIds = {...initialLevelIds};

    String? duplicateError(StateSetter setSheetState) {
      final trimmedName = name.text.trim();
      final trimmedCode = code.text.trim();
      final nameLower = trimmedName.toLowerCase();
      final codeLower = trimmedCode.toLowerCase();
      final duplicateName = widget.state.subjects.any(
        (s) =>
            s.id != existing?.id &&
            s.isActive &&
            s.name.trim().toLowerCase() == nameLower,
      );
      if (trimmedName.isNotEmpty && duplicateName) {
        return 'A subject named "$trimmedName" already exists.';
      }
      if (trimmedCode.isNotEmpty) {
        final duplicateCode = widget.state.subjects.any(
          (s) =>
              s.id != existing?.id &&
              s.isActive &&
              s.code.trim().toLowerCase() == codeLower,
        );
        if (duplicateCode) {
          return 'The code "$trimmedCode" is already in use.';
        }
      }
      return null;
    }

    Widget buildLevelPicker(StateSetter setSheetState) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: levels
            .map(
              (l) => FilterChip(
                label: Text(l.name),
                selected: selectedLevelIds.contains(l.id),
                onSelected: (v) => setSheetState(
                  () => v
                      ? selectedLevelIds.add(l.id)
                      : selectedLevelIds.remove(l.id),
                ),
              ),
            )
            .toList(),
      );
    }

    void submit(BuildContext sheetContext, StateSetter setSheetState) {
      final subjectName = name.text.trim();
      if (subjectName.isEmpty) {
        ScaffoldMessenger.of(
          sheetContext,
        ).showSnackBar(const SnackBar(content: Text('Enter a subject name.')));
        return;
      }
      final error = duplicateError(setSheetState);
      if (error != null) {
        ScaffoldMessenger.of(
          sheetContext,
        ).showSnackBar(SnackBar(content: Text(error)));
        return;
      }
      final subject = Subject(
        id: existing?.id ?? const Uuid().v4(),
        schoolId: widget.schoolId,
        name: subjectName,
        code: code.text.trim(),
        isActive: true,
        assignedLevelIds: selectedLevelIds.toList(),
        assignedClassIds: existing?.assignedClassIds ?? const [],
        order: existing?.order ?? widget.state.subjects.length,
      );
      // Dismiss the keyboard before popping: the sheet's Padding reads
      // MediaQuery.viewInsetsOf(sheetContext), so popping while the keyboard
      // is still closing races that dependency's teardown against the
      // Navigator's route removal, crashing with a "_dependents.isEmpty"
      // assertion in framework.dart. Popping first (before dispatching the
      // bloc event that triggers a BlocBuilder rebuild of this subtree) also
      // avoids targeting an Element already invalidated by that rebuild.
      FocusManager.instance.primaryFocus?.unfocus();
      Navigator.pop(sheetContext);
      if (existing == null) {
        widget.onBulkCreate([subject]);
      } else {
        widget.onSave(subject);
      }
    }

    final isWide = MediaQuery.sizeOf(context).width >= 900;
    if (isWide) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (dialogContext, setSheetState) => AlertDialog(
            title: Text(
              existing == null ? 'Add custom subject' : 'Edit subject',
            ),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: name,
                      autofocus: true,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Subject name *',
                        hintText: 'Enter subject name',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: code,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Short code (optional)',
                        hintText: 'e.g. ART',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Level / programme',
                      style: Theme.of(dialogContext).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    buildLevelPicker(setSheetState),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => submit(dialogContext, setSheetState),
                child: Text(existing == null ? 'Add subject' : 'Save'),
              ),
            ],
          ),
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => StatefulBuilder(
          builder: (sheetContext, setSheetState) => Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              MediaQuery.viewInsetsOf(sheetContext).bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null ? 'Add custom subject' : 'Edit subject',
                    style: Theme.of(sheetContext).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'This subject will be assigned to classes in the next step.',
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: name,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Subject name *',
                      hintText: 'Enter subject name',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: code,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Short code (optional)',
                      hintText: 'e.g. ART',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Level / programme',
                    style: Theme.of(sheetContext).textTheme.labelLarge,
                  ),
                  const SizedBox(height: 8),
                  buildLevelPicker(setSheetState),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => submit(sheetContext, setSheetState),
                      child: Text(existing == null ? 'Add subject' : 'Save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    name.dispose();
    code.dispose();
  }

  Future<void> _delete(Subject subject) async {
    final count = await di
        .sl<StructureDependencyService>()
        .countSubjectReferences(widget.schoolId, subject.id);
    if (!mounted) return;
    if (count == 0) {
      final confirmed = await showDeleteConfirmDialog(
        context,
        title: 'Delete subject',
        message: 'Delete "${subject.name}"? This cannot be undone.',
      );
      if (confirmed == true && mounted) {
        widget.onArchive(subject.id);
      }
      return;
    }
    final action = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Subject is in use'),
        content: Text(
          'This subject is referenced by $count teacher assignment(s) or '
          'assessment(s). Deactivate it instead to preserve those records.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'archive'),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
    if (action == 'archive' && mounted) {
      widget.onArchive(subject.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final levels = _levels;
    if (levels.isEmpty) {
      return const Center(
        child: Text('Add an education level before creating subjects.'),
      );
    }
    final level = _level ?? levels.first;
    if (_levelId != level.id) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _levelId = level.id);
      });
    }
    final totalSubjects = widget.state.subjects.where((s) => s.isActive).length;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final workspace = _SubjectLevelWorkspace(
            level: level,
            searchController: _searchController,
            onQueryChanged: (v) => setState(() => _query = v),
            selected: _selected,
            suggestions: _suggestions(level),
            onSelectAll: (names) => setState(() => _selected.addAll(names)),
            onClearAll: () => setState(() => _selected.clear()),
            onToggle: (name, value) => setState(
              () => value ? _selected.add(name) : _selected.remove(name),
            ),
            onAddSelected: _selected.isEmpty
                ? null
                : () => _addSelectedSuggestions(level, _suggestions(level)),
            onAddCustom: () => _custom(defaultLevelId: level.id),
            configured: _subjectsForLevel(level.id)
                .where(
                  (s) => '${s.name} ${s.code}'.toLowerCase().contains(
                    _query.toLowerCase(),
                  ),
                )
                .toList(),
            onEdit: (subject) => _custom(existing: subject),
            onDelete: _delete,
            onReorder: (reordered) => widget.onReorder([
              for (var i = 0; i < reordered.length; i++)
                reordered[i].copyWith(order: i),
            ]),
          );

          if (isWide) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose the subjects your school teaches. You assign them to classes next.',
                        ),
                        const SizedBox(height: 16),
                        _SubjectLevelSwitcher(
                          levels: levels,
                          selectedId: level.id,
                          subjectCount: (l) => _subjectCountForLevel(l.id),
                          onSelect: _selectLevel,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(child: workspace),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  SizedBox(
                    width: 300,
                    child: _SubjectCatalogueSummary(
                      levels: levels,
                      selectedId: level.id,
                      subjectCount: (l) => _subjectCountForLevel(l.id),
                      totalSubjects: totalSubjects,
                      onSelect: _selectLevel,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Choose the subjects your school teaches. You assign them to classes next.',
                    ),
                    const SizedBox(height: 12),
                    _SubjectLevelSwitcher(
                      levels: levels,
                      selectedId: level.id,
                      subjectCount: (l) => _subjectCountForLevel(l.id),
                      onSelect: _selectLevel,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  children: [workspace],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Horizontal, scrollable level/programme switcher for Step 7. Shows every
/// active level chosen in Step 4 - including custom and international
/// levels - none are hidden or specially ordered.
class _SubjectLevelSwitcher extends StatelessWidget {
  const _SubjectLevelSwitcher({
    required this.levels,
    required this.selectedId,
    required this.subjectCount,
    required this.onSelect,
  });

  final List<EducationalLevel> levels;
  final String selectedId;
  final int Function(EducationalLevel) subjectCount;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: levels.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = levels[index];
          final selected = item.id == selectedId;
          final count = subjectCount(item);
          return Semantics(
            button: true,
            selected: selected,
            label: '${item.name}, $count subject${count == 1 ? '' : 's'}',
            child: InkWell(
              onTap: () => onSelect(item.id),
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? scheme.primaryContainer : scheme.surface,
                    border: Border.all(
                      color: selected ? scheme.primary : scheme.outlineVariant,
                      width: selected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: selected
                              ? scheme.onPrimaryContainer
                              : scheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        count == 0 ? 'No subjects' : '$count subjects',
                        style: TextStyle(
                          fontSize: 11,
                          color: selected
                              ? scheme.onPrimaryContainer.withValues(alpha: 0.8)
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
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

/// The right-hand "Subject catalogue summary" card on wide (web) layouts:
/// total subjects across all levels, with a completion tick per level.
class _SubjectCatalogueSummary extends StatelessWidget {
  const _SubjectCatalogueSummary({
    required this.levels,
    required this.selectedId,
    required this.subjectCount,
    required this.totalSubjects,
    required this.onSelect,
  });

  final List<EducationalLevel> levels;
  final String selectedId;
  final int Function(EducationalLevel) subjectCount;
  final int totalSubjects;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject catalogue summary',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            'Total subjects across all levels.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          for (final level in levels) ...[
            _SubjectSummaryRow(
              level: level,
              count: subjectCount(level),
              selected: level.id == selectedId,
              onTap: () => onSelect(level.id),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: scheme.primaryContainer.withValues(alpha: 0.35),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.4)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: scheme.primary, size: 20),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'You assign subjects to classes in the next step.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectSummaryRow extends StatelessWidget {
  const _SubjectSummaryRow({
    required this.level,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final EducationalLevel level;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? scheme.primaryContainer : null,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  level.name,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '$count subject${count == 1 ? '' : 's'}',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(width: 6),
              if (count > 0)
                const Icon(Icons.check_circle, color: Colors.green, size: 18)
              else
                Icon(
                  Icons.radio_button_unchecked,
                  size: 18,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The single-level/programme editor: search, suggested-subject chips with
/// select-all/clear, add-custom action, and the reorderable "School
/// subjects" list. Same widget tree on mobile and web.
class _SubjectLevelWorkspace extends StatelessWidget {
  const _SubjectLevelWorkspace({
    required this.level,
    required this.searchController,
    required this.onQueryChanged,
    required this.selected,
    required this.suggestions,
    required this.onSelectAll,
    required this.onClearAll,
    required this.onToggle,
    required this.onAddSelected,
    required this.onAddCustom,
    required this.configured,
    required this.onEdit,
    required this.onDelete,
    required this.onReorder,
  });

  final EducationalLevel level;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final Set<String> selected;
  final List<_SuggestedSubject> suggestions;
  final ValueChanged<List<String>> onSelectAll;
  final VoidCallback onClearAll;
  final void Function(String name, bool value) onToggle;
  final VoidCallback? onAddSelected;
  final VoidCallback onAddCustom;
  final List<Subject> configured;
  final ValueChanged<Subject> onEdit;
  final ValueChanged<Subject> onDelete;
  final ValueChanged<List<Subject>> onReorder;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final allSelected =
        suggestions.isNotEmpty &&
        suggestions.every((s) => selected.contains(s.name));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: searchController,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.search),
            hintText: 'Search subjects',
          ),
          onChanged: onQueryChanged,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                '${level.name} subjects',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Add common subjects or search for more. You can edit these later.',
          style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: scheme.outlineVariant),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Suggested subjects',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  if (suggestions.isNotEmpty)
                    TextButton(
                      onPressed: allSelected
                          ? onClearAll
                          : () => onSelectAll(
                              suggestions.map((s) => s.name).toList(),
                            ),
                      child: Text(allSelected ? 'Clear all' : 'Select all'),
                    ),
                ],
              ),
              if (suggestions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'No configured suggestions for this level. Add the subjects your school uses.',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: suggestions
                        .map(
                          (s) => FilterChip(
                            label: Text(s.name),
                            selected: selected.contains(s.name),
                            onSelected: (value) => onToggle(s.name, value),
                          ),
                        )
                        .toList(),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 44,
          child: OutlinedButton.icon(
            onPressed: onAddCustom,
            icon: const Icon(Icons.add),
            label: const Text('Add custom subject'),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Catalogue setup only — subject-to-class assignment happens in the next step.',
          style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
        ),
        if (onAddSelected != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: onAddSelected,
              child: Text(
                'Add ${selected.length} subject${selected.length == 1 ? '' : 's'}',
              ),
            ),
          ),
        ],
        const SizedBox(height: 28),
        if (configured.isEmpty)
          EmptyState(
            icon: Icons.menu_book_outlined,
            title: 'No subjects yet',
            message: 'Add the subjects your school teaches at this level.',
            ctaLabel: 'Add custom subject',
            onCtaPressed: onAddCustom,
          )
        else ...[
          Row(
            children: [
              Text(
                'School subjects (${configured.length})',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const Spacer(),
              Text(
                'Drag to reorder',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            padding: EdgeInsets.zero,
            itemCount: configured.length,
            onReorder: (oldIndex, newIndex) {
              final reordered = [...configured];
              if (newIndex > oldIndex) newIndex -= 1;
              final moved = reordered.removeAt(oldIndex);
              reordered.insert(newIndex, moved);
              onReorder(reordered);
            },
            itemBuilder: (context, index) => _SubjectCard(
              key: ValueKey(configured[index].id),
              index: index,
              subject: configured[index],
              onEdit: () => onEdit(configured[index]),
              onAction: (action) {
                if (action == 'delete') onDelete(configured[index]);
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    super.key,
    required this.index,
    required this.subject,
    required this.onEdit,
    required this.onAction,
  });

  final int index;
  final Subject subject;
  final VoidCallback onEdit;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: scheme.outlineVariant),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                subject.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            if (subject.code.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  subject.code,
                  style: TextStyle(
                    fontSize: 12,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.edit_outlined, size: 20),
              onPressed: onEdit,
              tooltip: 'Edit',
            ),
            PopupMenuButton<String>(
              onSelected: onAction,
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
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

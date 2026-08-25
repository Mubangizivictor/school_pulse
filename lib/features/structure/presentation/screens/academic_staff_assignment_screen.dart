// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/curriculum_assignment_repository_impl.dart';
import '../../data/repositories/structure_people_readiness_repository_impl.dart';
import '../../data/repositories/teaching_assignment_repository_impl.dart';
import '../../domain/entities/curriculum_assignment.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../../domain/repositories/curriculum_assignment_repository.dart';
import '../../domain/repositories/structure_people_readiness_repository.dart';
import '../../domain/repositories/teaching_assignment_repository.dart';
import '../../domain/services/academic_responsibility_catalog.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

/// A self-contained academic duty feature. It deliberately has no dependency
/// on the onboarding shell, so it can be routed from Admin settings later.
class AcademicStaffAssignmentScreen extends StatefulWidget {
  const AcademicStaffAssignmentScreen({super.key});
  @override
  State<AcademicStaffAssignmentScreen> createState() =>
      _AcademicStaffAssignmentScreenState();
}

class _AcademicStaffAssignmentScreenState
    extends State<AcademicStaffAssignmentScreen> {
  late final StructureTenantResolver _tenant;
  late final TeachingAssignmentRepository _assignments;
  late final CurriculumAssignmentRepository _curriculum;
  late final StructurePeopleReadinessRepository _people;
  late final Future<String> _schoolId;
  String? _yearId;
  String? _termId;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    _tenant = StructureTenantResolver(firestore: firestore);
    _assignments = TeachingAssignmentRepositoryImpl(
      firestore: firestore,
      tenantResolver: _tenant,
    );
    _curriculum = CurriculumAssignmentRepositoryImpl(
      firestore: firestore,
      tenantResolver: _tenant,
    );
    _people = StructurePeopleReadinessRepositoryImpl(firestore: firestore);
    _schoolId = _tenant.resolve();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<StructureBloc, StructureState>(
    builder: (context, structure) {
      final years = structure.academicYears
          .where((year) => !year.isArchived)
          .toList();
      final selectedYear =
          years.where((year) => year.id == _yearId).firstOrNull ??
          years.where((year) => year.isCurrent).firstOrNull ??
          years.firstOrNull;
      final terms =
          structure.academicTerms
              .where(
                (term) =>
                    !term.isArchived && term.academicYearId == selectedYear?.id,
              )
              .toList()
            ..sort((a, b) => a.order.compareTo(b.order));
      final selectedTerm =
          terms.where((term) => term.id == _termId).firstOrNull ??
          terms.where((term) => term.isCurrent).firstOrNull ??
          terms.firstOrNull;
      if (selectedYear == null || selectedTerm == null)
        return const _StateMessage(
          title: 'Academic year and term required',
          body:
              'Set up at least one active academic year and term before assigning academic responsibilities.',
        );
      return FutureBuilder<String>(
        future: _schoolId,
        builder: (context, school) {
          if (school.hasError)
            return _StateMessage(
              title: 'School context unavailable',
              body: school.error.toString(),
              retry: () => setState(() {}),
            );
          if (!school.hasData)
            return const Center(child: CircularProgressIndicator());
          return StreamBuilder<List<UserEntity>>(
            stream: _people.watchSchoolStaff(school.data!),
            builder: (context, staff) {
              if (staff.hasError)
                return _StateMessage(
                  title: 'Could not load staff',
                  body: staff.error.toString(),
                  retry: () => setState(() {}),
                );
              if (!staff.hasData)
                return const Center(child: CircularProgressIndicator());
              return StreamBuilder<List<CurriculumAssignment>>(
                stream: _curriculum.watchAssignments(),
                builder: (context, curriculum) {
                  if (curriculum.hasError)
                    return _StateMessage(
                      title: 'Could not load curriculum',
                      body: curriculum.error.toString(),
                      retry: () => setState(() {}),
                    );
                  if (!curriculum.hasData)
                    return const Center(child: CircularProgressIndicator());
                  return StreamBuilder<List<TeachingAssignment>>(
                    stream: _assignments.watchAssignments(),
                    builder: (context, rows) {
                      if (rows.hasError)
                        return _StateMessage(
                          title: 'Could not load responsibilities',
                          body: rows.error.toString(),
                          retry: () => setState(() {}),
                        );
                      if (!rows.hasData)
                        return const Center(child: CircularProgressIndicator());
                      final current = rows.data!
                          .where(
                            (row) =>
                                row.isActive &&
                                row.academicYearId == selectedYear.id &&
                                row.academicTermId == selectedTerm.id,
                          )
                          .toList();
                      final available = configuredAcademicResponsibilities(
                        structure.designations,
                      );
                      return _Overview(
                        year: selectedYear,
                        term: selectedTerm,
                        years: years,
                        terms: terms,
                        assignments: current,
                        structure: structure,
                        staff: staff.data!
                            .where((person) => person.isActive)
                            .toList(),
                        onPeriodChanged: (year, term) => setState(() {
                          _yearId = year;
                          _termId = term;
                        }),
                        onAssign: () => _pickResponsibility(
                          context,
                          available,
                          (choice) => _showForm(
                            context,
                            choice,
                            selectedYear,
                            selectedTerm,
                            staff.data!,
                            curriculum.data!,
                            structure,
                          ),
                        ),
                        onEnd: (row) async {
                          try {
                            await _assignments.endAssignment(row.id);
                          } catch (e) {
                            if (mounted) _snack(e);
                          }
                        },
                      );
                    },
                  );
                },
              );
            },
          );
        },
      );
    },
  );

  void _snack(Object error) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
    );

  Future<void> _pickResponsibility(
    BuildContext context,
    List<AcademicResponsibilityDefinition> choices,
    ValueChanged<AcademicResponsibilityDefinition> onSelected,
  ) async {
    if (choices.isEmpty) {
      _snack(
        'No academic responsibilities are configured. Add active academic designations in Staff roles first.',
      );
      return;
    }
    final chosen = await Navigator.of(context).push<AcademicResponsibilityDefinition>(
      MaterialPageRoute(builder: (_) => _ResponsibilityPicker(choices: choices)),
    );
    if (chosen != null) onSelected(chosen);
  }

  Future<void> _showForm(
    BuildContext context,
    AcademicResponsibilityDefinition choice,
    AcademicYear year,
    AcademicTerm term,
    List<UserEntity> allStaff,
    List<CurriculumAssignment> allCurriculum,
    StructureState structure,
  ) async {
    // Require an intentional staff selection; assignments never default to a
    // potentially unrelated first person in the tenant list.
    var staffId = '';
    var selectedYear = year;
    var selectedTerm = term;
    var classId = '';
    var streamId = '';
    var subjectId = '';
    var departmentId = '';
    var saving = false;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) => FractionallySizedBox(
        heightFactor: .92,
        child: StatefulBuilder(
          builder: (context, setSheet) {
            final streams = structure.streams
                .where((item) => item.isActive && item.classId == classId)
                .toList();
            final permittedSubjects = allCurriculum
                .where(
                  (item) =>
                      item.isActive &&
                      item.academicYearId == selectedYear.id &&
                      item.classId == classId &&
                      (item.streamId.isEmpty || item.streamId == streamId),
                )
                .map((item) => item.subjectId)
                .toSet();
            final subjects = structure.subjects
                .where(
                  (item) =>
                      item.isActive && permittedSubjects.contains(item.id),
                )
                .toList();
            final scope = _scopeText(
              choice,
              structure,
              classId,
              streamId,
              subjectId,
              departmentId,
              selectedYear,
              selectedTerm,
            );
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  MediaQuery.viewInsetsOf(context).bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Assign ${choice.title}',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'This assigns an academic duty. It does not change the staff member’s app access role.',
                    ),
                    const SizedBox(height: 18),
                    _select(
                      'Staff member',
                      staffId,
                      allStaff
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      (value) => setSheet(() => staffId = value ?? ''),
                    ),
                    const SizedBox(height: 14),
                    _select(
                      'Academic year',
                      selectedYear.id,
                      structure.academicYears
                          .where(
                            (item) =>
                                !item.isArchived &&
                                structure.academicTerms.any(
                                  (term) =>
                                      !term.isArchived &&
                                      term.academicYearId == item.id,
                                ),
                          )
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      (value) => setSheet(() {
                        selectedYear = structure.academicYears.firstWhere(
                          (item) => item.id == value,
                        );
                        final matchingTerms = structure.academicTerms
                            .where(
                              (item) =>
                                  !item.isArchived &&
                                  item.academicYearId == selectedYear.id,
                            )
                            .toList();
                        selectedTerm = matchingTerms.firstWhere(
                          (item) => item.isCurrent,
                          orElse: () => matchingTerms.first,
                        );
                        classId = '';
                        streamId = '';
                        subjectId = '';
                      }),
                    ),
                    const SizedBox(height: 14),
                    _select(
                      'Term',
                      selectedTerm.id,
                      structure.academicTerms
                          .where(
                            (item) =>
                                !item.isArchived &&
                                item.academicYearId == selectedYear.id,
                          )
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      (value) => setSheet(
                        () => selectedTerm = structure.academicTerms.firstWhere(
                          (item) => item.id == value,
                        ),
                      ),
                    ),
                    if (choice.needsClass) ...[
                      const SizedBox(height: 14),
                      _select(
                        'Class',
                        classId,
                        structure.classes
                            .where((item) => item.isActive)
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        (value) => setSheet(() {
                          classId = value ?? '';
                          streamId = '';
                          subjectId = '';
                        }),
                      ),
                    ],
                    if (choice.needsClass && streams.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      _select(
                        'Stream / section (if applicable)',
                        streamId,
                        [
                          const DropdownMenuItem(
                            value: '',
                            child: Text('Whole class'),
                          ),
                          ...streams.map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                        ],
                        (value) => setSheet(() {
                          streamId = value ?? '';
                          subjectId = '';
                        }),
                      ),
                    ],
                    if (choice.needsSubject) ...[
                      const SizedBox(height: 14),
                      _select(
                        'Subject',
                        subjectId,
                        subjects
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        (value) => setSheet(() => subjectId = value ?? ''),
                      ),
                      if (classId.isNotEmpty && subjects.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'No subject is allocated to this class/stream for the selected year.',
                          ),
                        ),
                    ],
                    if (choice.needsDepartment) ...[
                      const SizedBox(height: 14),
                      _select(
                        'Department',
                        departmentId,
                        structure.departments
                            .where((item) => item.isActive)
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        (value) => setSheet(() => departmentId = value ?? ''),
                      ),
                    ],
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Responsibility scope',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 4),
                          Text(scope),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: saving
                            ? null
                            : () async {
                                if (staffId.isEmpty ||
                                    (choice.needsClass && classId.isEmpty) ||
                                    (choice.needsSubject &&
                                        subjectId.isEmpty) ||
                                    (choice.needsDepartment &&
                                        departmentId.isEmpty)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Complete all required scope fields.',
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                setSheet(() => saving = true);
                                try {
                                  await _assignments.saveAssignment(
                                    TeachingAssignment(
                                      id: const Uuid().v4(),
                                      staffId: staffId,
                                      academicYearId: selectedYear.id,
                                      academicTermId: selectedTerm.id,
                                      designationId: choice.designation.id,
                                      responsibilityType: choice.type,
                                      departmentId: choice.needsDepartment
                                          ? departmentId
                                          : '',
                                      classId: choice.needsClass ? classId : '',
                                      streamId: choice.needsClass
                                          ? streamId
                                          : '',
                                      subjectId: choice.needsSubject
                                          ? subjectId
                                          : '',
                                      isPrimary:
                                          choice.type ==
                                          TeachingResponsibilityType
                                              .classTeacher,
                                    ),
                                  );
                                  if (sheet.mounted) Navigator.pop(sheet);
                                } catch (e) {
                                  setSheet(() => saving = false);
                                  if (mounted) _snack(e);
                                }
                              },
                        child: Text(saving ? 'Saving…' : 'Save responsibility'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _select(
    String label,
    String value,
    List<DropdownMenuItem<String>> items,
    ValueChanged<String?> changed,
  ) => DropdownButtonFormField<String>(
    key: ValueKey('$label-$value'),
    initialValue: value.isEmpty ? null : value,
    isExpanded: true,
    decoration: InputDecoration(labelText: label),
    items: items,
    onChanged: changed,
  );
}

class _Overview extends StatelessWidget {
  const _Overview({
    required this.year,
    required this.term,
    required this.years,
    required this.terms,
    required this.assignments,
    required this.structure,
    required this.staff,
    required this.onPeriodChanged,
    required this.onAssign,
    required this.onEnd,
  });
  final AcademicYear year;
  final AcademicTerm term;
  final List<AcademicYear> years;
  final List<AcademicTerm> terms;
  final List<TeachingAssignment> assignments;
  final StructureState structure;
  final List<UserEntity> staff;
  final void Function(String, String) onPeriodChanged;
  final VoidCallback onAssign;
  final ValueChanged<TeachingAssignment> onEnd;
  @override
  Widget build(BuildContext context) {
    final groups = <AcademicResponsibilityGroup, List<TeachingAssignment>>{
      for (final group in AcademicResponsibilityGroup.values) group: [],
    };
    for (final row in assignments) {
      groups[academicResponsibilityGroup(row.responsibilityType)]!.add(row);
    }
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Academic responsibilities',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            const Text(
              'Assign teaching and academic duties. Staff access roles are managed separately.',
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('academic-year-${year.id}'),
                    initialValue: year.id,
                    decoration: const InputDecoration(
                      labelText: 'Academic year',
                    ),
                    items: years
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (id) => onPeriodChanged(
                      id!,
                      terms
                              .where((item) => item.academicYearId == id)
                              .firstOrNull
                              ?.id ??
                          '',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('academic-term-${term.id}'),
                    initialValue: term.id,
                    decoration: const InputDecoration(labelText: 'Term'),
                    items: terms
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (id) => onPeriodChanged(year.id, id!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  for (final entry in groups.entries)
                    _GroupCard(
                      group: entry.key,
                      count: entry.value.length,
                      onTap: () => _openGroup(context, entry.key, entry.value),
                    ),
                  const SizedBox(height: 20),
                  if (assignments.isNotEmpty) ...[
                    Text(
                      'Recent assignments',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...(assignments.toList()
                          ..sort(
                            (a, b) => (b.createdAt ?? DateTime(0)).compareTo(
                              a.createdAt ?? DateTime(0),
                            ),
                          ))
                        .take(5)
                        .map(
                          (row) => _Row(
                            row: row,
                            structure: structure,
                            staff: staff,
                            onEnd: onEnd,
                          ),
                        ),
                  ],
                  const SizedBox(height: 80),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAssign,
                icon: const Icon(Icons.add),
                label: const Text('Assign responsibility'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openGroup(
    BuildContext context,
    AcademicResponsibilityGroup group,
    List<TeachingAssignment> rows,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _GroupDetailScreen(
          group: group,
          rows: rows,
          structure: structure,
          staff: staff,
          onEnd: onEnd,
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group, required this.count, required this.onTap});
  final AcademicResponsibilityGroup group;
  final int count;
  final VoidCallback onTap;

  static const _icons = {
    AcademicResponsibilityGroup.teaching: Icons.menu_book_outlined,
    AcademicResponsibilityGroup.leadership: Icons.account_tree_outlined,
    AcademicResponsibilityGroup.assessmentTimetable: Icons.event_note_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(_icons[group], color: scheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.label,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$count assignment${count == 1 ? '' : 's'}',
                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupDetailScreen extends StatelessWidget {
  const _GroupDetailScreen({
    required this.group,
    required this.rows,
    required this.structure,
    required this.staff,
    required this.onEnd,
  });

  final AcademicResponsibilityGroup group;
  final List<TeachingAssignment> rows;
  final StructureState structure;
  final List<UserEntity> staff;
  final ValueChanged<TeachingAssignment> onEnd;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(group.label)),
      body: SafeArea(
        child: rows.isEmpty
            ? const Center(child: Text('No assignments for this term.'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: rows
                    .map(
                      (row) => _Row(
                        row: row,
                        structure: structure,
                        staff: staff,
                        onEnd: onEnd,
                      ),
                    )
                    .toList(),
              ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.row,
    required this.structure,
    required this.staff,
    required this.onEnd,
  });
  final TeachingAssignment row;
  final StructureState structure;
  final List<UserEntity> staff;
  final ValueChanged<TeachingAssignment> onEnd;
  @override
  Widget build(BuildContext context) {
    final staffName =
        staff.where((p) => p.id == row.staffId).firstOrNull?.name ??
        'Missing staff member';
    final scope = _scopeTextFor(row, structure);
    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          staffName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          '${academicResponsibilityLabel(row.responsibilityType)} · $scope',
        ),
        trailing: IconButton(
          tooltip: 'End responsibility',
          icon: const Icon(Icons.stop_circle_outlined),
          onPressed: () => onEnd(row),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({required this.title, required this.body, this.retry});
  final String title;
  final String body;
  final VoidCallback? retry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.info_outline, size: 44),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(body, textAlign: TextAlign.center),
          if (retry != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: retry, child: const Text('Retry')),
          ],
        ],
      ),
    ),
  );
}

class _ResponsibilityPicker extends StatefulWidget {
  const _ResponsibilityPicker({required this.choices});
  final List<AcademicResponsibilityDefinition> choices;
  @override
  State<_ResponsibilityPicker> createState() => _ResponsibilityPickerState();
}

class _ResponsibilityPickerState extends State<_ResponsibilityPicker> {
  String query = '';
  @override
  Widget build(BuildContext context) {
    final choices = widget.choices
        .where(
          (choice) => choice.title.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
    final groups =
        <AcademicResponsibilityGroup, List<AcademicResponsibilityDefinition>>{
          for (final group in AcademicResponsibilityGroup.values) group: [],
        };
    for (final choice in choices) {
      groups[choice.group]!.add(choice);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Select responsibility')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            children: [
              TextField(
                autofocus: true,
                onChanged: (value) => setState(() => query = value),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search responsibilities',
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: ListView(
                  children: [
                    for (final entry in groups.entries)
                      if (entry.value.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 4),
                        child: Text(
                          entry.key.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                        ...entry.value.map(
                          (choice) => ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(choice.title),
                            subtitle: Text(choice.scopeHint),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.pop(context, choice),
                          ),
                        ),
                      ],
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This assigns a duty; it does not change the staff member’s app access role.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

String _scopeText(
  AcademicResponsibilityDefinition choice,
  StructureState state,
  String classId,
  String streamId,
  String subjectId,
  String departmentId,
  AcademicYear year,
  AcademicTerm term,
) => _scopeTextValues(
  choice.title,
  state,
  classId,
  streamId,
  subjectId,
  departmentId,
  year.name,
  term.name,
);
String _scopeTextFor(TeachingAssignment row, StructureState state) =>
    _scopeTextValues(
      academicResponsibilityLabel(row.responsibilityType),
      state,
      row.classId,
      row.streamId,
      row.subjectId,
      row.departmentId,
      row.academicYearId,
      row.academicTermId,
    );
String _scopeTextValues(
  String title,
  StructureState state,
  String classId,
  String streamId,
  String subjectId,
  String departmentId,
  String year,
  String term,
) {
  String byId<T>(Iterable<T> items, String id, String Function(T) name) =>
      items
              .where(
                (item) => name(item).isNotEmpty && (item as dynamic).id == id,
              )
              .firstOrNull ==
          null
      ? ''
      : name(items.where((item) => (item as dynamic).id == id).first);
  final parts = <String>[
    if (classId.isNotEmpty)
      byId(state.classes, classId, (SchoolClass c) => c.name),
    if (streamId.isNotEmpty)
      byId(state.streams, streamId, (ClassStream s) => s.name),
    if (subjectId.isNotEmpty)
      byId(state.subjects, subjectId, (Subject s) => s.name),
    if (departmentId.isNotEmpty)
      byId(state.departments, departmentId, (Department d) => d.name),
    year,
    term,
  ]..removeWhere((item) => item.isEmpty);
  return parts.isEmpty ? '$title · institution-wide' : parts.join(' · ');
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

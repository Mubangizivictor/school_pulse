// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/design_system/app_components.dart';
import 'package:school_pulse/design_system/theme/app_colors.dart';
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

  Future<bool> _confirmPeriodChange() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch academic year or term?'),
        content: const Text(
          'Any responsibility form you have open for this period will be '
          'discarded. Saved assignments are never affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    return result ?? false;
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
        return _StateMessage(
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
                        available: available,
                        structure: structure,
                        staff: staff.data!
                            .where((person) => person.isActive)
                            .toList(),
                        onPeriodChanged: (year, term) async {
                          if (!await _confirmPeriodChange()) return;
                          setState(() {
                            _yearId = year;
                            _termId = term;
                          });
                        },
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
    final wide = MediaQuery.sizeOf(context).width >= 900;
    final chosen = wide
        ? await showDialog<AcademicResponsibilityDefinition>(
            context: context,
            builder: (_) => Dialog(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520, maxHeight: 640),
                child: _ResponsibilityPicker(choices: choices),
              ),
            ),
          )
        : await showModalBottomSheet<AcademicResponsibilityDefinition>(
            context: context,
            isScrollControlled: true,
            showDragHandle: true,
            builder: (_) => FractionallySizedBox(
              heightFactor: .85,
              child: _ResponsibilityPicker(choices: choices),
            ),
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

    Widget buildForm(BuildContext context, StateSetter setSheet) {
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
          .where((item) => item.isActive && permittedSubjects.contains(item.id))
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
      return SingleChildScrollView(
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
              'This assigns an academic duty. It does not change the staff '
              'member’s app access role. Staff access roles are managed '
              'separately.',
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
                            (choice.needsSubject && subjectId.isEmpty) ||
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
                              streamId: choice.needsClass ? streamId : '',
                              subjectId: choice.needsSubject ? subjectId : '',
                              isPrimary:
                                  choice.type ==
                                  TeachingResponsibilityType.classTeacher,
                            ),
                          );
                          if (context.mounted) Navigator.pop(context);
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
      );
    }

    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (wide) {
      await showDialog<void>(
        context: context,
        builder: (context) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
            child: StatefulBuilder(builder: buildForm),
          ),
        ),
      );
    } else {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) => FractionallySizedBox(
          heightFactor: .92,
          child: SafeArea(child: StatefulBuilder(builder: buildForm)),
        ),
      );
    }
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

enum _GroupStatus { ready, review, notSet }

class _Overview extends StatelessWidget {
  const _Overview({
    required this.year,
    required this.term,
    required this.years,
    required this.terms,
    required this.assignments,
    required this.available,
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
  final List<AcademicResponsibilityDefinition> available;
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
    final configuredGroups = available.map((item) => item.group).toSet();

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
              'Assign academic duties for this year and term. Staff access '
              'roles are managed separately.',
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
            const SizedBox(height: 14),
            _InfoBanner(text: 'Assignments apply to ${term.name} only.'),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  for (final entry in groups.entries)
                    _GroupCard(
                      group: entry.key,
                      count: entry.value.length,
                      status: _statusFor(
                        entry.key,
                        entry.value,
                        configuredGroups,
                      ),
                      onTap: () => _openGroup(context, entry.key, entry.value),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => _openAll(context),
                    icon: const Icon(Icons.list_alt_outlined),
                    label: const Text('View all assignments'),
                  ),
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

  _GroupStatus _statusFor(
    AcademicResponsibilityGroup group,
    List<TeachingAssignment> rows,
    Set<AcademicResponsibilityGroup> configuredGroups,
  ) {
    if (rows.isNotEmpty) return _GroupStatus.ready;
    if (configuredGroups.contains(group)) return _GroupStatus.review;
    return _GroupStatus.notSet;
  }

  void _openGroup(
    BuildContext context,
    AcademicResponsibilityGroup group,
    List<TeachingAssignment> rows,
  ) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (wide) {
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
            child: _GroupDetail(
              title: group.label,
              rows: rows,
              structure: structure,
              staff: staff,
              onEnd: onEnd,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => FractionallySizedBox(
          heightFactor: .85,
          child: _GroupDetail(
            title: group.label,
            rows: rows,
            structure: structure,
            staff: staff,
            onEnd: onEnd,
          ),
        ),
      );
    }
  }

  void _openAll(BuildContext context) {
    final all = assignments.toList()
      ..sort(
        (a, b) =>
            (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)),
      );
    final wide = MediaQuery.sizeOf(context).width >= 900;
    if (wide) {
      showDialog<void>(
        context: context,
        builder: (_) => Dialog(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
            child: _GroupDetail(
              title: 'All assignments – ${term.name}',
              rows: all,
              structure: structure,
              staff: staff,
              onEnd: onEnd,
            ),
          ),
        ),
      );
    } else {
      showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => FractionallySizedBox(
          heightFactor: .85,
          child: _GroupDetail(
            title: 'All assignments – ${term.name}',
            rows: all,
            structure: structure,
            staff: staff,
            onEnd: onEnd,
          ),
        ),
      );
    }
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.informationSurface(context),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        Icon(Icons.info_outline, size: 18, color: AppColors.information(context)),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.information(context),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    ),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});
  final _GroupStatus status;
  @override
  Widget build(BuildContext context) {
    switch (status) {
      case _GroupStatus.ready:
        return _pill(
          context,
          'Ready',
          Icons.check_circle,
          AppColors.success(context),
          AppColors.successSurface(context),
        );
      case _GroupStatus.review:
        return _pill(
          context,
          'Review',
          Icons.info,
          AppColors.information(context),
          AppColors.informationSurface(context),
        );
      case _GroupStatus.notSet:
        final scheme = Theme.of(context).colorScheme;
        return Text(
          'Not set',
          style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
        );
    }
  }

  Widget _pill(
    BuildContext context,
    String label,
    IconData icon,
    Color fg,
    Color bg,
  ) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: fg),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 12.5),
        ),
      ],
    ),
  );
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({
    required this.group,
    required this.count,
    required this.status,
    required this.onTap,
  });
  final AcademicResponsibilityGroup group;
  final int count;
  final _GroupStatus status;
  final VoidCallback onTap;

  static const _icons = {
    AcademicResponsibilityGroup.teaching: Icons.menu_book_outlined,
    AcademicResponsibilityGroup.leadership: Icons.groups_outlined,
    AcademicResponsibilityGroup.assessmentTimetable: Icons.event_note_outlined,
  };

  static const _descriptions = {
    AcademicResponsibilityGroup.teaching:
        'Class, subject and stream teaching assignments',
    AcademicResponsibilityGroup.leadership:
        'Heads of department, level or programme',
    AcademicResponsibilityGroup.assessmentTimetable:
        'Assessment coordination and timetable duties',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_icons[group], color: scheme.onSurfaceVariant),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _descriptions[group]!,
                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      status == _GroupStatus.notSet
                          ? 'Not set'
                          : '$count assigned',
                      style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _StatusPill(status: status),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupDetail extends StatelessWidget {
  const _GroupDetail({
    required this.title,
    required this.rows,
    required this.structure,
    required this.staff,
    required this.onEnd,
  });

  final String title;
  final List<TeachingAssignment> rows;
  final StructureState structure;
  final List<UserEntity> staff;
  final ValueChanged<TeachingAssignment> onEnd;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 14),
          Flexible(
            child: rows.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text('No assignments for this term.'),
                  )
                : ListView(
                    shrinkWrap: true,
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
        ],
      ),
    ),
  );
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select responsibility',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            TextField(
              autofocus: true,
              onChanged: (value) => setState(() => query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search responsibilities',
              ),
            ),
            const SizedBox(height: 14),
            Flexible(
              child: ListView(
                shrinkWrap: true,
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

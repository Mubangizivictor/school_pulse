import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/curriculum_assignment_repository_impl.dart';
import '../../data/repositories/structure_people_readiness_repository_impl.dart';
import '../../data/repositories/teaching_assignment_repository_impl.dart';
import '../../domain/entities/curriculum_assignment.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../../domain/repositories/curriculum_assignment_repository.dart';
import '../../domain/repositories/structure_people_readiness_repository.dart';
import '../../domain/repositories/teaching_assignment_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

class AcademicStaffAssignmentScreen extends StatefulWidget {
  const AcademicStaffAssignmentScreen({super.key});

  @override
  State<AcademicStaffAssignmentScreen> createState() =>
      _AcademicStaffAssignmentScreenState();
}

class _AcademicStaffAssignmentScreenState
    extends State<AcademicStaffAssignmentScreen> {
  late final StructureTenantResolver _tenantResolver;
  late final TeachingAssignmentRepository _assignmentRepository;
  late final CurriculumAssignmentRepository _curriculumRepository;
  late final StructurePeopleReadinessRepository _peopleRepository;
  late final Future<String> _schoolId;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    _tenantResolver = StructureTenantResolver(firestore: firestore);
    _assignmentRepository = TeachingAssignmentRepositoryImpl(
      firestore: firestore,
      tenantResolver: _tenantResolver,
    );
    _curriculumRepository = CurriculumAssignmentRepositoryImpl(
      firestore: firestore,
      tenantResolver: _tenantResolver,
    );
    _peopleRepository = StructurePeopleReadinessRepositoryImpl(
      firestore: firestore,
    );
    _schoolId = _tenantResolver.resolve();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StructureBloc, StructureState>(
      builder: (context, structure) {
        final currentYear = structure.academicYears
            .where((item) => item.isCurrent && !item.isArchived)
            .firstOrNull;
        if (currentYear == null) {
          return const _Message(
            title: 'Current academic year required',
            body:
                'Set a current academic year before assigning teachers and academic responsibilities.',
          );
        }

        return FutureBuilder<String>(
          future: _schoolId,
          builder: (context, schoolSnapshot) {
            if (schoolSnapshot.hasError) {
              return _Message(
                title: 'School context unavailable',
                body: schoolSnapshot.error.toString(),
              );
            }
            if (!schoolSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<List<UserEntity>>(
              stream: _peopleRepository.watchSchoolStaff(schoolSnapshot.data!),
              builder: (context, staffSnapshot) {
                if (staffSnapshot.hasError) {
                  return _Message(
                    title: 'Could not load staff',
                    body: staffSnapshot.error.toString(),
                  );
                }
                if (!staffSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final staff = staffSnapshot.data!
                    .where((item) => item.isActive)
                    .toList(growable: false);
                if (staff.isEmpty) {
                  return const _Message(
                    title: 'Add staff accounts first',
                    body:
                        'Academic responsibilities attach to existing staff accounts. One account can hold several responsibilities; do not create duplicate accounts for each role.',
                  );
                }

                return StreamBuilder<List<CurriculumAssignment>>(
                  stream: _curriculumRepository.watchAssignments(),
                  builder: (context, curriculumSnapshot) {
                    if (curriculumSnapshot.hasError) {
                      return _Message(
                        title: 'Could not load curriculum assignments',
                        body: curriculumSnapshot.error.toString(),
                      );
                    }
                    if (!curriculumSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final curriculum = curriculumSnapshot.data!
                        .where(
                          (item) =>
                              item.isActive &&
                              item.academicYearId == currentYear.id,
                        )
                        .toList(growable: false);

                    return StreamBuilder<List<TeachingAssignment>>(
                      stream: _assignmentRepository.watchAssignments(),
                      builder: (context, assignmentSnapshot) {
                        if (assignmentSnapshot.hasError) {
                          return _Message(
                            title: 'Could not load assignments',
                            body: assignmentSnapshot.error.toString(),
                          );
                        }
                        if (!assignmentSnapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        final assignments = assignmentSnapshot.data!
                            .where(
                              (item) =>
                                  item.isActive &&
                                  item.academicYearId == currentYear.id,
                            )
                            .toList(growable: false);

                        return _AssignmentList(
                          structure: structure,
                          staff: staff,
                          assignments: assignments,
                          onAdd: () => _showAssignmentForm(
                            context,
                            structure,
                            staff,
                            curriculum,
                            currentYear.id,
                          ),
                          onEdit: (assignment) => _showAssignmentForm(
                            context,
                            structure,
                            staff,
                            curriculum,
                            currentYear.id,
                            existing: assignment,
                          ),
                          onEnd: (assignment) async {
                            try {
                              await _assignmentRepository.endAssignment(
                                assignment.id,
                              );
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(content: Text(error.toString())),
                                  );
                              }
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
  }

  Future<void> _showAssignmentForm(
    BuildContext context,
    StructureState structure,
    List<UserEntity> staff,
    List<CurriculumAssignment> curriculum,
    String academicYearId, {
    TeachingAssignment? existing,
  }) async {
    var responsibility =
        existing?.responsibilityType ??
        TeachingResponsibilityType.subjectTeacher;
    var staffId = existing?.staffId ?? staff.first.id;
    var departmentId = existing?.departmentId ?? '';
    var classId = existing?.classId ?? '';
    var streamId = existing?.streamId ?? '';
    var subjectId = existing?.subjectId ?? '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final classes = structure.classes
              .where((item) => item.isActive)
              .toList(growable: false);
          final departments = structure.departments
              .where((item) => item.isActive)
              .toList(growable: false);
          final streams = structure.streams
              .where((item) => item.isActive && item.classId == classId)
              .toList(growable: false);
          if (streamId.isNotEmpty &&
              !streams.any((item) => item.id == streamId)) {
            streamId = '';
          }

          final allowedSubjectIds = curriculum
              .where(
                (item) =>
                    item.classId == classId &&
                    (item.streamId.isEmpty ||
                        streamId.isEmpty ||
                        item.streamId == streamId),
              )
              .map((item) => item.subjectId)
              .toSet();
          final subjects = structure.subjects
              .where(
                (item) => item.isActive && allowedSubjectIds.contains(item.id),
              )
              .toList(growable: false);
          if (subjectId.isNotEmpty &&
              !subjects.any((item) => item.id == subjectId)) {
            subjectId = '';
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              20,
              20,
              MediaQuery.of(context).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    existing == null
                        ? 'Assign Academic Responsibility'
                        : 'Edit Academic Responsibility',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'The same staff account can receive several responsibilities. Subject Teacher, Class Teacher and HOD are assignments, not separate logins.',
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<TeachingResponsibilityType>(
                    key: ValueKey('responsibility-${responsibility.name}'),
                    initialValue: responsibility,
                    decoration: const InputDecoration(
                      labelText: 'Responsibility *',
                    ),
                    items: TeachingResponsibilityType.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(_responsibilityLabel(item)),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        responsibility = value;
                        departmentId = '';
                        classId = '';
                        streamId = '';
                        subjectId = '';
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey('staff-$staffId'),
                    initialValue: staffId,
                    decoration: const InputDecoration(labelText: 'Staff *'),
                    items: staff
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => staffId = value ?? staffId,
                  ),
                  if (responsibility ==
                      TeachingResponsibilityType.headOfDepartment) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('department-$departmentId'),
                      initialValue: departmentId.isEmpty ? null : departmentId,
                      decoration: const InputDecoration(
                        labelText: 'Department *',
                      ),
                      items: departments
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => departmentId = value ?? '',
                    ),
                    if (departments.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text(
                          'No active departments exist. Configure departments first or do not assign an HOD.',
                        ),
                      ),
                  ] else ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      key: ValueKey('class-$classId'),
                      initialValue: classId.isEmpty ? null : classId,
                      decoration: const InputDecoration(labelText: 'Class *'),
                      items: classes
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setSheetState(() {
                          classId = value ?? '';
                          streamId = '';
                          subjectId = '';
                        });
                      },
                    ),
                    if (streams.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('stream-$classId-$streamId'),
                        initialValue: streamId,
                        decoration: const InputDecoration(
                          labelText: 'Stream / Section',
                        ),
                        items: [
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
                        onChanged: (value) =>
                            setSheetState(() => streamId = value ?? ''),
                      ),
                    ],
                    if (responsibility ==
                        TeachingResponsibilityType.subjectTeacher) ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        key: ValueKey('subject-$classId-$streamId-$subjectId'),
                        initialValue: subjectId.isEmpty ? null : subjectId,
                        decoration: const InputDecoration(
                          labelText: 'Subject *',
                        ),
                        items: subjects
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.id,
                                child: Text(item.name),
                              ),
                            )
                            .toList(),
                        onChanged: (value) => subjectId = value ?? '',
                      ),
                      if (classId.isNotEmpty && subjects.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'No curriculum subject is allocated to this class/stream yet. Complete Curriculum / Subject Allocation first.',
                          ),
                        ),
                    ],
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        try {
                          await _assignmentRepository.saveAssignment(
                            TeachingAssignment(
                              id: existing?.id ?? const Uuid().v4(),
                              staffId: staffId,
                              academicYearId: academicYearId,
                              responsibilityType: responsibility,
                              departmentId: departmentId,
                              classId: classId,
                              streamId: streamId,
                              subjectId: subjectId,
                              isPrimary:
                                  responsibility ==
                                  TeachingResponsibilityType.classTeacher,
                            ),
                          );
                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                        } catch (error) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context)
                              ..hideCurrentSnackBar()
                              ..showSnackBar(
                                SnackBar(content: Text(error.toString())),
                              );
                          }
                        }
                      },
                      child: const Text('Save Assignment'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AssignmentList extends StatelessWidget {
  final StructureState structure;
  final List<UserEntity> staff;
  final List<TeachingAssignment> assignments;
  final VoidCallback onAdd;
  final ValueChanged<TeachingAssignment> onEdit;
  final ValueChanged<TeachingAssignment> onEnd;

  const _AssignmentList({
    required this.structure,
    required this.staff,
    required this.assignments,
    required this.onAdd,
    required this.onEdit,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    final staffById = {for (final item in staff) item.id: item};
    final classesById = {for (final item in structure.classes) item.id: item};
    final streamsById = {for (final item in structure.streams) item.id: item};
    final subjectsById = {for (final item in structure.subjects) item.id: item};
    final departmentsById = {
      for (final item in structure.departments) item.id: item,
    };

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Assign real staff only after the academic structure exists. A person can be a Subject Teacher for many classes while also being a Class Teacher, HOD, Patron, Bursar or another system role.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ),
            Expanded(
              child: assignments.isEmpty
                  ? const _Message(
                      title: 'No academic responsibilities assigned',
                      body:
                          'Assign Subject Teachers, Class Teachers and Heads of Department without creating duplicate staff accounts.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                      itemCount: assignments.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final assignment = assignments[index];
                        return Card(
                          child: ListTile(
                            title: Text(
                              staffById[assignment.staffId]?.name ??
                                  'Missing staff account',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle: Text(
                              [
                                _responsibilityLabel(
                                  assignment.responsibilityType,
                                ),
                                if (assignment.departmentId.isNotEmpty)
                                  departmentsById[assignment.departmentId]
                                          ?.name ??
                                      'Missing department',
                                if (assignment.classId.isNotEmpty)
                                  classesById[assignment.classId]?.name ??
                                      'Missing class',
                                if (assignment.streamId.isNotEmpty)
                                  streamsById[assignment.streamId]?.name ??
                                      'Missing stream',
                                if (assignment.subjectId.isNotEmpty)
                                  subjectsById[assignment.subjectId]?.name ??
                                      'Missing subject',
                              ].join(' • '),
                            ),
                            trailing: PopupMenuButton<String>(
                              onSelected: (action) {
                                if (action == 'edit') {
                                  onEdit(assignment);
                                } else {
                                  onEnd(assignment);
                                }
                              },
                              itemBuilder: (_) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                PopupMenuItem(
                                  value: 'end',
                                  child: Text('End assignment'),
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
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Assign Responsibility'),
          ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String title;
  final String body;

  const _Message({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.badge_outlined, size: 46),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

String _responsibilityLabel(TeachingResponsibilityType type) {
  return switch (type) {
    TeachingResponsibilityType.subjectTeacher => 'Subject Teacher',
    TeachingResponsibilityType.classTeacher => 'Class Teacher',
    TeachingResponsibilityType.headOfDepartment => 'Head of Department',
  };
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/class_timetable_repository_impl.dart';
import '../../data/repositories/curriculum_assignment_repository_impl.dart';
import '../../data/repositories/structure_people_readiness_repository_impl.dart';
import '../../data/repositories/teaching_assignment_repository_impl.dart';
import '../../domain/entities/class_timetable_entities.dart';
import '../../domain/entities/curriculum_assignment.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/teaching_assignment.dart';
import '../../domain/entities/timetable_config.dart';
import '../../domain/repositories/class_timetable_repository.dart';
import '../../domain/repositories/curriculum_assignment_repository.dart';
import '../../domain/repositories/structure_people_readiness_repository.dart';
import '../../domain/repositories/teaching_assignment_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

class ClassTimetableScreen extends StatefulWidget {
  const ClassTimetableScreen({super.key});

  @override
  State<ClassTimetableScreen> createState() => _ClassTimetableScreenState();
}

class _ClassTimetableScreenState extends State<ClassTimetableScreen> {
  late final StructureTenantResolver _tenantResolver;
  late final ClassTimetableRepository _timetableRepository;
  late final CurriculumAssignmentRepository _curriculumRepository;
  late final TeachingAssignmentRepository _teachingAssignmentRepository;
  late final StructurePeopleReadinessRepository _peopleRepository;
  late final Future<String> _schoolId;

  @override
  void initState() {
    super.initState();
    final firestore = FirebaseFirestore.instance;
    _tenantResolver = StructureTenantResolver(firestore: firestore);
    _timetableRepository = ClassTimetableRepositoryImpl(
      firestore: firestore,
      tenantResolver: _tenantResolver,
    );
    _curriculumRepository = CurriculumAssignmentRepositoryImpl(
      firestore: firestore,
      tenantResolver: _tenantResolver,
    );
    _teachingAssignmentRepository = TeachingAssignmentRepositoryImpl(
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
    return Scaffold(
      appBar: AppBar(title: const Text('Class Timetables')),
      body: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, structure) {
          final currentYear = structure.academicYears
              .where((item) => item.isCurrent && !item.isArchived)
              .firstOrNull;
          final currentTerm = structure.academicTerms
              .where(
                (item) =>
                    item.isCurrent &&
                    currentYear != null &&
                    item.academicYearId == currentYear.id,
              )
              .firstOrNull;

          if (currentYear == null || currentTerm == null) {
            return const _EmptyMessage(
              title: 'Current year and term required',
              body:
                  'Set the current academic year and term before building class timetables.',
            );
          }

          final teachingSlots = structure.timetableConfig.slots
              .where((slot) => slot.type == 'period')
              .toList(growable: false);
          if (teachingSlots.isEmpty) {
            return const _EmptyMessage(
              title: 'School day required',
              body:
                  'Configure teaching periods, breaks and lunch before building class timetables.',
            );
          }

          return StreamBuilder<List<ClassTimetable>>(
            stream: _timetableRepository.watchTimetables(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _EmptyMessage(
                  title: 'Could not load timetables',
                  body: snapshot.error.toString(),
                );
              }
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final timetables = snapshot.data!
                  .where(
                    (item) =>
                        item.academicYearId == currentYear.id &&
                        item.termId == currentTerm.id,
                  )
                  .toList()
                ..sort((a, b) => a.name.compareTo(b.name));

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      '${currentYear.name} • ${currentTerm.name}\n'
                      'Create one timetable per class or stream. Class, teacher and room collisions are rejected before save and rechecked before publishing.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ),
                  Expanded(
                    child: timetables.isEmpty
                        ? const _EmptyMessage(
                            title: 'No class timetables yet',
                            body:
                                'Create a draft timetable, assign lessons, then publish after all collision checks pass.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: timetables.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final timetable = timetables[index];
                              final schoolClass = structure.classes
                                  .where(
                                    (item) => item.id == timetable.classId,
                                  )
                                  .firstOrNull;
                              final stream = structure.streams
                                  .where(
                                    (item) => item.id == timetable.streamId,
                                  )
                                  .firstOrNull;
                              return Card(
                                child: ListTile(
                                  leading: Icon(
                                    timetable.status ==
                                            ClassTimetableStatus.active
                                        ? Icons.check_circle_outline
                                        : timetable.status ==
                                                ClassTimetableStatus.archived
                                            ? Icons.archive_outlined
                                            : Icons.edit_calendar_outlined,
                                  ),
                                  title: Text(
                                    timetable.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text([
                                    schoolClass?.name ?? 'Missing class',
                                    if (stream != null) stream.name,
                                    timetable.status.name.toUpperCase(),
                                  ].join(' • ')),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => _TimetableBuilderScreen(
                                        timetable: timetable,
                                        structure: structure,
                                        timetableRepository:
                                            _timetableRepository,
                                        curriculumRepository:
                                            _curriculumRepository,
                                        teachingAssignmentRepository:
                                            _teachingAssignmentRepository,
                                        peopleRepository: _peopleRepository,
                                        schoolId: _schoolId,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
      floatingActionButton: BlocBuilder<StructureBloc, StructureState>(
        builder: (context, structure) {
          final year = structure.academicYears
              .where((item) => item.isCurrent && !item.isArchived)
              .firstOrNull;
          final term = structure.academicTerms
              .where(
                (item) =>
                    item.isCurrent &&
                    year != null &&
                    item.academicYearId == year.id,
              )
              .firstOrNull;
          final canCreate = year != null &&
              term != null &&
              structure.classes.any((item) => item.isActive);
          return FloatingActionButton.extended(
            onPressed: canCreate
                ? () => _createTimetable(context, structure, year, term)
                : null,
            icon: const Icon(Icons.add),
            label: const Text('Create Timetable'),
          );
        },
      ),
    );
  }

  Future<void> _createTimetable(
    BuildContext context,
    StructureState structure,
    AcademicYear year,
    AcademicTerm term,
  ) async {
    final classes = structure.classes.where((item) => item.isActive).toList();
    if (classes.isEmpty) return;

    var classId = classes.first.id;
    var streamId = '';
    final nameController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final streams = structure.streams
              .where((item) => item.isActive && item.classId == classId)
              .toList();
          if (streamId.isNotEmpty &&
              !streams.any((item) => item.id == streamId)) {
            streamId = '';
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
                    'Create Class Timetable',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey('class-$classId'),
                    initialValue: classId,
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
                      if (value == null) return;
                      setSheetState(() {
                        classId = value;
                        streamId = '';
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Timetable name *',
                      hintText: 'e.g. S1 Blue — Term 1',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final name = nameController.text.trim();
                        if (name.isEmpty) return;
                        try {
                          final schoolId = await _schoolId;
                          await _timetableRepository.saveTimetable(
                            ClassTimetable(
                              id: const Uuid().v4(),
                              schoolId: schoolId,
                              academicYearId: year.id,
                              termId: term.id,
                              classId: classId,
                              streamId: streamId,
                              name: name,
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
                      child: const Text('Create Draft'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    nameController.dispose();
  }
}

class _TimetableBuilderScreen extends StatelessWidget {
  final ClassTimetable timetable;
  final StructureState structure;
  final ClassTimetableRepository timetableRepository;
  final CurriculumAssignmentRepository curriculumRepository;
  final TeachingAssignmentRepository teachingAssignmentRepository;
  final StructurePeopleReadinessRepository peopleRepository;
  final Future<String> schoolId;

  const _TimetableBuilderScreen({
    required this.timetable,
    required this.structure,
    required this.timetableRepository,
    required this.curriculumRepository,
    required this.teachingAssignmentRepository,
    required this.peopleRepository,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: schoolId,
      builder: (context, schoolSnapshot) {
        if (schoolSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text(timetable.name)),
            body: _EmptyMessage(
              title: 'School context unavailable',
              body: schoolSnapshot.error.toString(),
            ),
          );
        }
        if (!schoolSnapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text(timetable.name)),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<List<CurriculumAssignment>>(
          stream: curriculumRepository.watchAssignments(),
          builder: (context, curriculumSnapshot) {
            if (!curriculumSnapshot.hasData) {
              return Scaffold(
                appBar: AppBar(title: Text(timetable.name)),
                body: const Center(child: CircularProgressIndicator()),
              );
            }
            final curriculum = curriculumSnapshot.data!
                .where(
                  (item) =>
                      item.isActive &&
                      item.academicYearId == timetable.academicYearId &&
                      item.classId == timetable.classId &&
                      (item.streamId.isEmpty ||
                          item.streamId == timetable.streamId),
                )
                .toList();

            return StreamBuilder<List<TeachingAssignment>>(
              stream: teachingAssignmentRepository.watchAssignments(),
              builder: (context, assignmentSnapshot) {
                if (!assignmentSnapshot.hasData) {
                  return Scaffold(
                    appBar: AppBar(title: Text(timetable.name)),
                    body: const Center(child: CircularProgressIndicator()),
                  );
                }
                final assignments = assignmentSnapshot.data!
                    .where(
                      (item) =>
                          item.isActive &&
                          item.academicYearId == timetable.academicYearId &&
                          item.responsibilityType ==
                              TeachingResponsibilityType.subjectTeacher &&
                          item.classId == timetable.classId &&
                          (item.streamId.isEmpty ||
                              item.streamId == timetable.streamId),
                    )
                    .toList();

                return StreamBuilder<List<UserEntity>>(
                  stream: peopleRepository.watchSchoolStaff(
                    schoolSnapshot.data!,
                  ),
                  builder: (context, peopleSnapshot) {
                    if (!peopleSnapshot.hasData) {
                      return Scaffold(
                        appBar: AppBar(title: Text(timetable.name)),
                        body: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    final staff = peopleSnapshot.data!;

                    return StreamBuilder<List<ClassTimetableLesson>>(
                      stream: timetableRepository.watchLessons(),
                      builder: (context, lessonSnapshot) {
                        if (!lessonSnapshot.hasData) {
                          return Scaffold(
                            appBar: AppBar(title: Text(timetable.name)),
                            body: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        final lessons = lessonSnapshot.data!
                            .where(
                              (item) =>
                                  item.isActive &&
                                  item.timetableId == timetable.id,
                            )
                            .toList();

                        return Scaffold(
                          appBar: AppBar(
                            title: Text(timetable.name),
                            actions: [
                              if (timetable.status !=
                                  ClassTimetableStatus.archived)
                                TextButton(
                                  onPressed: () => _publish(context),
                                  child: const Text('Publish'),
                                ),
                            ],
                          ),
                          body: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              Text(
                                '${timetable.status.name.toUpperCase()} • ${lessons.length} lesson(s)',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 16),
                              for (final day
                                  in structure.timetableConfig.teachingDays)
                                _DaySchedule(
                                  day: day,
                                  config: structure.timetableConfig,
                                  lessons: lessons,
                                  structure: structure,
                                  staff: staff,
                                  onAddLesson: (slot) => _addLesson(
                                    context,
                                    day,
                                    slot,
                                    curriculum,
                                    assignments,
                                    staff,
                                  ),
                                  onDeleteLesson: (lesson) =>
                                      timetableRepository.deleteLesson(
                                    lesson.id,
                                  ),
                                ),
                            ],
                          ),
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

  Future<void> _publish(BuildContext context) async {
    try {
      await timetableRepository.publishTimetable(timetable.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Timetable published.')),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(error.toString())));
      }
    }
  }

  Future<void> _addLesson(
    BuildContext context,
    String day,
    TimetableSlot slot,
    List<CurriculumAssignment> curriculum,
    List<TeachingAssignment> assignments,
    List<UserEntity> staff,
  ) async {
    if (curriculum.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Allocate subjects to this class/stream in Curriculum first.',
          ),
        ),
      );
      return;
    }

    final subjectsById = {for (final item in structure.subjects) item.id: item};
    final staffById = {for (final item in staff) item.id: item};
    var curriculumId = curriculum.first.id;
    var roomId = '';
    String? teacherId;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final selectedCurriculum = curriculum
              .where((item) => item.id == curriculumId)
              .first;
          final eligibleAssignments = assignments
              .where(
                (item) => item.subjectId == selectedCurriculum.subjectId,
              )
              .toList();
          final eligibleStaff = eligibleAssignments
              .map((item) => staffById[item.staffId])
              .whereType<UserEntity>()
              .where((item) => item.isActive)
              .toSet()
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

          if (teacherId != null &&
              !eligibleStaff.any((item) => item.id == teacherId)) {
            teacherId = null;
          }
          teacherId ??= eligibleStaff.firstOrNull?.id;

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
                    '$day • ${slot.startTime}-${slot.endTime}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    key: ValueKey('subject-$curriculumId'),
                    initialValue: curriculumId,
                    decoration: const InputDecoration(labelText: 'Subject *'),
                    items: curriculum
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(
                              subjectsById[item.subjectId]?.name ??
                                  'Missing subject',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setSheetState(() {
                        curriculumId = value;
                        teacherId = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (eligibleStaff.isEmpty)
                    const Text(
                      'No Subject Teacher is assigned to this subject and class/stream. Complete Academic Staff Assignments first.',
                    )
                  else
                    DropdownButtonFormField<String>(
                      key: ValueKey('teacher-$curriculumId-$teacherId'),
                      initialValue: teacherId,
                      decoration: const InputDecoration(labelText: 'Teacher *'),
                      items: eligibleStaff
                          .map(
                            (user) => DropdownMenuItem(
                              value: user.id,
                              child: Text(user.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) => teacherId = value,
                    ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    key: ValueKey('room-$roomId'),
                    initialValue: roomId,
                    decoration: const InputDecoration(
                      labelText: 'Room / Learning Space',
                    ),
                    items: [
                      const DropdownMenuItem(
                        value: '',
                        child: Text('No room assignment'),
                      ),
                      ...structure.facilities
                          .where((item) => item.isActive)
                          .map(
                            (item) => DropdownMenuItem(
                              value: item.id,
                              child: Text(item.name),
                            ),
                          ),
                    ],
                    onChanged: (value) => roomId = value ?? '',
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: eligibleStaff.isEmpty
                          ? null
                          : () async {
                              final selectedTeacherId = teacherId;
                              if (selectedTeacherId == null ||
                                  selectedTeacherId.isEmpty) {
                                return;
                              }
                              final selected = curriculum
                                  .where((item) => item.id == curriculumId)
                                  .first;
                              try {
                                final resolvedSchoolId = await schoolId;
                                await timetableRepository.saveLesson(
                                  ClassTimetableLesson(
                                    id: const Uuid().v4(),
                                    schoolId: resolvedSchoolId,
                                    timetableId: timetable.id,
                                    academicYearId: timetable.academicYearId,
                                    termId: timetable.termId,
                                    classId: timetable.classId,
                                    streamId: timetable.streamId,
                                    day: day,
                                    slotKey:
                                        '${slot.name}|${slot.startTime}|${slot.endTime}',
                                    startTime: slot.startTime,
                                    endTime: slot.endTime,
                                    subjectId: selected.subjectId,
                                    teacherId: selectedTeacherId,
                                    roomId: roomId,
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
                      child: const Text('Save Lesson'),
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

class _DaySchedule extends StatelessWidget {
  final String day;
  final TimetableConfig config;
  final List<ClassTimetableLesson> lessons;
  final StructureState structure;
  final List<UserEntity> staff;
  final ValueChanged<TimetableSlot> onAddLesson;
  final ValueChanged<ClassTimetableLesson> onDeleteLesson;

  const _DaySchedule({
    required this.day,
    required this.config,
    required this.lessons,
    required this.structure,
    required this.staff,
    required this.onAddLesson,
    required this.onDeleteLesson,
  });

  @override
  Widget build(BuildContext context) {
    final subjectsById = {for (final item in structure.subjects) item.id: item};
    final staffById = {for (final item in staff) item.id: item};
    final roomsById = {for (final item in structure.facilities) item.id: item};

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              day,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 10),
            for (var i = 0; i < config.slots.length; i++) ...[
              Builder(
                builder: (context) {
                  final slot = config.slots[i];
                  final lesson = lessons
                      .where(
                        (item) =>
                            item.day == day &&
                            item.startTime == slot.startTime &&
                            item.endTime == slot.endTime,
                      )
                      .firstOrNull;
                  final teachingSlot = slot.type == 'period';

                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: SizedBox(
                      width: 82,
                      child: Text('${slot.startTime}\n${slot.endTime}'),
                    ),
                    title: lesson == null
                        ? Text(teachingSlot ? 'Unassigned lesson' : slot.name)
                        : Text(
                            subjectsById[lesson.subjectId]?.name ??
                                'Missing subject',
                          ),
                    subtitle: lesson == null
                        ? Text(teachingSlot ? slot.name : _pretty(slot.type))
                        : Text([
                            staffById[lesson.teacherId]?.name ??
                                'Missing teacher',
                            if (lesson.roomId.isNotEmpty)
                              roomsById[lesson.roomId]?.name ?? 'Missing room',
                          ].join(' • ')),
                    trailing: !teachingSlot
                        ? null
                        : lesson == null
                            ? IconButton(
                                tooltip: 'Assign lesson',
                                icon: const Icon(Icons.add_circle_outline),
                                onPressed: () => onAddLesson(slot),
                              )
                            : IconButton(
                                tooltip: 'Remove lesson',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => onDeleteLesson(lesson),
                              ),
                  );
                },
              ),
              if (i < config.slots.length - 1) const Divider(height: 1),
            ],
          ],
        ),
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  final String title;
  final String body;

  const _EmptyMessage({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calendar_view_week_outlined, size: 48),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
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

String _pretty(String raw) {
  if (raw.isEmpty) return raw;
  return '${raw[0].toUpperCase()}${raw.substring(1).replaceAll('_', ' ')}';
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

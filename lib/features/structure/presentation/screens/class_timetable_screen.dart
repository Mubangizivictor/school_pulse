import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:school_pulse/core/user_roles.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:uuid/uuid.dart';
import '../../data/repositories/class_timetable_repository_impl.dart';
import '../../data/repositories/curriculum_assignment_repository_impl.dart';
import '../../data/repositories/structure_people_readiness_repository_impl.dart';
import '../../domain/entities/class_timetable_entities.dart';
import '../../domain/entities/curriculum_assignment.dart';
import '../../domain/entities/structure_entities.dart';
import '../../domain/entities/timetable_config.dart';
import '../../domain/repositories/class_timetable_repository.dart';
import '../../domain/repositories/curriculum_assignment_repository.dart';
import '../../domain/repositories/structure_people_readiness_repository.dart';
import '../../domain/services/structure_tenant_resolver.dart';
import '../bloc/structure_bloc.dart';
import '../bloc/structure_state.dart';

class ClassTimetableScreen extends StatefulWidget {
  const ClassTimetableScreen({super.key});

  @override
  State<ClassTimetableScreen> createState() => _ClassTimetableScreenState();
}

class _ClassTimetableScreenState extends State<ClassTimetableScreen> {
  late final FirebaseFirestore _firestore;
  late final StructureTenantResolver _tenantResolver;
  late final ClassTimetableRepository _timetableRepository;
  late final CurriculumAssignmentRepository _curriculumRepository;
  late final StructurePeopleReadinessRepository _peopleRepository;
  late final Future<String> _schoolId;

  @override
  void initState() {
    super.initState();
    _firestore = FirebaseFirestore.instance;
    _tenantResolver = StructureTenantResolver(firestore: _firestore);
    _timetableRepository = ClassTimetableRepositoryImpl(
      firestore: _firestore,
      tenantResolver: _tenantResolver,
    );
    _curriculumRepository = CurriculumAssignmentRepositoryImpl(
      firestore: _firestore,
      tenantResolver: _tenantResolver,
    );
    _peopleRepository = StructurePeopleReadinessRepositoryImpl(
      firestore: _firestore,
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
          if (structure.timetableConfig.slots
              .where((slot) => slot.type == 'period')
              .isEmpty) {
            return const _EmptyMessage(
              title: 'School day required',
              body:
                  'Configure teaching periods, breaks and lunch before building class timetables.',
            );
          }

          return StreamBuilder<List<ClassTimetable>>(
            stream: _timetableRepository.watchTimetables(),
            builder: (context, timetableSnapshot) {
              if (timetableSnapshot.hasError) {
                return _EmptyMessage(
                  title: 'Could not load timetables',
                  body: timetableSnapshot.error.toString(),
                );
              }
              if (!timetableSnapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = timetableSnapshot.data!
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
                      '${currentYear.name} • ${currentTerm.name}\nCreate one timetable for each class or stream. Teacher, class and room conflicts are checked before a lesson saves and again before publishing.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                    ),
                  ),
                  Expanded(
                    child: items.isEmpty
                        ? const _EmptyMessage(
                            title: 'No class timetables yet',
                            body:
                                'Create the first class/stream timetable. It starts as a draft until conflict validation passes.',
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final schoolClass = structure.classes
                                  .where((value) => value.id == item.classId)
                                  .firstOrNull;
                              final stream = structure.streams
                                  .where((value) => value.id == item.streamId)
                                  .firstOrNull;
                              return Card(
                                child: ListTile(
                                  leading: Icon(
                                    item.status == ClassTimetableStatus.active
                                        ? Icons.check_circle_outline
                                        : item.status ==
                                                ClassTimetableStatus.archived
                                            ? Icons.archive_outlined
                                            : Icons.edit_calendar_outlined,
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  subtitle: Text([
                                    schoolClass?.name ?? 'Missing class',
                                    if (stream != null) stream.name,
                                    item.status.name,
                                  ].join(' • ')),
                                  trailing: const Icon(Icons.chevron_right),
                                  onTap: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => _TimetableBuilderScreen(
                                        timetable: item,
                                        structure: structure,
                                        timetableRepository:
                                            _timetableRepository,
                                        curriculumRepository:
                                            _curriculumRepository,
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
          final canCreate = currentYear != null &&
              currentTerm != null &&
              structure.classes.any((item) => item.isActive);
          return FloatingActionButton.extended(
            onPressed: canCreate
                ? () => _createTimetable(
                      context,
                      structure,
                      currentYear,
                      currentTerm!,
                    )
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
    final activeClasses =
        structure.classes.where((item) => item.isActive).toList();
    var classId = activeClasses.first.id;
    var streamId = '';
    final name = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final classStreams = structure.streams
              .where((item) => item.classId == classId && item.isActive)
              .toList();
          if (streamId.isNotEmpty &&
              !classStreams.any((item) => item.id == streamId)) {
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
                    value: classId,
                    decoration: const InputDecoration(labelText: 'Class *'),
                    items: activeClasses
                        .map(
                          (item) => DropdownMenuItem(
                            value: item.id,
                            child: Text(item.name),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() {
                          classId = value;
                          streamId = '';
                        });
                      }
                    },
                  ),
                  if (classStreams.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: streamId,
                      decoration: const InputDecoration(
                        labelText: 'Stream / Section',
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: '',
                          child: Text('Whole class'),
                        ),
                        ...classStreams.map(
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
                    controller: name,
                    decoration: const InputDecoration(
                      labelText: 'Timetable Name *',
                      hintText: 'e.g. S1 Blue — Term 1',
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        final title = name.text.trim();
                        if (title.isEmpty) return;
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
                              name: title,
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
    name.dispose();
  }
}

class _TimetableBuilderScreen extends StatelessWidget {
  final ClassTimetable timetable;
  final StructureState structure;
  final ClassTimetableRepository timetableRepository;
  final CurriculumAssignmentRepository curriculumRepository;
  final StructurePeopleReadinessRepository peopleRepository;
  final Future<String> schoolId;

  const _TimetableBuilderScreen({
    required this.timetable,
    required this.structure,
    required this.timetableRepository,
    required this.curriculumRepository,
    required this.peopleRepository,
    required this.schoolId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: schoolId,
      builder: (context, schoolSnapshot) {
        if (!schoolSnapshot.hasData) {
          if (schoolSnapshot.hasError) {
            return Scaffold(
              appBar: AppBar(title: Text(timetable.name)),
              body: _EmptyMessage(
                title: 'School context unavailable',
                body: schoolSnapshot.error.toString(),
              ),
            );
          }
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
                      item.academicYearId == timetable.academicYearId &&
                      item.classId == timetable.classId &&
                      (item.streamId.isEmpty ||
                          item.streamId == timetable.streamId),
                )
                .toList();
            return StreamBuilder<List<UserEntity>>(
              stream: peopleRepository.watchSchoolStaff(schoolSnapshot.data!),
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
                        body: const Center(child: CircularProgressIndicator()),
                      );
                    }
                    final lessons = lessonSnapshot.data!
                        .where((item) => item.timetableId == timetable.id)
                        .toList();
                    return Scaffold(
                      appBar: AppBar(
                        title: Text(timetable.name),
                        actions: [
                          if (timetable.status != ClassTimetableStatus.archived)
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
                          for (final day in structure.timetableConfig.teachingDays)
                            _DaySchedule(
                              day: day,
                              config: structure.timetableConfig,
                              lessons: lessons,
                              structure: structure,
                              curriculum: curriculum,
                              staff: staff,
                              onAddLesson: (slot) => _addLesson(
                                context,
                                day,
                                slot,
                                curriculum,
                                staff,
                              ),
                              onDeleteLesson: (lesson) =>
                                  timetableRepository.deleteLesson(lesson.id),
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
    final subjectById = {
      for (final item in structure.subjects) item.id: item,
    };
    final className = structure.classes
            .where((item) => item.id == timetable.classId)
            .firstOrNull
            ?.name ??
        '';
    var curriculumId = curriculum.first.id;
    var roomId = '';

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) {
          final selectedAllocation = curriculum
              .where((item) => item.id == curriculumId)
              .first;
          final subject = subjectById[selectedAllocation.subjectId];
          final explicitlyAssigned = staff.where((user) {
            if (!user.roles.contains(UserRole.teacher)) return false;
            return user.subjects.any(
              (assignment) =>
                  assignment.subjectName.trim().toLowerCase() ==
                      (subject?.name ?? '').trim().toLowerCase() &&
                  assignment.className.trim().toLowerCase() ==
                      className.trim().toLowerCase(),
            );
          }).toList();
          final fallbackTeachers = staff
              .where((user) => user.roles.contains(UserRole.teacher))
              .toList();
          final eligibleTeachers = explicitlyAssigned.isNotEmpty
              ? explicitlyAssigned
              : fallbackTeachers;
          String? teacherId =
              eligibleTeachers.isEmpty ? null : eligibleTeachers.first.id;

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
                    value: curriculumId,
                    decoration: const InputDecoration(labelText: 'Subject *'),
                    items: curriculum.map((item) {
                      final itemSubject = subjectById[item.subjectId];
                      return DropdownMenuItem(
                        value: item.id,
                        child: Text(itemSubject?.name ?? 'Missing subject'),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setSheetState(() => curriculumId = value);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  if (eligibleTeachers.isEmpty)
                    const Text(
                      'No staff account with the Teacher role exists. Add staff before scheduling this lesson.',
                    )
                  else
                    DropdownButtonFormField<String>(
                      key: ValueKey('$curriculumId-${eligibleTeachers.length}'),
                      value: teacherId,
                      decoration: InputDecoration(
                        labelText: 'Teacher *',
                        helperText: explicitlyAssigned.isEmpty
                            ? 'No explicit subject assignment was found, so active teacher accounts are shown.'
                            : 'Filtered from the teacher’s subject/class assignments.',
                      ),
                      items: eligibleTeachers
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
                    value: roomId,
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
                      onPressed: eligibleTeachers.isEmpty
                          ? null
                          : () async {
                              final chosenTeacher = teacherId;
                              if (chosenTeacher == null ||
                                  chosenTeacher.isEmpty) {
                                return;
                              }
                              final allocation = curriculum
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
                                    subjectId: allocation.subjectId,
                                    teacherId: chosenTeacher,
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
  final List<CurriculumAssignment> curriculum;
  final List<UserEntity> staff;
  final ValueChanged<TimetableSlot> onAddLesson;
  final ValueChanged<ClassTimetableLesson> onDeleteLesson;

  const _DaySchedule({
    required this.day,
    required this.config,
    required this.lessons,
    required this.structure,
    required this.curriculum,
    required this.staff,
    required this.onAddLesson,
    required this.onDeleteLesson,
  });

  @override
  Widget build(BuildContext context) {
    final subjectById = {for (final item in structure.subjects) item.id: item};
    final staffById = {for (final item in staff) item.id: item};
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
            for (final slot in config.slots) ...[
              Builder(
                builder: (context) {
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
                            subjectById[lesson.subjectId]?.name ??
                                'Missing subject',
                          ),
                    subtitle: lesson == null
                        ? (teachingSlot ? Text(slot.name) : Text(slot.type))
                        : Text(
                            [
                              staffById[lesson.teacherId]?.name ??
                                  'Missing teacher',
                              if (lesson.roomId.isNotEmpty)
                                structure.facilities
                                        .where(
                                          (item) => item.id == lesson.roomId,
                                        )
                                        .firstOrNull
                                        ?.name ??
                                    'Missing room',
                            ].join(' • '),
                          ),
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
              if (slot != config.slots.last) const Divider(height: 1),
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

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

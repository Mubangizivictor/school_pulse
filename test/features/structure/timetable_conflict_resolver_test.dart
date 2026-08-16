import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable.dart';
import 'package:school_pulse/features/structure/domain/services/timetable_conflict_resolver.dart';

TimetableLesson _lesson({
  String id = '',
  String classId = 'c1',
  String className = 'P5',
  String streamId = '',
  String streamName = '',
  String subjectId = 'math',
  String subjectName = 'Mathematics',
  String teacherId = 't1',
  String teacherName = 'Mr John',
  String? roomId,
  String? roomName,
  String day = 'Monday',
  List<String>? slotIds,
}) {
  return TimetableLesson(
    id: id,
    schoolId: 'sch1',
    timetableId: 'tt1',
    classId: classId,
    className: className,
    streamId: streamId,
    streamName: streamName,
    subjectId: subjectId,
    subjectName: subjectName,
    teacherId: teacherId,
    teacherName: teacherName,
    roomId: roomId,
    roomName: roomName,
    occurrences: (slotIds ?? ['p1'])
        .map((s) => TimetableLessonOccurrence(day: day, slotId: s))
        .toList(),
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  const resolver = TimetableConflictResolver();

  test('no conflicts when the pool is empty', () {
    final candidate = _lesson();
    expect(
      resolver.findConflicts(candidate: candidate, otherLessons: const []),
      isEmpty,
    );
  });

  test('no conflicts for a lesson on a different day or slot', () {
    final candidate = _lesson(day: 'Monday', slotIds: ['p1']);
    final other = _lesson(
      id: 'other',
      streamId: 's2',
      streamName: 'Red',
      day: 'Tuesday',
      slotIds: ['p1'],
    );
    expect(
      resolver.findConflicts(candidate: candidate, otherLessons: [other]),
      isEmpty,
    );
  });

  test('blocks the same teacher teaching two classes at the same time', () {
    // Mr John, Monday 08:00-08:45 (slot p1), teaching S1 Blue Mathematics.
    final existing = _lesson(
      id: 'existing',
      classId: 'S1',
      className: 'S1',
      streamId: 'blue',
      streamName: 'Blue',
      teacherId: 't1',
      teacherName: 'Mr John',
      day: 'Monday',
      slotIds: ['p1'],
    );
    // Attempt: Mr John, Monday same slot, teaching S2 Red Mathematics.
    final candidate = _lesson(
      id: 'candidate',
      classId: 'S2',
      className: 'S2',
      streamId: 'red',
      streamName: 'Red',
      teacherId: 't1',
      teacherName: 'Mr John',
      day: 'Monday',
      slotIds: ['p1'],
    );

    final conflicts = resolver.findConflicts(
      candidate: candidate,
      otherLessons: [existing],
    );

    expect(conflicts, isNotEmpty);
    expect(conflicts.any((c) => c.type == TimetableConflictType.teacher), true);
    expect(conflicts.first.message, contains('Mr John'));
    expect(conflicts.first.message, contains('S1 Blue'));
  });

  test('does not block the same teacher at a different time', () {
    final existing = _lesson(
      id: 'existing',
      teacherId: 't1',
      day: 'Monday',
      slotIds: ['p1'],
    );
    final candidate = _lesson(
      id: 'candidate',
      classId: 'c2',
      className: 'P6',
      teacherId: 't1',
      day: 'Monday',
      slotIds: ['p2'],
    );
    expect(
      resolver.findConflicts(candidate: candidate, otherLessons: [existing]),
      isEmpty,
    );
  });

  test('blocks the same room being double-booked', () {
    final existing = _lesson(
      id: 'existing',
      classId: 'c1',
      teacherId: 't1',
      roomId: 'lab1',
      roomName: 'Chemistry Lab',
      day: 'Monday',
      slotIds: ['p1'],
    );
    final candidate = _lesson(
      id: 'candidate',
      classId: 'c2',
      className: 'P6',
      teacherId: 't2',
      teacherName: 'Ms Jane',
      roomId: 'lab1',
      roomName: 'Chemistry Lab',
      day: 'Monday',
      slotIds: ['p1'],
    );

    final conflicts = resolver.findConflicts(
      candidate: candidate,
      otherLessons: [existing],
    );

    expect(conflicts.any((c) => c.type == TimetableConflictType.room), true);
  });

  test('does not flag a room conflict when no room is assigned', () {
    final existing = _lesson(id: 'existing', day: 'Monday', slotIds: ['p1']);
    final candidate = _lesson(
      id: 'candidate',
      classId: 'c2',
      className: 'P6',
      teacherId: 't2',
      day: 'Monday',
      slotIds: ['p1'],
    );
    final conflicts = resolver.findConflicts(
      candidate: candidate,
      otherLessons: [existing],
    );
    expect(conflicts.any((c) => c.type == TimetableConflictType.room), false);
  });

  test('blocks a class/stream having two subjects in the same slot', () {
    // P5 Blue already has English at Monday p1.
    final existing = _lesson(
      id: 'existing',
      classId: 'p5',
      className: 'P5',
      streamId: 'blue',
      streamName: 'Blue',
      subjectId: 'eng',
      subjectName: 'English',
      teacherId: 't1',
      day: 'Monday',
      slotIds: ['p1'],
    );
    // Attempt to also assign Mathematics to P5 Blue at the same slot.
    final candidate = _lesson(
      id: 'candidate',
      classId: 'p5',
      className: 'P5',
      streamId: 'blue',
      streamName: 'Blue',
      subjectId: 'math',
      subjectName: 'Mathematics',
      teacherId: 't2',
      teacherName: 'Ms Jane',
      day: 'Monday',
      slotIds: ['p1'],
    );

    final conflicts = resolver.findConflicts(
      candidate: candidate,
      otherLessons: [existing],
    );

    expect(
      conflicts.any((c) => c.type == TimetableConflictType.classOrStream),
      true,
    );
  });

  test(
    'a class and its own stream do not conflict with each other on distinct streams',
    () {
      final existing = _lesson(
        id: 'existing',
        classId: 'p5',
        className: 'P5',
        streamId: 'blue',
        streamName: 'Blue',
        day: 'Monday',
        slotIds: ['p1'],
      );
      final candidate = _lesson(
        id: 'candidate',
        classId: 'p5',
        className: 'P5',
        streamId: 'red',
        streamName: 'Red',
        teacherId: 't2',
        day: 'Monday',
        slotIds: ['p1'],
      );
      final conflicts = resolver.findConflicts(
        candidate: candidate,
        otherLessons: [existing],
      );
      expect(
        conflicts.any((c) => c.type == TimetableConflictType.classOrStream),
        false,
      );
    },
  );

  test('a lesson never conflicts with itself when editing in place', () {
    final existing = _lesson(id: 'lesson-1', day: 'Monday', slotIds: ['p1']);
    final edited = existing.copyWith(notes: 'updated notes');
    final conflicts = resolver.findConflicts(
      candidate: edited,
      otherLessons: [existing],
    );
    expect(conflicts, isEmpty);
  });

  test('double lesson validates both consecutive slots', () {
    final existing = _lesson(
      id: 'existing',
      classId: 'c2',
      className: 'P6',
      teacherId: 't2',
      day: 'Monday',
      slotIds: ['p3'],
    );
    // Double practical: Monday p2 and p3, same teacher/room/class throughout.
    final candidate = _lesson(
      id: 'candidate',
      classId: 'c1',
      teacherId: 't1',
      day: 'Monday',
      slotIds: ['p2', 'p3'],
    );
    final conflicts = resolver.findConflicts(
      candidate: candidate,
      otherLessons: [existing],
    );
    // No conflict expected: different teacher, different class, only the
    // room/teacher/class of `existing` would collide if it matched.
    expect(conflicts, isEmpty);
    expect(candidate.isDoubleOrMore, true);
  });

  test('double lesson conflict is reported for each colliding slot', () {
    final existing = _lesson(
      id: 'existing',
      classId: 'c2',
      className: 'P6',
      teacherId: 't1',
      day: 'Monday',
      slotIds: ['p2'],
    );
    final candidate = _lesson(
      id: 'candidate',
      classId: 'c1',
      teacherId: 't1',
      day: 'Monday',
      slotIds: ['p2', 'p3'],
    );
    final conflicts = resolver.findConflicts(
      candidate: candidate,
      otherLessons: [existing],
    );
    expect(conflicts.length, 1);
    expect(conflicts.first.slotId, 'p2');
  });

  test('blocks a teacher scheduled outside their availability', () {
    final candidate = _lesson(day: 'Friday', slotIds: ['p6']);
    final conflicts = resolver.findConflicts(
      candidate: candidate,
      otherLessons: const [],
      teacherAvailabilityBlocks: const [
        TeacherAvailabilityBlock(teacherId: 't1', day: 'Friday', slotId: 'p6'),
      ],
    );
    expect(
      conflicts.any((c) => c.type == TimetableConflictType.teacherAvailability),
      true,
    );
  });

  test('does not block a teacher inside their availability window', () {
    final candidate = _lesson(day: 'Tuesday', slotIds: ['p1']);
    final conflicts = resolver.findConflicts(
      candidate: candidate,
      otherLessons: const [],
      teacherAvailabilityBlocks: const [
        TeacherAvailabilityBlock(teacherId: 't1', day: 'Friday', slotId: 'p6'),
      ],
    );
    expect(conflicts, isEmpty);
  });

  test('scanAll reports conflicts for every affected lesson', () {
    final a = _lesson(id: 'a', teacherId: 't1', day: 'Monday', slotIds: ['p1']);
    final b = _lesson(
      id: 'b',
      classId: 'c2',
      className: 'P6',
      teacherId: 't1',
      day: 'Monday',
      slotIds: ['p1'],
    );
    final c = _lesson(
      id: 'c',
      classId: 'c3',
      className: 'P7',
      teacherId: 't3',
      day: 'Tuesday',
      slotIds: ['p1'],
    );

    final result = resolver.scanAll(lessons: [a, b, c]);

    expect(result.containsKey('a'), true);
    expect(result.containsKey('b'), true);
    expect(result.containsKey('c'), false);
  });

  test('scanAll on a conflict-free set reports nothing', () {
    final a = _lesson(id: 'a', teacherId: 't1', day: 'Monday', slotIds: ['p1']);
    final b = _lesson(
      id: 'b',
      classId: 'c2',
      className: 'P6',
      teacherId: 't2',
      day: 'Monday',
      slotIds: ['p1'],
    );
    expect(resolver.scanAll(lessons: [a, b]), isEmpty);
  });
}

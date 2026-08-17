import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/structure/domain/entities/class_timetable_entities.dart';
import 'package:school_pulse/features/structure/domain/services/timetable_conflict_resolver.dart';

void main() {
  const resolver = TimetableConflictResolver();

  ClassTimetableLesson lesson({
    required String id,
    String classId = 's1',
    String streamId = 'blue',
    String teacherId = 'teacher-john',
    String roomId = 'science-lab',
    String start = '08:00',
    String end = '08:45',
  }) {
    return ClassTimetableLesson(
      id: id,
      schoolId: 'school-a',
      timetableId: 'table-$classId-$streamId',
      academicYearId: '2026',
      termId: 'term-1',
      classId: classId,
      streamId: streamId,
      day: 'Monday',
      slotKey: '$start-$end',
      startTime: start,
      endTime: end,
      subjectId: 'math',
      teacherId: teacherId,
      roomId: roomId,
    );
  }

  test('blocks one teacher teaching two classes at the same time', () {
    final existing = lesson(id: 'one');
    final proposed = lesson(
      id: 'two',
      classId: 's2',
      streamId: 'red',
      roomId: 'room-2',
    );

    final conflicts = resolver.findConflicts(
      proposed: proposed,
      existing: [existing],
    );

    expect(
      conflicts.any((item) => item.type == TimetableConflictType.teacher),
      isTrue,
    );
  });

  test('blocks two lessons for the same class and stream', () {
    final existing = lesson(id: 'one', teacherId: 'teacher-a', roomId: 'room-a');
    final proposed = lesson(id: 'two', teacherId: 'teacher-b', roomId: 'room-b');

    final conflicts = resolver.findConflicts(
      proposed: proposed,
      existing: [existing],
    );

    expect(
      conflicts.any(
        (item) => item.type == TimetableConflictType.classOrStream,
      ),
      isTrue,
    );
  });

  test('blocks a room used by two classes at the same time', () {
    final existing = lesson(id: 'one', teacherId: 'teacher-a');
    final proposed = lesson(
      id: 'two',
      classId: 's2',
      streamId: 'red',
      teacherId: 'teacher-b',
    );

    final conflicts = resolver.findConflicts(
      proposed: proposed,
      existing: [existing],
    );

    expect(
      conflicts.any((item) => item.type == TimetableConflictType.room),
      isTrue,
    );
  });

  test('allows adjacent non-overlapping lessons', () {
    final existing = lesson(id: 'one', start: '08:00', end: '08:45');
    final proposed = lesson(
      id: 'two',
      classId: 's2',
      streamId: 'red',
      start: '08:45',
      end: '09:30',
    );

    expect(
      resolver.findConflicts(proposed: proposed, existing: [existing]),
      isEmpty,
    );
  });

  test('ignores another tenant', () {
    final existing = ClassTimetableLesson(
      id: 'other-school',
      schoolId: 'school-b',
      timetableId: 'table-b',
      academicYearId: '2026',
      termId: 'term-1',
      classId: 's1',
      streamId: 'blue',
      day: 'Monday',
      slotKey: '08:00-08:45',
      startTime: '08:00',
      endTime: '08:45',
      subjectId: 'math',
      teacherId: 'teacher-john',
      roomId: 'science-lab',
    );

    expect(
      resolver.findConflicts(
        proposed: lesson(id: 'school-a'),
        existing: [existing],
      ),
      isEmpty,
    );
  });
}

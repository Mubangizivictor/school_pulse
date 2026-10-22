import 'package:flutter_test/flutter_test.dart';
import 'package:school_pulse/features/parent/presentation/bloc/parent_timetable_bloc.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable.dart';
import 'package:school_pulse/features/structure/domain/entities/timetable_config.dart';

TimetableLesson _lesson({required String subject, String? room}) {
  return TimetableLesson(
    id: 'lesson-$subject',
    schoolId: 'school-1',
    timetableId: 'timetable-1',
    classId: 'class-1',
    subjectId: 'subject-$subject',
    subjectName: subject,
    teacherId: 'teacher-1',
    roomName: room,
    occurrences: const [],
    createdAt: DateTime(2026, 1, 1),
  );
}

TimetableSlot _slot({
  required String id,
  required String start,
  required String end,
}) {
  return TimetableSlot(id: id, name: id, startTime: start, endTime: end);
}

ParentTimetableEntry _entry({
  required String subject,
  required String day,
  required String start,
  required String end,
  String? room,
}) {
  return ParentTimetableEntry(
    lesson: _lesson(subject: subject, room: room),
    day: day,
    slot: _slot(id: '$subject-$day', start: start, end: end),
  );
}

void main() {
  group('nextLessonForNow', () {
    test('returns null when there are no entries for today', () {
      final monday = DateTime(2026, 8, 24); // 24 Aug 2026 is a Monday
      expect(monday.weekday, DateTime.monday);

      final entries = [
        _entry(subject: 'Math', day: 'Tuesday', start: '08:00', end: '09:00'),
      ];

      final result = nextLessonForNow(
        entries,
        monday.add(const Duration(hours: 9)),
      );
      expect(result, isNull);
    });

    test('returns the first lesson still ahead of the current time', () {
      final monday = DateTime(2026, 8, 24); // Monday
      final entries = [
        _entry(subject: 'Math', day: 'Monday', start: '08:00', end: '09:00'),
        _entry(subject: 'English', day: 'Monday', start: '09:00', end: '10:00'),
        _entry(subject: 'Science', day: 'Monday', start: '10:00', end: '11:00'),
      ];

      // 10:30 is after English has ended (09:00-10:00) but before Science
      // ends (10:00-11:00), so Science is the next/current lesson.
      final now = monday.add(const Duration(hours: 10, minutes: 30));
      final result = nextLessonForNow(entries, now);

      expect(result, isNotNull);
      expect(result!.lesson.subjectName, 'Science');
    });

    test('returns a lesson currently in progress (not yet ended)', () {
      final monday = DateTime(2026, 8, 24);
      final entries = [
        _entry(subject: 'Math', day: 'Monday', start: '08:00', end: '09:00'),
        _entry(subject: 'English', day: 'Monday', start: '09:00', end: '10:00'),
      ];

      final now = monday.add(const Duration(hours: 9, minutes: 15));
      final result = nextLessonForNow(entries, now);

      expect(result, isNotNull);
      expect(result!.lesson.subjectName, 'English');
    });

    test('returns null once every lesson today has ended', () {
      final monday = DateTime(2026, 8, 24);
      final entries = [
        _entry(subject: 'Math', day: 'Monday', start: '08:00', end: '09:00'),
        _entry(subject: 'English', day: 'Monday', start: '09:00', end: '10:00'),
      ];

      final now = monday.add(const Duration(hours: 16));
      final result = nextLessonForNow(entries, now);

      expect(result, isNull);
    });

    test('returns null for an empty entries list', () {
      final result = nextLessonForNow(const [], DateTime(2026, 8, 24, 9));
      expect(result, isNull);
    });
  });
}

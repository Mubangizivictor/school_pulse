import '../entities/class_timetable_entities.dart';

enum TimetableConflictType {
  invalidTime,
  classOrStream,
  teacher,
  room,
}

class TimetableConflict {
  final TimetableConflictType type;
  final String message;
  final ClassTimetableLesson conflictingLesson;

  const TimetableConflict({
    required this.type,
    required this.message,
    required this.conflictingLesson,
  });
}

/// One source of truth for lesson collision checks.
class TimetableConflictResolver {
  const TimetableConflictResolver();

  List<TimetableConflict> findConflicts({
    required ClassTimetableLesson proposed,
    required Iterable<ClassTimetableLesson> existing,
  }) {
    final conflicts = <TimetableConflict>[];
    final proposedStart = _minutes(proposed.startTime);
    final proposedEnd = _minutes(proposed.endTime);
    if (proposedStart == null ||
        proposedEnd == null ||
        proposedStart >= proposedEnd) {
      return [
        TimetableConflict(
          type: TimetableConflictType.invalidTime,
          message: 'The lesson has an invalid start or end time.',
          conflictingLesson: proposed,
        ),
      ];
    }

    for (final lesson in existing) {
      if (!lesson.isActive || lesson.id == proposed.id) continue;
      if (lesson.schoolId != proposed.schoolId ||
          lesson.academicYearId != proposed.academicYearId ||
          lesson.termId != proposed.termId ||
          lesson.day != proposed.day) {
        continue;
      }
      final start = _minutes(lesson.startTime);
      final end = _minutes(lesson.endTime);
      if (start == null || end == null || !_overlaps(proposedStart, proposedEnd, start, end)) {
        continue;
      }

      final sameTeachingGroup = lesson.classId == proposed.classId &&
          lesson.streamId == proposed.streamId;
      if (sameTeachingGroup) {
        conflicts.add(
          TimetableConflict(
            type: TimetableConflictType.classOrStream,
            message:
                'This class/stream already has another lesson at ${proposed.startTime}-${proposed.endTime}.',
            conflictingLesson: lesson,
          ),
        );
      }

      if (proposed.teacherId.isNotEmpty &&
          lesson.teacherId == proposed.teacherId) {
        conflicts.add(
          TimetableConflict(
            type: TimetableConflictType.teacher,
            message:
                'The selected teacher is already teaching another class at this time.',
            conflictingLesson: lesson,
          ),
        );
      }

      if (proposed.roomId.isNotEmpty && lesson.roomId == proposed.roomId) {
        conflicts.add(
          TimetableConflict(
            type: TimetableConflictType.room,
            message: 'The selected room is already in use at this time.',
            conflictingLesson: lesson,
          ),
        );
      }
    }

    return conflicts;
  }

  bool _overlaps(int aStart, int aEnd, int bStart, int bEnd) =>
      aStart < bEnd && bStart < aEnd;

  int? _minutes(String raw) {
    final parts = raw.trim().split(':');
    if (parts.length != 2) return null;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }
    return hour * 60 + minute;
  }
}

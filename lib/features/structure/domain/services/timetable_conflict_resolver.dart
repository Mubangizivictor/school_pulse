import '../entities/timetable.dart';

enum TimetableConflictType {
  invalidTime,
  classOrStream,
  teacher,
  room,
  teacherAvailability,
}

class TimetableConflict {
  final TimetableConflictType type;
  final String message;
  final TimetableLesson conflictingLesson;

  /// The slot within [conflictingLesson.occurrences] (or the candidate
  /// lesson's occurrences, for an availability conflict) that collides -
  /// lets the UI highlight exactly which cell of a double/triple lesson is
  /// the problem rather than the whole lesson.
  final String slotId;

  const TimetableConflict({
    required this.type,
    required this.message,
    required this.conflictingLesson,
    required this.slotId,
  });
}

/// A window (or lack of one) in which a teacher is not available to teach,
/// e.g. a part-time teacher's off days, or a fixed non-teaching commitment.
/// Any candidate lesson occurrence whose (teacherId, day, slotId) matches one
/// of these blocks is rejected.
class TeacherAvailabilityBlock {
  final String teacherId;
  final String day;
  final String slotId;

  const TeacherAvailabilityBlock({
    required this.teacherId,
    required this.day,
    required this.slotId,
  });
}

/// One source of truth for lesson collision checks across the whole school.
///
/// A "lesson" schedules one subject/teacher/room/group for one or more
/// (day, slotId) occurrences (`TimetableLessonOccurrence`) - more than one
/// occurrence represents a double/triple/consecutive-block lesson, and every
/// occurrence is checked independently so a conflict on just one slot of a
/// double lesson is still caught and reported against that specific slot.
class TimetableConflictResolver {
  const TimetableConflictResolver();

  /// Checks [candidate] against every lesson in [otherLessons] (which should
  /// exclude the candidate's own previous version when editing in place) and
  /// optionally against [teacherAvailabilityBlocks].
  List<TimetableConflict> findConflicts({
    required TimetableLesson candidate,
    required Iterable<TimetableLesson> otherLessons,
    Iterable<TeacherAvailabilityBlock> teacherAvailabilityBlocks = const [],
  }) {
    final conflicts = <TimetableConflict>[];
    final others = otherLessons.where((l) => l.id != candidate.id).toList();

    for (final occurrence in candidate.occurrences) {
      conflicts.addAll(
        _conflictsForOccurrence(
          candidate,
          occurrence,
          others,
          teacherAvailabilityBlocks,
        ),
      );
    }

    return conflicts;
  }

  List<TimetableConflict> _conflictsForOccurrence(
    TimetableLesson candidate,
    TimetableLessonOccurrence occurrence,
    List<TimetableLesson> others,
    Iterable<TeacherAvailabilityBlock> teacherAvailabilityBlocks,
  ) {
    final conflicts = <TimetableConflict>[];

    for (final block in teacherAvailabilityBlocks) {
      if (block.teacherId == candidate.teacherId &&
          block.day == occurrence.day &&
          block.slotId == occurrence.slotId) {
        conflicts.add(
          TimetableConflict(
            type: TimetableConflictType.teacherAvailability,
            message:
                '${candidate.teacherName.isNotEmpty ? candidate.teacherName : 'This teacher'} is not available on ${occurrence.day} at this time.',
            conflictingLesson: candidate,
            slotId: occurrence.slotId,
          ),
        );
      }
    }

    for (final other in others) {
      for (final otherOccurrence in other.occurrences) {
        if (otherOccurrence.day != occurrence.day ||
            otherOccurrence.slotId != occurrence.slotId) {
          continue;
        }

        final sameTeachingGroup =
            other.classId == candidate.classId &&
            other.streamId == candidate.streamId;
        if (sameTeachingGroup) {
          conflicts.add(
            TimetableConflict(
              type: TimetableConflictType.classOrStream,
              message:
                  '${candidate.classLabel} already has ${other.subjectName} at ${occurrence.day} this slot.',
              conflictingLesson: other,
              slotId: occurrence.slotId,
            ),
          );
        }

        if (candidate.teacherId.isNotEmpty &&
            other.teacherId == candidate.teacherId) {
          conflicts.add(
            TimetableConflict(
              type: TimetableConflictType.teacher,
              message:
                  '${other.teacherName.isNotEmpty ? other.teacherName : 'This teacher'} is already teaching ${other.classLabel} at this time.',
              conflictingLesson: other,
              slotId: occurrence.slotId,
            ),
          );
        }

        if (candidate.roomId != null &&
            candidate.roomId!.isNotEmpty &&
            other.roomId == candidate.roomId) {
          conflicts.add(
            TimetableConflict(
              type: TimetableConflictType.room,
              message:
                  '${other.roomName ?? 'The selected room'} is already in use at this time.',
              conflictingLesson: other,
              slotId: occurrence.slotId,
            ),
          );
        }
      }
    }

    return conflicts;
  }

  /// Full conflict scan across every lesson in [lessons] (e.g. a whole
  /// timetable, or the whole school for a term), used before publishing.
  /// Returns a map of lessonId -> conflicts found for that lesson. A lesson
  /// with no conflicts is absent from the map.
  Map<String, List<TimetableConflict>> scanAll({
    required Iterable<TimetableLesson> lessons,
    Iterable<TeacherAvailabilityBlock> teacherAvailabilityBlocks = const [],
  }) {
    final all = lessons.toList();
    final result = <String, List<TimetableConflict>>{};
    for (final lesson in all) {
      final others = all.where((l) => l.id != lesson.id);
      final conflicts = findConflicts(
        candidate: lesson,
        otherLessons: others,
        teacherAvailabilityBlocks: teacherAvailabilityBlocks,
      );
      if (conflicts.isNotEmpty) {
        result[lesson.id] = conflicts;
      }
    }
    return result;
  }
}

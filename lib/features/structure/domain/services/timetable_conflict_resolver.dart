import 'package:equatable/equatable.dart';
import '../entities/timetable.dart';

enum TimetableConflictType { teacher, room, classOrStream, teacherAvailability }

/// One detected collision between a lesson being placed and an existing
/// lesson already occupying the same day/slot somewhere in the school.
class TimetableConflict extends Equatable {
  final TimetableConflictType type;
  final String day;
  final String slotId;

  /// The existing lesson this candidate collides with. Null for
  /// [TimetableConflictType.teacherAvailability], which has no opposing
  /// lesson - the teacher is simply unavailable at that time.
  final TimetableLesson? against;
  final String message;

  const TimetableConflict({
    required this.type,
    required this.day,
    required this.slotId,
    this.against,
    required this.message,
  });

  @override
  List<Object?> get props => [type, day, slotId, against, message];
}

/// A teacher's configured unavailability - they simply cannot be scheduled
/// during these day/slot combinations (e.g. a part-time teacher who is only
/// in school Tuesday and Thursday mornings).
class TeacherAvailabilityBlock extends Equatable {
  final String teacherId;
  final String day;
  final String slotId;

  const TeacherAvailabilityBlock({
    required this.teacherId,
    required this.day,
    required this.slotId,
  });

  @override
  List<Object?> get props => [teacherId, day, slotId];
}

/// The single source of truth for timetable collision detection. Every
/// surface that can create or move a lesson (manual assignment, auto-fill,
/// duplication, publish validation) must route through this resolver rather
/// than re-implementing collision checks.
///
/// Conflicts are evaluated against a caller-supplied pool of "other"
/// lessons, deliberately not scoped to a single [Timetable] - a teacher or
/// room collision can originate from a different class/stream's timetable
/// entirely, which is exactly the case this engine exists to catch.
class TimetableConflictResolver {
  const TimetableConflictResolver();

  /// Checks whether [candidate] can be placed alongside [otherLessons]
  /// (every other lesson at the school for the relevant academic
  /// year/term, excluding [candidate]'s own timetable target - i.e. its own
  /// class/stream lessons are still included, since a class cannot double
  /// book itself). Returns every conflict found; an empty list means the
  /// candidate is safe to save.
  List<TimetableConflict> findConflicts({
    required TimetableLesson candidate,
    required List<TimetableLesson> otherLessons,
    List<TeacherAvailabilityBlock> teacherAvailabilityBlocks = const [],
  }) {
    final conflicts = <TimetableConflict>[];

    for (final occurrence in candidate.occurrences) {
      conflicts.addAll(
        _blockedByAvailability(
          candidate: candidate,
          occurrence: occurrence,
          blocks: teacherAvailabilityBlocks,
        ),
      );

      for (final other in otherLessons) {
        if (other.id.isNotEmpty && other.id == candidate.id) continue;

        for (final otherOccurrence in other.occurrences) {
          if (otherOccurrence.day != occurrence.day ||
              otherOccurrence.slotId != occurrence.slotId) {
            continue;
          }

          if (other.teacherId == candidate.teacherId) {
            conflicts.add(
              TimetableConflict(
                type: TimetableConflictType.teacher,
                day: occurrence.day,
                slotId: occurrence.slotId,
                against: other,
                message:
                    '${candidate.teacherName.isEmpty ? 'This teacher' : candidate.teacherName} '
                    'is already teaching '
                    '${other.subjectName.isEmpty ? 'another subject' : other.subjectName} '
                    'to ${_classLabel(other)} at this time.',
              ),
            );
          }

          if (candidate.roomId != null &&
              candidate.roomId!.isNotEmpty &&
              other.roomId == candidate.roomId) {
            conflicts.add(
              TimetableConflict(
                type: TimetableConflictType.room,
                day: occurrence.day,
                slotId: occurrence.slotId,
                against: other,
                message:
                    '${candidate.roomName?.isNotEmpty == true ? candidate.roomName : 'This room'} '
                    'is already booked for '
                    '${other.subjectName.isEmpty ? 'another lesson' : other.subjectName} '
                    'with ${_classLabel(other)} at this time.',
              ),
            );
          }

          final sameClassAndStream =
              other.classId == candidate.classId &&
              other.streamId == candidate.streamId;
          if (sameClassAndStream) {
            conflicts.add(
              TimetableConflict(
                type: TimetableConflictType.classOrStream,
                day: occurrence.day,
                slotId: occurrence.slotId,
                against: other,
                message:
                    '${_classLabel(candidate)} already has '
                    '${other.subjectName.isEmpty ? 'a lesson' : other.subjectName} '
                    'scheduled at this time.',
              ),
            );
          }
        }
      }
    }

    return conflicts;
  }

  List<TimetableConflict> _blockedByAvailability({
    required TimetableLesson candidate,
    required TimetableLessonOccurrence occurrence,
    required List<TeacherAvailabilityBlock> blocks,
  }) {
    final blocked = blocks.any(
      (b) =>
          b.teacherId == candidate.teacherId &&
          b.day == occurrence.day &&
          b.slotId == occurrence.slotId,
    );
    if (!blocked) return const [];
    return [
      TimetableConflict(
        type: TimetableConflictType.teacherAvailability,
        day: occurrence.day,
        slotId: occurrence.slotId,
        message:
            '${candidate.teacherName.isEmpty ? 'This teacher' : candidate.teacherName} '
            'is not available at this time.',
      ),
    ];
  }

  /// Runs [findConflicts] for every lesson in [lessons] against the rest of
  /// the pool (each lesson excluded from its own check), used before
  /// publishing a timetable to guarantee a zero-conflict scan across
  /// everything it contains plus every other active/draft lesson supplied.
  Map<String, List<TimetableConflict>> scanAll({
    required List<TimetableLesson> lessons,
    List<TeacherAvailabilityBlock> teacherAvailabilityBlocks = const [],
  }) {
    final result = <String, List<TimetableConflict>>{};
    for (final lesson in lessons) {
      final others = lessons.where((l) => l.id != lesson.id).toList();
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

  String _classLabel(TimetableLesson lesson) =>
      lesson.classLabel.isEmpty ? 'this class' : lesson.classLabel;
}

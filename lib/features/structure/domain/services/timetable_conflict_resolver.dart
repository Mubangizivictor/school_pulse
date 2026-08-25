import '../entities/teaching_assignment.dart';
import '../entities/teaching_plan.dart';
import '../entities/timetable.dart';
import '../entities/timetable_config.dart';

enum TimetableConflictType {
  invalidTime,
  classOrStream,
  teacher,
  room,
  teacherAvailability,
  unallocatedSubject,
  teacherNotAssigned,
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

  /// Checks [candidate] against the school's own curriculum/assignment
  /// records rather than other lessons: is this subject actually allocated
  /// to this class (via its education level's [TeachingPlan] plus any
  /// [ClassPlanOverride]), and is this teacher actually assigned to teach
  /// this subject for this class in this academic year/term. Both checks
  /// are skipped (never silently assumed) when the referenced plan/subject
  /// or assignment data is not passed in - callers are expected to load the
  /// relevant year/term's data before validating.
  List<TimetableConflict> checkAllocation({
    required TimetableLesson candidate,
    required List<TeachingPlanSubject> levelPlanSubjects,
    required List<ClassPlanOverride> classOverrides,
    required List<TeachingAssignment> teachingAssignments,
  }) {
    final conflicts = <TimetableConflict>[];

    final override = classOverrides
        .where((o) => o.subjectId == candidate.subjectId && o.isActive)
        .toList();
    final removedByOverride = override.any(
      (o) => o.action == ClassPlanOverrideAction.remove,
    );
    final addedByOverride = override.any(
      (o) => o.action == ClassPlanOverrideAction.add,
    );
    final inLevelPlan = levelPlanSubjects.any(
      (s) => s.subjectId == candidate.subjectId && s.isActive,
    );
    final allocated = addedByOverride || (inLevelPlan && !removedByOverride);
    if (!allocated) {
      conflicts.add(
        TimetableConflict(
          type: TimetableConflictType.unallocatedSubject,
          message:
              '${candidate.subjectName.isNotEmpty ? candidate.subjectName : 'This subject'} is not allocated to ${candidate.classLabel.isNotEmpty ? candidate.classLabel : 'this class'}.',
          conflictingLesson: candidate,
          slotId: '',
        ),
      );
    }

    final assigned = teachingAssignments.any(
      (a) =>
          a.isActive &&
          a.staffId == candidate.teacherId &&
          a.subjectId == candidate.subjectId &&
          a.classId == candidate.classId &&
          (a.streamId.isEmpty || a.streamId == candidate.streamId) &&
          a.academicYearId == candidate.academicYearId &&
          (a.academicTermId.isEmpty || a.academicTermId == candidate.termId),
    );
    if (candidate.teacherId.isNotEmpty && !assigned) {
      conflicts.add(
        TimetableConflict(
          type: TimetableConflictType.teacherNotAssigned,
          message:
              '${candidate.teacherName.isNotEmpty ? candidate.teacherName : 'This teacher'} does not have an active teaching assignment for ${candidate.subjectName.isNotEmpty ? candidate.subjectName : 'this subject'} in ${candidate.classLabel.isNotEmpty ? candidate.classLabel : 'this class'}.',
          conflictingLesson: candidate,
          slotId: '',
        ),
      );
    }

    return conflicts;
  }

  /// Every occurrence of [candidate] must reference a currently-configured,
  /// active, teaching-type slot on the right day - never a break/lunch/
  /// assembly slot or a slot the school has since removed. This is what
  /// [TimetableConflictType.invalidTime] represents.
  List<TimetableConflict> checkValidTimes({
    required TimetableLesson candidate,
    required List<TimetableSlot> configuredSlots,
  }) {
    final conflicts = <TimetableConflict>[];
    for (final occurrence in candidate.occurrences) {
      final slot = configuredSlots
          .where((s) => s.id == occurrence.slotId)
          .toList();
      if (slot.isEmpty) {
        conflicts.add(
          TimetableConflict(
            type: TimetableConflictType.invalidTime,
            message: 'This lesson uses a slot that no longer exists.',
            conflictingLesson: candidate,
            slotId: occurrence.slotId,
          ),
        );
        continue;
      }
      final matched = slot.first;
      if (!matched.isActive) {
        conflicts.add(
          TimetableConflict(
            type: TimetableConflictType.invalidTime,
            message: '${matched.name} is no longer an active slot.',
            conflictingLesson: candidate,
            slotId: occurrence.slotId,
          ),
        );
      } else if (matched.type != 'period') {
        conflicts.add(
          TimetableConflict(
            type: TimetableConflictType.invalidTime,
            message:
                '${matched.name} is a ${matched.type}, not a teaching period.',
            conflictingLesson: candidate,
            slotId: occurrence.slotId,
          ),
        );
      } else if (matched.days.isNotEmpty &&
          !matched.days.contains(occurrence.day)) {
        conflicts.add(
          TimetableConflict(
            type: TimetableConflictType.invalidTime,
            message: '${matched.name} is not scheduled on ${occurrence.day}.',
            conflictingLesson: candidate,
            slotId: occurrence.slotId,
          ),
        );
      }
    }
    return conflicts;
  }
}

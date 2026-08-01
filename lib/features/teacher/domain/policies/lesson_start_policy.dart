import 'package:school_pulse/core/permissions/permission.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/lesson.dart';

/// Why a lesson may not be started. Each maps to a distinct message, because
/// "you are not the teacher for this lesson" and "it is too early" need
/// different reactions from the person holding the phone.
enum LessonStartRefusal {
  noPermission,
  notYourLesson,
  outsideAssignmentScope,
  alreadyStarted,
  alreadyFinished,
  cancelled,
  tooEarly,
  tooLate,
}

extension LessonStartRefusalMessage on LessonStartRefusal {
  String get message => switch (this) {
        LessonStartRefusal.noPermission =>
          'You do not have permission to start lessons.',
        LessonStartRefusal.notYourLesson =>
          'This lesson is assigned to another teacher.',
        LessonStartRefusal.outsideAssignmentScope =>
          'This lesson is outside your current responsibility. Switch subject or class first.',
        LessonStartRefusal.alreadyStarted => 'This lesson has already started.',
        LessonStartRefusal.alreadyFinished => 'This lesson has already ended.',
        LessonStartRefusal.cancelled => 'This lesson was cancelled.',
        LessonStartRefusal.tooEarly =>
          'It is too early to start this lesson.',
        LessonStartRefusal.tooLate =>
          'The window for starting this lesson has passed.',
      };
}

/// How far either side of the scheduled start a lesson may be opened.
///
/// Both bounds exist for the same reason: a lesson session stamps the time
/// attendance was taken, so letting one be opened at any hour would make the
/// register meaningless. The school can widen them, but not to infinity.
class LessonStartWindow {
  final Duration early;
  final Duration late;

  const LessonStartWindow({
    this.early = const Duration(minutes: 15),
    this.late = const Duration(hours: 2),
  });
}

/// Decides whether the signed-in teacher may open a given lesson.
///
/// Deliberately a pure function of (lesson, context, clock): no repository,
/// no network. That keeps every branch testable, and means the same rule runs
/// identically offline - a teacher in a basement classroom gets the same
/// answer as one on wifi.
class LessonStartPolicy {
  final LessonStartWindow window;

  const LessonStartPolicy({this.window = const LessonStartWindow()});

  /// Returns null when the lesson may be started, or the reason it may not.
  LessonStartRefusal? evaluate({
    required Lesson lesson,
    required ActiveResponsibilityContext context,
    DateTime? now,
  }) {
    if (!context.can(Permission.subjectLessonStart)) {
      return LessonStartRefusal.noPermission;
    }

    // The teacher must be the one the timetable named, or the substitute
    // covering for them. Holding a Mathematics assignment is not enough to
    // walk into another teacher's Mathematics lesson.
    if (!lesson.isTaughtBy(context.staffId)) {
      return LessonStartRefusal.notYourLesson;
    }

    // ...and the lesson must fall inside the responsibility currently in
    // effect, so a teacher acting as Class Teacher cannot start a subject
    // lesson without switching back.
    if (!context.permissionScope.covers(
      subjectId: lesson.subjectId,
      classId: lesson.classId,
      streamId: lesson.streamId,
      academicYearId: lesson.academicYearId,
    )) {
      return LessonStartRefusal.outsideAssignmentScope;
    }

    switch (lesson.status) {
      case LessonStatus.ongoing:
        return LessonStartRefusal.alreadyStarted;
      case LessonStatus.completed:
      case LessonStatus.missed:
        return LessonStartRefusal.alreadyFinished;
      case LessonStatus.cancelled:
        return LessonStartRefusal.cancelled;
      case LessonStatus.draft:
      case LessonStatus.scheduled:
      case LessonStatus.substituted:
      case LessonStatus.rescheduled:
        break;
    }

    // A second session for a lesson that already recorded one would give the
    // register two start times.
    if (lesson.actualStart != null) return LessonStartRefusal.alreadyStarted;

    final clock = now ?? DateTime.now();
    if (clock.isBefore(lesson.scheduledStart.subtract(window.early))) {
      return LessonStartRefusal.tooEarly;
    }
    if (clock.isAfter(lesson.scheduledStart.add(window.late))) {
      return LessonStartRefusal.tooLate;
    }

    return null;
  }

  bool canStart({
    required Lesson lesson,
    required ActiveResponsibilityContext context,
    DateTime? now,
  }) =>
      evaluate(lesson: lesson, context: context, now: now) == null;
}

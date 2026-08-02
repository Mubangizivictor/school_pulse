import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/lesson.dart';

/// The timetable, as the Subject Teacher panel reads it.
///
/// The panel does not own lessons and cannot create or move them - it reads
/// the periods the timetable produced and records what happened during them.
abstract class LessonRepository {
  /// Lessons for the active responsibility, optionally bounded by date.
  ///
  /// Scoped to the teacher: a class may have more than one teacher for the
  /// same subject, and "my lessons" should not list a colleague's periods.
  Future<Either<Failure, List<Lesson>>> getLessons({
    required ActiveResponsibilityContext context,
    DateTime? from,
    DateTime? to,
    bool forceRefresh = false,
  });

  /// Today's lessons for the active responsibility, in time order.
  Future<Either<Failure, List<Lesson>>> getTodaysLessons({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  });

  Future<Either<Failure, Lesson?>> getLesson({
    required ActiveResponsibilityContext context,
    required String lessonId,
  });

  /// Opens a lesson: stamps the actual start time and moves it to ongoing.
  /// Refuses when the start policy says so.
  Future<Either<Failure, Lesson>> startLesson({
    required ActiveResponsibilityContext context,
    required Lesson lesson,
  });

  /// Closes a lesson, recording what was covered.
  Future<Either<Failure, Lesson>> completeLesson({
    required ActiveResponsibilityContext context,
    required Lesson lesson,
    required LessonCompletion completion,
  });
}

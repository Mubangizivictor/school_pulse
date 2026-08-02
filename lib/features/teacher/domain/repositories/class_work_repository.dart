import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_behaviour.dart';
import '../entities/class_homework.dart';

/// Class work a teacher sets, and the conduct they record against students.
///
/// Together in one repository because they share everything that matters: the
/// same class scope, the same assignment guard, the same audit trail, and the
/// same rule that a class teacher observes and recommends but never decides an
/// outcome.
abstract class ClassWorkRepository {
  Future<Either<Failure, List<ClassHomework>>> getHomework({
    required ActiveResponsibilityContext context,
  });

  /// Saves a draft or edits existing work. Publishing is a separate call
  /// because it carries its own permission and reaches parents.
  Future<Either<Failure, ClassHomework>> saveHomework({
    required ActiveResponsibilityContext context,
    required ClassHomework homework,
  });

  /// Publishes to the class. Refused without `class.homework.publish`, so a
  /// teacher who may draft cannot reach students by drafting and saving.
  Future<Either<Failure, ClassHomework>> publishHomework({
    required ActiveResponsibilityContext context,
    required ClassHomework homework,
  });

  Future<Either<Failure, ClassHomework>> cancelHomework({
    required ActiveResponsibilityContext context,
    required ClassHomework homework,
    required String reason,
  });

  /// The behaviour categories this school uses, falling back to a shared
  /// default set when it has configured none.
  Future<Either<Failure, List<BehaviourCategory>>> getBehaviourCategories({
    required ActiveResponsibilityContext context,
  });

  /// Records for the class, or for one student when [studentId] is given.
  Future<Either<Failure, List<ClassBehaviourRecord>>> getBehaviourRecords({
    required ActiveResponsibilityContext context,
    String? studentId,
  });

  /// Records an observation. Never deletes and never decides - an entry that
  /// turns out to be wrong is amended and audited, because a conduct record a
  /// teacher can quietly erase is not a record.
  Future<Either<Failure, ClassBehaviourRecord>> recordBehaviour({
    required ActiveResponsibilityContext context,
    required ClassBehaviourRecord record,
    required List<String> rosterStudentIds,
  });

  /// Amends a record's note, recommendation or follow-up state. Refused once
  /// the record has been escalated into a formal discipline case.
  Future<Either<Failure, ClassBehaviourRecord>> updateBehaviour({
    required ActiveResponsibilityContext context,
    required ClassBehaviourRecord record,
  });
}

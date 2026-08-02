import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_task.dart';

/// The teacher's own working list.
///
/// Scoped by ownership rather than by class, unlike everything else in this
/// panel: a task is a note to oneself, and it should follow the teacher
/// across responsibilities rather than emptying when they switch class.
abstract class ClassTaskRepository {
  Future<Either<Failure, List<ClassTask>>> getTasks({
    required ActiveResponsibilityContext context,
  });

  /// Creates or updates. A blank id means new, and the coordinates are
  /// stamped from the verified context rather than trusted from the form.
  Future<Either<Failure, ClassTask>> saveTask({
    required ActiveResponsibilityContext context,
    required ClassTask task,
  });

  /// Marks done and stamps the completion time - the teacher says it is
  /// finished, the app records when.
  Future<Either<Failure, ClassTask>> completeTask({
    required ActiveResponsibilityContext context,
    required ClassTask task,
  });

  /// Removes a task. The owner's alone: a collaborator may work one but not
  /// take it off somebody else's list.
  Future<Either<Failure, void>> deleteTask({
    required ActiveResponsibilityContext context,
    required ClassTask task,
  });
}

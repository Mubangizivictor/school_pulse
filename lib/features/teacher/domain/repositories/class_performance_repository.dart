import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_performance.dart';
import '../policies/class_performance_policy.dart';

/// How the class is doing, composed from the modules that own each number.
///
/// This repository computes nothing authoritative: marks come from the
/// Assessment engine already approved, attendance from the Attendance
/// engine's own registers, behaviour from the class records. What it adds is
/// the join - one student's standing across every subject - which no single
/// one of those modules is in a position to assemble.
abstract class ClassPerformanceRepository {
  /// The whole performance picture for the active class and term.
  ///
  /// [thresholds] decide which students are surfaced for attention; omit them
  /// to use the shared defaults.
  Future<Either<Failure, ClassPerformanceSummary>> getPerformance({
    required ActiveResponsibilityContext context,
    AttentionThresholds? thresholds,
  });

  /// One student's individual assessment results in one subject, newest
  /// first - the drill-down behind a subject tile on the Assessments screen.
  Future<Either<Failure, List<StudentAssessmentResult>>>
  getStudentAssessmentResults({
    required ActiveResponsibilityContext context,
    required String studentId,
    required String subjectId,
  });
}

import 'package:dartz/dartz.dart';

import 'package:school_pulse/core/error/failures.dart';

import '../entities/active_responsibility_context.dart';
import '../entities/class_dashboard_summary.dart';

/// Composes the Class Teacher home tab from the modules that own each part.
///
/// Nothing here calculates: the roster count comes from the student roster,
/// attendance from the Attendance engine's register, the schedule from the
/// timetable, and the activity feed from the audit trail. Keeping the
/// composition in one repository is what stops five BLoCs each inventing
/// their own version of "how many are absent today".
abstract class ClassDashboardRepository {
  /// One pass over everything the home tab shows. Falls back to the cached
  /// summary when offline, flagged as such so the UI can say so rather than
  /// presenting yesterday's register as today's.
  Future<Either<Failure, ClassDashboardSummary>> getDashboard({
    required ActiveResponsibilityContext context,
    bool forceRefresh = false,
  });

  Future<Either<Failure, void>> clearCache({String? schoolId});
}

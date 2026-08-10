import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/attendance_access_context.dart';
import '../entities/attendance_category.dart';
import '../entities/attendance_record.dart';
import '../entities/attendance_scope.dart';

abstract class AttendanceRepository {
  /// Scopes returned are restricted to [access] - a Class Teacher only gets
  /// their assigned classes back for `students`, never every class in the
  /// school. See AttendanceParticipantResolver for how [access] is built.
  Future<Either<Failure, List<AttendanceScope>>> getScopes(
    String schoolId,
    AttendanceCategory category,
    AttendanceAccessContext access,
  );

  /// Throws no exception and returns no roster for a scopeId [access] does
  /// not authorise - callers must not pass an unresolved/unchecked scopeId.
  Future<Either<Failure, List<AttendancePerson>>> getRoster(
    String schoolId,
    AttendanceCategory category,
    String scopeId,
    AttendanceAccessContext access,
  );

  /// Marks one person. Returns a ValidationFailure with a 'duplicate'
  /// message if a record already exists for this exact session/person/day.
  Future<Either<Failure, AttendanceRecord>> markAttendance(
    AttendanceRecord record,
  );

  Future<Either<Failure, List<AttendanceRecord>>> markBatch(
    List<AttendanceRecord> records,
  );

  /// Records returned are restricted to [access] - a Class Teacher only
  /// sees Previous Attendance sessions for their assigned classes, never the
  /// whole school's history.
  Future<Either<Failure, List<AttendanceRecord>>> getRecords({
    required String schoolId,
    required AttendanceAccessContext access,
    AttendanceCategory? category,
    DateTime? from,
    DateTime? to,
    String? scopeId,
  });
}

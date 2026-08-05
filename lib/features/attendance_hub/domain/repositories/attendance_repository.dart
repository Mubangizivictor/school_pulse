import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/attendance_category.dart';
import '../entities/attendance_record.dart';
import '../entities/attendance_scope.dart';

abstract class AttendanceRepository {
  Future<Either<Failure, List<AttendanceScope>>> getScopes(
    String schoolId,
    AttendanceCategory category,
  );

  Future<Either<Failure, List<AttendancePerson>>> getRoster(
    String schoolId,
    AttendanceCategory category,
    String scopeId,
  );

  /// Marks one person. Returns a ValidationFailure with a 'duplicate'
  /// message if a record already exists for this exact session/person/day.
  Future<Either<Failure, AttendanceRecord>> markAttendance(
    AttendanceRecord record,
  );

  Future<Either<Failure, List<AttendanceRecord>>> markBatch(
    List<AttendanceRecord> records,
  );

  Future<Either<Failure, List<AttendanceRecord>>> getRecords({
    required String schoolId,
    AttendanceCategory? category,
    DateTime? from,
    DateTime? to,
    String? scopeId,
  });
}

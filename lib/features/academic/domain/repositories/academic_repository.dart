import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/academic_record.dart';
import '../entities/attendance_record.dart';

abstract class AcademicRepository {
  Future<Either<Failure, List<AcademicRecord>>> getAcademicRecords(
    String studentId, {
    String? term,
    String? year,
  });

  Future<Either<Failure, List<AttendanceRecord>>> getAttendanceRecords(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/academic_record.dart';
import '../entities/attendance_record.dart';

import '../entities/report_card.dart';

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

  Future<Either<Failure, List<ReportCard>>> getReportCards({
    String? studentId,
    String? className,
    String? term,
    String? year,
    ReportCardStatus? status,
  });

  Future<Either<Failure, void>> signReportCard({
    required String reportCardId,
    required String signerId,
    required bool isHeadTeacher,
  });
}

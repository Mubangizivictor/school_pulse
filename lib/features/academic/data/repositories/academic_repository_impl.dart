import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/academic_record.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/report_card.dart';
import '../../domain/repositories/academic_repository.dart';
import '../datasources/academic_remote_data_source.dart';

class AcademicRepositoryImpl implements AcademicRepository {
  final AcademicRemoteDataSource remoteDataSource;

  AcademicRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<AcademicRecord>>> getAcademicRecords(
    String studentId, {
    String? term,
    String? year,
  }) async {
    try {
      final remoteRecords = await remoteDataSource.getAcademicRecords(
        studentId,
        term: term,
        year: year,
      );
      return Right(remoteRecords);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceRecord>>> getAttendanceRecords(
    String studentId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final remoteRecords = await remoteDataSource.getAttendanceRecords(
        studentId,
        startDate: startDate,
        endDate: endDate,
      );
      return Right(remoteRecords);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportCard>>> getReportCards({
    String? studentId,
    String? className,
    String? term,
    String? year,
    ReportCardStatus? status,
  }) async {
    try {
      final remoteRecords = await remoteDataSource.getReportCards(
        studentId: studentId,
        className: className,
        term: term,
        year: year,
        status: status,
      );
      return Right(remoteRecords);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> signReportCard({
    required String reportCardId,
    required String signerId,
    required bool isHeadTeacher,
  }) async {
    try {
      await remoteDataSource.signReportCard(
        reportCardId: reportCardId,
        signerId: signerId,
        isHeadTeacher: isHeadTeacher,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

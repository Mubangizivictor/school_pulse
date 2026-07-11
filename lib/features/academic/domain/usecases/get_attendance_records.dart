import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/attendance_record.dart';
import '../repositories/academic_repository.dart';

class GetAttendanceRecords implements UseCase<List<AttendanceRecord>, GetAttendanceRecordsParams> {
  final AcademicRepository repository;

  GetAttendanceRecords(this.repository);

  @override
  Future<Either<Failure, List<AttendanceRecord>>> call(GetAttendanceRecordsParams params) async {
    return await repository.getAttendanceRecords(
      params.studentId,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetAttendanceRecordsParams extends Equatable {
  final String studentId;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetAttendanceRecordsParams({
    required this.studentId,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [studentId, startDate, endDate];
}

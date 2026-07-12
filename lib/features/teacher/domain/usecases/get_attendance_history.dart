import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/teacher_repository.dart';

class GetAttendanceHistory implements UseCase<List<AttendanceHistoryRecord>, String> {
  final TeacherRepository repository;

  GetAttendanceHistory(this.repository);

  @override
  Future<Either<Failure, List<AttendanceHistoryRecord>>> call(String params) async {
    return await repository.getAttendanceHistory(params);
  }
}

class AttendanceHistoryRecord extends Equatable {
  final String className;
  final DateTime date;
  final int presentCount;
  final int totalCount;
  final String status;

  const AttendanceHistoryRecord({
    required this.className,
    required this.date,
    required this.presentCount,
    required this.totalCount,
    required this.status,
  });

  @override
  List<Object?> get props => [className, date, presentCount, totalCount, status];
}

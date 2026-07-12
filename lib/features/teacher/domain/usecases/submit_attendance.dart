import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/enums/student_status.dart';
import '../repositories/teacher_repository.dart';

class SubmitAttendance implements UseCase<void, AttendanceParams> {
  final TeacherRepository repository;

  SubmitAttendance(this.repository);

  @override
  Future<Either<Failure, void>> call(AttendanceParams params) async {
    return await repository.submitAttendance(
      className: params.className,
      date: params.date,
      attendance: params.attendance,
    );
  }
}

class AttendanceParams extends Equatable {
  final String className;
  final DateTime date;
  final Map<String, StudentStatus> attendance;

  const AttendanceParams({
    required this.className,
    required this.date,
    required this.attendance,
  });

  @override
  List<Object?> get props => [className, date, attendance];
}

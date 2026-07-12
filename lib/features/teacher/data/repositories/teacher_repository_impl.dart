import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/enums/student_status.dart';
import 'package:school_pulse/features/teacher/data/datasources/teacher_remote_data_source.dart';
import 'package:school_pulse/features/teacher/domain/repositories/teacher_repository.dart';
import 'package:school_pulse/features/teacher/presentation/bloc/teacher_state.dart';
import 'package:school_pulse/features/teacher/domain/entities/teacher_dashboard_stats.dart';
import 'package:school_pulse/features/teacher/domain/usecases/get_attendance_history.dart';

class TeacherRepositoryImpl implements TeacherRepository {
  final TeacherRemoteDataSource remoteDataSource;

  TeacherRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<TeacherStudent>>> getStudentsByClass(String className) async {
    try {
      final students = await remoteDataSource.getStudentsByClass(className);
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitAttendance({
    required String className,
    required DateTime date,
    required Map<String, StudentStatus> attendance,
  }) async {
    try {
      await remoteDataSource.submitAttendance(
        className: className,
        date: date,
        attendance: attendance.map((key, value) => MapEntry(key, value.name)),
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AttendanceHistoryRecord>>> getAttendanceHistory(String teacherId) async {
    try {
      final history = await remoteDataSource.getAttendanceHistory(teacherId);
      return Right(history);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, TeacherDashboardStats>> getTeacherDashboardStats(String teacherId) async {
    try {
      final stats = await remoteDataSource.getTeacherDashboardStats(teacherId);
      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

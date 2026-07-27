import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/repositories/matron_repository.dart';
import '../../presentation/bloc/matron_state.dart';
import '../datasources/matron_remote_data_source.dart';

class MatronRepositoryImpl implements MatronRepository {
  final MatronRemoteDataSource remoteDataSource;

  MatronRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, MatronLoaded>> getDashboardData() async {
    try {
      final dormitories = await remoteDataSource.getDormitoriesStatus();
      final stats = await remoteDataSource.getAttendanceStats();
      
      return Right(MatronLoaded(
        dormitories: dormitories,
        totalStudents: stats['totalStudents'] ?? 0,
        studentsPresent: stats['studentsPresent'] ?? 0,
        studentsOnLeave: stats['studentsOnLeave'] ?? 0,
      ));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getUnallocatedStudents() async {
    try {
      final students = await remoteDataSource.getUnallocatedStudents();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> allocateStudent(String studentId, String dormitoryId) async {
    try {
      await remoteDataSource.allocateStudent(studentId, dormitoryId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getDormitoryStudents(String dormitoryId) async {
    try {
      final students = await remoteDataSource.getDormitoryStudents(dormitoryId);
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitNightAttendance(String dormitoryId, Map<String, bool> attendance) async {
    try {
      await remoteDataSource.submitNightAttendance(dormitoryId, attendance);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

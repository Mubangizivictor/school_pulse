import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/boarding_entities.dart';
import '../../domain/repositories/matron_repository.dart';
import '../datasources/matron_remote_data_source.dart';

class MatronRepositoryImpl implements MatronRepository {
  final MatronRemoteDataSource remoteDataSource;

  MatronRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, BoardingDashboardData>> getDashboardData({
    String? schoolId,
    String? gender,
  }) async {
    try {
      final data = await remoteDataSource.getDashboardData(
        schoolId: schoolId,
        gender: gender,
      );
      return Right(data);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Dormitory>>> getDormitories({
    String? gender,
  }) async {
    try {
      final dorms = await remoteDataSource.getDormitories(gender: gender);
      return Right(dorms);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BoardingStudent>>> getUnallocatedStudents({
    String? gender,
  }) async {
    try {
      final students = await remoteDataSource.getUnallocatedStudents(
        gender: gender,
      );
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> allocateStudent(
    String studentId,
    String dormitoryId,
    String? bedNumber,
  ) async {
    try {
      await remoteDataSource.allocateStudent(studentId, dormitoryId, bedNumber);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BoardingStudent>>> getDormitoryStudents(
    String dormitoryId,
  ) async {
    try {
      final students = await remoteDataSource.getDormitoryStudents(dormitoryId);
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> submitAttendance({
    required String dormitoryId,
    required String type,
    required Map<String, String> attendance,
  }) async {
    try {
      await remoteDataSource.submitAttendance(
        dormitoryId: dormitoryId,
        type: type,
        attendance: attendance,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<WelfareRecord>>> getWelfareRecords({
    String? schoolId,
    String? studentId,
    String? gender,
    bool publicOnly = false,
  }) async {
    try {
      final records = await remoteDataSource.getWelfareRecords(
        schoolId: schoolId,
        studentId: studentId,
        gender: gender,
        publicOnly: publicOnly,
      );
      return Right(records);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addWelfareRecord(WelfareRecord record) async {
    try {
      await remoteDataSource.addWelfareRecord(record);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DisciplineCase>>> getDisciplineCases({
    String? studentId,
    String? gender,
  }) async {
    try {
      final cases = await remoteDataSource.getDisciplineCases(
        studentId: studentId,
        gender: gender,
      );
      return Right(cases);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addDisciplineCase(
    DisciplineCase disciplineCase,
  ) async {
    try {
      await remoteDataSource.addDisciplineCase(disciplineCase);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HygieneCheck>>> getHygieneChecks({
    String? dormitoryId,
    String? gender,
  }) async {
    try {
      final checks = await remoteDataSource.getHygieneChecks(
        dormitoryId: dormitoryId,
        gender: gender,
      );
      return Right(checks);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addHygieneCheck(HygieneCheck check) async {
    try {
      await remoteDataSource.addHygieneCheck(check);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<BoardingStudent>>> getStudentsOnLeave({
    String? gender,
  }) async {
    try {
      final students = await remoteDataSource.getStudentsOnLeave(
        gender: gender,
      );
      return Right(students);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

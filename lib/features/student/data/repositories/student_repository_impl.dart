import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/student.dart';
import '../../domain/entities/parent_access_code.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_data_source.dart';
import '../models/student_model.dart';

class StudentRepositoryImpl implements StudentRepository {
  final StudentRemoteDataSource remoteDataSource;

  StudentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, void>> createStudent(Student student) async {
    try {
      final model = StudentModel(
        id: student.id,
        name: student.name,
        className: student.className,
        studentId: student.studentId,
        photoUrl: student.photoUrl,
      );
      await remoteDataSource.createStudent(model);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getStudentsByIds(
    List<String> ids,
  ) async {
    try {
      final students = await remoteDataSource.getStudentsByIds(ids);
      return Right(students);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Student>>> getAllStudents() async {
    try {
      final students = await remoteDataSource.getAllStudents();
      return Right(students);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, ParentAccessCode?>> resolveAccessCode(String code) async {
    try {
      final result = await remoteDataSource.resolveAccessCode(code);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ParentAccessCode>>> getAllAccessCodes() async {
    try {
      final result = await remoteDataSource.getAllAccessCodes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> createAccessCode({required List<String> studentIds, String? parentName}) async {
    try {
      final code = await remoteDataSource.createAccessCode(studentIds: studentIds, parentName: parentName);
      return Right(code);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, String>> regenerateAccessCode(String oldCode) async {
    try {
      final code = await remoteDataSource.regenerateAccessCode(oldCode);
      return Right(code);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> toggleAccessCodeStatus(String code, bool isActive) async {
    try {
      await remoteDataSource.toggleAccessCodeStatus(code, isActive);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}

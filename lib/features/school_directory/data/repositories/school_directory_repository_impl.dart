import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/directory_contact_entity.dart';
import '../../domain/repositories/school_directory_repository.dart';
import '../datasources/school_directory_remote_data_source.dart';

class SchoolDirectoryRepositoryImpl implements SchoolDirectoryRepository {
  final SchoolDirectoryRemoteDataSource remoteDataSource;

  SchoolDirectoryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<DirectoryContactEntity>>> getContacts(
    String schoolId,
  ) async {
    try {
      final contacts = await remoteDataSource.getContacts(schoolId);
      return Right(contacts);
    } catch (e, st) {
      debugPrint('SchoolDirectoryRepositoryImpl error: $e\n$st');
      return Left(ServerFailure('$e'));
    }
  }
}

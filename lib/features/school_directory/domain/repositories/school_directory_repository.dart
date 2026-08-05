import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/directory_contact_entity.dart';

abstract class SchoolDirectoryRepository {
  Future<Either<Failure, List<DirectoryContactEntity>>> getContacts(
    String schoolId,
  );
}

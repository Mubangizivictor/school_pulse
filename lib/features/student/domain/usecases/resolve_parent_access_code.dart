import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/parent_access_code.dart';
import '../repositories/student_repository.dart';

class ResolveParentAccessCode {
  final StudentRepository repository;

  ResolveParentAccessCode(this.repository);

  Future<Either<Failure, ParentAccessCode>> call(String code) async {
    return await repository.resolveAccessCode(code);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class GetStudentsByIds {
  final StudentRepository repository;

  GetStudentsByIds(this.repository);

  Future<Either<Failure, List<Student>>> call(List<String> ids) async {
    return await repository.getStudentsByIds(ids);
  }
}

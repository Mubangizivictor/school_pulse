import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../teacher/domain/entities/homework.dart';
import '../repositories/student_repository.dart';

class GetHomeworkForStudent {
  final StudentRepository repository;

  GetHomeworkForStudent(this.repository);

  Future<Either<Failure, List<Homework>>> call(String className) async {
    return await repository.getHomeworkForStudent(className);
  }
}

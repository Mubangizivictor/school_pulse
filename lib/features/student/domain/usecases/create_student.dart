import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class CreateStudent {
  final StudentRepository repository;

  CreateStudent(this.repository);

  Future<Either<Failure, void>> call(Student student) async {
    return await repository.createStudent(student);
  }
}

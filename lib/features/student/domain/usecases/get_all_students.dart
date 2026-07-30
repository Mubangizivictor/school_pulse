import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class GetAllStudents {
  final StudentRepository repository;

  GetAllStudents(this.repository);

  Future<Either<Failure, List<Student>>> call({String? schoolId}) async {
    return await repository.getAllStudents(schoolId: schoolId);
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class SearchStudents {
  final StudentRepository repository;

  SearchStudents(this.repository);

  Future<Either<Failure, List<Student>>> call({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? parentPhone,
    String? classId,
  }) {
    return repository.searchStudents(
      schoolId: schoolId,
      query: query,
      admissionNumber: admissionNumber,
      parentPhone: parentPhone,
      classId: classId,
    );
  }
}

import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../repositories/student_repository.dart';

class StudentService {
  final StudentRepository repository;

  StudentService(this.repository);

  Future<Either<Failure, Student>> getStudentProfile(String studentId) {
    return repository.getStudentById(studentId);
  }

  Future<Either<Failure, List<Student>>> searchStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? classId,
  }) {
    return repository.searchStudents(
      schoolId: schoolId,
      query: query,
      admissionNumber: admissionNumber,
      classId: classId,
    );
  }

  Future<Either<Failure, List<Student>>> getStudentsByClass(String schoolId, String classId) {
    return repository.searchStudents(schoolId: schoolId, classId: classId);
  }
}

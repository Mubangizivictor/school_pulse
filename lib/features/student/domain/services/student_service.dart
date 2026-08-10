import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/student.dart';
import '../entities/student_enums.dart';
import '../repositories/student_repository.dart';
import 'student_lifecycle_policy.dart';

class StudentService {
  final StudentRepository repository;
  final StudentLifecyclePolicy lifecyclePolicy;

  StudentService(this.repository, {StudentLifecyclePolicy? lifecyclePolicy})
    : lifecyclePolicy = lifecyclePolicy ?? const StudentLifecyclePolicy();

  Future<Either<Failure, Student>> getStudentProfile(String studentId) {
    return repository.getStudentById(studentId);
  }

  Future<Either<Failure, List<Student>>> searchStudents({
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

  Future<Either<Failure, List<Student>>> getStudentsByClass(
    String schoolId,
    String classId,
  ) {
    return repository.searchStudents(schoolId: schoolId, classId: classId);
  }

  /// Changes lifecycle state only when it is a valid SIS transition. This
  /// gives every downstream module one authoritative lifecycle contract.
  Future<Either<Failure, void>> changeLifecycle({
    required Student student,
    required StudentStatus nextStatus,
  }) {
    if (!lifecyclePolicy.canTransition(student.status, nextStatus)) {
      return Future.value(
        Left(
          ServerFailure(
            'Cannot change ${student.status.name} student to ${nextStatus.name}.',
          ),
        ),
      );
    }
    return repository.updateStudentStatus(student.id, nextStatus);
  }
}

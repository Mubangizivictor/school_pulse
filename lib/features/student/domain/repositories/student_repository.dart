import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../teacher/domain/entities/homework.dart';
import '../../../matron/domain/entities/boarding_entities.dart';
import '../entities/student.dart';
import '../entities/admission_application.dart';
import '../entities/student_enums.dart';
import '../entities/parent_access_code.dart';

abstract class StudentRepository {
  // Student Management
  Future<Either<Failure, Student>> getStudentById(String studentId);
  Future<Either<Failure, List<Student>>> getAllStudents({String? schoolId});
  Future<Either<Failure, List<Student>>> getStudentsByIds(List<String> ids);
  Future<Either<Failure, void>> createStudent(Student student);
  Future<Either<Failure, List<Student>>> searchStudents({
    required String schoolId,
    String? query,
    String? admissionNumber,
    String? parentPhone,
    String? classId,
  });
  Future<Either<Failure, void>> updateStudent(Student student);
  Future<Either<Failure, void>> updateStudentStatus(
    String studentId,
    StudentStatus status,
  );

  // Admission Workflow
  Future<Either<Failure, void>> createAdmissionApplication(
    AdmissionApplication application,
  );
  Future<Either<Failure, List<AdmissionApplication>>> getApplications(
    String schoolId,
  );
  Future<Either<Failure, void>> updateApplicationStatus(
    String applicationId,
    AdmissionStatus status, {
    String? reviewerId,
    String? comments,
  });
  Future<Either<Failure, String>> generateAdmissionNumber(
    String schoolId,
    String academicYearId,
  );
  Future<Either<Failure, String>> finalizeAdmission(
    String applicationId, {
    required String studentCode,
    required String admissionNumber,
    String? qrReference,
  });

  // Document Management
  Future<Either<Failure, String>> uploadStudentDocument(
    String studentId,
    String type,
    dynamic file,
  );
  Future<Either<Failure, void>> deleteStudentDocument(
    String studentId,
    String type,
  );

  // Promotion
  Future<Either<Failure, void>> promoteStudents({
    required String schoolId,
    required List<String> studentIds,
    required String targetClassId,
    String? targetStreamId,
    required String targetAcademicYearId,
  });

  // Parent Access Codes
  Future<Either<Failure, List<ParentAccessCode>>> getAllAccessCodes({
    String? schoolId,
  });
  Future<Either<Failure, String>> createAccessCode({
    required List<String> studentIds,
    required String schoolId,
    required String phoneNumber,
    String? parentName,
  });
  Future<Either<Failure, String>> regenerateAccessCode(String oldCode);
  Future<Either<Failure, void>> toggleAccessCodeStatus(
    String code,
    bool isActive, {
    String? reason,
  });
  Future<Either<Failure, void>> deleteAccessCode(String code);
  Future<Either<Failure, void>> updateAccessCode(ParentAccessCode code);
  Future<Either<Failure, ParentAccessCode>> resolveAccessCode(String code);

  // Homework
  Future<Either<Failure, List<Homework>>> getHomeworkForStudent(
    String className,
  );

  // Boarding / Welfare
  Future<Either<Failure, List<WelfareRecord>>> getWelfareRecords({
    String? schoolId,
    String? studentId,
    bool publicOnly = false,
  });
  Future<Either<Failure, List<DisciplineCase>>> getDisciplineCases({
    String? studentId,
  });
}

import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/permissions/permission.dart';
import 'package:school_pulse/features/auth/domain/entities/user_entity.dart';
import 'package:school_pulse/features/student/domain/repositories/student_repository.dart';
import 'package:school_pulse/features/verification/domain/repositories/permission_evaluator.dart';
import '../entities/nurse_student_view.dart';
import '../repositories/health_repository.dart';

/// The Nurse-facing lookup: identity/photo/age/class always (once
/// health.student.basic.read is granted), allergies/medications/emergency
/// contacts/clinic history only when health.student.clinical.read is also
/// granted. Never touches fees or academics - this service has no
/// dependency capable of reading either.
class NurseStudentProjectionService {
  final PermissionEvaluator permissionEvaluator;
  final StudentRepository studentRepository;
  final HealthRepository healthRepository;

  NurseStudentProjectionService({
    required this.permissionEvaluator,
    required this.studentRepository,
    required this.healthRepository,
  });

  Future<Either<Failure, NurseStudentView>> getStudentView({
    required String studentId,
    required String schoolId,
    required UserEntity operatorUser,
  }) async {
    final basicAllowed = await _can(
      Permission.healthStudentBasicRead,
      operatorUser,
    );
    if (!basicAllowed) {
      return const Left(
        PermissionDeniedFailure(
          'You do not have permission to view student health records.',
        ),
      );
    }

    final studentResult = await studentRepository.getStudentById(studentId);
    return studentResult.fold(Left.new, (student) async {
      final age = _ageFrom(student.dateOfBirth);
      final clinicalAllowed = await _can(
        Permission.healthStudentClinicalRead,
        operatorUser,
      );

      if (!clinicalAllowed) {
        return Right(
          NurseStudentView(
            studentId: student.id,
            name: student.name,
            photoUrl: student.photoUrl,
            age: age,
            classId: student.classId,
            hasClinicalAccess: false,
          ),
        );
      }

      final profileResult = await healthRepository.getStudentHealthProfile(
        studentId,
        schoolId,
      );
      final visitsResult = await healthRepository.getClinicVisits(
        schoolId: schoolId,
        studentId: studentId,
      );
      final recentVisitCount = visitsResult.fold(
        (_) => null,
        (visits) => visits.length,
      );

      return profileResult.fold(
        // No health profile on file yet isn't a permission problem -
        // still show basic + whatever the Student record itself has.
        (_) => Right(
          NurseStudentView(
            studentId: student.id,
            name: student.name,
            photoUrl: student.photoUrl,
            age: age,
            classId: student.classId,
            hasClinicalAccess: true,
            allergies: student.medicalInfo?.allergies ?? const [],
            currentMedications: student.medicalInfo?.medications != null
                ? [student.medicalInfo!.medications!]
                : const [],
            chronicIllnesses:
                student.medicalInfo?.chronicConditions ?? const [],
            emergencyContactName: student.emergencyContacts.isNotEmpty
                ? student.emergencyContacts.first.name
                : null,
            emergencyContactPhone: student.emergencyContacts.isNotEmpty
                ? student.emergencyContacts.first.phoneNumber
                : null,
            recentClinicVisitCount: recentVisitCount,
          ),
        ),
        (profile) => Right(
          NurseStudentView(
            studentId: student.id,
            name: student.name,
            photoUrl: student.photoUrl,
            age: age,
            classId: student.classId,
            hasClinicalAccess: true,
            allergies: profile.allergies,
            currentMedications: profile.currentMedications,
            chronicIllnesses: profile.chronicIllnesses,
            emergencyContactName: profile.emergencyContactName,
            emergencyContactPhone: profile.emergencyContactPhone,
            recentClinicVisitCount: recentVisitCount,
          ),
        ),
      );
    });
  }

  Future<bool> _can(String permissionId, UserEntity operatorUser) async {
    final result = await permissionEvaluator.can(permissionId, operatorUser);
    return result.fold((_) => false, (allowed) => allowed);
  }

  int? _ageFrom(DateTime dateOfBirth) {
    final now = DateTime.now();
    var age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}

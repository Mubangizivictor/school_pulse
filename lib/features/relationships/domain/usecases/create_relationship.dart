import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../entities/parent_student_relationship.dart';
import '../entities/people_policy.dart';
import '../entities/relationship_enums.dart';
import '../repositories/relationship_repository.dart';

/// Standard guardian types the configured guardian limit applies to -
/// sponsors/foster/relative/caregiver/institutionAppointed/custom links
/// are not counted against it, matching the spec's "standard parent
/// portal links" wording.
const _standardGuardianTypes = {
  RelationshipType.parent,
  RelationshipType.guardian,
};

class GuardianLimitExceededFailure extends Failure {
  const GuardianLimitExceededFailure(int limit)
    : super(
        'This student already has the maximum of $limit standard parent/guardian links.',
      );
}

class CreateRelationship
    implements UseCase<ParentStudentRelationship, CreateRelationshipParams> {
  final RelationshipRepository repository;

  CreateRelationship(this.repository);

  @override
  Future<Either<Failure, ParentStudentRelationship>> call(
    CreateRelationshipParams params,
  ) async {
    if (_standardGuardianTypes.contains(params.type)) {
      PeoplePolicy? policy;
      final policyResult = await repository.getPeoplePolicy(params.schoolId);
      final policyFailure = policyResult.fold((f) => f, (p) {
        policy = p;
        return null;
      });
      if (policyFailure != null) return Left(policyFailure);

      List<ParentStudentRelationship>? existing;
      final existingResult = await repository.getRelationshipsForStudent(
        params.schoolId,
        params.studentId,
      );
      final existingFailure = existingResult.fold((f) => f, (e) {
        existing = e;
        return null;
      });
      if (existingFailure != null) return Left(existingFailure);

      final activeStandardCount = existing!
          .where((r) => r.isActive && _standardGuardianTypes.contains(r.type))
          .length;
      if (activeStandardCount >= policy!.maxStandardGuardians) {
        return Left(GuardianLimitExceededFailure(policy!.maxStandardGuardians));
      }
    }

    return repository.createRelationship(
      schoolId: params.schoolId,
      studentId: params.studentId,
      userId: params.userId,
      parentCode: params.parentCode,
      type: params.type,
      isLegalGuardian: params.isLegalGuardian,
      isPrimaryGuardian: params.isPrimaryGuardian,
      createdBy: params.createdBy,
      financialAccess: params.financialAccess,
      academicAccess: params.academicAccess,
      attendanceAccess: params.attendanceAccess,
      medicalAccess: params.medicalAccess,
      emergencyContactAccess: params.emergencyContactAccess,
      pickupAuthorized: params.pickupAuthorized,
      communicationPermission: params.communicationPermission,
    );
  }
}

class CreateRelationshipParams extends Equatable {
  final String schoolId;
  final String studentId;
  final String? userId;
  final String? parentCode;
  final RelationshipType type;
  final bool isLegalGuardian;
  final bool isPrimaryGuardian;
  final String createdBy;
  final bool? financialAccess;
  final bool? academicAccess;
  final bool? attendanceAccess;
  final bool? medicalAccess;
  final bool? emergencyContactAccess;
  final bool? pickupAuthorized;
  final bool? communicationPermission;

  const CreateRelationshipParams({
    required this.schoolId,
    required this.studentId,
    this.userId,
    this.parentCode,
    required this.type,
    this.isLegalGuardian = false,
    this.isPrimaryGuardian = false,
    required this.createdBy,
    this.financialAccess,
    this.academicAccess,
    this.attendanceAccess,
    this.medicalAccess,
    this.emergencyContactAccess,
    this.pickupAuthorized,
    this.communicationPermission,
  });

  @override
  List<Object?> get props => [
    schoolId,
    studentId,
    userId,
    parentCode,
    type,
    isLegalGuardian,
    isPrimaryGuardian,
    createdBy,
    financialAccess,
    academicAccess,
    attendanceAccess,
    medicalAccess,
    emergencyContactAccess,
    pickupAuthorized,
    communicationPermission,
  ];
}

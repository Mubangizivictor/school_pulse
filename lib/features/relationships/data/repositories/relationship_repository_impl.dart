import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../../domain/entities/parent_student_relationship.dart';
import '../../domain/entities/people_policy.dart';
import '../../domain/entities/relationship_enums.dart';
import '../../domain/entities/student_enrolment.dart';
import '../../domain/repositories/relationship_repository.dart';
import '../datasources/relationship_remote_data_source.dart';
import '../models/people_policy_model.dart';

class RelationshipRepositoryImpl implements RelationshipRepository {
  final RelationshipRemoteDataSource remoteDataSource;

  RelationshipRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ParentStudentRelationship>>>
  getRelationshipsForStudent(String schoolId, String studentId) async {
    try {
      return Right(
        await remoteDataSource.getRelationshipsForStudent(schoolId, studentId),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParentStudentRelationship>>>
  getRelationshipsForParent(String schoolId, String userId) async {
    try {
      return Right(
        await remoteDataSource.getRelationshipsForParent(schoolId, userId),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ParentStudentRelationship>>>
  getRelationshipsForSchool(String schoolId) async {
    try {
      return Right(await remoteDataSource.getRelationshipsForSchool(schoolId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParentStudentRelationship>> createRelationship({
    required String schoolId,
    required String studentId,
    String? userId,
    String? parentCode,
    required RelationshipType type,
    bool isLegalGuardian = false,
    bool isPrimaryGuardian = false,
    required String createdBy,
    bool? financialAccess,
    bool? academicAccess,
    bool? attendanceAccess,
    bool? medicalAccess,
    bool? emergencyContactAccess,
    bool? pickupAuthorized,
    bool? communicationPermission,
  }) async {
    try {
      final data = {
        'schoolId': schoolId,
        'studentId': studentId,
        'userId': userId,
        'parentCode': parentCode,
        'type': type.name,
        'isLegalGuardian': isLegalGuardian,
        'isPrimaryGuardian': isPrimaryGuardian,
        'financialAccess': financialAccess ?? false,
        'academicAccess': academicAccess ?? true,
        'attendanceAccess': attendanceAccess ?? true,
        'medicalAccess': medicalAccess ?? false,
        'emergencyContactAccess': emergencyContactAccess ?? true,
        'pickupAuthorized': pickupAuthorized ?? false,
        'communicationPermission': communicationPermission ?? true,
        'status': RelationshipStatus.active.name,
        'createdBy': createdBy,
        'createdAt': Timestamp.now(),
      };
      return Right(await remoteDataSource.createRelationship(data));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ParentStudentRelationship>> reallocateRelationship({
    required String schoolId,
    required String relationshipId,
    required String reason,
    required String reallocatedBy,
    String? newUserId,
    RelationshipType? newType,
  }) async {
    try {
      final existing = await remoteDataSource.getRelationshipById(
        relationshipId,
      );

      await remoteDataSource.supersedeRelationship(relationshipId, {
        'status': RelationshipStatus.superseded.name,
        'supersededAt': Timestamp.now(),
        'supersededBy': reallocatedBy,
        'supersessionReason': reason,
      });

      final newData = {
        'schoolId': schoolId,
        'studentId': existing.studentId,
        'userId': newUserId ?? existing.userId,
        'parentCode': existing.parentCode,
        'type': (newType ?? existing.type).name,
        'isLegalGuardian': existing.isLegalGuardian,
        'isPrimaryGuardian': existing.isPrimaryGuardian,
        'financialAccess': existing.financialAccess,
        'academicAccess': existing.academicAccess,
        'attendanceAccess': existing.attendanceAccess,
        'medicalAccess': existing.medicalAccess,
        'emergencyContactAccess': existing.emergencyContactAccess,
        'pickupAuthorized': existing.pickupAuthorized,
        'communicationPermission': existing.communicationPermission,
        'status': RelationshipStatus.active.name,
        'createdBy': reallocatedBy,
        'createdAt': Timestamp.now(),
        'previousRelationshipId': relationshipId,
      };
      return Right(await remoteDataSource.createRelationship(newData));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, PeoplePolicy>> getPeoplePolicy(String schoolId) async {
    try {
      return Right(await remoteDataSource.getPeoplePolicy(schoolId));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePeoplePolicy(PeoplePolicy policy) async {
    try {
      final model = PeoplePolicyModel(
        schoolId: policy.schoolId,
        maxStandardGuardians: policy.maxStandardGuardians,
        allowAdditionalEmergencyContacts:
            policy.allowAdditionalEmergencyContacts,
        sponsorsGetFinanceAccess: policy.sponsorsGetFinanceAccess,
        updatedBy: policy.updatedBy,
      );
      await remoteDataSource.updatePeoplePolicy(policy.schoolId, model.toMap());
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> recordEnrolmentChange({
    required String schoolId,
    required String studentId,
    required String classId,
    String? streamId,
    required String academicYearId,
    required String recordedBy,
    String? reason,
  }) async {
    try {
      // Close out whatever placement was previously active before opening
      // the new one, so exactly one enrolment record is ever "active" for
      // a student at a time.
      await remoteDataSource.endActiveEnrolment(schoolId, studentId);
      await remoteDataSource.createEnrolment({
        'schoolId': schoolId,
        'studentId': studentId,
        'classId': classId,
        'streamId': streamId,
        'academicYearId': academicYearId,
        'status': EnrolmentStatus.active.name,
        'startDate': Timestamp.now(),
        'reason': reason,
        'recordedBy': recordedBy,
        'createdAt': Timestamp.now(),
      });
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<StudentEnrolment>>> getEnrolmentHistory(
    String schoolId,
    String studentId,
  ) async {
    try {
      return Right(
        await remoteDataSource.getEnrolmentHistory(schoolId, studentId),
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

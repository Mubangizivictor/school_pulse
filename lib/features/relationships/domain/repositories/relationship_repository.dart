import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import '../entities/parent_student_relationship.dart';
import '../entities/people_policy.dart';
import '../entities/student_enrolment.dart';
import '../entities/relationship_enums.dart';

abstract class RelationshipRepository {
  Future<Either<Failure, List<ParentStudentRelationship>>>
  getRelationshipsForStudent(String schoolId, String studentId);

  Future<Either<Failure, List<ParentStudentRelationship>>>
  getRelationshipsForParent(String schoolId, String userId);

  Future<Either<Failure, ParentStudentRelationship>> createRelationship({
    required String schoolId,
    required String studentId,
    String? userId,
    String? parentCode,
    required RelationshipType type,
    bool isLegalGuardian,
    bool isPrimaryGuardian,
    required String createdBy,
  });

  /// Supersedes [relationshipId] (sets status: superseded, requires
  /// [reason]) and creates a new active relationship in its place, linked
  /// via previousRelationshipId. Admin-only at the rules layer.
  Future<Either<Failure, ParentStudentRelationship>> reallocateRelationship({
    required String schoolId,
    required String relationshipId,
    required String reason,
    required String reallocatedBy,
    String? newUserId,
    RelationshipType? newType,
  });

  Future<Either<Failure, PeoplePolicy>> getPeoplePolicy(String schoolId);

  Future<Either<Failure, void>> updatePeoplePolicy(PeoplePolicy policy);

  Future<Either<Failure, void>> recordEnrolmentChange({
    required String schoolId,
    required String studentId,
    required String classId,
    String? streamId,
    required String academicYearId,
    required String recordedBy,
    String? reason,
  });

  Future<Either<Failure, List<StudentEnrolment>>> getEnrolmentHistory(
    String schoolId,
    String studentId,
  );
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../entities/parent_student_relationship.dart';
import '../entities/relationship_enums.dart';
import '../repositories/relationship_repository.dart';

/// Admin-only reallocation - the rules layer is the real backstop
/// (ordinary parents/staff never get write access to this collection at
/// all), this usecase just requires a non-empty reason client-side too so
/// the UI fails fast instead of round-tripping to a denied write.
class ReallocateRelationship
    implements
        UseCase<ParentStudentRelationship, ReallocateRelationshipParams> {
  final RelationshipRepository repository;

  ReallocateRelationship(this.repository);

  @override
  Future<Either<Failure, ParentStudentRelationship>> call(
    ReallocateRelationshipParams params,
  ) {
    if (params.reason.trim().isEmpty) {
      return Future.value(
        const Left(
          ServerFailure('A reason is required to reallocate a relationship.'),
        ),
      );
    }
    return repository.reallocateRelationship(
      schoolId: params.schoolId,
      relationshipId: params.relationshipId,
      reason: params.reason.trim(),
      reallocatedBy: params.reallocatedBy,
      newUserId: params.newUserId,
      newType: params.newType,
    );
  }
}

class ReallocateRelationshipParams extends Equatable {
  final String schoolId;
  final String relationshipId;
  final String reason;
  final String reallocatedBy;
  final String? newUserId;
  final RelationshipType? newType;

  const ReallocateRelationshipParams({
    required this.schoolId,
    required this.relationshipId,
    required this.reason,
    required this.reallocatedBy,
    this.newUserId,
    this.newType,
  });

  @override
  List<Object?> get props => [
    schoolId,
    relationshipId,
    reason,
    reallocatedBy,
    newUserId,
    newType,
  ];
}

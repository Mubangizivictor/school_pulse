import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../entities/parent_student_relationship.dart';
import '../repositories/relationship_repository.dart';

class GetRelationshipsForParent
    implements
        UseCase<
          List<ParentStudentRelationship>,
          GetRelationshipsForParentParams
        > {
  final RelationshipRepository repository;

  GetRelationshipsForParent(this.repository);

  @override
  Future<Either<Failure, List<ParentStudentRelationship>>> call(
    GetRelationshipsForParentParams params,
  ) {
    return repository.getRelationshipsForParent(params.schoolId, params.userId);
  }
}

class GetRelationshipsForParentParams extends Equatable {
  final String schoolId;
  final String userId;

  const GetRelationshipsForParentParams({
    required this.schoolId,
    required this.userId,
  });

  @override
  List<Object?> get props => [schoolId, userId];
}

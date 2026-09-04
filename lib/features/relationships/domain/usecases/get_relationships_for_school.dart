import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../entities/parent_student_relationship.dart';
import '../repositories/relationship_repository.dart';

class GetRelationshipsForSchool
    implements
        UseCase<
          List<ParentStudentRelationship>,
          GetRelationshipsForSchoolParams
        > {
  final RelationshipRepository repository;

  GetRelationshipsForSchool(this.repository);

  @override
  Future<Either<Failure, List<ParentStudentRelationship>>> call(
    GetRelationshipsForSchoolParams params,
  ) {
    return repository.getRelationshipsForSchool(params.schoolId);
  }
}

class GetRelationshipsForSchoolParams extends Equatable {
  final String schoolId;

  const GetRelationshipsForSchoolParams({required this.schoolId});

  @override
  List<Object?> get props => [schoolId];
}

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../entities/parent_student_relationship.dart';
import '../repositories/relationship_repository.dart';

class GetRelationshipsForStudent
    implements
        UseCase<
          List<ParentStudentRelationship>,
          GetRelationshipsForStudentParams
        > {
  final RelationshipRepository repository;

  GetRelationshipsForStudent(this.repository);

  @override
  Future<Either<Failure, List<ParentStudentRelationship>>> call(
    GetRelationshipsForStudentParams params,
  ) {
    return repository.getRelationshipsForStudent(
      params.schoolId,
      params.studentId,
    );
  }
}

class GetRelationshipsForStudentParams extends Equatable {
  final String schoolId;
  final String studentId;

  const GetRelationshipsForStudentParams({
    required this.schoolId,
    required this.studentId,
  });

  @override
  List<Object?> get props => [schoolId, studentId];
}

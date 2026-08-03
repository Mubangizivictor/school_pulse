import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../entities/people_policy.dart';
import '../repositories/relationship_repository.dart';

class GetPeoplePolicy implements UseCase<PeoplePolicy, String> {
  final RelationshipRepository repository;

  GetPeoplePolicy(this.repository);

  @override
  Future<Either<Failure, PeoplePolicy>> call(String schoolId) {
    return repository.getPeoplePolicy(schoolId);
  }
}

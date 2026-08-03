import 'package:dartz/dartz.dart';
import 'package:school_pulse/core/error/failures.dart';
import 'package:school_pulse/core/usecases/usecase.dart';
import '../entities/people_policy.dart';
import '../repositories/relationship_repository.dart';

class UpdatePeoplePolicy implements UseCase<void, PeoplePolicy> {
  final RelationshipRepository repository;

  UpdatePeoplePolicy(this.repository);

  @override
  Future<Either<Failure, void>> call(PeoplePolicy params) {
    return repository.updatePeoplePolicy(params);
  }
}
